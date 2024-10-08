---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/spacy_embedding/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/spacy_embedding.ipynb
---

# SpaCy

> [spaCy](https://spacy.io/) is an open-source software library for advanced natural language processing, written in the programming languages Python and Cython.

## Installation and Setup

```python
%pip install --upgrade --quiet  spacy
```

Import the necessary classes

```python
<!--IMPORTS:[{"imported": "SpacyEmbeddings", "source": "langchain_community.embeddings.spacy_embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.spacy_embeddings.SpacyEmbeddings.html", "title": "SpaCy"}]-->
from langchain_community.embeddings.spacy_embeddings import SpacyEmbeddings
```

## Example

Initialize SpacyEmbeddings.This will load the Spacy model into memory.

```python
embedder = SpacyEmbeddings(model_name="en_core_web_sm")
```

Define some example texts . These could be any documents that you want to analyze - for example, news articles, social media posts, or product reviews.

```python
texts = [
    "The quick brown fox jumps over the lazy dog.",
    "Pack my box with five dozen liquor jugs.",
    "How vexingly quick daft zebras jump!",
    "Bright vixens jump; dozy fowl quack.",
]
```

Generate and print embeddings for the texts . The SpacyEmbeddings class generates an embedding for each document, which is a numerical representation of the document's content. These embeddings can be used for various natural language processing tasks, such as document similarity comparison or text classification.

```python
embeddings = embedder.embed_documents(texts)
for i, embedding in enumerate(embeddings):
    print(f"Embedding for document {i+1}: {embedding}")
```

Generate and print an embedding for a single piece of text. You can also generate an embedding for a single piece of text, such as a search query. This can be useful for tasks like information retrieval, where you want to find documents that are similar to a given query.

```python
query = "Quick foxes and lazy dogs."
query_embedding = embedder.embed_query(query)
print(f"Embedding for query: {query_embedding}")
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)