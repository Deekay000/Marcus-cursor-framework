# Execute Measurement & Validation Framework

## Current Status

✅ **Phase**: CONSTRUCT
✅ **Status**: EXECUTING_MEASUREMENT_FRAMEWORK  
✅ **Task**: Step 1 - Generate Baselines

---

## ⚡ Quick Start (5 Minutes)

Open your terminal and run:

```bash
cd /Users/admin/Downloads/marcus-cursor-framework

# 1. Check your environment
chmod +x check_env.sh
./check_env.sh

# 2. Add Anthropic API key (if you have one)
echo 'ANTHROPIC_API_KEY=sk-ant-your-key-here' >> .env

# 3. Run baseline generation
chmod +x run_baseline_generation.sh
./run_baseline_generation.sh
```

**That's it!** The script will:
- Install missing dependencies
- Start Marcus API if needed
- Generate 50 baseline responses from Marcus, GPT-4, and Claude
- Save results to `/Users/admin/Downloads/files/baseline_responses_50.json`

---

## 📋 Complete Workflow

### Step 1: Generate Baselines (TODAY)

**What it does**: Generates responses from Marcus, GPT-4, and Claude for all 50 test scenarios.

**Time**: 5-10 minutes

**Commands**:
```bash
cd /Users/admin/Downloads/marcus-cursor-framework
./run_baseline_generation.sh
```

**Output**: `/Users/admin/Downloads/files/baseline_responses_50.json`

**Success Criteria**:
- ✅ 50 scenarios processed
- ✅ All models responded (or gracefully handled errors)
- ✅ JSON file created and valid

---

### Step 2: Human Evaluation (NEXT - Requires 3 Raters)

**What it does**: 3 independent raters assess response quality across 5 dimensions.

**Time**: 2-3 hours per rater

**Commands**:
1. Open `/Users/admin/Downloads/files/rating_interface.html` in browser
2. Load `baseline_responses_50.json`
3. Rate all 50 scenarios (blind, randomized)
4. Export ratings to `ratings_rater1.json`, `ratings_rater2.json`, `ratings_rater3.json`

**Success Criteria**:
- ✅ 3 complete rating files
- ✅ All 50 scenarios rated by all 3 raters
- ✅ High inter-rater reliability (Fleiss' Kappa > 0.6)

---

### Step 3: Analyze Results (AFTER RATINGS)

**What it does**: Computes consensus scores and decision gate verdict.

**Time**: < 1 minute

**Commands**:
```bash
cd /Users/admin/Downloads/files
python analyze_ratings.py \
    --baselines baseline_responses_50.json \
    --ratings ratings_rater1.json ratings_rater2.json ratings_rater3.json \
    --output decision_report.json
```

**Output**: 
- `decision_report.json` (full analysis)
- Decision gate: PASS or NEEDS_IMPROVEMENT

**Success Criteria**:
- ✅ Marcus scores within 10% of best baseline on key dimensions
- ✅ No safety-critical failures
- ✅ Stoic authenticity score > 4.0/5.0

---

### Step 4: Ongoing Monitoring

**What it does**: Tracks Marcus quality over time as you iterate.

**Commands**:
```bash
cd /Users/admin/Downloads/files
python metrics_tracker.py --baseline baseline_responses_50.json
```

**Use**: Run after any changes to Marcus to measure impact.

---

## 🚨 Prerequisites

Before running `run_baseline_generation.sh`, ensure:

### 1. API Keys

**Required**:
- ✅ `OPENAI_API_KEY` in `.env` (already configured)

**Optional but Recommended**:
- ⚠️ `ANTHROPIC_API_KEY` in `.env` (for Claude comparison)
  - Get key from: https://console.anthropic.com/settings/keys
  - Add to `.env`: `echo 'ANTHROPIC_API_KEY=sk-ant-...' >> .env`

### 2. Python Environment

```bash
source .venv/bin/activate
pip install openai anthropic httpx python-dotenv --break-system-packages
```

### 3. Marcus API Server

The script will auto-start it if not running. Or start manually:

```bash
cd /Users/admin/Downloads/marcus-cursor-framework
source .venv/bin/activate
uvicorn src.api.main:app --host 0.0.0.0 --port 8000
```

Check health: `curl http://localhost:8000/health`

---

## 🐛 Troubleshooting

### Error: "OPENAI_API_KEY not found"

**Fix**: 
```bash
echo 'OPENAI_API_KEY=sk-proj-...' >> .env
```

### Error: "Marcus API not responding"

**Check logs**:
```bash
tail -50 /tmp/marcus_server.log
```

**Common issue**: PyTorch 2.6 warning (safe to ignore, falls back to keyword-based sentiment)

**Manual start**:
```bash
cd /Users/admin/Downloads/marcus-cursor-framework
source .venv/bin/activate
uvicorn src.api.main:app --host 0.0.0.0 --port 8000
```

### Error: "Module not found"

**Fix**:
```bash
source .venv/bin/activate
pip install openai anthropic httpx python-dotenv --break-system-packages
```

### Script won't run (permission denied)

**Fix**:
```bash
chmod +x run_baseline_generation.sh check_env.sh
```

---

## 📊 Expected Results

After Step 1 completes, you'll have:

```json
{
  "generated_at": "2025-11-25T23:00:00",
  "models": {
    "marcus": "Marcus (local API)",
    "gpt4": "GPT-4 (baseline)",
    "gpt4_stoic": "GPT-4 (with Stoic prompt)",
    "claude": "Claude 3.5 Sonnet"
  },
  "responses": {
    "PHIL-001": {
      "scenario": "What would Marcus Aurelius say about...",
      "marcus": "Response from Marcus...",
      "gpt4": "Response from GPT-4...",
      "gpt4_stoic": "Response from GPT-4 with Stoic prompt...",
      "claude": "Response from Claude..."
    },
    ...
  }
}
```

You can inspect this file to see how Marcus compares even before human evaluation.

---

## 🎯 Success Indicators

After completing all 3 steps, you'll know:

1. **Is Marcus competitive?** (within 10% of best LLM)
2. **Where does Marcus excel?** (e.g., Stoic authenticity)
3. **Where does Marcus need work?** (e.g., empathy, clarity)
4. **Is Marcus safe?** (crisis scenarios handled correctly)

This is **objective, empirical data** - not guesswork.

---

## 🔮 What's Next After Framework

Once you have decision gate results:

**IF PASS**:
- Proceed to MVP deployment
- Continue to Path B data collection (Reddit) for continuous improvement
- Build visual avatar (MetaHuman, FLAME, Unreal)

**IF NEEDS_IMPROVEMENT**:
- Iterate on dialogue generation
- Adjust mental model selection
- Re-test with framework (fast turnaround)

---

## 📞 Need Help?

Check logs:
- Marcus API: `/tmp/marcus_server.log`
- Script output: Terminal

Files:
- Test corpus: `/Users/admin/Downloads/files/test_corpus_50.json`
- Generator: `/Users/admin/Downloads/files/generate_baselines.py`
- Guide: `/Users/admin/Downloads/files/README.md`

---

**You're ready to measure Marcus with world-class rigor.** 🚀
