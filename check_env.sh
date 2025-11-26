#!/bin/bash
# Quick environment check for Marcus baseline generation

echo "🔍 Marcus Environment Check"
echo "==========================="
echo ""

cd "$(dirname "$0")"

# Check Python
echo "Python:"
python3 --version || echo "  ❌ Python not found"
echo ""

# Check venv
echo "Virtual Environment:"
if [ -d ".venv" ]; then
    echo "  ✅ .venv exists"
    source .venv/bin/activate
    echo "  Python path: $(which python)"
else
    echo "  ❌ .venv not found"
fi
echo ""

# Check .env file
echo "Environment Variables:"
if [ -f ".env" ]; then
    echo "  ✅ .env exists"
    
    if grep -q "OPENAI_API_KEY=sk-" .env; then
        echo "  ✅ OPENAI_API_KEY configured"
    else
        echo "  ❌ OPENAI_API_KEY missing or invalid"
    fi
    
    if grep -q "ANTHROPIC_API_KEY" .env; then
        echo "  ✅ ANTHROPIC_API_KEY configured"
    else
        echo "  ⚠️  ANTHROPIC_API_KEY not found (optional)"
    fi
else
    echo "  ❌ .env not found"
fi
echo ""

# Check Marcus API
echo "Marcus API Server:"
if curl -s -m 2 http://localhost:8000/health > /dev/null 2>&1; then
    echo "  ✅ Running on http://localhost:8000"
else
    echo "  ❌ Not running on http://localhost:8000"
    echo "     To start: uvicorn src.api.main:app --host 0.0.0.0 --port 8000"
fi
echo ""

# Check framework files
echo "Measurement Framework Files:"
EVAL_DIR="/Users/admin/Downloads/files"
for file in "test_corpus_50.json" "generate_baselines.py" "rating_interface.html" "analyze_ratings.py"; do
    if [ -f "${EVAL_DIR}/${file}" ]; then
        echo "  ✅ ${file}"
    else
        echo "  ❌ ${file} missing"
    fi
done
echo ""

# Check Python packages
echo "Python Dependencies:"
for pkg in "openai" "anthropic" "httpx" "dotenv"; do
    if python -c "import ${pkg}" 2>/dev/null; then
        echo "  ✅ ${pkg}"
    else
        echo "  ❌ ${pkg} (install with: pip install ${pkg})"
    fi
done
echo ""

echo "==========================="
echo "✅ = Ready | ❌ = Needs attention | ⚠️ = Optional"
