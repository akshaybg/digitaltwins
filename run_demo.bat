@echo off
REM Simple demo launcher for Windows - No Docker needed!

echo.
echo Construction Site Digital Twin - Demo Mode
echo ==============================================
echo.

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo Installing dependencies...
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet

echo.
echo Setup complete!
echo.
echo Starting Construction Site Digital Twin...
echo.
echo Access points:
echo    - Main Portal:      http://localhost:8001/
echo    - 2D Dashboard:     http://localhost:8001/dashboard
echo    - 3D Visualization: http://localhost:8001/3d
echo.
echo Press Ctrl+C to stop the demo
echo.
echo ================================================
echo.

REM Run the application
python construction_digital_twin.py
