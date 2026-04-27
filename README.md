# AI Shopper

Full-stack shopping assistant: a **Flutter** app talks to a **FastAPI** backend that stores fashion products, 
supports search and favorites, and powers an **AI fashion chat** (Google Gemini + LangChain) with 
**Hugging Face** embeddings for semantic / image-related search. 
Products are **scraped and synced** from multiple configured brands into **PostgreSQL** (with **pgvector** for vector search).

## Key Features
- **Multimodal AI Chat:** Natural language fashion advice powered by Gemini & LangChain.
- **Visual Search:** Upload images to find similar clothing using SigLIP embeddings.
- **Smart Validation:** Automatic filtering of non-fashion images using Gemini Vision.
- **Cross-Brand Aggregation:** Integrated product data from multiple Lebanese retailers.
- **Price Tracking:** Save favorites and get notified when price drops.

## Repository layout
- `server/` — FastAPI API, database models, chatbot, scraper  
- `flutter_shopper/` — Flutter (Dart) mobile app  
- `hugging_face_app/` — companion service for image/text embeddings (to set up a Hugging Face Space; see below)

## Prerequisites
- **Python 3.11+** (recommended) with `pip`  
- **PostgreSQL** with the **pgvector** extension available for the database you use  
- **Flutter** (SDK matches `pubspec.yaml`, e.g. Dart ^3.9)  
- **Google API key** for **Gemini**, used by the fashion agent and image classification  
- **Hugging Face Space URL** ( expected by the server for embedding calls)   

## Backend (`server/`)

### 1. Create a virtual environment and install dependencies

```bash
cd server
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Environment variables
Create a .env file inside server/. The app uses at least:
- **DATABASE_URL**: SQLAlchemy connection string, e.g. postgresql://user:password@localhost:5432/ai_shopper
- **SECRET_KEY**: Same secret for signing JWTs on login and verifying x-auth-token on every request. 
- **GOOGLE_API_KEY**: Gemini API key for the fashion agent and image classification agent.
- **HF_SPACE_URL**: Base URL of the Hugging Face Space that serves the embedding API the backend calls.

### 3. Database
Create an empty PostgreSQL database.
Enable the pgvector extension in that database (e.g. CREATE EXTENSION IF NOT EXISTS vector; — exact steps depend on your Postgres/pgvector install).

### 4. Run the API
```bash
cd server
.venv/scripts/activate
fastapi dev main.py
```
- API root: http://127.0.0.1:8000
- Interactive docs: http://127.0.0.1:8000/docs
  
A manual product sync is available at POST /sync (all brands), useful after the DB is ready so the app has data to show.
Scheduled sync in main.py is present but commented out; you can enable periodic sync by uncommenting the background task in the lifespan block if you want automatic refreshes.

## Flutter app (flutter_shopper/)

### 1. Install dependencies
```bash
cd flutter_shopper
flutter pub get
```
### 2. Point the app at your backend
The app uses a hardcoded base URL in lib/core/constants/server_constant.dart (ServerConstant.serverURL).
- Android emulator (default in repo is often http://10.0.2.2:8000) — maps to the host machine’s localhost:8000.
(Change that constant to match your setup, then rebuild/run.)

### 3. Run the app
```bash
cd flutter_shopper
flutter run
```
Choose a device or emulator when prompted.

## Hugging Face Space
- Create a new FastAPI Space on Hugging Face.
- Upload the contents of the folder `hugging_face_app/`.
- Once the Space is "Running", copy the App URL and paste it into the `HF_SPACE_URL` in the server's `.env`.
