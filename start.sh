#!/bin/bash
set -e
cd "$(dirname "$0")"

cleanup() {
    echo "\n🛑 Shutting down..."
    if [ -n "$SERVER_PID" ]; then
        kill $SERVER_PID 2>/dev/null || true
        wait $SERVER_PID 2>/dev/null || true
    fi
    exit 0
}
trap cleanup SIGTERM SIGINT

echo "🚀 Starting Outbound Mass Caller..."

# Only load .env if file exists AND we're NOT in a container (no Coolify/Docker env)
# In production (Coolify/Docker), env vars are set directly — .env is for dev only
if [ -f ".env" ] && [ -z "${COOLIFY_CONTAINER_ID:-}" ] && [ -z "${DOCKER_HOST:-}" ]; then
    echo "📄 Loading .env file (dev mode)..."
    set -a
    source .env
    set +a
fi

echo "📋 Configuration:"
echo "   LiveKit: ${LIVEKIT_URL:-(not set)}"
echo "   Gemini: ${GEMINI_MODEL:-gemini-3.1-flash-live-preview}"
echo "   Supabase: ${SUPABASE_URL:-(not set)}"

echo "🌐 Starting FastAPI server on port 8000..."
uvicorn server:app --host 0.0.0.0 --port 8000 &
SERVER_PID=$!

sleep 2

echo "🤖 Starting LiveKit agent worker..."
python agent.py start &
AGENT_PID=$!

# Wait for either process to exit
wait -n $SERVER_PID $AGENT_PID 2>/dev/null || true
kill $SERVER_PID $AGENT_PID 2>/dev/null || true
wait 2>/dev/null || true
