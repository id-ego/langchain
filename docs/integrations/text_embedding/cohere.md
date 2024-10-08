---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/cohere/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/cohere.ipynb
sidebar_label: Cohere
---

# CohereEmbeddings

This will help you get started with Cohere embedding models using LangChain. For detailed documentation on `CohereEmbeddings` features and configuration options, please refer to the [API reference](https://api.python.langchain.com/en/latest/embeddings/langchain_cohere.embeddings.CohereEmbeddings.html).

## Overview
### Integration details

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="Cohere" />


## Setup

To access Cohere embedding models you'll need to create a/an Cohere account, get an API key, and install the `langchain-cohere` integration package.

### Credentials

Head to [cohere.com](https://cohere.com) to sign up to Cohere and generate an API key. Once you’ve done this set the COHERE_API_KEY environment variable:

```python
import getpass
import os

if not os.getenv("COHERE_API_KEY"):
    os.environ["COHERE_API_KEY"] = getpass.getpass("Enter your Cohere API key: ")
```

If you want to get automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```

### Installation

The LangChain Cohere integration lives in the `langchain-cohere` package:

```python
%pip install -qU langchain-cohere
```

## Instantiation

Now we can instantiate our model object and generate chat completions:

```python
<!--IMPORTS:[{"imported": "CohereEmbeddings", "source": "langchain_cohere", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_cohere.embeddings.CohereEmbeddings.html", "title": "CohereEmbeddings"}]-->
from langchain_cohere import CohereEmbeddings

embeddings = CohereEmbeddings(
    model="embed-english-v3.0",
)
```

## Indexing and Retrieval

Embedding models are often used in retrieval-augmented generation (RAG) flows, both as part of indexing data as well as later retrieving it. For more detailed instructions, please see our RAG tutorials under the [working with external knowledge tutorials](/docs/tutorials/#working-with-external-knowledge).

Below, see how to index and retrieve data using the `embeddings` object we initialized above. In this example, we will index and retrieve a sample document in the `InMemoryVectorStore`.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "CohereEmbeddings"}]-->
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
[-0.022979736, -0.030212402, -0.08886719, -0.08569336, 0.007030487, -0.0010671616, -0.033813477, 0.0
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
[-0.028869629, -0.030410767, -0.099121094, -0.07116699, -0.012748718, -0.0059432983, -0.04360962, 0.
[-0.047332764, -0.049957275, -0.07458496, -0.034332275, -0.057922363, -0.0112838745, -0.06994629, 0.
```
## API Reference

For detailed documentation on `CohereEmbeddings` features and configuration options, please refer to the [API reference](https://api.python.langchain.com/en/latest/embeddings/langchain_cohere.embeddings.CohereEmbeddings.html).

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)