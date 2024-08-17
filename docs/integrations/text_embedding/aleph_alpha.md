---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/aleph_alpha/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/aleph_alpha.ipynb
---

# Aleph Alpha

There are two possible ways to use Aleph Alpha's semantic embeddings. If you have texts with a dissimilar structure (e.g. a Document and a Query) you would want to use asymmetric embeddings. Conversely, for texts with comparable structures, symmetric embeddings are the suggested approach.

## Asymmetric

```python
<!--IMPORTS:[{"imported": "AlephAlphaAsymmetricSemanticEmbedding", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.aleph_alpha.AlephAlphaAsymmetricSemanticEmbedding.html", "title": "Aleph Alpha"}]-->
from langchain_community.embeddings import AlephAlphaAsymmetricSemanticEmbedding
```

```python
document = "This is a content of the document"
query = "What is the content of the document?"
```

```python
embeddings = AlephAlphaAsymmetricSemanticEmbedding(normalize=True, compress_to_size=128)
```

```python
doc_result = embeddings.embed_documents([document])
```

```python
query_result = embeddings.embed_query(query)
```

## Symmetric

```python
<!--IMPORTS:[{"imported": "AlephAlphaSymmetricSemanticEmbedding", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.aleph_alpha.AlephAlphaSymmetricSemanticEmbedding.html", "title": "Aleph Alpha"}]-->
from langchain_community.embeddings import AlephAlphaSymmetricSemanticEmbedding
```

```python
text = "This is a test text"
```

```python
embeddings = AlephAlphaSymmetricSemanticEmbedding(normalize=True, compress_to_size=128)
```

```python
doc_result = embeddings.embed_documents([text])
```

```python
query_result = embeddings.embed_query(text)
```

## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)