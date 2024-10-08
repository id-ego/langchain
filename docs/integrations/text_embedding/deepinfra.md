---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/deepinfra/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/deepinfra.ipynb
---

# DeepInfra

[DeepInfra](https://deepinfra.com/?utm_source=langchain) is a serverless inference as a service that provides access to a [variety of LLMs](https://deepinfra.com/models?utm_source=langchain) and [embeddings models](https://deepinfra.com/models?type=embeddings&utm_source=langchain). This notebook goes over how to use LangChain with DeepInfra for text embeddings.

```python
# sign up for an account: https://deepinfra.com/login?utm_source=langchain

from getpass import getpass

DEEPINFRA_API_TOKEN = getpass()
```
```output
 ········
```

```python
import os

os.environ["DEEPINFRA_API_TOKEN"] = DEEPINFRA_API_TOKEN
```

```python
<!--IMPORTS:[{"imported": "DeepInfraEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.deepinfra.DeepInfraEmbeddings.html", "title": "DeepInfra"}]-->
from langchain_community.embeddings import DeepInfraEmbeddings
```

```python
embeddings = DeepInfraEmbeddings(
    model_id="sentence-transformers/clip-ViT-B-32",
    query_instruction="",
    embed_instruction="",
)
```

```python
docs = ["Dog is not a cat", "Beta is the second letter of Greek alphabet"]
document_result = embeddings.embed_documents(docs)
```

```python
query = "What is the first letter of Greek alphabet"
query_result = embeddings.embed_query(query)
```

```python
import numpy as np

query_numpy = np.array(query_result)
for doc_res, doc in zip(document_result, docs):
    document_numpy = np.array(doc_res)
    similarity = np.dot(query_numpy, document_numpy) / (
        np.linalg.norm(query_numpy) * np.linalg.norm(document_numpy)
    )
    print(f'Cosine similarity between "{doc}" and query: {similarity}')
```
```output
Cosine similarity between "Dog is not a cat" and query: 0.7489097144129355
Cosine similarity between "Beta is the second letter of Greek alphabet" and query: 0.9519380640702013
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)