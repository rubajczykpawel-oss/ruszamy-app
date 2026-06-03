from fastapi import FastAPI
from database import Base, engine
from routers import auth_router, users_router, events_router, groups_router, friends_router

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Ruszamy Api",
    description="Api do aplikacji Wyjdżmy na dwór ",
    version="0.1.0"
)

@app.get("/")
def root():
    return {
        "message": "Ruszamy Api działa"
    }

app.include_router(auth_router.router)
app.include_router(users_router.router)
app.include_router(events_router.router)
app.include_router(friends_router.router)
app.include_router(groups_router.router)