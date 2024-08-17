---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/youtube/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/youtube.ipynb
---

# YouTube

> [YouTube Search](https://github.com/joetats/youtube_search) package searches `YouTube` videos avoiding using their heavily rate-limited API.
> 
> It uses the form on the `YouTube` homepage and scrapes the resulting page.

This notebook shows how to use a tool to search YouTube.

Adapted from [https://github.com/venuv/langchain_yt_tools](https://github.com/venuv/langchain_yt_tools)

```python
%pip install --upgrade --quiet  youtube_search
```

```python
<!--IMPORTS:[{"imported": "YouTubeSearchTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.youtube.search.YouTubeSearchTool.html", "title": "YouTube"}]-->
from langchain_community.tools import YouTubeSearchTool
```

```python
tool = YouTubeSearchTool()
```

```python
tool.run("lex fridman")
```

```output
"['/watch?v=VcVfceTsD0A&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=gPfriiHBBek&pp=ygUMbGV4IGZyaWVkbWFu']"
```

You can also specify the number of results that are returned

```python
tool.run("lex friedman,5")
```

```output
"['/watch?v=VcVfceTsD0A&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=YVJ8gTnDC4Y&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=Udh22kuLebg&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=gPfriiHBBek&pp=ygUMbGV4IGZyaWVkbWFu', '/watch?v=L_Guz73e6fw&pp=ygUMbGV4IGZyaWVkbWFu']"
```

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)