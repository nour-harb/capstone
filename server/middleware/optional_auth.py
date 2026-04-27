import jwt
from fastapi import Header

from middleware.auth_middleware import SECRET_KEY


def try_get_user_id_from_token(
    x_auth_token: str | None = Header(default=None, convert_underscores=True),
) -> str | None:
    if not x_auth_token or not x_auth_token.strip():
        return None
    try:
        payload = jwt.decode(
            x_auth_token.strip(), SECRET_KEY, algorithms=["HS256"]
        )
    except jwt.PyJWTError:
        return None
    uid = payload.get("id")
    if uid is None:
        return None
    return str(uid)
