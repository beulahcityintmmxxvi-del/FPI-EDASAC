"""
Role-Based Access Control Middleware
Permission checking based on user roles
"""

from fastapi import Depends, HTTPException, status
from app.models.user import User
from app.models.enums import UserRole
from app.middleware.auth_middleware import get_current_active_user


def require_admin(current_user: User = Depends(get_current_active_user)) -> User:
    """
    Require admin role
    
    Args:
        current_user: Authenticated user
        
    Returns:
        Admin user object
        
    Raises:
        HTTPException: If user is not admin
    """
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required"
        )
    return current_user


def require_tutor(current_user: User = Depends(get_current_active_user)) -> User:
    """
    Require tutor role (and approved status)
    
    Args:
        current_user: Authenticated user
        
    Returns:
        Approved tutor user object
        
    Raises:
        HTTPException: If user is not tutor or not approved
    """
    if current_user.role != UserRole.TUTOR:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tutor access required"
        )
    
    if not current_user.is_approved:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your tutor account is pending admin approval"
        )
    
    return current_user


def require_student(current_user: User = Depends(get_current_active_user)) -> User:
    """
    Require student role
    
    Args:
        current_user: Authenticated user
        
    Returns:
        Student user object
        
    Raises:
        HTTPException: If user is not student
    """
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Student access required"
        )
    return current_user


def require_tutor_or_admin(current_user: User = Depends(get_current_active_user)) -> User:
    """
    Require tutor or admin role
    
    Args:
        current_user: Authenticated user
        
    Returns:
        Tutor or admin user object
        
    Raises:
        HTTPException: If user is neither tutor nor admin
    """
    if current_user.role not in [UserRole.TUTOR, UserRole.ADMIN]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tutor or admin access required"
        )
    return current_user