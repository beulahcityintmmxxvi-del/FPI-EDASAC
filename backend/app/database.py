"""
Database Configuration and Session Management
SQLAlchemy setup for PostgreSQL
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.pool import NullPool

from app.config import settings

# ─────────────────────────────────────────────────────────────
# Handle Render's postgres:// vs SQLAlchemy's postgresql:// scheme
# ─────────────────────────────────────────────────────────────
db_url = settings.DATABASE_URL
if db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql://", 1)

# ─────────────────────────────────────────────────────────────
# SQLAlchemy Engine
# ─────────────────────────────────────────────────────────────
engine = create_engine(
    db_url,
    echo=settings.DB_ECHO,
    pool_pre_ping=True,   # verifies connections before using them
    pool_recycle=300,      # recycle connections every 5 minutes
)

# ─────────────────────────────────────────────────────────────
# Session Factory
# ─────────────────────────────────────────────────────────────
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)

# ─────────────────────────────────────────────────────────────
# Declarative Base for models
# ─────────────────────────────────────────────────────────────
Base = declarative_base()


# ─────────────────────────────────────────────────────────────
# Dependency for FastAPI routes
# ─────────────────────────────────────────────────────────────
def get_db():
    """
    FastAPI dependency that provides a database session
    per request and closes it when done.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ─────────────────────────────────────────────────────────────
# Table creation (called on app startup)
# ─────────────────────────────────────────────────────────────
def init_db():
    """
    Import all models and create tables if they don't exist.
    Called from FastAPI's startup event.
    """
    # Import all models so they're registered with Base
    from app.models import (
        user,
        department,
        vocation,
        course,
        module,
        multimedia,
        assignment,
        submission,
        enrollment,
    )
    
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created successfully")