#!/bin/bash
# Quick test of Marcus AI (keyword-based sentiment)

echo "=========================================="
echo "Testing Marcus AI"
echo "=========================================="
echo ""

# Kill old server
echo "1. Restarting server..."
pkill -9 -f "uvicorn.*marcus" 2>/dev/null
sleep 2

# Start server
cd /Users/admin/Downloads/marcus-cursor-framework
python -m uvicorn src.api.main:app --host 0.0.0.0 --port 8000 > /tmp/marcus_server.log 2>&1 &
SERVER_PID=$!

echo "   Server starting (PID: $SERVER_PID)..."
sleep 5

# Test connection
echo ""
echo "2. Testing Marcus..."
echo ""

curl --max-time 10 -X POST http://localhost:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"content":"I feel overwhelmed and lost"}' \
  2>/dev/null | python3 -m json.tool

echo ""
echo ""
echo "=========================================="
echo "✓ Test complete"
echo "=========================================="
echo ""
echo "Server running on: http://localhost:8000"
echo "Server PID: $SERVER_PID"
echo "Logs: tail -f /tmp/marcus_server.log"
