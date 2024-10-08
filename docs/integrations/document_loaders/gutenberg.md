---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/gutenberg/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/gutenberg.ipynb
---

# Gutenberg

> [Project Gutenberg](https://www.gutenberg.org/about/) is an online library of free eBooks.

This notebook covers how to load links to `Gutenberg` e-books into a document format that we can use downstream.

```python
<!--IMPORTS:[{"imported": "GutenbergLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.gutenberg.GutenbergLoader.html", "title": "Gutenberg"}]-->
from langchain_community.document_loaders import GutenbergLoader
```

```python
loader = GutenbergLoader("https://www.gutenberg.org/cache/epub/69972/pg69972.txt")
```

```python
data = loader.load()
```

```python
data[0].page_content[:300]
```

```output
'The Project Gutenberg eBook of The changed brides, by Emma Dorothy\r\n\n\nEliza Nevitte Southworth\r\n\n\n\r\n\n\nThis eBook is for the use of anyone anywhere in the United States and\r\n\n\nmost other parts of the world at no cost and with almost no restrictions\r\n\n\nwhatsoever. You may copy it, give it away or re-u'
```

```python
data[0].metadata
```

```output
{'source': 'https://www.gutenberg.org/cache/epub/69972/pg69972.txt'}
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)