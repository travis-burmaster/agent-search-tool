# Agent Search — Installation Guide

## For Humans

Copy this to your AI Agent:

```
Install Agent Search: https://raw.githubusercontent.com/travis-burmaster/agent-search-tool/main/docs/install.md
```

> 🛡️ **Security-conscious?** Use safe mode — it won't auto-install system packages:
> ```
> Install Agent Search (safe mode): https://raw.githubusercontent.com/travis-burmaster/agent-search-tool/main/docs/install.md
> Install with the --safe flag
> ```

---

## For AI Agents

### Goal

Install Agent Search and all upstream tools so your user's agent has full internet access. After installation, you'll use the upstream tools directly (twitter-cli, rdt-cli, xhs-cli, yt-dlp, mcporter, gh CLI, etc.) — Agent Search is just the installer and health checker.

### ⚠️ Boundaries

When fixing issues, stay within these limits:

- **DO NOT** run commands with `sudo` unless the user explicitly approved
- **DO NOT** modify system files outside `~/.agent-search/`
- **DO NOT** install packages not listed in this guide
- **DO NOT** disable firewalls, security settings, or system protections
- **DO NOT** clone repos, create files, or run commands inside the agent workspace / working directory
- If something requires elevated permissions, **tell the user** what's needed and let them decide

### Step 1: Install the basics

```bash
# Recommended: pipx (easiest)
pipx install https://github.com/travis-burmaster/agent-search-tool/archive/main.zip
agent-search install --env=auto

# If your Python is from Homebrew or you hit PEP 668 (externally-managed-environment):
python3 -m venv ~/.agent-search-venv
source ~/.agent-search-venv/bin/activate
pip install https://github.com/travis-burmaster/agent-search-tool/archive/main.zip
agent-search install --env=auto
```

**Safe mode / Dry run:**

```bash
agent-search install --env=auto --safe      # Check only, no auto-install
agent-search install --env=auto --dry-run   # Preview what would be done
```

### Step 2: Ask the user which optional channels they want

After installing the basics, **ask the user** which additional channels they need:

> The core channels are ready! You can now search the web, watch YouTube, read GitHub, and more.
>
> Here are optional channels — which ones do you need?
>
> - 🐦 **Twitter/X** — search tweets and timelines (requires browser cookie)
> - 📰 **Weibo** — trending topics, search, user feeds
> - 💬 **WeChat Articles** — search and read official account posts
> - 📈 **Xueqiu** — stock quotes and hot posts (requires browser cookie)
> - 🎙️ **Xiaoyuzhou Podcast** — audio-to-text transcription (free Groq API key needed)
> - 📕 **XiaoHongShu** — read, search, and post (requires login)
> - 📖 **Reddit** — search and read posts
> - 📺 **Bilibili full access** — trending, rankings, search
> - 🎵 **Douyin** — video parsing
> - 💼 **LinkedIn** — profiles, company pages, job search
>
> Tell me which ones you want, e.g. "set up Weibo and Twitter" — or say "install all".

```bash
agent-search install --env=auto --channels=twitter,weibo   # user chose Twitter + Weibo
agent-search install --env=auto --channels=all              # user wants everything
```

Supported channel names: `twitter`, `weibo`, `wechat`, `xiaoyuzhou`, `xueqiu`, `xiaohongshu`, `reddit`, `bilibili`, `douyin`, `linkedin`, `all`

### Step 3: Fix what's broken

Run `agent-search doctor` and check the output. Try to get as many channels to ✅ as possible.

### Step 4: Configure channels that need user input

**Twitter/X search & posting:**
> "To unlock Twitter search, I need your Twitter cookies. Install the Cookie-Editor Chrome extension, go to x.com, click the extension → Export → Header String, and paste it here."

```bash
agent-search configure twitter-cookies "PASTED_STRING"
```

**Reddit & Bilibili (server users):**
> "Reddit and Bilibili block server IPs. To unlock full access, I need a residential proxy. You can get one at https://webshare.io ($1/month)."

```bash
agent-search configure proxy http://user:pass@ip:port
```

**XiaoHongShu:**
```bash
pipx install xiaohongshu-cli
xhs login
```

**Xueqiu (stock data):**
> "Xueqiu requires a browser cookie. Log in at xueqiu.com in Chrome, then run:"

```bash
agent-search configure --from-browser chrome
```

**Xiaoyuzhou Podcast (free Groq key):**
```bash
agent-search configure groq-key gsk_xxxxx
```

> Get a free Groq API key (no credit card) at https://console.groq.com → API Keys → Create

**Douyin:**
```bash
pip install douyin-mcp-server
mcporter config add douyin http://localhost:18070/mcp
```

**LinkedIn:**
```bash
pip install linkedin-scraper-mcp
linkedin-scraper-mcp --login --no-headless
linkedin-scraper-mcp --transport streamable-http --port 8001
mcporter config add linkedin http://localhost:8001/mcp
```

### Step 5: Final check

```bash
agent-search doctor
```

### Step 6: Set up daily monitoring (OpenClaw only)

If running inside **OpenClaw**, ask your user:

> "Agent Search is installed. Want me to set up a daily health check? It will monitor your channels for issues and new versions — only notifies you when something needs attention."

If yes, create a daily cron job (`sessionTarget: "isolated"`, `delivery: "announce"`) with this task:

```
Run agent-search watch.
If output contains "all OK", finish silently — do not notify user.
If output contains issues (❌ ⚠️) or a new version (🆕), send the full report to the user with suggested fixes.
If a new version is available, ask user whether to upgrade:
  pip install --upgrade https://github.com/travis-burmaster/agent-search-tool/archive/main.zip
```

---

## Quick Reference

| Command | What it does |
|---------|-------------|
| `agent-search install --env=auto` | Install core channels |
| `agent-search install --env=auto --channels=twitter,weibo` | Install specific optional channels |
| `agent-search install --env=auto --channels=all` | Install everything |
| `agent-search doctor` | Show channel status |
| `agent-search watch` | Quick health + update check |
| `agent-search configure twitter-cookies "..."` | Unlock Twitter |
| `agent-search configure proxy URL` | Unlock Reddit + Bilibili on servers |
| `agent-search configure groq-key gsk_xxx` | Unlock podcast transcription |

| Platform | Upstream Tool | Example |
|----------|--------------|---------|
| Twitter/X | `twitter` | `twitter search "query" -n 10` |
| YouTube | `yt-dlp` | `yt-dlp --dump-json URL` |
| Bilibili | `yt-dlp` | `bili hot` / `bili search "query"` |
| Reddit | `rdt` | `rdt search "query"` |
| GitHub | `gh` | `gh search repos "query"` |
| Web | Jina Reader | `curl -s "https://r.jina.ai/URL"` |
| Exa Search | `mcporter` | `mcporter call 'exa.web_search_exa(...)'` |
| XiaoHongShu | `mcporter` | `mcporter call 'xiaohongshu.search_feeds(...)'` |
| Weibo | `mcporter` | `mcporter call 'weibo.get_trendings(limit: 10)'` |
| Douyin | `mcporter` | `mcporter call 'douyin.parse_douyin_video_info(...)'` |
| LinkedIn | `mcporter` | `mcporter call 'linkedin.get_person_profile(...)'` |
