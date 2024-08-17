---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/together/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/together.ipynb
sidebar_label: Together AI
---

# TogetherEmbeddings

This will help you get started with Together embedding models using LangChain. For detailed documentation on `TogetherEmbeddings` features and configuration options, please refer to the [API reference](https://api.python.langchain.com/en/latest/embeddings/langchain_together.embeddings.TogetherEmbeddings.html).

## Overview
### Integration details

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="Together" />


## Setup

To access Together embedding models you'll need to create a/an Together account, get an API key, and install the `langchain-together` integration package.

### Credentials

Head to [https://api.together.xyz/](https://api.together.xyz/) to sign up to Together and generate an API key. Once you've done this set the TOGETHER_API_KEY environment variable:

```python
import getpass
import os

if not os.getenv("TOGETHER_API_KEY"):
    os.environ["TOGETHER_API_KEY"] = getpass.getpass("Enter your Together API key: ")
```

If you want to get automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```

### Installation

The LangChain Together integration lives in the `langchain-together` package:

```python
%pip install -qU langchain-together
```
```output

[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip is available: [0m[31;49m24.0[0m[39;49m -> [0m[32;49m24.2[0m
[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpython -m pip install --upgrade pip[0m
Note: you may need to restart the kernel to use updated packages.
```
## Instantiation

Now we can instantiate our model object and generate chat completions:

```python
<!--IMPORTS:[{"imported": "TogetherEmbeddings", "source": "langchain_together", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_together.embeddings.TogetherEmbeddings.html", "title": "TogetherEmbeddings"}]-->
from langchain_together import TogetherEmbeddings

embeddings = TogetherEmbeddings(
    model="togethercomputer/m2-bert-80M-8k-retrieval",
)
```

## Indexing and Retrieval

Embedding models are often used in retrieval-augmented generation (RAG) flows, both as part of indexing data as well as later retrieving it. For more detailed instructions, please see our RAG tutorials under the [working with external knowledge tutorials](/docs/tutorials/#working-with-external-knowledge).

Below, see how to index and retrieve data using the `embeddings` object we initialized above. In this example, we will index and retrieve a sample document in the `InMemoryVectorStore`.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "TogetherEmbeddings"}]-->
# Create a vector store with a sample text
from langchain_core.vectorstores import InMemoryVectorStore

text = "LangChain is the framework for building context-aware reasoning applications"

vectorstore = InMemoryVectorStore.from_texts(
    [text],
    embedding=embeddings,
)

# Use the vectorstore as a retriever
retriever = vectorstore.as_retriever()

# Retrieve the most similar text
retrieved_documents = retriever.invoke("What is LangChain?")

# show the retrieved document's content
retrieved_documents[0].page_content
```

```output
'LangChain is the framework for building context-aware reasoning applications'
```

## Direct Usage

Under the hood, the vectorstore and retriever implementations are calling `embeddings.embed_documents(...)` and `embeddings.embed_query(...)` to create embeddings for the text(s) used in `from_texts` and retrieval `invoke` operations, respectively.

You can directly call these methods to get embeddings for your own use cases.

### Embed single texts

You can embed single texts or documents with `embed_query`:

```python
single_vector = embeddings.embed_query(text)
print(str(single_vector)[:100])  # Show the first 100 characters of the vector
```
```output
[0.3812227, -0.052848946, -0.10564975, 0.03480297, 0.2878488, 0.0084609175, 0.11605915, 0.05303011,
```
### Embed multiple texts

You can embed multiple texts with `embed_documents`:

```python
text2 = (
    "LangGraph is a library for building stateful, multi-actor applications with LLMs"
)
two_vectors = embeddings.embed_documents([text, text2])
for vector in two_vectors:
    print(str(vector)[:100])  # Show the first 100 characters of the vector
```
```output
[0.3812227, -0.052848946, -0.10564975, 0.03480297, 0.2878488, 0.0084609175, 0.11605915, 0.05303011, 
[0.066308185, -0.032866564, 0.115751594, 0.19082588, 0.14017, -0.26976448, -0.056340694, -0.26923394
```
## API Reference

For detailed documentation on `TogetherEmbeddings` features and configuration options, please refer to the [API reference](https://api.python.langchain.com/en/latest/embeddings/langchain_together.embeddings.TogetherEmbeddings.html).

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)