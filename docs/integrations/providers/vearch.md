---
canonical: https://python.langchain.com/v0.2/docs/integrations/providers/vearch/
---

# Vearch

[Vearch](https://github.com/vearch/vearch) is a scalable distributed system for efficient similarity search of deep learning vectors.

# Installation and Setup

Vearch Python SDK enables vearch to use locally. Vearch python sdk can be installed easily by pip install vearch.

# Vectorstore

Vearch also can used as vectorstore. Most details in [this notebook](/docs/integrations/vectorstores/vearch)

```python
<!--IMPORTS:[{"imported": "Vearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vearch.Vearch.html", "title": "Vearch"}]-->
from langchain_community.vectorstores import Vearch
```