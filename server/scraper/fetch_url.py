import asyncio
import httpx
import random

MAX_CONCURRENT_REQUESTS = 15
BATCH_LIMITER = asyncio.Semaphore(MAX_CONCURRENT_REQUESTS)

# fetches JSON from a single URL 
async def fetch_json(url, headers=None, retries=3):
    for attempt in range(1, retries + 1):
        try:
            async with BATCH_LIMITER:
                async with httpx.AsyncClient(
                    http2=True, 
                    timeout=30
                ) as client:
                    response = await client.get(url, headers=headers)                
                    response.raise_for_status()
                    return response.json()

        except httpx.HTTPStatusError as e:
            status = e.response.status_code
            if status == 404:
                return None
            if 400 <= status < 500:
                print(f"Permanent HTTP error {status} for {url}. Skipping.")
                return None
            print(f"Server error {status} for {url}, attempt {attempt}/{retries}")

        except (httpx.ConnectError, httpx.TimeoutException, httpx.RequestError) as e:
            print(f"Connection issue for {url}: {e}, attempt {attempt}/{retries}")

        except Exception as e:
            print(f"Critical error fetching {url}: {e}")
            raise Exception(f"Halted due to unexpected error: {e}")

        if attempt < retries:
            jitter = random.uniform(0, 1)
            wait_time = (0.2 * (2 ** (attempt - 1))) + jitter
            wait_time = min(wait_time, 10.0) 
            print(f"Retrying in {wait_time:.2f}s...")
            await asyncio.sleep(wait_time)

    return None

# creates multiple parallel JSON requests 
async def fetch_batch_json(urls, headers=None):

    print(f"Fetching {len(urls)} URLs. (Concurrency: {MAX_CONCURRENT_REQUESTS})...")

    tasks = [fetch_json(url, headers) for url in urls]
    
    results = await asyncio.gather(*tasks)

    num_successful = sum(1 for r in results if r is not None)
    print(f"Batch complete: {num_successful}/{len(urls)} successful responses")
    
    return results