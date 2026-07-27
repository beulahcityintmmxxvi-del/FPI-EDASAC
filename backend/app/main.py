"""
FastAPI Application Entry Point
REST API Server for Flutter Mobile Application (Android/iOS/Web)
"""

import os
import sys
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.config import settings
from app.database import SessionLocal, init_db
from app.routes import admin, auth, multimedia, student, tutor
from app.utils import seed_all

BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Enterprise-grade REST API for Flutter mobile vocational skills app",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json"
)

# ============================================================================
# CORS — Fixed for Flutter Web + Mobile
# ============================================================================
# Browsers REJECT `allow_origins=["*"]` when `allow_credentials=True`.
# Since the app uses Bearer tokens (not cookies), credentials are NOT needed.
# ============================================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["Content-Range", "Accept-Ranges", "Content-Length"],
)


@app.on_event("startup")
async def startup_event():
    print(f"🚀 Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    print(f"📊 Environment: {settings.ENVIRONMENT}")
    print("📱 Mobile & Web API Server for Flutter")

    upload_dirs = [
        settings.UPLOAD_DIR, settings.VIDEO_DIR,
        settings.PDF_DIR, settings.IMAGE_DIR, settings.TEMP_DIR
    ]

    for directory in upload_dirs:
        os.makedirs(directory, exist_ok=True)

    print("📁 Upload directories ready")

    init_db()

    db = SessionLocal()
    try:
        seed_all(db)
    finally:
        db.close()

    print("✅ Application startup complete")
    print("📡 API Documentation: http://127.0.0.1:8000/api/docs")


@app.on_event("shutdown")
async def shutdown_event():
    print("🛑 Shutting down application...")


@app.get("/", tags=["System"])
async def root():
    return {
        "status": "operational",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
        "platform": "REST API (Flutter Android/iOS/Web)",
        "docs": "/api/docs"
    }


@app.get("/health", tags=["System"])
async def health_check():
    return {"status": "healthy", "database": "connected"}

for _dir in [
    settings.UPLOAD_DIR,
    settings.VIDEO_DIR,
    settings.PDF_DIR,
    settings.IMAGE_DIR,
    settings.TEMP_DIR,
]:
# Ensure uploads directory exists before mounting
    os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(admin.router, prefix="/api/admin", tags=["Admin"])
app.include_router(tutor.router, prefix="/api/tutor", tags=["Tutor"])
app.include_router(student.router, prefix="/api/student", tags=["Student"])
app.include_router(multimedia.router, prefix="/api/media", tags=["Multimedia"])