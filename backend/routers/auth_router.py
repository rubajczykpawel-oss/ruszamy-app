from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from auth import get_current_user
from database import get_db
from models import User
from schemas import LoginRequest, UserCreate, UserResponse, TokenResponse
from services import auth_service

router = APIRouter(
    prefix="/auth",
    tags=["Auth"]
)

@router.post("/register", response_model=UserResponse)
def register_user_endpoint(
        user_data: UserCreate,
        db: Session = Depends(get_db)
):
    return auth_service.register_user(user_data, db)

@router.post("/login", response_model=TokenResponse)
def login_user_endpoint(
        login_data: LoginRequest,
        db: Session = Depends(get_db)
):
    return auth_service.login_user(login_data, db)

@router.get("/me", response_model=UserResponse)
def get_my_profile_endpoint(
        current_user: User = Depends(get_current_user)
):
    return current_user