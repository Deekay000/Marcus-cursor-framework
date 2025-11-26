#!/bin/bash
# Setup script for Reddit data collection

echo "=========================================="
echo "Reddit Data Collection - Setup"
echo "=========================================="
echo ""

# Check Python version
echo "1. Checking Python version..."
python_version=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
echo "   ✓ Python $python_version"

# Install dependencies
echo ""
echo "2. Installing dependencies..."
pip install praw pandas pyarrow python-dotenv --quiet
echo "   ✓ Packages installed"

# Check .env file
echo ""
echo "3. Checking .env configuration..."
if [ -f ".env" ]; then
    if grep -q "REDDIT_CLIENT_ID" .env && grep -q "REDDIT_CLIENT_SECRET" .env; then
        echo "   ✓ Reddit credentials found in .env"
    else
        echo "   ⚠️  Reddit credentials not found in .env"
        echo ""
        echo "   To add them:"
        echo "   1. Go to: https://www.reddit.com/prefs/apps"
        echo "   2. Click 'Create App'"
        echo "   3. Fill out form (type: script)"
        echo "   4. Add to .env:"
        echo "      REDDIT_CLIENT_ID=your_client_id"
        echo "      REDDIT_CLIENT_SECRET=your_secret"
    fi
else
    echo "   ⚠️  .env file not found"
    echo "   Creating from .env.example..."
    cp .env.example .env
    echo "   ✓ Created .env (add Reddit credentials)"
fi

# Create evaluation directory
echo ""
echo "4. Creating evaluation directory..."
mkdir -p evaluation
echo "   ✓ evaluation/ directory ready"

# Make scripts executable
echo ""
echo "5. Making scripts executable..."
chmod +x scripts/collect_reddit_data.py
echo "   ✓ Scripts are executable"

# Test API connection (if credentials exist)
echo ""
echo "6. Testing API connection..."
if grep -q "REDDIT_CLIENT_ID=your" .env 2>/dev/null || ! grep -q "REDDIT_CLIENT_ID" .env 2>/dev/null; then
    echo "   ⚠️  Skipped (add credentials first)"
else
    python3 << 'EOF'
import os
import sys
from dotenv import load_dotenv
load_dotenv()

try:
    import praw
    client_id = os.getenv('REDDIT_CLIENT_ID')
    client_secret = os.getenv('REDDIT_CLIENT_SECRET')
    
    if not client_id or not client_secret:
        print("   ⚠️  Credentials not configured")
        sys.exit(0)
    
    reddit = praw.Reddit(
        client_id=client_id,
        client_secret=client_secret,
        user_agent='Marcus AI Test'
    )
    
    # Test connection
    subreddit = reddit.subreddit('stoicism')
    subscribers = subreddit.subscribers
    
    print(f"   ✓ Connected to Reddit API")
    print(f"   ✓ Test subreddit: r/stoicism ({subscribers:,} subscribers)")
except Exception as e:
    print(f"   ✗ Connection failed: {e}")
EOF
fi

echo ""
echo "=========================================="
echo "✓ Setup complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Add Reddit credentials to .env (if not done)"
echo "2. Run test collection:"
echo "   python scripts/collect_reddit_data.py --test"
echo ""
echo "Full guide: evaluation/README_REDDIT_COLLECTION.md"
