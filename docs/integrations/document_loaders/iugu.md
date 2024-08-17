---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/iugu/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/iugu.ipynb
---

# Iugu

> [Iugu](https://www.iugu.com/) is a Brazilian services and software as a service (SaaS) company. It offers payment-processing software and application programming interfaces for e-commerce websites and mobile applications.

This notebook covers how to load data from the `Iugu REST API` into a format that can be ingested into LangChain, along with example usage for vectorization.

```python
<!--IMPORTS:[{"imported": "VectorstoreIndexCreator", "source": "langchain.indexes", "docs": "https://api.python.langchain.com/en/latest/indexes/langchain.indexes.vectorstore.VectorstoreIndexCreator.html", "title": "Iugu"}, {"imported": "IuguLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.iugu.IuguLoader.html", "title": "Iugu"}]-->
from langchain.indexes import VectorstoreIndexCreator
from langchain_community.document_loaders import IuguLoader
```

The Iugu API requires an access token, which can be found inside of the Iugu dashboard.

This document loader also requires a `resource` option which defines what data you want to load.

Following resources are available:

`Documentation` [Documentation](https://dev.iugu.com/reference/metadados)

```python
iugu_loader = IuguLoader("charges")
```

```python
# Create a vectorstore retriever from the loader
# see https://python.langchain.com/en/latest/modules/data_connection/getting_started.html for more details

index = VectorstoreIndexCreator().from_loaders([iugu_loader])
iugu_doc_retriever = index.vectorstore.as_retriever()
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)