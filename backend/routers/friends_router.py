from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from auth import get_current_user
from database import get_db
from models import User
from schemas import UserResponse, FriendshipResponse
from services import friends_service


router = APIRouter(
    prefix="/friends",
    tags=["Friends"]
)


@router.post("/request/{user_id}", response_model=FriendshipResponse)
def send_friend_request_endpoint(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return friends_service.send_friend_request(
        user_id=user_id,
        db=db,
        current_user=current_user
    )


@router.get("/requests/received", response_model=list[FriendshipResponse])
def get_received_friend_requests_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return friends_service.get_received_friend_requests(
        db=db,
        current_user=current_user
    )


@router.get("/requests/sent", response_model=list[FriendshipResponse])
def get_sent_friend_requests_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return friends_service.get_sent_friend_requests(
        db=db,
        current_user=current_user
    )


@router.post("/accept/{friendship_id}", response_model=FriendshipResponse)
def accept_friend_request_endpoint(
    friendship_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return friends_service.accept_friend_request(
        friendship_id=friendship_id,
        db=db,
        current_user=current_user
    )


@router.post("/reject/{friendship_id}", response_model=FriendshipResponse)
def reject_friend_request_endpoint(
    friendship_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return friends_service.reject_friend_request(
        friendship_id=friendship_id,
        db=db,
        current_user=current_user
    )


@router.get("", response_model=list[UserResponse])
def get_my_friends_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return friends_service.get_my_friends(
        db=db,
        current_user=current_user
    )