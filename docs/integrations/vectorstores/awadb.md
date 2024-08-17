---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/awadb/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/awadb.ipynb
---

# AwaDB
> [AwaDB](https://github.com/awa-ai/awadb) is an AI Native database for the search and storage of embedding vectors used by LLM Applications.

You'll need to install `langchain-community` with `pip install -qU langchain-community` to use this integration

This notebook shows how to use functionality related to the `AwaDB`.

```python
%pip install --upgrade --quiet  awadb
```

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "AwaDB"}, {"imported": "AwaDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.awadb.AwaDB.html", "title": "AwaDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "AwaDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import AwaDB
from langchain_text_splitters import CharacterTextSplitter
```

```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=100, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
```

```python
db = AwaDB.from_documents(docs)
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)
```

```python
print(docs[0].page_content)
```
```output
And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```
## Similarity search with score

The returned distance score is between 0-1. 0 is dissimilar, 1 is the most similar

```python
docs = db.similarity_search_with_score(query)
```

```python
print(docs[0])
```
```output
(Document(page_content='And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': '../../how_to/state_of_the_union.txt'}), 0.561813814013747)
```
## Restore the table created and added data before

AwaDB automatically persists added document data.

If you can restore the table you created and added before, you can just do this as below:

```python
import awadb

awadb_client = awadb.Client()
ret = awadb_client.Load("langchain_awadb")
if ret:
    print("awadb load table success")
else:
    print("awadb load table failed")
```
awadb load table success

## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)