---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/mosaicml/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/mosaicml.ipynb
---

# MosaicML

>[MosaicML](https://docs.mosaicml.com/en/latest/inference.html) offers a managed inference service. You can either use a variety of open-source models, or deploy your own.

This example goes over how to use LangChain to interact with `MosaicML` Inference for text embedding.


```python
# sign up for an account: https://forms.mosaicml.com/demo?utm_source=langchain

from getpass import getpass

MOSAICML_API_TOKEN = getpass()
```


```python
import os

os.environ["MOSAICML_API_TOKEN"] = MOSAICML_API_TOKEN
```


```python
<!--IMPORTS:[{"imported": "MosaicMLInstructorEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.mosaicml.MosaicMLInstructorEmbeddings.html", "title": "MosaicML"}]-->
from langchain_community.embeddings import MosaicMLInstructorEmbeddings
```


```python
embeddings = MosaicMLInstructorEmbeddings(
    query_instruction="Represent the query for retrieval: "
)
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


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)