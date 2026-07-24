"""
Application Configuration Module
Manages environment variables and application settings
"""

from pydantic_settings import BaseSettings
from typing import List
from functools import lru_cache

class Settings(BaseSettings):
    """
    Application settings loaded from environment variables
    Uses Pydantic for validation and type safety
    """
    
    # Application Info
    APP_NAME: str = "Vocational Skills Platform"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    ENVIRONMENT: str = "development"
    
    # Server Configuration
    HOST: str = "127.0.0.1"
    PORT: int = 8000
    
    # Database
    DATABASE_URL: str = "postgresql://postgres:admin123@localhost:5432/vocational_skills_db"
    DB_ECHO: bool = True
    
    # Security
    SECRET_KEY: str = "your-super-secret-key-change-in-production-min-32-chars-required-for-security"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 days
    
    # Default Credentials
    DEFAULT_STUDENT_PASSWORD: str = "12345678"
    
    # File Upload
    MAX_UPLOAD_SIZE: int = 524288000  # 500MB
    ALLOWED_VIDEO_EXTENSIONS: str = "mp4,avi,mov,mkv"
    ALLOWED_IMAGE_EXTENSIONS: str = "jpg,jpeg,png,gif,webp"
    ALLOWED_DOCUMENT_EXTENSIONS: str = "pdf,doc,docx"
    
    # Paths
    UPLOAD_DIR: str = "uploads"
    VIDEO_DIR: str = "uploads/videos"
    PDF_DIR: str = "uploads/pdfs"
    IMAGE_DIR: str = "uploads/images"
    TEMP_DIR: str = "uploads/temp"
    
    # CORS
    ALLOWED_ORIGINS: str = "http://localhost:3000"
    
    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 60
    
    class Config:
        # Look for .env file in backend directory
        env_file = ".env"
        env_file_encoding = 'utf-8'
        case_sensitive = True
        # Don't fail if .env doesn't exist
        extra = "ignore"

    @property
    def allowed_origins_list(self) -> List[str]:
        """Convert comma-separated origins to list"""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]
    
    @property
    def video_extensions_list(self) -> List[str]:
        """Convert comma-separated video extensions to list"""
        return [ext.strip() for ext in self.ALLOWED_VIDEO_EXTENSIONS.split(",")]
    
    @property
    def image_extensions_list(self) -> List[str]:
        """Convert comma-separated image extensions to list"""
        return [ext.strip() for ext in self.ALLOWED_IMAGE_EXTENSIONS.split(",")]
    
    @property
    def document_extensions_list(self) -> List[str]:
        """Convert comma-separated document extensions to list"""
        return [ext.strip() for ext in self.ALLOWED_DOCUMENT_EXTENSIONS.split(",")]


@lru_cache()
def get_settings() -> Settings:
    """
    Create cached settings instance
    Uses lru_cache to avoid reading .env file on every call
    """
    return Settings()


# Global settings instance
settings = get_settings()