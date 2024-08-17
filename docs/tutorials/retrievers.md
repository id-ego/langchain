---
canonical: https://python.langchain.com/v0.2/docs/tutorials/retrievers/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/retrievers.ipynb
---

# Vector stores and retrievers

This tutorial will familiarize you with LangChain's vector store and retriever abstractions. These abstractions are designed to support retrieval of data--  from (vector) databases and other sources--  for integration with LLM workflows. They are important for applications that fetch data to be reasoned over as part of model inference, as in the case of retrieval-augmented generation, or RAG (see our RAG tutorial [here](/docs/tutorials/rag)).

## Concepts

This guide focuses on retrieval of text data. We will cover the following concepts:

- Documents;
- Vector stores;
- Retrievers.

## Setup

### Jupyter Notebook

This and other tutorials are perhaps most conveniently run in a Jupyter notebook. See [here](https://jupyter.org/install) for instructions on how to install.

### Installation

This tutorial requires the `langchain`, `langchain-chroma`, and `langchain-openai` packages:

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import CodeBlock from "@theme/CodeBlock";

<Tabs>
  <TabItem value="pip" label="Pip" default>
    <CodeBlock language="bash">pip install langchain langchain-chroma langchain-openai</CodeBlock>
  </TabItem>
  <TabItem value="conda" label="Conda">
    <CodeBlock language="bash">conda install langchain langchain-chroma langchain-openai -c conda-forge</CodeBlock>
  </TabItem>
</Tabs>


For more details, see our [Installation guide](/docs/how_to/installation).

### LangSmith

Many of the applications you build with LangChain will contain multiple steps with multiple invocations of LLM calls.
As these applications get more and more complex, it becomes crucial to be able to inspect what exactly is going on inside your chain or agent.
The best way to do this is with [LangSmith](https://smith.langchain.com).

After you sign up at the link above, make sure to set your environment variables to start logging traces:

```shell
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_API_KEY="..."
```

Or, if in a notebook, you can set them with:

```python
import getpass
import os

os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```

## Documents

LangChain implements a [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) abstraction, which is intended to represent a unit of text and associated metadata. It has two attributes:

- `page_content`: a string representing the content;
- `metadata`: a dict containing arbitrary metadata.

The `metadata` attribute can capture information about the source of the document, its relationship to other documents, and other information. Note that an individual `Document` object often represents a chunk of a larger document.

Let's generate some sample documents:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Vector stores and retrievers"}]-->
from langchain_core.documents import Document

documents = [
    Document(
        page_content="Dogs are great companions, known for their loyalty and friendliness.",
        metadata={"source": "mammal-pets-doc"},
    ),
    Document(
        page_content="Cats are independent pets that often enjoy their own space.",
        metadata={"source": "mammal-pets-doc"},
    ),
    Document(
        page_content="Goldfish are popular pets for beginners, requiring relatively simple care.",
        metadata={"source": "fish-pets-doc"},
    ),
    Document(
        page_content="Parrots are intelligent birds capable of mimicking human speech.",
        metadata={"source": "bird-pets-doc"},
    ),
    Document(
        page_content="Rabbits are social animals that need plenty of space to hop around.",
        metadata={"source": "mammal-pets-doc"},
    ),
]
```

Here we've generated five documents, containing metadata indicating three distinct "sources".

## Vector stores

Vector search is a common way to store and search over unstructured data (such as unstructured text). The idea is to store numeric vectors that are associated with the text. Given a query, we can [embed](/docs/concepts#embedding-models) it as a vector of the same dimension and use vector similarity metrics to identify related data in the store.

LangChain [VectorStore](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html) objects contain methods for adding text and `Document` objects to the store, and querying them using various similarity metrics. They are often initialized with [embedding](/docs/how_to/embed_text) models, which determine how text data is translated to numeric vectors.

LangChain includes a suite of [integrations](/docs/integrations/vectorstores) with different vector store technologies. Some vector stores are hosted by a provider (e.g., various cloud providers) and require specific credentials to use; some (such as [Postgres](/docs/integrations/vectorstores/pgvector)) run in separate infrastructure that can be run locally or via a third-party; others can run in-memory for lightweight workloads. Here we will demonstrate usage of LangChain VectorStores using [Chroma](/docs/integrations/vectorstores/chroma), which includes an in-memory implementation.

To instantiate a vector store, we often need to provide an [embedding](/docs/how_to/embed_text) model to specify how text should be converted into a numeric vector. Here we will use [OpenAI embeddings](/docs/integrations/text_embedding/openai/).

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Vector stores and retrievers"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Vector stores and retrievers"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings

vectorstore = Chroma.from_documents(
    documents,
    embedding=OpenAIEmbeddings(),
)
```

Calling `.from_documents` here will add the documents to the vector store. [VectorStore](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html) implements methods for adding documents that can also be called after the object is instantiated. Most implementations will allow you to connect to an existing vector store--  e.g., by providing a client, index name, or other information. See the documentation for a specific [integration](/docs/integrations/vectorstores) for more detail.

Once we've instantiated a `VectorStore` that contains documents, we can query it. [VectorStore](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html) includes methods for querying:
- Synchronously and asynchronously;
- By string query and by vector;
- With and without returning similarity scores;
- By similarity and [maximum marginal relevance](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html#langchain_core.vectorstores.VectorStore.max_marginal_relevance_search) (to balance similarity with query to diversity in retrieved results).

The methods will generally include a list of [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html#langchain_core.documents.base.Document) objects in their outputs.

### Examples

Return documents based on similarity to a string query:

```python
vectorstore.similarity_search("cat")
```

```output
[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Dogs are great companions, known for their loyalty and friendliness.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Rabbits are social animals that need plenty of space to hop around.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Parrots are intelligent birds capable of mimicking human speech.', metadata={'source': 'bird-pets-doc'})]
```

Async query:

```python
await vectorstore.asimilarity_search("cat")
```

```output
[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Dogs are great companions, known for their loyalty and friendliness.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Rabbits are social animals that need plenty of space to hop around.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Parrots are intelligent birds capable of mimicking human speech.', metadata={'source': 'bird-pets-doc'})]
```

Return scores:

```python
# Note that providers implement different scores; Chroma here
# returns a distance metric that should vary inversely with
# similarity.

vectorstore.similarity_search_with_score("cat")
```

```output
[(Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'}),
  0.3751849830150604),
 (Document(page_content='Dogs are great companions, known for their loyalty and friendliness.', metadata={'source': 'mammal-pets-doc'}),
  0.48316916823387146),
 (Document(page_content='Rabbits are social animals that need plenty of space to hop around.', metadata={'source': 'mammal-pets-doc'}),
  0.49601367115974426),
 (Document(page_content='Parrots are intelligent birds capable of mimicking human speech.', metadata={'source': 'bird-pets-doc'}),
  0.4972994923591614)]
```

Return documents based on similarity to an embedded query:

```python
embedding = OpenAIEmbeddings().embed_query("cat")

vectorstore.similarity_search_by_vector(embedding)
```

```output
[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Dogs are great companions, known for their loyalty and friendliness.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Rabbits are social animals that need plenty of space to hop around.', metadata={'source': 'mammal-pets-doc'}),
 Document(page_content='Parrots are intelligent birds capable of mimicking human speech.', metadata={'source': 'bird-pets-doc'})]
```

Learn more:

- [API reference](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html)
- [How-to guide](/docs/how_to/vectorstores)
- [Integration-specific docs](/docs/integrations/vectorstores)

## Retrievers

LangChain `VectorStore` objects do not subclass [Runnable](https://api.python.langchain.com/en/latest/core_api_reference.html#module-langchain_core.runnables), and so cannot immediately be integrated into LangChain Expression Language [chains](/docs/concepts/#langchain-expression-language-lcel).

LangChain [Retrievers](https://api.python.langchain.com/en/latest/core_api_reference.html#module-langchain_core.retrievers) are Runnables, so they implement a standard set of methods (e.g., synchronous and asynchronous `invoke` and `batch` operations) and are designed to be incorporated in LCEL chains.

We can create a simple version of this ourselves, without subclassing `Retriever`. If we choose what method we wish to use to retrieve documents, we can create a runnable easily. Below we will build one around the `similarity_search` method:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Vector stores and retrievers"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "Vector stores and retrievers"}]-->
from typing import List

from langchain_core.documents import Document
from langchain_core.runnables import RunnableLambda

retriever = RunnableLambda(vectorstore.similarity_search).bind(k=1)  # select top result

retriever.batch(["cat", "shark"])
```

```output
[[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'})],
 [Document(page_content='Goldfish are popular pets for beginners, requiring relatively simple care.', metadata={'source': 'fish-pets-doc'})]]
```

Vectorstores implement an `as_retriever` method that will generate a Retriever, specifically a [VectorStoreRetriever](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStoreRetriever.html). These retrievers include specific `search_type` and `search_kwargs` attributes that identify what methods of the underlying vector store to call, and how to parameterize them. For instance, we can replicate the above with the following:

```python
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 1},
)

retriever.batch(["cat", "shark"])
```

```output
[[Document(page_content='Cats are independent pets that often enjoy their own space.', metadata={'source': 'mammal-pets-doc'})],
 [Document(page_content='Goldfish are popular pets for beginners, requiring relatively simple care.', metadata={'source': 'fish-pets-doc'})]]
```

`VectorStoreRetriever` supports search types of `"similarity"` (default), `"mmr"` (maximum marginal relevance, described above), and `"similarity_score_threshold"`. We can use the latter to threshold documents output by the retriever by similarity score.

Retrievers can easily be incorporated into more complex applications, such as retrieval-augmented generation (RAG) applications that combine a given question with retrieved context into a prompt for a LLM. Below we show a minimal example.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Vector stores and retrievers"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Vector stores and retrievers"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

message = """
Answer this question using the provided context only.

{question}

Context:
{context}
"""

prompt = ChatPromptTemplate.from_messages([("human", message)])

rag_chain = {"context": retriever, "question": RunnablePassthrough()} | prompt | llm
```

```python
response = rag_chain.invoke("tell me about cats")

print(response.content)
```
```output
Cats are independent pets that often enjoy their own space.
```
## Learn more:

Retrieval strategies can be rich and complex. For example:

- We can [infer hard rules and filters](/docs/how_to/self_query/) from a query (e.g., "using documents published after 2020");
- We can [return documents that are linked](/docs/how_to/parent_document_retriever/) to the retrieved context in some way (e.g., via some document taxonomy);
- We can generate [multiple embeddings](/docs/how_to/multi_vector) for each unit of context;
- We can [ensemble results](/docs/how_to/ensemble_retriever) from multiple retrievers;
- We can assign weights to documents, e.g., to weigh [recent documents](/docs/how_to/time_weighted_vectorstore/) higher.

The [retrievers](/docs/how_to#retrievers) section of the how-to guides covers these and other built-in retrieval strategies.

It is also straightforward to extend the [BaseRetriever](https://api.python.langchain.com/en/latest/retrievers/langchain_core.retrievers.BaseRetriever.html) class in order to implement custom retrievers. See our how-to guide [here](/docs/how_to/custom_retriever).