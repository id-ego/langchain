---
canonical: https://python.langchain.com/v0.2/docs/integrations/retrievers/pinecone_hybrid_search/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/pinecone_hybrid_search.ipynb
---

# Pinecone Hybrid Search

> [Pinecone](https://docs.pinecone.io/docs/overview) is a vector database with broad functionality.

This notebook goes over how to use a retriever that under the hood uses Pinecone and Hybrid Search.

The logic of this retriever is taken from [this documentation](https://docs.pinecone.io/docs/hybrid-search)

To use Pinecone, you must have an API key and an Environment.
Here are the [installation instructions](https://docs.pinecone.io/docs/quickstart).

```python
%pip install --upgrade --quiet  pinecone-client pinecone-text pinecone-notebooks
```

```python
# Connect to Pinecone and get an API key.
from pinecone_notebooks.colab import Authenticate

Authenticate()

import os

api_key = os.environ["PINECONE_API_KEY"]
```

```python
<!--IMPORTS:[{"imported": "PineconeHybridSearchRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.pinecone_hybrid_search.PineconeHybridSearchRetriever.html", "title": "Pinecone Hybrid Search"}]-->
from langchain_community.retrievers import (
    PineconeHybridSearchRetriever,
)
```

We want to use `OpenAIEmbeddings` so we have to get the OpenAI API Key.

```python
import getpass

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```

## Setup Pinecone

You should only have to do this part once.

```python
import os

from pinecone import Pinecone, ServerlessSpec

index_name = "langchain-pinecone-hybrid-search"

# initialize Pinecone client
pc = Pinecone(api_key=api_key)

# create the index
if index_name not in pc.list_indexes().names():
    pc.create_index(
        name=index_name,
        dimension=1536,  # dimensionality of dense model
        metric="dotproduct",  # sparse values supported only for dotproduct
        spec=ServerlessSpec(cloud="aws", region="us-east-1"),
    )
```

```output
WhoAmIResponse(username='load', user_label='label', projectname='load-test')
```

Now that the index is created, we can use it.

```python
index = pc.Index(index_name)
```

## Get embeddings and sparse encoders

Embeddings are used for the dense vectors, tokenizer is used for the sparse vector

```python
<!--IMPORTS:[{"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Pinecone Hybrid Search"}]-->
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings()
```

To encode the text to sparse values you can either choose SPLADE or BM25. For out of domain tasks we recommend using BM25.

For more information about the sparse encoders you can checkout pinecone-text library [docs](https://pinecone-io.github.io/pinecone-text/pinecone_text.html).

```python
from pinecone_text.sparse import BM25Encoder

# or from pinecone_text.sparse import SpladeEncoder if you wish to work with SPLADE

# use default tf-idf values
bm25_encoder = BM25Encoder().default()
```

The above code is using default tfids values. It's highly recommended to fit the tf-idf values to your own corpus. You can do it as follow:

```python
corpus = ["foo", "bar", "world", "hello"]

# fit tf-idf values on your corpus
bm25_encoder.fit(corpus)

# store the values to a json file
bm25_encoder.dump("bm25_values.json")

# load to your BM25Encoder object
bm25_encoder = BM25Encoder().load("bm25_values.json")
```

## Load Retriever

We can now construct the retriever!

```python
retriever = PineconeHybridSearchRetriever(
    embeddings=embeddings, sparse_encoder=bm25_encoder, index=index
)
```

## Add texts (if necessary)

We can optionally add texts to the retriever (if they aren't already in there)

```python
retriever.add_texts(["foo", "bar", "world", "hello"])
```
```output
100%|██████████| 1/1 [00:02<00:00,  2.27s/it]
```
## Use Retriever

We can now use the retriever!

```python
result = retriever.invoke("foo")
```

```python
result[0]
```

```output
Document(page_content='foo', metadata={})
```

## Related

- Retriever [conceptual guide](/docs/concepts/#retrievers)
- Retriever [how-to guides](/docs/how_to/#retrievers)