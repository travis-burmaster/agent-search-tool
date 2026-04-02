# Troubleshooting

## Xueqiu: API returns 400

**Symptom:** `agent-search doctor` shows Xueqiu ⚠️ with `HTTP Error 400`

**Cause:** Xueqiu's API requires a browser login cookie — anonymous access is not supported.

**Fix:** Log in at xueqiu.com in Chrome, then run:

```bash
agent-search configure --from-browser chrome
```

Run `agent-search doctor` again to confirm ✅. Re-run if the cookie expires.

---

## Twitter/X: twitter-cli connection failure

**Symptom:** `twitter search` or other commands return errors

**Cause:** twitter-cli requires AUTH_TOKEN and CT0 environment variables. If your network requires a proxy to reach x.com, you also need to configure one.

**Fix:**

### Option 1: Set proxy environment variables

```bash
export HTTP_PROXY="http://user:pass@host:port"
export HTTPS_PROXY="http://user:pass@host:port"
twitter search "test" -n 1
```

### Option 2: Use a global proxy tool

Let a proxy tool handle all traffic so twitter-cli requests go through it:

```bash
# macOS — enable "Enhanced Mode" in ClashX / Surge
# Linux — use proxychains or tun2socks
proxychains twitter search "test" -n 1
```

### Option 3: Use Exa search as a fallback

When twitter-cli is unavailable, use Exa to search Twitter content:

```bash
mcporter call 'exa.web_search_exa(query: "site:x.com search_term", numResults: 5)'
```

### Option 4: Check authentication

```bash
twitter check
```

> If it returns "Missing credentials", set the AUTH_TOKEN and CT0 environment variables.
>
> **Fallback:** If you have bird CLI installed (`npm install -g @steipete/bird`), it works too — Agent Search auto-detects installed tools.
