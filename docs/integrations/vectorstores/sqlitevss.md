---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/sqlitevss.ipynb
description: SQLite-VSS는 로컬 우선 작업과 외부 서버 없이 애플리케이션에 쉽게 통합할 수 있는 벡터 검색을 위한 SQLite 확장입니다.
---

# SQLite-VSS

> [SQLite-VSS](https://alexgarcia.xyz/sqlite-vss/)는 벡터 검색을 위해 설계된 `SQLite` 확장으로, 로컬 우선 작업 및 외부 서버 없이 애플리케이션에 쉽게 통합할 수 있도록 강조합니다. `Faiss` 라이브러리를 활용하여 효율적인 유사성 검색 및 클러스터링 기능을 제공합니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

이 노트북은 `SQLiteVSS` 벡터 데이터베이스를 사용하는 방법을 보여줍니다.

```python
# You need to install sqlite-vss as a dependency.
%pip install --upgrade --quiet  sqlite-vss
```


## 빠른 시작

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "SQLite-VSS"}, {"imported": "SentenceTransformerEmbeddings", "source": "langchain_community.embeddings.sentence_transformer", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.huggingface.SentenceTransformerEmbeddings.html", "title": "SQLite-VSS"}, {"imported": "SQLiteVSS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.sqlitevss.SQLiteVSS.html", "title": "SQLite-VSS"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "SQLite-VSS"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings.sentence_transformer import (
    SentenceTransformerEmbeddings,
)
from langchain_community.vectorstores import SQLiteVSS
from langchain_text_splitters import CharacterTextSplitter

# load the document and split it into chunks
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()

# split it into chunks
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
texts = [doc.page_content for doc in docs]


# create the open-source embedding function
embedding_function = SentenceTransformerEmbeddings(model_name="all-MiniLM-L6-v2")


# load it in sqlite-vss in a table named state_union.
# the db_file parameter is the name of the file you want
# as your sqlite database.
db = SQLiteVSS.from_texts(
    texts=texts,
    embedding=embedding_function,
    table="state_union",
    db_file="/tmp/vss.db",
)

# query it
query = "What did the president say about Ketanji Brown Jackson"
data = db.similarity_search(query)

# print results
data[0].page_content
```


```output
'Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.'
```


## 기존 SQLite 연결 사용

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "SQLite-VSS"}, {"imported": "SentenceTransformerEmbeddings", "source": "langchain_community.embeddings.sentence_transformer", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.huggingface.SentenceTransformerEmbeddings.html", "title": "SQLite-VSS"}, {"imported": "SQLiteVSS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.sqlitevss.SQLiteVSS.html", "title": "SQLite-VSS"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "SQLite-VSS"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings.sentence_transformer import (
    SentenceTransformerEmbeddings,
)
from langchain_community.vectorstores import SQLiteVSS
from langchain_text_splitters import CharacterTextSplitter

# load the document and split it into chunks
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()

# split it into chunks
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
texts = [doc.page_content for doc in docs]


# create the open-source embedding function
embedding_function = SentenceTransformerEmbeddings(model_name="all-MiniLM-L6-v2")
connection = SQLiteVSS.create_connection(db_file="/tmp/vss.db")

db1 = SQLiteVSS(
    table="state_union", embedding=embedding_function, connection=connection
)

db1.add_texts(["Ketanji Brown Jackson is awesome"])
# query it again
query = "What did the president say about Ketanji Brown Jackson"
data = db1.similarity_search(query)

# print results
data[0].page_content
```


```output
'Ketanji Brown Jackson is awesome'
```


```python
# Cleaning up
import os

os.remove("/tmp/vss.db")
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)