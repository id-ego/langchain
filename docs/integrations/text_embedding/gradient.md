---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/gradient/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/gradient.ipynb
---

# Gradient

`Gradient` allows to create `Embeddings` as well fine tune and get completions on LLMs with a simple web API.

This notebook goes over how to use Langchain with Embeddings of [Gradient](https://gradient.ai/).

## Imports

```python
<!--IMPORTS:[{"imported": "GradientEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.gradient_ai.GradientEmbeddings.html", "title": "Gradient"}]-->
from langchain_community.embeddings import GradientEmbeddings
```

## Set the Environment API Key
Make sure to get your API key from Gradient AI. You are given $10 in free credits to test and fine-tune different models.

```python
import os
from getpass import getpass

if not os.environ.get("GRADIENT_ACCESS_TOKEN", None):
    # Access token under https://auth.gradient.ai/select-workspace
    os.environ["GRADIENT_ACCESS_TOKEN"] = getpass("gradient.ai access token:")
if not os.environ.get("GRADIENT_WORKSPACE_ID", None):
    # `ID` listed in `$ gradient workspace list`
    # also displayed after login at at https://auth.gradient.ai/select-workspace
    os.environ["GRADIENT_WORKSPACE_ID"] = getpass("gradient.ai workspace id:")
```

Optional: Validate your environment variables `GRADIENT_ACCESS_TOKEN` and `GRADIENT_WORKSPACE_ID` to get currently deployed models. Using the `gradientai` Python package.

```python
%pip install --upgrade --quiet  gradientai
```

## Create the Gradient instance

```python
documents = [
    "Pizza is a dish.",
    "Paris is the capital of France",
    "numpy is a lib for linear algebra",
]
query = "Where is Paris?"
```

```python
embeddings = GradientEmbeddings(model="bge-large")

documents_embedded = embeddings.embed_documents(documents)
query_result = embeddings.embed_query(query)
```

```python
# (demo) compute similarity
import numpy as np

scores = np.array(documents_embedded) @ np.array(query_result).T
dict(zip(documents, scores))
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)