<h1 align="center">🔍 Agent Search</h1>

<p align="center">
  <strong>Give your AI Agent instant access to the internet</strong>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="MIT License"></a>
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-3.8+-green.svg?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.8+"></a>
  <a href="https://github.com/travis-burmaster/agent-search-tool/stargazers"><img src="https://img.shields.io/github/stars/travis-burmaster/agent-search-tool?style=for-the-badge" alt="GitHub Stars"></a>
</p>

---

## What is Agent Search?

Agent Search gives your AI agent the ability to search and read content from 10+ platforms — Twitter/X, Reddit, YouTube, GitHub, Bilibili, LinkedIn, web pages, and more — with a single install command.

**The problem it solves:**

| Pain Point | Reality |
|---|---|
| Twitter/X API | Paid, $215/mo for moderate use |
| Reddit | Server IPs get 403'd |
| YouTube transcripts | No official API |
| GitHub search | Auth required, rate limited |
| Web scraping | Returns raw HTML, not readable content |

Agent Search handles all of this transparently. Your agent calls a function, gets back clean readable text.

## Quick Start

Paste this into your AI agent (Claude Code, Cursor, OpenAI Assistants, etc.):

```
Install Agent Search: https://raw.githubusercontent.com/travis-burmaster/agent-search-tool/main/docs/install.md
```

## Installation

```bash
pip install agent-search-tool
```

## Supported Platforms

| Platform | Search | Read | Auth Required |
|---|---|---|---|
| Web | ✅ | ✅ | No |
| GitHub | ✅ | ✅ | Optional |
| Reddit | ✅ | ✅ | No |
| YouTube | ❌ | ✅ (transcript) | No |
| Twitter/X | ✅ | ✅ | Cookie |
| LinkedIn | ❌ | ✅ | Cookie |
| Bilibili | ✅ | ✅ | Cookie |
| Exa Search | ✅ | ✅ | API key |
| RSS | ❌ | ✅ | No |
| V2EX | ✅ | ✅ | No |

## Usage

```bash
# Check what's working
agent-search doctor

# Search the web
agent-search search "latest LLM benchmarks 2026"

# Configure optional channels
agent-search configure
```

## Setting Up Twitter/X

Twitter search requires browser cookies. Two ways to set it up:

**Option 1 — Auto-extract from your local browser (fastest):**
```bash
agent-search configure --from-browser chrome
```
Automatically pulls Twitter cookies from Chrome. Also works with Firefox, Edge, Brave.

**Option 2 — Manual via Cookie-Editor:**
1. Log into [x.com](https://x.com) in Chrome
2. Install the [Cookie-Editor](https://chromewebstore.google.com/detail/cookie-editor/hlkenndednhfkekhgcdicdfddnkalmdm) extension
3. Click the extension → **Export** → **Header String**
4. Run:
```bash
agent-search configure twitter-cookies "PASTE_COOKIE_STRING_HERE"
```

Once configured:
```bash
twitter search "AI agents 2026" -n 10
twitter read https://x.com/username/status/123456789
```

## Setting Up LinkedIn

LinkedIn uses cookie-based auth via browser automation:

**Option 1 — Auto-extract:**
```bash
agent-search configure --from-browser chrome
```

**Option 2 — Manual via Cookie-Editor:**
1. Log into [linkedin.com](https://linkedin.com) in Chrome
2. Cookie-Editor → Export → Header String
3. Run:
```bash
agent-search configure linkedin-cookies "PASTE_COOKIE_STRING_HERE"
```

## Setting Up Other Platforms

| Platform | Command |
|---|---|
| Reddit | Works out of the box — `rdt search "query"` |
| YouTube | Works out of the box — `yt-dlp --dump-json URL` |
| GitHub | Works out of the box — `gh repo view owner/repo` |
| Web | Works out of the box — `curl https://r.jina.ai/URL` |
| Exa Search | `agent-search configure exa-key YOUR_KEY` |
| Bilibili | `agent-search configure --from-browser chrome` |
| Xiaoyuzhou Podcast | `agent-search configure groq-key gsk_...` |

## Run a Health Check

```bash
agent-search doctor
```

Shows which channels are ready and exactly what to run to fix anything that isn't.

## Security

No hardcoded credentials. All cookies and API keys are stored in `~/.agent-search/config.yaml` with `0600` permissions (owner read/write only). Credentials never leave your machine.

## License

MIT — Copyright (c) 2026 Travis Burmaster
