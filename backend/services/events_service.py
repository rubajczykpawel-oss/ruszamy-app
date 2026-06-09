from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from models import Event, EventParticipant, GroupMember, User
from schemas import EventCreate

def add_participants_count(
        event: Event,
        db: Session
) -> Event:
    participants_count = (
        db.query(EventParticipant)
        .filter(EventParticipant.event_id == event.id).count()
    )
    
    event.participants_count = participants_count

    return event

def create_event(
    event_data: EventCreate,
    db: Session,
    current_user: User
) -> Event:
    if event_data.max_participants <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Limit uczestników musi być większy od 0"
        )

    if event_data.group_id is not None:
        group_member = (
            db.query(GroupMember)
            .filter(GroupMember.group_id == event_data.group_id)
            .filter(GroupMember.user_id == current_user.id)
            .first()
        )

        if group_member is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Nie jesteś członkiem tej grupy"
            )

    new_event = Event(
        title=event_data.title,
        description=event_data.description,
        activity_type=event_data.activity_type,
        city=event_data.city,
        location_name=event_data.location_name,
        date=event_data.date,
        time=event_data.time,
        max_participants=event_data.max_participants,
        level=event_data.level,
        age_min=event_data.age_min,
        age_max=event_data.age_max,
        is_public=event_data.is_public,
        creator_id=current_user.id,
        group_id=event_data.group_id
    )

    db.add(new_event)
    db.commit()
    db.refresh(new_event)

    creator_participation = EventParticipant(
        user_id=current_user.id,
        event_id=new_event.id
    )

    db.add(creator_participation)
    db.commit()

    return add_participants_count(new_event, db)


def get_events(
    db: Session,
    city: str | None = None,
    activity_type: str | None = None
) -> list[Event]:
    query = db.query(Event).filter(Event.is_public == True)

    if city is not None:
        query = query.filter(Event.city.ilike(f"%{city}%"))

    if activity_type is not None:
        query = query.filter(Event.activity_type == activity_type)

    events = query.order_by(Event.date.asc(), Event.time.asc()).all()

    events_with_count = [
        add_participants_count(event, db)
        for event in events
    ]

    return events_with_count


def get_event_details(
    event_id: int,
    db: Session,
    current_user: User
) -> Event:
    event = db.query(Event).filter(Event.id == event_id).first()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono wydarzenia"
        )

    if event.group_id is not None:
        group_member = (
            db.query(GroupMember)
            .filter(GroupMember.group_id == event.group_id)
            .filter(GroupMember.user_id == current_user.id)
            .first()
        )

        if group_member is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="To wydarzenie jest dostępne tylko dla członków grupy"
            )

    return add_participants_count(event, db)



def join_event(
    event_id: int,
    db: Session,
    current_user: User
) -> dict:
    event = db.query(Event).filter(Event.id == event_id).first()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono wydarzenia"
        )

    if event.group_id is not None:
        group_member = (
            db.query(GroupMember)
            .filter(GroupMember.group_id == event.group_id)
            .filter(GroupMember.user_id == current_user.id)
            .first()
        )

        if group_member is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Nie możesz dołączyć do wydarzenia grupowego, jeśli nie jesteś w grupie"
            )

    existing_participation = (
        db.query(EventParticipant)
        .filter(EventParticipant.event_id == event_id)
        .filter(EventParticipant.user_id == current_user.id)
        .first()
    )

    if existing_participation:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Już jesteś zapisany na to wydarzenie"
        )

    participants_count = (
        db.query(EventParticipant)
        .filter(EventParticipant.event_id == event_id)
        .count()
    )

    if participants_count >= event.max_participants:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Brak wolnych miejsc na wydarzenie"
        )

    new_participation = EventParticipant(
        user_id=current_user.id,
        event_id=event_id
    )

    db.add(new_participation)
    db.commit()

    return {
        "message": "Dołączono do wydarzenia"
    }


def leave_event(
    event_id: int,
    db: Session,
    current_user: User
) -> dict:
    participation = (
        db.query(EventParticipant)
        .filter(EventParticipant.event_id == event_id)
        .filter(EventParticipant.user_id == current_user.id)
        .first()
    )

    if participation is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie jesteś zapisany na to wydarzenie"
        )

    db.delete(participation)
    db.commit()

    return {
        "message": "Opuszczono wydarzenie"
    }


def get_my_events(
    db: Session,
    current_user: User
) -> list[Event]:
    participations = (
        db.query(EventParticipant)
        .filter(EventParticipant.user_id == current_user.id)
        .all()
    )

    events = [participation.event for participation in participations]

    events_with_count = [
        add_participants_count(event, db)
        for event in events
    ]

    return events_with_count

def delete_event(
    event_id: int,
    db: Session,
    current_user: User
) -> dict:
    event = db.query(Event).filter(Event.id == event_id).first()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono wydarzenia"
        )

    if event.creator_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Możesz usunąć tylko wydarzenie, które sam stworzyłeś"
        )

    db.query(EventParticipant).filter(EventParticipant.event_id == event_id).delete()

    db.delete(event)
    db.commit()

    return{
        "message": "Usunięto wydarzenie"
    }

def get_event_participants(
    event_id: int,
    db: Session,
    current_user: User
) -> list[EventParticipant]:
    event = db.query(Event).filter(Event.id == event_id).first()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nie znaleziono wydarzenia"
        )

    if event.group_id is not None:
        group_member = (
            db.query(GroupMember)
            .filter(GroupMember.group_id == event.group_id)
            .filter(GroupMember.user_id == current_user.id)
            .first()
        )

        if group_member is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Uczestników wydarzenia grupowego mogą zobaczyć tylko członkowie grupy"
            )

    participants = (
        db.query(EventParticipant)
        .filter(EventParticipant.event_id == event_id)
        .all()
    )

    return participants
