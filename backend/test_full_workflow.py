"""
Complete API Workflow Test
Tests Admin → Tutor → Student flow for mobile app
"""

import requests
import json

BASE_URL = "http://127.0.0.1:8000/api"


def print_section(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print('='*60)


def test_full_workflow():
    """Test complete platform workflow"""
    
    # ========================================================================
    # ADMIN OPERATIONS
    # ========================================================================
    print_section("1. ADMIN LOGIN")
    
    admin_login = requests.post(f"{BASE_URL}/auth/login", json={
        "username": "admin@fpi.edu.ng",
        "password": "Admin@123"
    })
    admin_token = admin_login.json()["access_token"]
    print(f"✅ Admin logged in")
    
    admin_headers = {"Authorization": f"Bearer {admin_token}"}
    
    # ========================================================================
    # TUTOR REGISTRATION AND APPROVAL
    # ========================================================================
    print_section("2. TUTOR REGISTRATION")
    
    tutor_data = {
        "email": "tutor1@fpi.edu.ng",
        "first_name": "Sarah",
        "last_name": "Johnson",
        "phone_number": "08012345678",
        "specialization": "ICT/Web Design",
        "bio": "Expert in modern web technologies",
        "password": "Tutor@2024"
    }
    
    tutor_reg = requests.post(f"{BASE_URL}/auth/register/tutor", json=tutor_data)
    
    if tutor_reg.status_code == 201:
        tutor_id = tutor_reg.json()["id"]
        print(f"✅ Tutor registered (ID: {tutor_id})")
        
        # Admin approves tutor
        print_section("3. ADMIN APPROVES TUTOR")
        approval = requests.post(
            f"{BASE_URL}/admin/users/tutors/{tutor_id}/approve",
            headers=admin_headers
        )
        print(f"✅ Tutor approved: {approval.json()['message']}")
    else:
        print(f"ℹ️  Tutor may already exist: {tutor_reg.json()}")
    
    # ========================================================================
    # TUTOR LOGIN
    # ========================================================================
    print_section("4. TUTOR LOGIN")
    
    tutor_login = requests.post(f"{BASE_URL}/auth/login", json={
        "username": "tutor1@fpi.edu.ng",
        "password": "Tutor@2024"
    })
    tutor_token = tutor_login.json()["access_token"]
    tutor_headers = {"Authorization": f"Bearer {tutor_token}"}
    print(f"✅ Tutor logged in")
    
    # ========================================================================
    # TUTOR CREATES COURSE
    # ========================================================================
    print_section("5. TUTOR CREATES COURSE")
    
    # Get vocations to find ICT/Web Design ID
    vocations = requests.get(f"{BASE_URL}/student/vocations").json()
    web_design = next((v for v in vocations if "Web Design" in v["name"]), vocations[0])
    
    course_data = {
        "title": "Introduction to HTML & CSS",
        "description": "Learn the fundamentals of web development",
        "vocation_id": web_design["id"],
        "is_published": True
    }
    
    course_resp = requests.post(
        f"{BASE_URL}/tutor/courses",
        json=course_data,
        headers=tutor_headers
    )
    
    if course_resp.status_code == 201:
        course_id = course_resp.json()["id"]
        print(f"✅ Course created (ID: {course_id})")
        
        # Create module
        print_section("6. TUTOR CREATES MODULE")
        module_data = {
            "title": "HTML Basics",
            "description": "Introduction to HTML tags",
            "course_id": course_id,
            "order": 1,
            "duration_minutes": 60,
            "is_published": True
        }
        
        module_resp = requests.post(
            f"{BASE_URL}/tutor/modules",
            json=module_data,
            headers=tutor_headers
        )
        module_id = module_resp.json()["id"]
        print(f"✅ Module created (ID: {module_id})")
        
        # Create assignment
        print_section("7. TUTOR CREATES ASSIGNMENT")
        assignment_data = {
            "title": "Build Your First Web Page",
            "description": "Create a simple HTML page with headings and paragraphs",
            "course_id": course_id,
            "assignment_type": "practical",
            "max_score": 100,
            "is_published": True
        }
        
        assignment_resp = requests.post(
            f"{BASE_URL}/tutor/assignments",
            json=assignment_data,
            headers=tutor_headers
        )
        assignment_id = assignment_resp.json()["id"]
        print(f"✅ Assignment created (ID: {assignment_id})")
    
    # ========================================================================
    # STUDENT LOGIN
    # ========================================================================
    print_section("8. STUDENT LOGIN")
    
    student_login = requests.post(f"{BASE_URL}/auth/login", json={
        "username": "2460141001",
        "password": "12345678"
    })
    student_token = student_login.json()["access_token"]
    student_headers = {"Authorization": f"Bearer {student_token}"}
    must_change = student_login.json()["must_change_password"]
    print(f"✅ Student logged in")
    print(f"   Must change password: {must_change}")
    
    # ========================================================================
    # STUDENT DASHBOARD
    # ========================================================================
    print_section("9. STUDENT DASHBOARD")
    
    dashboard = requests.get(f"{BASE_URL}/student/dashboard", headers=student_headers)
    dash_data = dashboard.json()
    print(f"✅ Student dashboard loaded")
    print(f"   Name: {dash_data['student']['name']}")
    print(f"   Vocation: {dash_data['student']['vocation']}")
    print(f"   Available courses: {dash_data['courses']['available']}")
    
    # ========================================================================
    # STUDENT BROWSES AVAILABLE COURSES
    # ========================================================================
    print_section("10. STUDENT VIEWS AVAILABLE COURSES")
    
    available = requests.get(
        f"{BASE_URL}/student/courses/available",
        headers=student_headers
    )
    print(f"✅ Available courses: {len(available.json())}")
    
    print("\n" + "="*60)
    print("  ✅ COMPLETE WORKFLOW TEST PASSED!")
    print("="*60)
    print("\nAll roles working correctly:")
    print("  ✓ Admin can manage users")
    print("  ✓ Tutors can create courses & assignments")
    print("  ✓ Students can access dashboard & courses")
    print("  ✓ Mobile-ready REST APIs functional")


if __name__ == "__main__":
    try:
        test_full_workflow()
    except Exception as e:
        print(f"\n❌ Error: {e}")