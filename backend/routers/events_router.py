from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from auth import get_current_user
from database import get_db
from models import User 
from schemas import EventCreate, EventResponse, EventUpdate, EventParticipantWithUserResponse
from services import events_service

router = APIRouter(
    prefix="/events",
    tags=["Events"]
)

@router.post("", response_model=EventResponse)
def create_event_endpoint(
    event_data: EventCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return events_service.create_event(
        event_data=event_data,
        db=db,
        current_user=current_user
    )

@router.get("", response_model=list[EventResponse])
def get_events_endpoint(
    city: str | None = None,
    activity_type: str | None = None,
    db: Session = Depends(get_db)
):
    return events_service.get_events(
        db=db,
        city=city,
        activity_type=activity_type
    )

@router.get("/my", response_model=list[EventResponse])
def get_my_events_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return events_service.get_my_events(
        db=db,
        current_user=current_user
    )

@router.get("/{event_id}/participants", response_model=list[EventParticipantWithUserResponse])
def get_event_participants_endpoint(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return events_service.get_event_participants(
        event_id=event_id,
        db=db,
        current_user=current_user
    )

@router.get("/{event_id}", response_model=EventResponse)
def get_event_details_endpoint(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return events_service.get_event_details(
        event_id=event_id,
        db=db,
        current_user=current_user
    )

@router.post("/{event_id}/join")
def join_event_endpoint(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user) 
):
    return events_service.join_event(
        event_id=event_id,
        db=db,
        current_user=current_user
    )

@router.delete("/{event_id}/leave")
def leave_event_endpoint(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return events_service.leave_event(
        event_id=event_id,
        db=db,
        current_user=current_user    
    )

@router.put("/{event_id}", response_model=EventResponse)
def update_event_endpoint(
    event_id: int,
    event_data: EventUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return events_service.update_event(
        event_id=event_id,
        event_data=event_data,
        db=db,
        current_user=current_user
    )

@router.delete("/{event_id}")
def delete_event_endpoint(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return events_service.delete_event(
        event_id=event_id,
        db=db,
        current_user=current_user
    )