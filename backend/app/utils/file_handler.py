"""
File Upload and Management Utilities
Handles secure file uploads for mobile clients
"""

import os
import uuid
from typing import Optional, Tuple
from fastapi import UploadFile, HTTPException, status
import aiofiles
from app.config import settings
from app.models.enums import MediaType


# File size limits (in bytes)
FILE_SIZE_LIMITS = {
    MediaType.VIDEO: 524288000,   # 500MB
    MediaType.PDF: 52428800,      # 50MB
    MediaType.IMAGE: 10485760,    # 10MB
    MediaType.DOCUMENT: 26214400, # 25MB
}


def get_upload_directory(media_type: MediaType) -> str:
    """Get upload directory based on media type"""
    directory_map = {
        MediaType.VIDEO: settings.VIDEO_DIR,
        MediaType.PDF: settings.PDF_DIR,
        MediaType.IMAGE: settings.IMAGE_DIR,
        MediaType.DOCUMENT: settings.PDF_DIR,
    }
    return directory_map.get(media_type, settings.TEMP_DIR)


def detect_media_type(filename: str) -> Optional[MediaType]:
    """Detect media type from file extension"""
    if not filename:
        return None
    
    ext = filename.rsplit('.', 1)[-1].lower() if '.' in filename else ''
    
    if ext in settings.video_extensions_list:
        return MediaType.VIDEO
    elif ext in settings.image_extensions_list:
        return MediaType.IMAGE
    elif ext == 'pdf':
        return MediaType.PDF
    elif ext in settings.document_extensions_list:
        return MediaType.DOCUMENT
    
    return None


def validate_file(file: UploadFile, media_type: MediaType) -> None:
    """
    Validate uploaded file
    
    Raises:
        HTTPException: If file is invalid
    """
    if not file.filename:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Filename is required"
        )
    
    # Validate extension
    ext = file.filename.rsplit('.', 1)[-1].lower() if '.' in file.filename else ''
    
    allowed_extensions = {
        MediaType.VIDEO: settings.video_extensions_list,
        MediaType.IMAGE: settings.image_extensions_list,
        MediaType.PDF: ['pdf'],
        MediaType.DOCUMENT: settings.document_extensions_list,
    }
    
    if ext not in allowed_extensions.get(media_type, []):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file type. Allowed: {allowed_extensions.get(media_type)}"
        )


def generate_unique_filename(original_filename: str) -> str:
    """Generate unique filename to prevent conflicts"""
    ext = original_filename.rsplit('.', 1)[-1].lower() if '.' in original_filename else ''
    unique_id = uuid.uuid4().hex
    return f"{unique_id}.{ext}" if ext else unique_id


async def save_upload_file(
    file: UploadFile,
    media_type: MediaType,
    validate: bool = True
) -> Tuple[str, str, int]:
    """
    Save uploaded file to disk
    
    Args:
        file: FastAPI UploadFile object
        media_type: Type of media being uploaded
        validate: Whether to validate file
        
    Returns:
        Tuple of (file_path, unique_filename, file_size)
    """
    if validate:
        validate_file(file, media_type)
    
    # Get upload directory
    upload_dir = get_upload_directory(media_type)
    os.makedirs(upload_dir, exist_ok=True)
    
    # Generate unique filename
    unique_filename = generate_unique_filename(file.filename)
    file_path = os.path.join(upload_dir, unique_filename)
    
    # Check file size while saving
    file_size = 0
    max_size = FILE_SIZE_LIMITS.get(media_type, settings.MAX_UPLOAD_SIZE)
    
    # Save file asynchronously
    async with aiofiles.open(file_path, 'wb') as buffer:
        while True:
            chunk = await file.read(1024 * 1024)  # 1MB chunks
            if not chunk:
                break
            
            file_size += len(chunk)
            
            if file_size > max_size:
                # Delete partial file
                await buffer.close()
                os.remove(file_path)
                raise HTTPException(
                    status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                    detail=f"File too large. Maximum size: {max_size / (1024 * 1024):.1f}MB"
                )
            
            await buffer.write(chunk)
    
    # Return relative path for storage
    relative_path = file_path.replace('\\', '/')
    
    return relative_path, unique_filename, file_size


def delete_file(file_path: str) -> bool:
    """
    Delete file from disk
    
    Args:
        file_path: Path to file
        
    Returns:
        True if deleted successfully
    """
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
            return True
    except Exception as e:
        print(f"Error deleting file {file_path}: {e}")
    
    return False


def get_file_size_mb(file_path: str) -> float:
    """Get file size in megabytes"""
    if os.path.exists(file_path):
        return os.path.getsize(file_path) / (1024 * 1024)
    return 0.0