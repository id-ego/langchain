---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/pgvecto_rs.ipynb
description: 이 문서는 Postgres 벡터 데이터베이스(pgvecto.rs)의 기능 사용 방법을 설명합니다. 설치 및 유사성 검색 예제를
  포함합니다.
---

# PGVecto.rs

이 노트북은 Postgres 벡터 데이터베이스 ([pgvecto.rs](https://github.com/tensorchord/pgvecto.rs))와 관련된 기능을 사용하는 방법을 보여줍니다.

```python
%pip install "pgvecto_rs[sdk]" langchain-community
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "PGVecto.rs"}, {"imported": "FakeEmbeddings", "source": "langchain_community.embeddings.fake", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.FakeEmbeddings.html", "title": "PGVecto.rs"}, {"imported": "PGVecto_rs", "source": "langchain_community.vectorstores.pgvecto_rs", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.pgvecto_rs.PGVecto_rs.html", "title": "PGVecto.rs"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "PGVecto.rs"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "PGVecto.rs"}]-->
from typing import List

from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings.fake import FakeEmbeddings
from langchain_community.vectorstores.pgvecto_rs import PGVecto_rs
from langchain_core.documents import Document
from langchain_text_splitters import CharacterTextSplitter
```


```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = FakeEmbeddings(size=3)
```


[공식 데모 도커 이미지](https://github.com/tensorchord/pgvecto.rs#installation)로 데이터베이스를 시작하세요.

```python
! docker run --name pgvecto-rs-demo -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 -d tensorchord/pgvecto-rs:latest
```


그런 다음 db URL을 구성합니다.

```python
## PGVecto.rs needs the connection string to the database.
## We will load it from the environment variables.
import os

PORT = os.getenv("DB_PORT", 5432)
HOST = os.getenv("DB_HOST", "localhost")
USER = os.getenv("DB_USER", "postgres")
PASS = os.getenv("DB_PASS", "mysecretpassword")
DB_NAME = os.getenv("DB_NAME", "postgres")

# Run tests with shell:
URL = "postgresql+psycopg://{username}:{password}@{host}:{port}/{db_name}".format(
    port=PORT,
    host=HOST,
    username=USER,
    password=PASS,
    db_name=DB_NAME,
)
```


마지막으로 문서에서 VectorStore를 생성합니다:

```python
db1 = PGVecto_rs.from_documents(
    documents=docs,
    embedding=embeddings,
    db_url=URL,
    # The table name is f"collection_{collection_name}", so that it should be unique.
    collection_name="state_of_the_union",
)
```


나중에 다음과 같이 테이블에 연결할 수 있습니다:

```python
# Create new empty vectorstore with collection_name.
# Or connect to an existing vectorstore in database if exists.
# Arguments should be the same as when the vectorstore was created.
db1 = PGVecto_rs.from_collection_name(
    embedding=embeddings,
    db_url=URL,
    collection_name="state_of_the_union",
)
```


사용자가 테이블을 생성할 수 있는 권한이 있는지 확인하세요.

## 점수를 통한 유사성 검색

### 유클리드 거리로 유사성 검색 (기본값)

```python
query = "What did the president say about Ketanji Brown Jackson"
docs: List[Document] = db1.similarity_search(query, k=4)
for doc in docs:
    print(doc.page_content)
    print("======================")
```


### 필터를 통한 유사성 검색

```python
from pgvecto_rs.sdk.filters import meta_contains

query = "What did the president say about Ketanji Brown Jackson"
docs: List[Document] = db1.similarity_search(
    query, k=4, filter=meta_contains({"source": "../../how_to/state_of_the_union.txt"})
)

for doc in docs:
    print(doc.page_content)
    print("======================")
```


또는:

```python
query = "What did the president say about Ketanji Brown Jackson"
docs: List[Document] = db1.similarity_search(
    query, k=4, filter={"source": "../../how_to/state_of_the_union.txt"}
)

for doc in docs:
    print(doc.page_content)
    print("======================")
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)