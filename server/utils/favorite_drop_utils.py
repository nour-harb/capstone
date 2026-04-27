from sqlalchemy.orm import Session
from models.user_favorite import UserFavorite
from models.products.product import Product


def refresh_favorite_drop_flags(db: Session) -> int:
    favorites = db.query(UserFavorite).all()
    updated_count = 0

    for fav in favorites:
        product = db.query(Product).filter(Product.id == fav.product_id).first()
        
        if not product or not product.is_active or product.price is None:
            continue

        new_price = float(product.price)
        price_at_add = float(fav.price_at_add)
        
        last_p = float(fav.current_price) if fav.current_price is not None else price_at_add

        if new_price != last_p:
            
            if new_price < price_at_add:
                # if it dropped even lower than the last time we scraped, 
                # we set notified to False so the app can show a new alert
                if new_price < last_p:
                    fav.notified = False
            
            else:
                fav.notified = True

            # update the 'current_price' column for next time
            fav.current_price = new_price
            updated_count += 1

    if updated_count > 0:
        db.commit()
        
    return updated_count
