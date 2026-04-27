# helper function to remove last two digits from price
def format_price(price_value):
    if price_value is None:
        return None
    
    try:
        # convert to string to manipulate
        price_str = str(price_value)
        
        # remove last two digits
        if len(price_str) > 2:
            return int(price_str[:-2])
        else:
            # if price is too short, return as is or handle as 0
            return 0
    except (ValueError, TypeError):
        return price_value