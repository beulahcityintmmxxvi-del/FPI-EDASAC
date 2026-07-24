@echo off
cls
echo ================================================
echo   VOCATIONAL SKILLS PLATFORM
echo   Development Server Launcher
echo ================================================
echo.

REM Navigate to backend directory
cd /d "%~dp0"

REM Activate virtual environment
echo [1/4] Activating virtual environment...
call venv\Scripts\activate.bat

REM Verify activation
if not defined VIRTUAL_ENV (
    echo [ERROR] Failed to activate virtual environment
    pause
    exit /b 1
)

echo [✓] Virtual environment activated
echo.

REM Set Python path
echo [2/4] Setting Python path...
set PYTHONPATH=%CD%
echo [✓] PYTHONPATH = %PYTHONPATH%
echo.

REM Verify required files exist
echo [3/4] Checking project structure...
if not exist "app\main.py" (
    echo [ERROR] app\main.py not found!
    pause
    exit /b 1
)
if not exist "app\config.py" (
    echo [ERROR] app\config.py not found!
    pause
    exit /b 1
)
if not exist "app\database.py" (
    echo [ERROR] app\database.py not found!
    pause
    exit /b 1
)
echo [✓] Project structure verified
echo.

REM Start server
echo [4/4] Starting FastAPI server...
echo ================================================
echo Server will run on: http://127.0.0.1:8000
echo API Docs available at: http://127.0.0.1:8000/api/docs
echo.
echo Press CTRL+C to stop the server
echo ================================================
echo.

python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000

pause