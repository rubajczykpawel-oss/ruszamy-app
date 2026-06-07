from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from models import ActivityGroup, GroupMember, User
from schemas import GroupCreate
from services.friends_service import are_users_friends


def create_group(
    group_data: GroupCreate,
    db: Session,
    current_user: User
) -> ActivityGroup:
    new_group = ActivityGroup(
        name=group_data.name,
        description=group_data.description,
        city=group_data.city,
        activity_type=group_data.activity_type,
        owner_id=current_user.id
    )

    db.add(new_group)
    db.commit()
    db.refresh(new_group)

    owner_membership = GroupMember(
        group_id=new_group.id,
        user_id=current_user.id,
        role="owner"
    )

    db.add(owner_membership)
    db.commit()

    return new_group


def get_my_groups(
    db: Session,
    current_user: User
) -> list[ActivityGroup]:
    memberships = (
        db.query(GroupMember)
        .filter(GroupMember.user_id == current_user.id)
        .all()
    )

    groups = [membership.group for membership in memberships]

    return groups


def get_group_details(
    group_id: int,
    db: Session,
    current_user: User
) -> ActivityGroup:
    group = db.query(ActivityGroup).filter(ActivityGroup.id == group_id).first()

    if group is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono grupy"
        )

    membership = (
        db.query(GroupMember)
        .filter(GroupMember.group_id == group_id)
        .filter(GroupMember.user_id == current_user.id)
        .first()
    )

    if membership is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nie jesteś członkiem tej grupy"
        )

    return group


def add_member_to_group(
    group_id: int,
    user_id: int,
    db: Session,
    current_user: User
) -> GroupMember:
    group = db.query(ActivityGroup).filter(ActivityGroup.id == group_id).first()

    if group is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono grupy"
        )

    if group.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tylko właściciel grupy może dodawać członków"
        )

    user_to_add = db.query(User).filter(User.id == user_id).first()

    if user_to_add is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono użytkownika"
        )

    if not are_users_friends(db, current_user.id, user_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Możesz dodać do grupy tylko zaakceptowanego znajomego"
        )

    existing_membership = (
        db.query(GroupMember)
        .filter(GroupMember.group_id == group_id)
        .filter(GroupMember.user_id == user_id)
        .first()
    )

    if existing_membership:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ten użytkownik już jest w grupie"
        )

    new_membership = GroupMember(
        group_id=group_id,
        user_id=user_id,
        role="member"
    )

    db.add(new_membership)
    db.commit()
    db.refresh(new_membership)

    return new_membership


def leave_group(
    group_id: int,
    db: Session,
    current_user: User
) -> dict:
    group = db.query(ActivityGroup).filter(ActivityGroup.id == group_id).first()

    if group is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono grupy"
        )

    if group.owner_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Właściciel grupy nie może opuścić grupy"
        )

    membership = (
        db.query(GroupMember)
        .filter(GroupMember.group_id == group_id)
        .filter(GroupMember.user_id == current_user.id)
        .first()
    )

    if membership is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie jesteś członkiem grupy"
        )

    db.delete(membership)
    db.commit()

    return {
        "message": "Opuszczono grupę"
    }


def remove_member_from_group(
    group_id: int,
    user_id: int,
    db: Session,
    current_user: User
) -> dict:
    group = db.query(ActivityGroup).filter(ActivityGroup.id == group_id).first()

    if group is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono grupy"
        )

    if group.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tylko właściciel grupy może usuwać członków"
        )

    if user_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Nie możesz usunąć samego siebie jako właściciela"
        )

    membership = (
        db.query(GroupMember)
        .filter(GroupMember.group_id == group_id)
        .filter(GroupMember.user_id == user_id)
        .first()
    )

    if membership is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ten użytkownik nie jest członkiem grupy"
        )

    db.delete(membership)
    db.commit()

    return {
        "message": "Usunięto użytkownika z grupy"
    }

def get_group_members(
    group_id: int,
    db: Session,
    current_user: User    
) -> list[GroupMember]:
    group = db.query(ActivityGroup).filter(ActivityGroup.id == group_id).first()

    if group is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono grupy"
        )
    
    current_user_membership = (
        db.query(GroupMember)
        .filter(GroupMember.id == group_id)
        .filter(GroupMember.user_id == current_user.id).first()   
    )

    if current_user_membership is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Nie jesteś członkiem grupy"
        )
    
    members = (
        db.query(GroupMember)
        .filter(GroupMember.group_id == group_id).all()
    )

    return members

    