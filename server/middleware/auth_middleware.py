from fastapi import HTTPException, Header
import jwt
from dotenv import load_dotenv
import os

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")

def auth_middleware(x_auth_token = Header()):
    try:
        if not x_auth_token:
            raise HTTPException(status_code=401, detail="No auth token. Access denied.")

        verified_token = jwt.decode(x_auth_token, SECRET_KEY, algorithms=["HS256"])

        if not verified_token:
            raise HTTPException(status_code=401, detail="Token verification failed. Authorization denied.")
    
        uid = verified_token.get('id')
        return {'uid': uid, 'token': x_auth_token}
    
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Token is not valid. Authorization denied.")
    