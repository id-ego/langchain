---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/minimax/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/minimax.ipynb
---

# MiniMax

[MiniMax](https://api.minimax.chat/document/guides/embeddings?id=6464722084cdc277dfaa966a) offers an embeddings service.

This example goes over how to use LangChain to interact with MiniMax Inference for text embedding.

```python
import os

os.environ["MINIMAX_GROUP_ID"] = "MINIMAX_GROUP_ID"
os.environ["MINIMAX_API_KEY"] = "MINIMAX_API_KEY"
```

```python
<!--IMPORTS:[{"imported": "MiniMaxEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.minimax.MiniMaxEmbeddings.html", "title": "MiniMax"}]-->
from langchain_community.embeddings import MiniMaxEmbeddings
```

```python
embeddings = MiniMaxEmbeddings()
```

```python
query_text = "This is a test query."
query_result = embeddings.embed_query(query_text)
```

```python
document_text = "This is a test document."
document_result = embeddings.embed_documents([document_text])
```

```python
import numpy as np

query_numpy = np.array(query_result)
document_numpy = np.array(document_result[0])
similarity = np.dot(query_numpy, document_numpy) / (
    np.linalg.norm(query_numpy) * np.linalg.norm(document_numpy)
)
print(f"Cosine similarity between document and query: {similarity}")
```
```output
Cosine similarity between document and query: 0.1573236279277012
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)