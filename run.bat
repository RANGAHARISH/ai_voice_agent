@echo off
cd /d "%~dp0"
echo ============================================
echo   OutboundAI — Local Server
echo ============================================
echo.

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Set UTF-8 encoding for emoji support
set PYTHONIOENCODING=utf-8

echo Starting FastAPI server on http://localhost:8000 ...
echo Open http://localhost:8000 in your browser
echo Press Ctrl+C to stop
echo.

uvicorn server:app --host 0.0.0.0 --port 8000 --reload

pause
