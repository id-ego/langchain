---
canonical: https://python.langchain.com/v0.2/docs/integrations/text_embedding/fake/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/fake.ipynb
---

# Fake Embeddings

LangChain also provides a fake embedding class. You can use this to test your pipelines.


```python
<!--IMPORTS:[{"imported": "FakeEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.FakeEmbeddings.html", "title": "Fake Embeddings"}]-->
from langchain_community.embeddings import FakeEmbeddings
```


```python
embeddings = FakeEmbeddings(size=1352)
```


```python
query_result = embeddings.embed_query("foo")
```


```python
doc_results = embeddings.embed_documents(["foo"])
```


## Related

- Embedding model [conceptual guide](/docs/concepts/#embedding-models)
- Embedding model [how-to guides](/docs/how_to/#embedding-models)