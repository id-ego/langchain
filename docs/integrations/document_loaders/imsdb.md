---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/imsdb/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/imsdb.ipynb
---

# IMSDb

> [IMSDb](https://imsdb.com/) is the `Internet Movie Script Database`.

This covers how to load `IMSDb` webpages into a document format that we can use downstream.

```python
<!--IMPORTS:[{"imported": "IMSDbLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.imsdb.IMSDbLoader.html", "title": "IMSDb"}]-->
from langchain_community.document_loaders import IMSDbLoader
```

```python
loader = IMSDbLoader("https://imsdb.com/scripts/BlacKkKlansman.html")
```

```python
data = loader.load()
```

```python
data[0].page_content[:500]
```

```output
'\n\r\n\r\n\r\n\r\n                                    BLACKKKLANSMAN\r\n                         \r\n                         \r\n                         \r\n                         \r\n                                      Written by\r\n\r\n                          Charlie Wachtel & David Rabinowitz\r\n\r\n                                         and\r\n\r\n                              Kevin Willmott & Spike Lee\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n                         FADE IN:\r\n                         \r\n          SCENE FROM "GONE WITH'
```

```python
data[0].metadata
```

```output
{'source': 'https://imsdb.com/scripts/BlacKkKlansman.html'}
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)