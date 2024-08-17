---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/google_generative_ai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/google_generative_ai.ipynb
---

# Google Generative AI Embeddings

Connect to Google's generative AI embeddings service using the `GoogleGenerativeAIEmbeddings` class, found in the [langchain-google-genai](https://pypi.org/project/langchain-google-genai/) package.

## Installation


```python
%pip install --upgrade --quiet  langchain-google-genai
```

## Credentials


```python
import getpass
import os

if "GOOGLE_API_KEY" not in os.environ:
    os.environ["GOOGLE_API_KEY"] = getpass("Provide your Google API key here")
```

## Usage


```python
from langchain_google_genai import GoogleGenerativeAIEmbeddings

embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")
vector = embeddings.embed_query("hello, world!")
vector[:5]
```



```output
[0.05636945, 0.0048285457, -0.0762591, -0.023642512, 0.05329321]
```


## Batch

You can also embed multiple strings at once for a processing speedup:


```python
vectors = embeddings.embed_documents(
    [
        "Today is Monday",
        "Today is Tuesday",
        "Today is April Fools day",
    ]
)
len(vectors), len(vectors[0])
```



```output
(3, 768)
```


## Task type
`GoogleGenerativeAIEmbeddings` optionally support a `task_type`, which currently must be one of:

- task_type_unspecified
- retrieval_query
- retrieval_document
- semantic_similarity
- classification
- clustering

By default, we use `retrieval_document` in the `embed_documents` method and `retrieval_query` in the `embed_query` method. If you provide a task type, we will use that for all methods.


```python
%pip install --upgrade --quiet  matplotlib scikit-learn
```
```output
Note: you may need to restart the kernel to use updated packages.
```

```python
query_embeddings = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001", task_type="retrieval_query"
)
doc_embeddings = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001", task_type="retrieval_document"
)
```

All of these will be embedded with the 'retrieval_query' task set
```python
query_vecs = [query_embeddings.embed_query(q) for q in [query, query_2, answer_1]]
```
All of these will be embedded with the 'retrieval_document' task set
```python
doc_vecs = [doc_embeddings.embed_query(q) for q in [query, query_2, answer_1]]
```

In retrieval, relative distance matters. In the image above, you can see the difference in similarity scores between the "relevant doc" and "simil stronger delta between the similar query and relevant doc on the latter case.

## Additional Configuration

You can pass the following parameters to ChatGoogleGenerativeAI in order to customize the SDK's behavior:

- `client_options`: [Client Options](https://googleapis.dev/python/google-api-core/latest/client_options.html#module-google.api_core.client_options) to pass to the Google API Client, such as a custom `client_options["api_endpoint"]`
- `transport`: The transport method to use, such as `rest`, `grpc`, or `grpc_asyncio`.


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)