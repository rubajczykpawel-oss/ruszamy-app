from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from auth import create_access_token, hash_password, verify_password
from models import User
from schemas import LoginRequest, UserCreate


def register_user(user_data: UserCreate, db: Session) -> User:
    existing_email = db.query(User).filter(User.email == user_data.email).first()
    
    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Użytkownik z takim emailem juz istnieje"
        )
    
    existing_username = (
        db.query(User)
        .filter(User.username == user_data.username)
        .first()
    )
    if existing_username:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Użytkownik z taką nazwą już istnieje"
        )
    
    new_user = User(
        email=user_data.email,
        username=user_data.username,
        hashed_password=hash_password(user_data.password),
        city=user_data.city,
        age=user_data.age
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user

def login_user(login_data: LoginRequest, db: Session) -> dict:
    user = db.query(User).filter(User.email == login_data.email).first()

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Nieprawidłowy e-mail lub hasło"
        )

    password_is_valid = verify_password(
        login_data.password,
        user.hashed_password
    )

    if not password_is_valid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Nieprawidłowy e-mail lub hasło"
        )
    
    token = create_access_token(
        data={"sub": str(user.id)}
    )

    return{
        "access_token": token,
        "token_type": "bearer"
    }