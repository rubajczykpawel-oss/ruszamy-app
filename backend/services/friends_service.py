from datetime import datetime

from fastapi import HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from models import Friendship, User


def friendship_exists_between_users(
    db: Session,
    user_id_1: int,
    user_id_2: int
) -> Friendship | None:
    friendship = (
        db.query(Friendship)
        .filter(
            or_(
                (Friendship.requester_id == user_id_1) & (Friendship.receiver_id == user_id_2),
                (Friendship.requester_id == user_id_2) & (Friendship.receiver_id == user_id_1)
            )
        )
        .first()
    )

    return friendship


def are_users_friends(
    db: Session,
    user_id_1: int,
    user_id_2: int
) -> bool:
    friendship = (
        db.query(Friendship)
        .filter(
            or_(
                (Friendship.requester_id == user_id_1) & (Friendship.receiver_id == user_id_2),
                (Friendship.requester_id == user_id_2) & (Friendship.receiver_id == user_id_1)
            )
        )
        .filter(Friendship.status == "accepted")
        .first()
    )

    return friendship is not None


def send_friend_request(
    user_id: int,
    db: Session,
    current_user: User
) -> Friendship:
    if user_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Nie możesz dodać samego siebie do znajomych"
        )

    receiver = db.query(User).filter(User.id == user_id).first()

    if receiver is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono użytkownika"
        )

    existing_friendship = friendship_exists_between_users(
        db=db,
        user_id_1=current_user.id,
        user_id_2=user_id
    )

    if existing_friendship:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Zaproszenie albo znajomość już istnieje"
        )

    friendship = Friendship(
        requester_id=current_user.id,
        receiver_id=user_id,
        status="pending"
    )

    db.add(friendship)
    db.commit()
    db.refresh(friendship)

    return friendship


def get_received_friend_requests(
    db: Session,
    current_user: User
) -> list[Friendship]:
    requests = (
        db.query(Friendship)
        .filter(Friendship.receiver_id == current_user.id)
        .filter(Friendship.status == "pending")
        .all()
    )

    return requests


def get_sent_friend_requests(
    db: Session,
    current_user: User
) -> list[Friendship]:
    requests = (
        db.query(Friendship)
        .filter(Friendship.requester_id == current_user.id)
        .filter(Friendship.status == "pending")
        .all()
    )

    return requests


def accept_friend_request(
    friendship_id: int,
    db: Session,
    current_user: User
) -> Friendship:
    friendship = db.query(Friendship).filter(Friendship.id == friendship_id).first()

    if friendship is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono zaproszenia"
        )

    if friendship.receiver_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nie możesz zaakceptować tego zaproszenia"
        )

    if friendship.status != "pending":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="To zaproszenie nie jest już aktywne"
        )

    friendship.status = "accepted"
    friendship.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(friendship)

    return friendship


def reject_friend_request(
    friendship_id: int,
    db: Session,
    current_user: User
) -> Friendship:
    friendship = db.query(Friendship).filter(Friendship.id == friendship_id).first()

    if friendship is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono zaproszenia"
        )

    if friendship.receiver_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nie możesz odrzucić tego zaproszenia"
        )

    if friendship.status != "pending":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="To zaproszenie nie jest już aktywne"
        )

    friendship.status = "rejected"
    friendship.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(friendship)

    return friendship


def get_my_friends(
    db: Session,
    current_user: User
) -> list[User]:
    friendships = (
        db.query(Friendship)
        .filter(
            or_(
                Friendship.requester_id == current_user.id,
                Friendship.receiver_id == current_user.id
            )
        )
        .filter(Friendship.status == "accepted")
        .all()
    )

    friends = []

    for friendship in friendships:
        if friendship.requester_id == current_user.id:
            friends.append(friendship.receiver)
        else:
            friends.append(friendship.requester)

    return friends

def remove_friend(
    friend_id: int,
    db: Session,
    current_user: User
) -> dict:
    if friend_id is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie możesz usunąć samego siebie"
        )
    
    friend = db.query(User).filter(User.id == friend_id).first()

    if friend is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono użytkownika"
        )
    
    friendship = (
                db.query(Friendship)
                .filter(
                    or_(
                        (Friendship.requester_id == current_user.id) & (Friendship.receiver_id == friend_id),
                        (Friendship.requester_id == friend_id) & (Friendship.receiver_id == current_user.id)
                    )
                )
                .filter(Friendship.status == "accepted").first()
    )

    if friendship is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono zaakceptowanej znajomości"
        )
    
    db.delete(friendship)
    db.commit()

    return {
        "message": "Znajomy został usunięty"
    }