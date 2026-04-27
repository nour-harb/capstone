import asyncio
from contextlib import asynccontextmanager
from fastapi import Depends, FastAPI
from sqlalchemy.orm import Session
from database import Sessionlocal, engine, get_db
from routes import auth, profile, categories, products, chat, favorites
from models.base import Base
from scraper.scraper import sync_all_brands

# background task to scrape and sync product data at set intervals
async def schedule_scrape(interval: int):
    while True:
        print("Starting scheduled product sync")
        
        # sessionlocal is used to ensure the database session is closed
        with Sessionlocal() as db:
            try:
                await sync_all_brands(db)
                print("Scheduled sync completed successfully")
            except Exception as e:
                print(f"Scheduled sync failed: {e}")
        
        await asyncio.sleep(interval)

# "lifespan" handles startup and shutdown events for the server
@asynccontextmanager
async def lifespan(app: FastAPI):
    # startup: executes when the server starts
    print("Server starting up")
    
    # ensure all database tables are created
    Base.metadata.create_all(engine)
        
    # start the initial scrape at server startup, then schedule it periodically
    ## task = asyncio.create_task(schedule_scrape(60 * 60 * 12)) 
        
    yield 
        
    # Shutdown: executes when teh server is stopped
    print("Server shutting down")
    ## task.cancel() 

# link the lifespan logic to the FastAPI instance
app = FastAPI(lifespan=lifespan)

app.include_router(auth.router, prefix="/auth")
app.include_router(profile.router, prefix="/profile")
app.include_router(categories.router, prefix="/categories")
app.include_router(products.router, prefix="/products")
app.include_router(chat.router, prefix="/chat")
app.include_router(favorites.router, prefix="/favorites")

# post endpoint to manually trigger the scrape and sync process
@app.post("/sync")
async def sync(db: Session = Depends(get_db)):
    try:
        await sync_all_brands(db)
        return {"message": "All is synced successfully!"}
    except Exception as e:
        print(f"Manual sync failed: {e}")
        return {"message": f"Sync failed: {str(e)}"}
