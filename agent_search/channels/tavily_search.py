# -*- coding: utf-8 -*-
"""Tavily Search — semantic web search via tavily-python SDK."""

from .base import Channel


class TavilySearchChannel(Channel):
    name = "tavily_search"
    description = "Tavily 语义搜索"
    backends = ["Tavily API"]
    tier = 0

    def can_handle(self, url: str) -> bool:
        return False  # Search-only channel

    def check(self, config=None):
        api_key = None
        if config:
            api_key = config.get("tavily_api_key")
        if not api_key:
            import os
            api_key = os.environ.get("TAVILY_API_KEY")

        if not api_key:
            return "off", (
                "需要 TAVILY_API_KEY。获取：\n"
                "  https://app.tavily.com（免费 1000 次/月）\n"
                "  然后设置环境变量 TAVILY_API_KEY 或运行 agent-search configure"
            )

        try:
            from tavily import TavilyClient  # noqa: F401
        except ImportError:
            return "off", (
                "需要 tavily-python 包。安装：\n"
                "  pip install tavily-python"
            )

        return "ok", "Tavily 语义搜索可用"
