from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from auth import get_current_user
from database import get_db
from models import User
from schemas import UserResponse
from services import users_service


router = APIRouter(
    prefix="/users",
    tags=["Users"]
)


@router.get("/search", response_model=list[UserResponse])
def search_users_endpoint(
    username: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return users_service.search_users_by_username(
        username=username,
        db=db,
        current_user=current_user
    )