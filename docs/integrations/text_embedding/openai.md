---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/openai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/openai.ipynb
keywords:
- openaiembeddings
sidebar_label: OpenAI
---

# OpenAIEmbeddings

This will help you get started with OpenAI embedding models using LangChain. For detailed documentation on `OpenAIEmbeddings` features and configuration options, please refer to the [API reference](https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html).

## Overview
### Integration details

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="OpenAI" />


## Setup

To access OpenAI embedding models you'll need to create a/an OpenAI account, get an API key, and install the `langchain-openai` integration package.

### Credentials

Head to [platform.openai.com](https://platform.openai.com) to sign up to OpenAI and generate an API key. Once you’ve done this set the OPENAI_API_KEY environment variable:

```python
import getpass
import os

if not os.getenv("OPENAI_API_KEY"):
    os.environ["OPENAI_API_KEY"] = getpass.getpass("Enter your OpenAI API key: ")
```

If you want to get automated tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```

### Installation

The LangChain OpenAI integration lives in the `langchain-openai` package:

```python
%pip install -qU langchain-openai
```

## Instantiation

Now we can instantiate our model object and generate chat completions:

```python
<!--IMPORTS:[{"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "OpenAIEmbeddings"}]-->
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings(
    model="text-embedding-3-large",
    # With the `text-embedding-3` class
    # of models, you can specify the size
    # of the embeddings you want returned.
    # dimensions=1024
)
```

## Indexing and Retrieval

Embedding models are often used in retrieval-augmented generation (RAG) flows, both as part of indexing data as well as later retrieving it. For more detailed instructions, please see our RAG tutorials under the [working with external knowledge tutorials](/docs/tutorials/#working-with-external-knowledge).

Below, see how to index and retrieve data using the `embeddings` object we initialized above. In this example, we will index and retrieve a sample document in the `InMemoryVectorStore`.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "OpenAIEmbeddings"}]-->
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
[-0.019276829436421394, 0.0037708976306021214, -0.03294256329536438, 0.0037671267054975033, 0.008175
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
[-0.019260549917817116, 0.0037612367887049913, -0.03291035071015358, 0.003757466096431017, 0.0082049
[-0.010181212797760963, 0.023419594392180443, -0.04215526953339577, -0.001532090245746076, -0.023573
```
## API Reference

For detailed documentation on `OpenAIEmbeddings` features and configuration options, please refer to the [API reference](https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html).

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)