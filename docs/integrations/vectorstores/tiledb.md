---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/tiledb.ipynb
description: TileDB는 밀집 및 희소 다차원 배열을 인덱싱하고 쿼리하는 강력한 엔진으로, ANN 검색 기능을 제공합니다.
---

# TileDB

> [TileDB](https://github.com/TileDB-Inc/TileDB)는 밀집 및 희소 다차원 배열을 인덱싱하고 쿼리하는 강력한 엔진입니다.

> TileDB는 [TileDB-Vector-Search](https://github.com/TileDB-Inc/TileDB-Vector-Search) 모듈을 사용하여 ANN 검색 기능을 제공합니다. 이는 ANN 쿼리의 서버리스 실행과 로컬 디스크 및 클라우드 객체 저장소(예: AWS S3)에서 벡터 인덱스 저장을 제공합니다.

자세한 내용은 다음을 참조하세요:
- [왜 TileDB를 벡터 데이터베이스로 선택해야 하는가](https://tiledb.com/blog/why-tiledb-as-a-vector-database)
- [TileDB 101: 벡터 검색](https://tiledb.com/blog/tiledb-101-vector-search)

이 노트북은 `TileDB` 벡터 데이터베이스를 사용하는 방법을 보여줍니다.

```python
%pip install --upgrade --quiet  tiledb-vector-search langchain-community
```


## 기본 예제

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "TileDB"}, {"imported": "TileDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.tiledb.TileDB.html", "title": "TileDB"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "TileDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "TileDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import TileDB
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import CharacterTextSplitter

raw_documents = TextLoader("../../how_to/state_of_the_union.txt").load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
documents = text_splitter.split_documents(raw_documents)
embeddings = HuggingFaceEmbeddings()
db = TileDB.from_documents(
    documents, embeddings, index_uri="/tmp/tiledb_index", index_type="FLAT"
)
```


```python
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query)
docs[0].page_content
```


### 벡터에 의한 유사성 검색

```python
embedding_vector = embeddings.embed_query(query)
docs = db.similarity_search_by_vector(embedding_vector)
docs[0].page_content
```


### 점수를 포함한 유사성 검색

```python
docs_and_scores = db.similarity_search_with_score(query)
docs_and_scores[0]
```


## 최대 한계 관련성 검색 (MMR)

검색기 객체에서 유사성 검색을 사용하는 것 외에도 `mmr`을 검색기로 사용할 수 있습니다.

```python
retriever = db.as_retriever(search_type="mmr")
retriever.invoke(query)
```


또는 `max_marginal_relevance_search`를 직접 사용할 수 있습니다:

```python
db.max_marginal_relevance_search(query, k=2, fetch_k=10)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)