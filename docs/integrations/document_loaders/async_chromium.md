---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/async_chromium/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/async_chromium.ipynb
---

# Async Chromium

Chromium is one of the browsers supported by Playwright, a library used to control browser automation. 

By running `p.chromium.launch(headless=True)`, we are launching a headless instance of Chromium. 

Headless mode means that the browser is running without a graphical user interface.

In the below example we'll use the `AsyncChromiumLoader` to loads the page, and then the [`Html2TextTransformer`](/docs/integrations/document_transformers/html2text/) to strip out the HTML tags and other semantic information.

```python
%pip install --upgrade --quiet playwright beautifulsoup4 html2text
!playwright install
```

**Note:** If you are using Jupyter notebooks, you might also need to install and apply `nest_asyncio` before loading the documents like this:

```python
!pip install nest-asyncio
import nest_asyncio

nest_asyncio.apply()
```

```python
<!--IMPORTS:[{"imported": "AsyncChromiumLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.chromium.AsyncChromiumLoader.html", "title": "Async Chromium"}]-->
from langchain_community.document_loaders import AsyncChromiumLoader

urls = ["https://docs.smith.langchain.com/"]
loader = AsyncChromiumLoader(urls, user_agent="MyAppUserAgent")
docs = loader.load()
docs[0].page_content[0:100]
```

```output
'<!DOCTYPE html><html lang="en" dir="ltr" class="docs-wrapper docs-doc-page docs-version-2.0 plugin-d'
```

Now let's transform the documents into a more readable syntax using the transformer:

```python
<!--IMPORTS:[{"imported": "Html2TextTransformer", "source": "langchain_community.document_transformers", "docs": "https://api.python.langchain.com/en/latest/document_transformers/langchain_community.document_transformers.html2text.Html2TextTransformer.html", "title": "Async Chromium"}]-->
from langchain_community.document_transformers import Html2TextTransformer

html2text = Html2TextTransformer()
docs_transformed = html2text.transform_documents(docs)
docs_transformed[0].page_content[0:500]
```

```output
'Skip to main content\n\nGo to API Docs\n\nSearch`⌘``K`\n\nGo to App\n\n  * Quick start\n  * Tutorials\n\n  * How-to guides\n\n  * Concepts\n\n  * Reference\n\n  * Pricing\n  * Self-hosting\n\n  * LangGraph Cloud\n\n  *   * Quick start\n\nOn this page\n\n# Get started with LangSmith\n\n**LangSmith** is a platform for building production-grade LLM applications. It\nallows you to closely monitor and evaluate your application, so you can ship\nquickly and with confidence. Use of LangChain is not necessary - LangSmith\nworks on it'
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)