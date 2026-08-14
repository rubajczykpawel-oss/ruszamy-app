from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import Base, engine
from logger_config import logger
from routers import auth_router, users_router, events_router, groups_router, friends_router

logger.info("Starting Ruszamy API")

Base.metadata.create_all(bind=engine)

logger.info("Database tables initialized")

app = FastAPI(
    title="Ruszamy API",
    description="API do aplikacji Wyjdźmy na dwór",
    version="0.1.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(auth_router.router)
app.include_router(users_router.router)
app.include_router(events_router.router)
app.include_router(friends_router.router)
app.include_router(groups_router.router)

logger.info("Application routers registered")


@app.get("/")
def root():
    return {"message": "Ruszamy Api działa"}