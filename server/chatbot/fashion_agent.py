import json
import os
import time
from typing import Any, List, Optional, Tuple
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.tools import StructuredTool
from langchain_classic.agents import AgentExecutor, create_tool_calling_agent
from sqlalchemy.orm import Session
from chatbot.util import (
    check_if_timeout,
    get_clean_text,
    get_predefined_options_cached)
from chatbot.turn_context import TurnContext
from utils.hugging_face_utils import get_embedding_from_hf
from chatbot.structured_search_utils import (
    GetStoreOptionsInput,
    StructuredSearchInput,
    resolve_color_filter_id_by_name,
    structured_search_logic,
)
from chatbot.semantic_search_utils import SemanticSearchInput, rank_products_by_query_vector, semantic_search_logic
from chatbot.classify_image_agent import classify_fashion_image, load_chat_uploaded_image
from chatbot.chat_history import load_conversation_for_agent, save_chat_turn


# calls the agent and returns (reply_text, product_ids, selected_color_filter_ids, assistant_message_id)
async def run_fashion_assistant(
    db: Session,
    user_input: str,
    user_id: str = "",
    image_attachment_id: Optional[str] = None,
) -> Tuple[str, List[int], List[int], int]:

    ctx = TurnContext(user_id=user_id)
    agent_input = user_input
    
    reply_text = ""
    product_ids = []
    color_ids = []

    # call second agent 
    if image_attachment_id:
        loaded = load_chat_uploaded_image(db, user_id, image_attachment_id)
        if loaded:
            image_bytes, image_mime = loaded
            vision = await classify_fashion_image(image_bytes, image_mime)
            
            if vision.get("is_overloaded"):
                reply_text = ("The image service is busy right now. Please try again in a moment, "
                              "or describe what you're looking for in text instead.")
            elif not vision.get("is_apparel"):
                reply_text = "I'm sorry, I couldn't find a clothing item in that image. Try a clearer photo."
            else:
                ctx.set_uploaded_image((image_bytes, image_mime))
                desc = vision.get("description")
                agent_input = (
                    f"[Photo analysis: shoppable apparel — {desc}]\n"
                    f"[User attached image attachment_id={image_attachment_id}]\n"
                    f"{user_input}"
                )

    # if no error from image classification
    if not reply_text:
        prior_messages = load_conversation_for_agent(db, user_id)
        executor = await create_fashion_agent(db, ctx)
        t0 = time.perf_counter()
        try:
            response = await executor.ainvoke(
                {"input": agent_input, "chat_history": prior_messages}
            )
        except Exception as e:
             if "503" in str(e):
                 reply_text = (
                     "The server is under pressure right now. "
                     "Please try again in a moment."
                 )
             else:
                 raise
        if not reply_text:
            output = response.get("output", response)
            raw_text = get_clean_text(output)
            product_ids = [p["id"] for p in ctx.get_products_per_turn()]
            color_ids = list(ctx.selected_color_filter_ids)

            if check_if_timeout(raw_text):
                reply_text = "That took a bit longer than usual on my side. Please try once more."
            else:
                reply_text = raw_text or "I couldn't generate a reply right now. Please try again."

    # save chat turn
    assistant_id = save_chat_turn(
        db, user_id, user_input, image_attachment_id,
        reply_text, product_ids, color_ids
    )

    return reply_text, product_ids, color_ids, assistant_id

