#!/bin/bash
# ============================================================================
# Marcus Baseline Generation - Complete Workflow
# ============================================================================
# This script executes Step 1 of the Measurement & Validation Framework

set -e  # Exit on error

echo "🚀 Marcus Baseline Generation Workflow"
echo "========================================"
echo ""

# Navigate to project directory
cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)"
EVAL_DIR="/Users/admin/Downloads/files"

# Step 1: Check/Install Dependencies
echo "📦 Step 1: Checking dependencies..."
source .venv/bin/activate

# Check if packages are installed
if ! python -c "import openai" 2>/dev/null; then
    echo "  Installing openai..."
    pip install openai --break-system-packages -q
fi

if ! python -c "import anthropic" 2>/dev/null; then
    echo "  Installing anthropic..."
    pip install anthropic --break-system-packages -q
fi

if ! python -c "import httpx" 2>/dev/null; then
    echo "  Installing httpx..."
    pip install httpx --break-system-packages -q
fi

if ! python -c "import dotenv" 2>/dev/null; then
    echo "  Installing python-dotenv..."
    pip install python-dotenv --break-system-packages -q
fi

echo "  ✅ All dependencies installed"
echo ""

# Step 2: Check API Keys
echo "🔑 Step 2: Checking API keys..."
source .env

if [ -z "$OPENAI_API_KEY" ]; then
    echo "  ❌ ERROR: OPENAI_API_KEY not found in .env"
    exit 1
fi
echo "  ✅ OpenAI API key found"

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "  ⚠️  WARNING: ANTHROPIC_API_KEY not found in .env"
    echo "  To add it, run: echo 'ANTHROPIC_API_KEY=sk-ant-...' >> .env"
    echo "  Get your key from: https://console.anthropic.com/settings/keys"
    echo ""
    read -p "  Do you want to continue without Claude comparison? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""

# Step 3: Start Marcus API Server (if not running)
echo "🖥️  Step 3: Checking Marcus API server..."

if ! curl -s -m 2 http://localhost:8000/health > /dev/null 2>&1; then
    echo "  Marcus API not running. Starting it now..."
    echo "  This will run in the background. Logs at: /tmp/marcus_server.log"
    
    # Kill any existing server on port 8000
    lsof -ti:8000 | xargs kill -9 2>/dev/null || true
    sleep 2
    
    # Start server in background
    nohup python -m uvicorn src.api.main:app --host 0.0.0.0 --port 8000 > /tmp/marcus_server.log 2>&1 &
    SERVER_PID=$!
    echo "  Server starting (PID: $SERVER_PID)..."
    
    # Wait for server to be ready (max 30 seconds)
    echo -n "  Waiting for server to be ready"
    for i in {1..30}; do
        if curl -s -m 2 http://localhost:8000/health > /dev/null 2>&1; then
            echo " ✅"
            break
        fi
        echo -n "."
        sleep 1
    done
    
    if ! curl -s -m 2 http://localhost:8000/health > /dev/null 2>&1; then
        echo " ❌"
        echo "  ERROR: Server failed to start. Check logs at /tmp/marcus_server.log"
        tail -20 /tmp/marcus_server.log
        exit 1
    fi
else
    echo "  ✅ Marcus API is running"
fi

echo ""

# Step 4: Generate Baselines
echo "🎯 Step 4: Generating baseline responses..."
echo "  This will query 50 scenarios across:"
echo "  - Marcus (local API)"
echo "  - GPT-4 (with and without Stoic prompt)"
if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "  - Claude 3.5 Sonnet"
fi
echo ""
echo "  Expected duration: 5-10 minutes"
echo "  Output: ${EVAL_DIR}/baseline_responses_50.json"
echo ""

python "${EVAL_DIR}/generate_baselines.py" \
    --corpus "${EVAL_DIR}/test_corpus_50.json" \
    --output "${EVAL_DIR}/baseline_responses_50.json" \
    --marcus-url "http://localhost:8000/api/v1/chat"

echo ""
echo "✅ BASELINE GENERATION COMPLETE"
echo "========================================"
echo ""
echo "📊 Results saved to: ${EVAL_DIR}/baseline_responses_50.json"
echo ""
echo "📋 Next Steps:"
echo "  1. Open ${EVAL_DIR}/rating_interface.html in your browser"
echo "  2. Load baseline_responses_50.json"
echo "  3. Have 3 raters evaluate all 50 scenarios (blind, randomized)"
echo "  4. Run: python ${EVAL_DIR}/analyze_ratings.py"
echo ""
echo "🎉 You're on your way to world-class AI measurement!"
