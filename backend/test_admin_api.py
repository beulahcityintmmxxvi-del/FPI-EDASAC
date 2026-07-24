"""
Quick API Test Script
Tests authentication and admin endpoints
"""

import requests
import json

BASE_URL = "http://127.0.0.1:8000/api"

def test_admin_workflow():
    """Test complete admin authentication flow"""
    
    print("="*60)
    print("TESTING ADMIN API WORKFLOW")
    print("="*60 + "\n")
    
    # Step 1: Login
    print("STEP 1: Admin Login")
    login_response = requests.post(
        f"{BASE_URL}/auth/login",
        json={
            "username": "admin@fpi.edu.ng",
            "password": "Admin@123"
        }
    )
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.text}")
        return
    
    token_data = login_response.json()
    access_token = token_data["access_token"]
    
    print(f"✅ Login successful!")
    print(f"   Token: {access_token[:50]}...")
    print(f"   Role: {token_data['role']}\n")
    
    # Step 2: Get Dashboard Stats
    print("STEP 2: Get Dashboard Statistics")
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    
    stats_response = requests.get(
        f"{BASE_URL}/admin/dashboard/stats",
        headers=headers
    )
    
    if stats_response.status_code != 200:
        print(f"❌ Dashboard stats failed: {stats_response.text}")
        return
    
    stats = stats_response.json()
    print(f"✅ Dashboard stats retrieved!")
    print(f"   Total Students: {stats['users']['total_students']}")
    print(f"   Total Tutors: {stats['users']['total_tutors']}")
    print(f"   Total Courses: {stats['courses']['total']}\n")
    
    # Step 3: Get All Students
    print("STEP 3: Get All Students")
    students_response = requests.get(
        f"{BASE_URL}/admin/users/students",
        headers=headers
    )
    
    if students_response.status_code != 200:
        print(f"❌ Get students failed: {students_response.text}")
        return
    
    students = students_response.json()
    print(f"✅ Students retrieved!")
    print(f"   Total: {len(students)}")
    
    if students:
        print(f"   First student: {students[0]['first_name']} {students[0]['last_name']}")
        print(f"   Matric: {students[0]['matric_number']}\n")
    
    # Step 4: Get Departments
    print("STEP 4: Get All Departments")
    dept_response = requests.get(
        f"{BASE_URL}/admin/departments",
        headers=headers
    )
    
    if dept_response.status_code != 200:
        print(f"❌ Get departments failed: {dept_response.text}")
        return
    
    departments = dept_response.json()
    print(f"✅ Departments retrieved!")
    print(f"   Total: {len(departments)}")
    
    for dept in departments[:3]:
        print(f"   - [{dept['code']}] {dept['name']} ({dept['student_count']} students)")
    
    print("\n" + "="*60)
    print("✅ ALL TESTS PASSED!")
    print("="*60)

if __name__ == "__main__":
    test_admin_workflow()