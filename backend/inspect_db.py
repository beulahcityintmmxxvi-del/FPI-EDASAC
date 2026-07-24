"""
Database Inspection Script
Displays database contents for verification
"""

from app.database import SessionLocal
from app.models import User, Department, Vocation
from sqlalchemy import inspect

def inspect_database():
    """Display database tables and sample data"""
    db = SessionLocal()
    
    try:
        print("\n" + "="*60)
        print("DATABASE INSPECTION")
        print("="*60 + "\n")
        
        # Check departments
        departments = db.query(Department).all()
        print(f"📚 DEPARTMENTS ({len(departments)} records):")
        for dept in departments[:5]:
            print(f"   - [{dept.code}] {dept.name}")
        if len(departments) > 5:
            print(f"   ... and {len(departments) - 5} more\n")
        else:
            print()
        
        # Check vocations
        vocations = db.query(Vocation).all()
        print(f"🛠️  VOCATIONS ({len(vocations)} records):")
        for voc in vocations[:5]:
            print(f"   - {voc.name} ({voc.slug})")
        if len(vocations) > 5:
            print(f"   ... and {len(vocations) - 5} more\n")
        else:
            print()
        
        # Check users
        users = db.query(User).all()
        print(f"👤 USERS ({len(users)} records):")
        for user in users:
            print(f"   - {user.role.value.upper()}: {user.email or user.matric_number} ({user.first_name} {user.last_name})")
        print()
        
        print("="*60)
        print("✅ DATABASE INSPECTION COMPLETE")
        print("="*60 + "\n")
        
    finally:
        db.close()

if __name__ == "__main__":
    inspect_database()