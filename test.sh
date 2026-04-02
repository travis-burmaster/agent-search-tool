#!/bin/bash
# Agent Search
# : bash test-agent-search.sh
# Python 3.10+

set -e

echo "╔════════════════════════════════════════════╗"
echo ║ 👁️ Agent Search ║
echo "╚════════════════════════════════════════════╝"
echo ""

# ── 1. ──
echo 📦 ...
TEST_DIR=$(mktemp -d)
python3 -m venv "$TEST_DIR/venv"
source "$TEST_DIR/venv/bin/activate"

# ── 2. install ──
echo 📥 GitHub install...
pip install -q https://github.com/travis-burmaster/agent-search-tool/archive/main.zip 2>&1 | tail -1
echo ""

# ── 3. configure ──
echo "⚙️  Run install..."
agent-search install --env=auto 2>&1
echo ""

# ── 4. ──
echo "🩺 Run doctor..."
agent-search doctor 2>&1
echo ""

# ── 5. ──
PASS=0
FAIL=0
SKIP=0

test_it() {
    local name="$1"
    shift
    echo -n "  $name ... "
    output=$(eval "$@" 2>&1) || true
    if echo "$output" | grep -q "📖\|🔗\|http"; then
        echo "✅"
        PASS=$((PASS+1))
    elif echo "$output" | grep -q "⚠️\|not installed\|not configured"; then
 echo ⏭️ (Skipped — )
        SKIP=$((SKIP+1))
    else
        echo "❌"
        echo "    $(echo "$output" | head -2)"
        FAIL=$((FAIL+1))
    fi
}

echo 📖 
test_it agent-search read 'https://example.com'
test_it "GitHub" "agent-search read 'https://github.com/travis-burmaster/agent-search-tool'"
test_it "YouTube" "agent-search read 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'"
test_it "Bilibili" "agent-search read 'https://www.bilibili.com/video/BV1d4411N7zD'"
test_it "RSS" "agent-search read 'https://hnrss.org/frontpage'"
test_it "Twitter" "agent-search read 'https://x.com/elonmusk/status/1893797839927353448'"
test_it "Reddit" "agent-search read 'https://www.reddit.com/r/LocalLLaMA/hot'"

echo ""
echo 🔍 search
test_it search agent-search search 'best AI agent framework' -n 2
test_it "GitHubsearch" "agent-search search-github 'yt-dlp' -n 2"
test_it "Twittersearch" "agent-search search-twitter 'AI agent' -n 2"
test_it "Redditsearch" "agent-search search-reddit 'machine learning' -n 2"
test_it "YouTubesearch" "agent-search search-youtube 'AI tutorial' -n 2"
test_it "Bilibilisearch" "agent-search search-bilibili 'AI' -n 2"
test_it "XiaoHongShusearch" "agent-search search-xhs 'AI' -n 2"

echo ""
echo "════════════════════════════════════════════"
echo ✅ : $PASS ❌ Failed: $FAIL ⏭️ Skipped: $SKIP
echo "════════════════════════════════════════════"

# ── 6. ──
deactivate 2>/dev/null || true
rm -rf "$TEST_DIR"

if [ $FAIL -eq 0 ]; then
    echo ""
 echo 🎉 
else
    echo ""
 echo ⚠️ $FAIL Failed
    exit 1
fi
