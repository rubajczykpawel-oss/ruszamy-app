from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from auth import get_current_user
from database import get_db
from models import User
from schemas import GroupCreate, GroupMemberResponse, GroupResponse, GroupMemberWithUserResponse
from services import groups_service


router = APIRouter(
    prefix="/groups",
    tags=["Groups"]
)


@router.post("", response_model=GroupResponse)
def create_group_endpoint(
    group_data: GroupCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return groups_service.create_group(
        group_data=group_data,
        db=db,
        current_user=current_user
    )


@router.get("/my", response_model=list[GroupResponse])
def get_my_groups_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return groups_service.get_my_groups(
        db=db,
        current_user=current_user
    )

@router.get("/{group_id}/members", response_model=list[GroupMemberWithUserResponse])
def get_groups_endpoint(
    group_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return groups_service.get_group_members(
        group_id=group_id,
        db=db,
        current_user=current_user
    )

@router.get("/{group_id}", response_model=GroupResponse)
def get_group_details_endpoint(
    group_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return groups_service.get_group_details(
        group_id=group_id,
        db=db,
        current_user=current_user
    )


@router.post("/{group_id}/members/{user_id}", response_model=GroupMemberResponse)
def add_member_to_group_endpoint(
    group_id: int,
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return groups_service.add_member_to_group(
        group_id=group_id,
        user_id=user_id,
        db=db,
        current_user=current_user
    )


@router.delete("/{group_id}/leave")
def leave_group_endpoint(
    group_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return groups_service.leave_group(
        group_id=group_id,
        db=db,
        current_user=current_user
    )


@router.delete("/{group_id}/members/{user_id}")
def remove_member_from_group_endpoint(
    group_id: int,
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return groups_service.remove_member_from_group(
        group_id=group_id,
        user_id=user_id,
        db=db,
        current_user=current_user
    )
@router.delete("/{group_id}")
def delete_group_endpoint(
    group_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return groups_service.delete_group(
        group_id=group_id,
        db=db,
        current_user=current_user
    )