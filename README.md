# Ruszamy App

Ruszamy App is a web/mobile application for finding people, groups and outdoor activities.

The project is currently in development.

## Tech stack

### Backend

* Python
* FastAPI
* SQLAlchemy
* PostgreSQL
* JWT authentication
* Pydantic

### Planned frontend

* Flutter

## Current backend features

### Auth

* User registration
* User login
* JWT authentication
* Getting current logged-in user profile

### Users

* User search by username
* Updating own profile

### Friends

* Sending friend requests
* Viewing sent friend requests
* Viewing received friend requests
* Accepting friend requests
* Rejecting friend requests
* Viewing accepted friends

### Groups

* Creating groups
* Viewing own groups
* Viewing group details
* Viewing group members
* Adding accepted friends to groups
* Leaving groups
* Removing members from groups
* Deleting own groups

### Events

* Creating events
* Viewing public events
* Viewing event details
* Viewing own joined events
* Joining events
* Leaving events
* Deleting own events
* Viewing event participants
* Showing participants count

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
│   │   ├── auth_router.py
│   │   ├── users_router.py
│   │   ├── friends_router.py
│   │   ├── groups_router.py
│   │   └── events_router.py
│   ├── services
│   │   ├── auth_service.py
│   │   ├── users_service.py
│   │   ├── friends_service.py
│   │   ├── groups_service.py
│   │   └── events_service.py
│   └── requirements.txt
├── README.md
├── .gitignore
└── .env.example
```

## Environment variables

The project uses environment variables stored locally in a `.env` file.

Example file:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/database_name
SECRET_KEY=your_secret_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

The real `.env` file should not be committed to GitHub.

## Running the backend locally

Go to the backend folder:

```bash
cd backend
```

Run the FastAPI server:

```bash
uvicorn app:app --reload
```

Then open Swagger documentation:

```text
http://127.0.0.1:8000/docs
```

## About

This project is built as a learning backend application focused on clean FastAPI structure, authentication, database models, routers, services and real API flow.
