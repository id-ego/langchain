---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/fireworks/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/fireworks.ipynb
sidebar_label: Fireworks
---

# FireworksEmbeddings

This will help you get started with Fireworks embedding models using LangChain. For detailed documentation on `FireworksEmbeddings` features and configuration options, please refer to the [API reference](https://api.python.langchain.com/en/latest/embeddings/langchain_fireworks.embeddings.FireworksEmbeddings.html).

## Overview

### Integration details

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="Fireworks" />


## Setup

To access Fireworks embedding models you'll need to create a Fireworks account, get an API key, and install the `langchain-fireworks` integration package.

### Credentials

Head to [fireworks.ai](https://fireworks.ai/) to sign up to Fireworks and generate an API key. Once you’ve done this set the FIREWORKS_API_KEY environment variable:

```python
import getpass
import os

if not os.getenv("FIREWORKS_API_KEY"):
    os.environ["FIREWORKS_API_KEY"] = getpass.getpass("Enter your Fireworks API key: ")
```

If you want to get automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```

### Installation

The LangChain Fireworks integration lives in the `langchain-fireworks` package:

```python
%pip install -qU langchain-fireworks
```

## Instantiation

Now we can instantiate our model object and generate chat completions:

```python
<!--IMPORTS:[{"imported": "FireworksEmbeddings", "source": "langchain_fireworks", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_fireworks.embeddings.FireworksEmbeddings.html", "title": "FireworksEmbeddings"}]-->
from langchain_fireworks import FireworksEmbeddings

embeddings = FireworksEmbeddings(
    model="nomic-ai/nomic-embed-text-v1.5",
)
```

## Indexing and Retrieval

Embedding models are often used in retrieval-augmented generation (RAG) flows, both as part of indexing data as well as later retrieving it. For more detailed instructions, please see our RAG tutorials under the [working with external knowledge tutorials](/docs/tutorials/#working-with-external-knowledge).

Below, see how to index and retrieve data using the `embeddings` object we initialized above. In this example, we will index and retrieve a sample document in the `InMemoryVectorStore`.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "FireworksEmbeddings"}]-->
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
[0.01666259765625, 0.011688232421875, -0.1181640625, -0.10205078125, 0.05438232421875, -0.0890502929
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
[0.016632080078125, 0.01165008544921875, -0.1181640625, -0.10186767578125, 0.05438232421875, -0.0890
[-0.02667236328125, 0.036651611328125, -0.1630859375, -0.0904541015625, -0.022430419921875, -0.09545
```
## API Reference

For detailed documentation of all `FireworksEmbeddings` features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/embeddings/langchain_fireworks.embeddings.FireworksEmbeddings.html).

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)