# agent prompt and tools
async def create_fashion_agent(db: Session, ctx: TurnContext):

    instructions = f"""You are a warm, natural Fashion Assistant for a Lebanese clothing store — like a stylist in chat, not a search box.
    FIRST: TALK LIKE A HUMAN
    CRITICAL: If the user message is a greeting (like 'hi' or 'hello'),simply say hello back as a friendly stylist. In that cae\se, DO NOT call any tools. DO NOT use the shopping flow.
- Most turns are normal conversation: advice, reassurance, short opinions, clarifying questions.
- You do **not** need to call tools on every message. Many messages need **zero** tools (greetings, thanks, corrections, "that wasn't what I meant", general fashion tips, follow-ups that don't ask for new items).
- Never repeat the same canned script twice in a row. If the user corrects you, apologize briefly and respond to **their actual point** — do not ignore what they said.
- If you're ever unsure of what to respond, ask claryfying questions.

VALID GENDERS (use judgment)
- Valid catalog **`gender`** strings for **GetStoreOptions** and **StructuredSearch** (must match the database exactly): **"man", "woman"**
- You must infer gender from the user's message (e.g. men's / guys → man; women's / ladies → woman). If unclear, default to **woman** and proceed unless they object.

WHEN TO USE TOOLS (GetStoreOptions / StructuredSearch / SemanticSearch)
- Use tools only when the user is clearly **shopping** or wants to **see products**: e.g. "I'm looking for…", "show me…", "find…", "what do you have in…", "under $X", "more options like that".
- If they only say hi, vent, ask a generic style question without wanting inventory, or push back on your last answer — **reply in text only**, no tools.
- If you already showed products and they comment or complain (e.g. "I didn't ask for shoes"), **do not run another product search** unless they explicitly ask for a new search. Address their message in words.
- **New product type or different gender in the same chat**: run **GetStoreOptions** again for the correct **`gender`**, then **StructuredSearch** with matching filters.

SHOPPING FLOW (strict order)
1. Infer **`gender`** (see above).
2. Call **GetStoreOptions** with that **`gender`**. Read the JSON result: **categories**, **categories_map** (category → list of valid subcategories), **colors**, **brands**.
3. Call **StructuredSearch** with the **same** **`gender`**. Choose **category** from **GetStoreOptions**. Set **`subcategory`** and **`color`** only when the user specified or clearly implied them — otherwise omit those fields for a **broader** browse. When you **do** set **`subcategory`**, it must be from the subcategory list on the same row as the chosen **`category`** — never mix rows.
4. Optionally **SemanticSearch** after StructuredSearch as before.

HOW TO WRITE YOUR REPLY
- About 1–4 short sentences. Sound like a friend who knows fashion, not a catalog.
- Do **not** list individual products (no names, brands, prices, or "first item / second item"). The app shows product cards; your message adds context or a follow-up question only.
- Follow-up questions should match what they asked about (dress → length, formality, sleeves; budget → range; shoes → heel vs flat).

COLOR MAPPING (use judgment)
- When the user **did** mention a color (or clearly implied one), map their words to the **closest** name in **GetStoreOptions**'s **colors** list and pass **`color` on StructuredSearch**. Use common fashion/color sense: dusty or muted purples → the purple/violet/lilac-like option that exists; burgundy/wine → closest red or burgundy if present; navy → blue; cream/ivory → off-white or beige as available; sage/mint → green, etc.
- **Never** skip **`color`** when they asked for a specific shade but the list differs — e.g. "mauve" vs "purple" → **map and search**. You may briefly acknowledge the mapping in one clause ("searching our purple tones for a mauve feel").
- When they **did not** specify or imply a color, **omit `color`** on StructuredSearch (stay broad); do not invent a color filter.

SIZE MAPPING (use judgment)
- When the user **did** ask for a size (or implied one, e.g. "in medium", "42 EU"), map their words to the **closest** `code` in **GetStoreOptions**'s **`sizes`** list and pass **`size`** on **StructuredSearch**. Never invent a size code that is not in the list.
- When they **did not** mention size, **omit `size`** on StructuredSearch; do not filter by size.

OUTFIT & PAIRING QUESTIONS ("what goes with…", "something for this dress", "shoes for that look")
- **Infer intent from context** (recent messages): e.g. they browsed a **blue dress** and now ask what goes with it → they often want **shoes, bag, or accessories** suggestions, not another dress search.
- **Advice-only / vague**: first reply can be text + clarifying questions without tools.
- **If they ask to browse inventory** ("do you have shoes for that", "show me something that goes with") while you already named a type (e.g. flat sandals for the beach), 
**StructuredSearch must use that subcategory** (Sandals / Slides / Flats as applicable) — not a broad shoe search.
- **Pairing colors are your judgment:** For "what goes with this dress/outfit", **you** decide which entries from **colors** in the latest **GetStoreOptions** fit the look, occasion, and conversation — there is no fixed rule (e.g. no mandated "X always with Y").
Map your choice to the list and use **`color` on StructuredSearch**; you may run **up to 2–3** narrow searches when several color directions make sense.
- When they **confirm** a specific buy ("white heels", "that black bag"), use StructuredSearch with matching category/subcategory and **mapped color** as above.

WHEN YOU DO SEARCH (StructuredSearch)
- **SemanticSearch** re-ranks what StructuredSearch already returned (text vibe and/or the user's photo embedding) — it cannot fix wrong categories. Get **GetStoreOptions** + category/subcategory right first.
- CRITICAL (**`text_query` only**): If a user uses multiple descriptive keywords (e.g. 'ripped distressed'), do **not** put both in one `text_query`. Call **StructuredSearch** again with **one** keyword per call **for `text_query` only** — this does **not** mean looping every subcategory in **categories_map**.
- **Up to 3 StructuredSearch calls per message**: use that budget for different **`text_query`** keywords and/or **meaningfully different** category or subcategory angles the user implied — **not** for exhaustively trying every subcategory in the map.

**Basics**
- Prefer **filters** (category, subcategory, color, size, price, brands) that match the **product type** the user asked for; keep the search **broad** by omitting **`subcategory`**, **`color`**, and **`size`** unless the user narrowed those.
- `text_query` = **one** short keyword per call that might appear in a product **name** (e.g. "denim", "zip", "midi") — never full sentences or occasion phrases.
- Occasion/vibe words ("wedding", "party", "elegant") go to **SemanticSearch** re-ranking after you have candidates — not as one giant SQL phrase.
- **If a `text_query` search returns no products**: try at most **two** more **StructuredSearch** calls with the **same** other filters but a **different** single-word **`text_query`** you think likelier in titles (synonyms / catalog wording). If still empty, run **one** broader **StructuredSearch** **without** `text_query`, then **SemanticSearch** with a short phrase for the user's attribute or vibe so results rank toward their words **without** claiming the name filter matched them.
- **SemanticSearch**: for text-only re-ranking use a short vibe `text_query`.
On **photo shopping** turns, after StructuredSearch you **should** call SemanticSearch with `use_uploaded_image_embedding=true` (and optional `text_query` for vibe on top of the image).
It re-ranks whatever StructuredSearch returned **in this turn**. Do not paste product lists into tools.
- If StructuredSearch results are already very specific (e.g. < 5 items), you **should** skip SemanticSearch and provide your final response.

Clarifying questions: ask 1–2 when the shopping request is too vague to search well; keep examples relevant to their category (not random defaults).

USER-ATTACHED IMAGES (photo shopping)
- If the message includes **`[Photo analysis: shoppable apparel — ...]`**, the image was checked and shows **wearable fashion**.
For any shopping intent ("something like this", "similar", "show me options", etc.) you **must** run **GetStoreOptions** then **StructuredSearch**: choose **gender** and **category** from the **GetStoreOptions** JSON; set **subcategory**, **color**, and **size** (mapped from the analysis line + user words) when they clearly narrow the item — otherwise omit for a broader first pass — never invent labels.
- Then call **SemanticSearch** with **`use_uploaded_image_embedding=true`** so results match the **photo** visually (you may add a short **`text_query`** for extra vibe).
Do **not** skip GetStoreOptions or StructuredSearch on these turns.
- **Never** tell them to attach a photo when the attachment line is present.

HOW TO WRITE YOUR REPLY
- About 1–4 short sentences. Sound like a friend who knows fashion, not a catalog.
- Do **not** list individual products (no names, brands, prices, or "first item / second item"). The app shows product cards; your message adds context or a follow-up question only.
- Follow-up questions should match what they asked about (dress → length, formality, sleeves; budget → range; shoes → heel vs flat).

RULES
- NEVER invent categories, subcategories, colors, or sizes; use only the latest **GetStoreOptions** payload for the **`gender`** you pass into **StructuredSearch**.
- No product-by-product narration in your message.

Summary: Chat naturally; for shopping use GetStoreOptions then StructuredSearch (then SemanticSearch when useful); stylist tone, not a catalog."""

    prompt = ChatPromptTemplate.from_messages([
        ("system", instructions),
        MessagesPlaceholder(variable_name="chat_history"),
        ("human", "{input}"),
        MessagesPlaceholder(variable_name="agent_scratchpad"),
    ])

    llm = ChatGoogleGenerativeAI(
        # model="gemini-3.1-flash-lite-preview",
        model="gemini-3.1-pro-preview",
        temperature=0.45,
        google_api_key=os.getenv("GOOGLE_API_KEY"),
        max_output_tokens=280,
    )

    async def get_store_options_wrapper(gender: str) -> str:
        opts = await get_predefined_options_cached(db, gender)
        sizes = opts.get("sizes", [])
        payload = {
            "gender": gender,
            "categories": opts.get("categories", []),
            "categories_map": opts.get("categories_map", {}),
            "colors": opts.get("colors", []),
            "sizes": sizes,
            "brands": opts.get("brands", []),
        }
        out = json.dumps(payload)
        return out

    async def structured_search_wrapper(**kwargs):
        try:
            products = await structured_search_logic(db=db, **{**kwargs})
            color_raw = kwargs.get("color")
            if color_raw is not None and str(color_raw).strip():
                cf_id = resolve_color_filter_id_by_name(db, str(color_raw).strip())
                if cf_id is not None:
                    ctx.add_color_filter_id(cf_id)
            ctx.accumulate_unique_products(products)
            return products
        except Exception as e:
            raise

    async def semantic_search_wrapper(
        text_query: Optional[str] = None,
        use_uploaded_image_embedding: bool = False,
    ):
        try:
            tq0 = (text_query or "").strip()
            results = ctx.get_products_per_turn()
            if not results:
                return []

            ranked_results = results
            query_vec = None
            tq = tq0

            if use_uploaded_image_embedding:
                payload = ctx.get_uploaded_image()
                if payload:
                    img_bytes, img_mime = payload
                    query_vec = await get_embedding_from_hf(
                        image_bytes=img_bytes,
                        text_query=tq[:800],
                        image_mime=img_mime,
                    )

            if query_vec:
                ranked_results = await rank_products_by_query_vector(db, results, query_vec)
            elif tq:
                ranked_results = await semantic_search_logic(db, results, tq)
            
            final_output = ranked_results[:60]
            
            ctx.set_products_per_turn(final_output) 
            return final_output

        except Exception as e:
            raise

    tools = [
        StructuredTool.from_function(
            name="GetStoreOptions",
            coroutine=get_store_options_wrapper,
            description=(
                "Load allowed categories, category→subcategory map, colors, sizes (variant codes in stock for this gender), and brands. "
                "Call this first on shopping turns before StructuredSearch. "
                "Pass the same gender string you will use on StructuredSearch."
            ),
            args_schema=GetStoreOptionsInput,
        ),
        StructuredTool.from_function(
            name="StructuredSearch",
            coroutine=structured_search_wrapper,
            description=(
                "Browse inventory with category/subcategory/color/size/price/brands + optional text_query. "
                "Subcategory must be one of the subcategories listed for that category in the latest "
                "GetStoreOptions JSON for the same gender. Omit subcategory, color, and size unless the user narrowed them. "
                "When the user asked for a size, pass `size` as one `code` from the latest `sizes` list. "
                "Use when the user wants to shop. Up to 3 calls per turn: for different text_query keywords or "
                "meaningful category/subcategory angles — not to loop every subcategory in the map. "
                "Subcategory must match what you tell the user (sandals vs boots, zip-up vs plain crew)."
            ),
            args_schema=StructuredSearchInput
        ),
        StructuredTool.from_function(
            name="SemanticSearch",
            coroutine=semantic_search_wrapper,
            description=(
                "Re-rank the current turn's StructuredSearch results using embeddings. "
                "Call only after StructuredSearch in the same reply. "
                "Use text_query for vibe/occasion (including ranking toward a phrase after a broad StructuredSearch "
                "without text_query), or set use_uploaded_image_embedding=true on photo turns "
                "(optional text_query combines with the photo embedding). Does not use earlier messages' product lists."
            ),
            args_schema=SemanticSearchInput
        ),
    ]

    agent = create_tool_calling_agent(llm, tools, prompt)
    executor = AgentExecutor(
        agent=agent,
        tools=tools,
        verbose=False,
        handle_parsing_errors=True,
        max_iterations=10,
        max_execution_time=120,
        return_intermediate_steps=True,
    )
    return executor




