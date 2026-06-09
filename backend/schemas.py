from datetime import datetime, date, time
from typing import Optional

from pydantic import BaseModel


class UserCreate(BaseModel):
    email: str
    username: str
    password: str
    city: Optional[str] = None
    age: Optional[int] = None


class UserResponse(BaseModel):
    id: int
    email: str
    username: str
    city: Optional[str] = None
    age: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str


class EventCreate(BaseModel):
    title: str
    description: str
    activity_type: str
    city: str
    location_name: str
    date: date
    time: time
    max_participants: int
    level: str
    age_min: Optional[int] = None
    age_max: Optional[int] = None
    is_public: bool = True
    group_id: Optional[int] = None


class EventResponse(BaseModel):
    id: int
    title: str
    description: str
    activity_type: str
    city: str
    location_name: str
    date: date
    time: time
    max_participants: int
    participants_count: int = 0
    level: str
    age_min: Optional[int] = None
    age_max: Optional[int] = None
    is_public: bool
    creator_id: int
    group_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True


class FriendshipResponse(BaseModel):
    id: int
    requester_id: int
    receiver_id: int
    status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class GroupCreate(BaseModel):
    name: str
    description: str
    city: str
    activity_type: str


class GroupResponse(BaseModel):
    id: int
    name: str
    description: str
    city: str
    activity_type: str
    owner_id: int
    created_at: datetime

    class Config:
        from_attributes = True


class GroupMemberResponse(BaseModel):
    id: int
    group_id: int
    user_id: int
    role: str
    joined_at: datetime

    class Config:
        from_attributes = True

class GroupMemberWithUserResponse(BaseModel):
    id: int
    group_id: int
    user_id: int
    role: str
    joined_at: datetime
    user: UserResponse

    class Config:
        from_attributes = True

class EventParticipantWithUserResponse(BaseModel):
    id: int
    event_id: int
    user_id: int
    joined_at: datetime
    user: UserResponse

    class Config:
        from_attributes = True