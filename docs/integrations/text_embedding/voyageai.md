---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/voyageai/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/voyageai.ipynb
---

# Voyage AI

> [Voyage AI](https://www.voyageai.com/) provides cutting-edge embedding/vectorizations models.

Let's load the Voyage AI Embedding class. (Install the LangChain partner package with `pip install langchain-voyageai`)

```python
<!--IMPORTS:[{"imported": "VoyageAIEmbeddings", "source": "langchain_voyageai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_voyageai.embeddings.VoyageAIEmbeddings.html", "title": "Voyage AI"}]-->
from langchain_voyageai import VoyageAIEmbeddings
```

Voyage AI utilizes API keys to monitor usage and manage permissions. To obtain your key, create an account on our [homepage](https://www.voyageai.com). Then, create a VoyageEmbeddings model with your API key. You can use any of the following models: ([source](https://docs.voyageai.com/docs/embeddings)):

- `voyage-large-2` (default)
- `voyage-code-2`
- `voyage-2`
- `voyage-law-2`
- `voyage-large-2-instruct`
- `voyage-finance-2`
- `voyage-multilingual-2`

```python
embeddings = VoyageAIEmbeddings(
    voyage_api_key="[ Your Voyage API key ]", model="voyage-law-2"
)
```

Prepare the documents and use `embed_documents` to get their embeddings.

```python
documents = [
    "Caching embeddings enables the storage or temporary caching of embeddings, eliminating the necessity to recompute them each time.",
    "An LLMChain is a chain that composes basic LLM functionality. It consists of a PromptTemplate and a language model (either an LLM or chat model). It formats the prompt template using the input key values provided (and also memory key values, if available), passes the formatted string to LLM and returns the LLM output.",
    "A Runnable represents a generic unit of work that can be invoked, batched, streamed, and/or transformed.",
]
```

```python
documents_embds = embeddings.embed_documents(documents)
```

```python
documents_embds[0][:5]
```

```output
[0.0562174916267395,
 0.018221192061901093,
 0.0025736060924828053,
 -0.009720131754875183,
 0.04108370840549469]
```

Similarly, use `embed_query` to embed the query.

```python
query = "What's an LLMChain?"
```

```python
query_embd = embeddings.embed_query(query)
```

```python
query_embd[:5]
```

```output
[-0.0052348352037370205,
 -0.040072452276945114,
 0.0033957737032324076,
 0.01763271726667881,
 -0.019235141575336456]
```

## A minimalist retrieval system

The main feature of the embeddings is that the cosine similarity between two embeddings captures the semantic relatedness of the corresponding original passages. This allows us to use the embeddings to do semantic retrieval / search.

We can find a few closest embeddings in the documents embeddings based on the cosine similarity, and retrieve the corresponding document using the `KNNRetriever` class from LangChain.

```python
<!--IMPORTS:[{"imported": "KNNRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.knn.KNNRetriever.html", "title": "Voyage AI"}]-->
from langchain_community.retrievers import KNNRetriever

retriever = KNNRetriever.from_texts(documents, embeddings)

# retrieve the most relevant documents
result = retriever.invoke(query)
top1_retrieved_doc = result[0].page_content  # return the top1 retrieved result

print(top1_retrieved_doc)
```
```output
An LLMChain is a chain that composes basic LLM functionality. It consists of a PromptTemplate and a language model (either an LLM or chat model). It formats the prompt template using the input key values provided (and also memory key values, if available), passes the formatted string to LLM and returns the LLM output.
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)