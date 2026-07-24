"""
Database Seeder
Populates initial data (departments, vocations, admin user)
"""

from sqlalchemy.orm import Session
from app.models.user import User
from app.models.department import Department
from app.models.vocation import Vocation
from app.models.enums import UserRole, DEPARTMENTS, VOCATIONS
from app.utils.security import get_password_hash
from slugify import slugify


def seed_departments(db: Session) -> None:
    """Create initial departments"""
    existing_count = db.query(Department).count()
    
    if existing_count > 0:
        print(f"ℹ️  Departments already seeded ({existing_count} records)")
        return
    
    print("📚 Seeding departments...")
    
    for dept_name in DEPARTMENTS:
        # Generate department code from first letters
        code = ''.join([word[0].upper() for word in dept_name.split()[:3]])
        
        department = Department(
            name=dept_name,
            code=code,
            description=f"{dept_name} Department"
        )
        db.add(department)
    
    db.commit()
    print(f"✅ Seeded {len(DEPARTMENTS)} departments")


def seed_vocations(db: Session) -> None:
    """Create initial vocational programs"""
    existing_count = db.query(Vocation).count()
    
    if existing_count > 0:
        print(f"ℹ️  Vocations already seeded ({existing_count} records)")
        return
    
    print("🛠️  Seeding vocations...")
    
    for vocation_name in VOCATIONS:
        vocation = Vocation(
            name=vocation_name,
            slug=slugify(vocation_name),
            description=f"Learn professional skills in {vocation_name}",
            is_active=True,
            duration_weeks="12-16 weeks"
        )
        db.add(vocation)
    
    db.commit()
    print(f"✅ Seeded {len(VOCATIONS)} vocations")


def seed_admin_user(db: Session) -> None:
    """Create default admin user"""
    existing_admin = db.query(User).filter(
        User.role == UserRole.ADMIN
    ).first()
    
    if existing_admin:
        print(f"ℹ️  Admin user already exists: {existing_admin.email}")
        return
    
    print("👤 Creating default admin user...")
    
    admin = User(
        email="admin@fpi.edu.ng",
        hashed_password=get_password_hash("Admin@123"),
        role=UserRole.ADMIN,
        is_active=True,
        is_approved=True,
        must_change_password=False,
        first_name="System",
        last_name="Administrator",
        phone_number="0800000000"
    )
    
    db.add(admin)
    db.commit()
    db.refresh(admin)
    
    print(f"✅ Admin user created: {admin.email}")
    print(f"   Password: Admin@123")


def seed_all(db: Session) -> None:
    """Run all seeders"""
    print("\n" + "="*50)
    print("🌱 SEEDING DATABASE")
    print("="*50 + "\n")
    
    seed_departments(db)
    seed_vocations(db)
    seed_admin_user(db)
    
    print("\n" + "="*50)
    print("✅ DATABASE SEEDING COMPLETE")
    print("="*50 + "\n")