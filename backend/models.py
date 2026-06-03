from datetime import datetime

from sqlalchemy import Boolean, Column, Date, DateTime, ForeignKey, Integer, String, Text, Time, UniqueConstraint
from sqlalchemy.orm import relationship

from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    email = Column(String(255), unique=True, nullable=False, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)

    city = Column(String(100), nullable=True)
    age = Column(Integer, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    created_events = relationship("Event", back_populates="creator")
    event_participations = relationship("EventParticipant", back_populates="user")

    sent_friend_requests = relationship(
        "Friendship",
        foreign_keys="Friendship.requester_id",
        back_populates="requester"
    )

    received_friend_requests = relationship(
        "Friendship",
        foreign_keys="Friendship.receiver_id",
        back_populates="receiver"
    )

    owned_groups = relationship("ActivityGroup", back_populates="owner")
    group_memberships = relationship("GroupMember", back_populates="user")


class Event(Base):
    __tablename__ = "events"

    id = Column(Integer, primary_key=True, index=True)

    title = Column(String(120), nullable=False)
    description = Column(Text, nullable=False)

    activity_type = Column(String(50), nullable=False)
    city = Column(String(100), nullable=False)
    location_name = Column(String(150), nullable=False)

    date = Column(Date, nullable=False)
    time = Column(Time, nullable=False)

    max_participants = Column(Integer, nullable=False)
    level = Column(String(50), nullable=False)

    age_min = Column(Integer, nullable=True)
    age_max = Column(Integer, nullable=True)

    is_public = Column(Boolean, default=True)

    creator_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    group_id = Column(Integer, ForeignKey("groups.id"), nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    creator = relationship("User", back_populates="created_events")
    participants = relationship("EventParticipant", back_populates="event")
    group = relationship("ActivityGroup", back_populates="events")


class EventParticipant(Base):
    __tablename__ = "event_participants"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    event_id = Column(Integer, ForeignKey("events.id"), nullable=False)

    joined_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="event_participations")
    event = relationship("Event", back_populates="participants")

    __table_args__ = (
        UniqueConstraint("user_id", "event_id", name="unique_user_event"),
    )


class Friendship(Base):
    __tablename__ = "friendships"

    id = Column(Integer, primary_key=True, index=True)

    requester_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    receiver_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    status = Column(String(30), default="pending")

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)

    requester = relationship(
        "User",
        foreign_keys=[requester_id],
        back_populates="sent_friend_requests"
    )

    receiver = relationship(
        "User",
        foreign_keys=[receiver_id],
        back_populates="received_friend_requests"
    )

    __table_args__ = (
        UniqueConstraint("requester_id", "receiver_id", name="unique_friend_request"),
    )


class ActivityGroup(Base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=False)

    city = Column(String(100), nullable=False)
    activity_type = Column(String(50), nullable=False)

    owner_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    owner = relationship("User", back_populates="owned_groups")
    members = relationship("GroupMember", back_populates="group")
    events = relationship("Event", back_populates="group")


class GroupMember(Base):
    __tablename__ = "group_members"

    id = Column(Integer, primary_key=True, index=True)

    group_id = Column(Integer, ForeignKey("groups.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    role = Column(String(30), default="member")

    joined_at = Column(DateTime, default=datetime.utcnow)

    group = relationship("ActivityGroup", back_populates="members")
    user = relationship("User", back_populates="group_memberships")

    __table_args__ = (
        UniqueConstraint("group_id", "user_id", name="unique_group_member"),
    )




















    