from sqlalchemy.orm import Session

from models import User


def search_users_by_username(
    username: str,
    db: Session,
    current_user: User
) -> list[User]:
    users = (
        db.query(User)
        .filter(User.username.ilike(f"%{username}%"))
        .filter(User.id != current_user.id)
        .limit(20)
        .all()
    )

    return users