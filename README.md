# Ruszamy App

Ruszamy App is a web/mobile application for finding people, groups and outdoor activities.

The project is currently in development.

## Tech stack

### Backend
- Python
- FastAPI
- SQLAlchemy
- PostgreSQL
- JWT authentication

### Planned frontend
- Flutter

## Current backend features

- User registration
- User login
- JWT authentication
- User search
- Friend requests
- Accepting and rejecting friend requests
- Groups
- Group members
- Events
- Joining and leaving events
- Deleting own events

## Project structure

```text
ruszamy_app
├── backend
│   ├── app.py
│   ├── auth.py
│   ├── database.py
│   ├── models.py
│   ├── schemas.py
│   ├── routers
│   ├── services
│   └── requirements.txt
├── README.md
├── .gitignore
└── .env.example