"""
Database Configuration and Session Management
Handles PostgreSQL connection using SQLAlchemy ORM
"""
import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from typing import Generator
from app.config import settings

# Fix for Render PostgreSQL URL (postgres:// -> postgresql://)
db_url = settings.DATABASE_URL

if db_url.startswith("postgres://"):
    db_url = db_url.replace("postgres://", "postgresql://", 1)

# Create SQLAlchemy engine
engine = create_engine(
    db_url,
    pool_pre_ping=True,
    echo=settings.DB_ECHO,
    future=True
)

# SessionLocal: Database session factory
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# Base class for ORM models
Base = declarative_base()


def get_db() -> Generator[Session, None, None]:
    """
    Dependency function that provides database session
    Automatically handles session lifecycle and cleanup
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    """
    Initialize database tables
    Creates all tables defined in models
    Should be called on application startup
    """
    # Import all models to ensure they're registered with Base
    from app.models import (
        User, Department, Vocation, Course, 
        Module, Multimedia, Assignment, Submission, Enrollment
    )
    
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created successfully")