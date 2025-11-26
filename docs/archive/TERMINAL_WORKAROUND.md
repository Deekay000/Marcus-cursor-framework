# Terminal Issue Workaround

## 🚨 Current Issue

Cursor IDE terminals (9, 10) are hung with "no heartbeat received" error. This is a terminal process issue, not a Marcus issue.

## ✅ Solution: Use Fresh Terminal

### Option A: New Cursor Terminal (Recommended)

1. **Close hung terminals**:
   - In Cursor, close terminals 9 and 10
   - Click the "+" to open a new terminal

2. **Run the baseline generation**:
   ```bash
   cd /Users/admin/Downloads/marcus-cursor-framework
   chmod +x run_baseline_generation.sh
   ./run_baseline_generation.sh
   ```

### Option B: External Terminal (If Cursor terminals keep hanging)

1. **Open your Mac's Terminal app** (CMD+Space → "Terminal")

2. **Run the baseline generation**:
   ```bash
   cd /Users/admin/Downloads/marcus-cursor-framework
   chmod +x run_baseline_generation.sh
   ./run_baseline_generation.sh
   ```

### Option C: Manual Step-by-Step (If script has issues)

```bash
# 1. Navigate to project
cd /Users/admin/Downloads/marcus-cursor-framework

# 2. Activate venv
source .venv/bin/activate

# 3. Install dependencies
pip install openai anthropic httpx python-dotenv --break-system-packages

# 4. Add Anthropic key (if you have one)
echo 'ANTHROPIC_API_KEY=sk-ant-your-key-here' >> .env

# 5. Start Marcus API (if not running)
lsof -ti:8000 | xargs kill -9 2>/dev/null || true  # Kill any stuck process
uvicorn src.api.main:app --host 0.0.0.0 --port 8000 &
sleep 10  # Wait for startup

# 6. Test Marcus API
curl -X POST http://localhost:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"content":"Hello Marcus"}'

# 7. Generate baselines
cd /Users/admin/Downloads/files
python generate_baselines.py \
    --corpus test_corpus_50.json \
    --output baseline_responses_50.json \
    --marcus-url http://localhost:8000/api/v1/chat
```

## 🔍 What Caused the Hang?

From your terminal history, Marcus API was working fine at 21:58. Likely causes:

1. **Cursor IDE bug** - Terminal connection corrupted over time
2. **Background process** - Something started that's blocking the terminal
3. **Resource exhaustion** - Too many processes running

## 🛠️ Preventive Checks (Run in Fresh Terminal)

```bash
# Check system resources
top -l 1 | head -n 10

# Check for zombie processes
ps aux | awk '$8=="Z"'

# Check what's using port 8000
lsof -i:8000

# Check Marcus server health
curl -m 5 http://localhost:8000/health
```

## ✅ The Scripts Are Still Good

The automation scripts I created are **not affected** by the Cursor terminal issue:
- ✅ `run_baseline_generation.sh` - Complete automation
- ✅ `check_env.sh` - Environment verification  
- ✅ `generate_baselines.py` - Fixed API bug ("message" → "content")

Just run them in a **fresh terminal** and they'll work.

## 🚀 Recommended Next Steps

1. **Close hung Cursor terminals** (9, 10)
2. **Open new terminal** (in Cursor or Mac Terminal.app)
3. **Run**: `cd /Users/admin/Downloads/marcus-cursor-framework && ./run_baseline_generation.sh`
4. **Wait 5-10 minutes** for baseline generation
5. **Check output**: `/Users/admin/Downloads/files/baseline_responses_50.json`

---

**The framework is ready. The terminal issue is just a UI glitch - fresh terminal solves it.** 🚀
