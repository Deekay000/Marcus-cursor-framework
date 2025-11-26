#!/bin/bash
# Quick test script for Marcus AI

echo "🧪 Testing Marcus AI System..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Health Check
echo "1️⃣  Testing health endpoint..."
HEALTH=$(curl -s http://localhost:8000/health)
if echo "$HEALTH" | grep -q "healthy"; then
    echo -e "${GREEN}✅ Health check passed${NC}"
else
    echo -e "${RED}❌ Health check failed${NC}"
    echo "$HEALTH"
    exit 1
fi
echo ""

# Test 2: Simple Message
echo "2️⃣  Testing chat endpoint..."
RESPONSE=$(curl -s -X POST http://localhost:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello Marcus, I need wisdom"}')

echo "$RESPONSE" | python3 -m json.tool

# Check if response has introspection fields
if echo "$RESPONSE" | grep -q "strategy_used"; then
    echo -e "\n${GREEN}✅ Introspection system working${NC}"
else
    echo -e "\n${RED}❌ Introspection system not working${NC}"
    exit 1
fi

# Check if LLM responded (not error message)
if echo "$RESPONSE" | grep -q "trouble thinking clearly"; then
    echo -e "${YELLOW}⚠️  LLM error - check OpenAI API key in .env${NC}"
    exit 1
else
    echo -e "${GREEN}✅ LLM generating responses${NC}"
fi

echo ""
echo "3️⃣  Testing crisis detection..."
CRISIS_RESPONSE=$(curl -s -X POST http://localhost:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"content": "I cant handle this anymore. Everything is falling apart."}')

STRATEGY=$(echo "$CRISIS_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('strategy_used', 'none'))")
echo "Strategy selected for crisis: $STRATEGY"

if [ "$STRATEGY" = "supportive" ] || [ "$STRATEGY" = "balanced" ]; then
    echo -e "${GREEN}✅ Appropriate strategy for crisis${NC}"
else
    echo -e "${YELLOW}⚠️  Strategy: $STRATEGY (expected supportive/balanced)${NC}"
fi

echo ""
echo "✨ All tests complete!"
