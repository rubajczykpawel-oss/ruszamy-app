from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from models import User
from schemas import UserUpdate


def search_users_by_username(
    username: str,
    db: Session,
    current_user: User
) -> list[User]:
    users = (
        db.query(User)
        .filter(User.username.ilike(f"%{username}%"))
        .filter(User.id != current_user.id)
        .limit(20)
        .all()
    )

    return users

def update_my_profile(
    user_data: UserUpdate,
    db: Session,
    current_user: User
) -> User:
    if user_data.username is not None:
        existing_username = (
            db.query(User)
            .filter(User.username == user_data.username)
            .filter(User.id != current_user.id).first()
        )
        if existing_username:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Użytkownik z taką nazwą już istnieje"
            )
        
        current_user.username = user_data.username
    
    if user_data.city is not None:
        current_user.city = user_data.city

    if user_data.age is not None:
        current_user.age = user_data.age

    db.commit()
    db.refresh(current_user)

    return current_user