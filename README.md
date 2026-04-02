<h1 align="center">🔍 Agent Search</h1>

<p align="center">
  <strong>Give your AI Agent instant access to the internet</strong>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="MIT License"></a>
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-3.10+-green.svg?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.10+"></a>
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

## Installation

```bash
pip install agent-search-tool
```

## Usage

```bash
# Check what's working
agent-search doctor

# Configure optional features
agent-search configure

# Search the web
agent-search search "latest LLM benchmarks 2026"

# Read a URL
agent-search read https://github.com/travis-burmaster/agent-search-tool
```

## Security

No hardcoded credentials. Cookies and API keys are stored in `~/.agent-search/config.yaml` with `0600` permissions (owner read/write only).

## License

MIT — Copyright (c) 2026 Travis Burmaster
