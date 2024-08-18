---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/tencentvectordb.ipynb
description: 텐센트 클라우드 벡터DB는 다차원 벡터 데이터를 저장, 검색 및 분석하기 위한 완전 관리형 분산 데이터베이스 서비스입니다.
---

# 텐센트 클라우드 벡터DB

> [텐센트 클라우드 벡터DB](https://cloud.tencent.com/document/product/1709)는 다차원 벡터 데이터를 저장, 검색 및 분석하기 위해 설계된 완전 관리형, 자체 개발된 기업 수준의 분산 데이터베이스 서비스입니다. 이 데이터베이스는 여러 인덱스 유형과 유사성 계산 방법을 지원합니다. 단일 인덱스는 최대 10억의 벡터 규모를 지원할 수 있으며, 수백만 QPS 및 밀리초 수준의 쿼리 대기 시간을 지원할 수 있습니다. 텐센트 클라우드 벡터 데이터베이스는 대형 모델의 응답 정확도를 향상시키기 위한 외부 지식 기반을 제공할 수 있을 뿐만 아니라 추천 시스템, NLP 서비스, 컴퓨터 비전 및 지능형 고객 서비스와 같은 AI 분야에서도 널리 사용될 수 있습니다.

이 노트북은 텐센트 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

실행하려면 [데이터베이스 인스턴스](https://cloud.tencent.com/document/product/1709/95101)가 필요합니다.

## 기본 사용법

```python
!pip3 install tcvectordb langchain-community
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Tencent Cloud VectorDB"}, {"imported": "FakeEmbeddings", "source": "langchain_community.embeddings.fake", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.FakeEmbeddings.html", "title": "Tencent Cloud VectorDB"}, {"imported": "TencentVectorDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.tencentvectordb.TencentVectorDB.html", "title": "Tencent Cloud VectorDB"}, {"imported": "ConnectionParams", "source": "langchain_community.vectorstores.tencentvectordb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.tencentvectordb.ConnectionParams.html", "title": "Tencent Cloud VectorDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Tencent Cloud VectorDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings.fake import FakeEmbeddings
from langchain_community.vectorstores import TencentVectorDB
from langchain_community.vectorstores.tencentvectordb import ConnectionParams
from langchain_text_splitters import CharacterTextSplitter
```


문서를 로드하고 청크로 나눕니다.

```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
```


문서를 임베드하는 두 가지 방법을 지원합니다:
- Langchain Embeddings와 호환되는 모든 임베딩 모델 사용.
- 텐센트 벡터스토어 DB의 임베딩 모델 이름 지정, 선택 사항은:
  - `bge-base-zh`, 차원: 768
  - `m3e-base`, 차원: 768
  - `text2vec-large-chinese`, 차원: 1024
  - `e5-large-v2`, 차원: 1024
  - `multilingual-e5-base`, 차원: 768 

다음 코드는 문서를 임베드하는 두 가지 방법을 보여줍니다. 다른 방법을 주석 처리하여 하나를 선택할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "OpenAIEmbeddings", "source": "langchain_community.embeddings.openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.openai.OpenAIEmbeddings.html", "title": "Tencent Cloud VectorDB"}]-->
##  you can use a Langchain Embeddings model, like OpenAIEmbeddings:

# from langchain_community.embeddings.openai import OpenAIEmbeddings
#
# embeddings = OpenAIEmbeddings()
# t_vdb_embedding = None

## Or you can use a Tencent Embedding model, like `bge-base-zh`:

t_vdb_embedding = "bge-base-zh"  # bge-base-zh is the default model
embeddings = None
```


이제 텐센트 벡터DB 인스턴스를 생성할 수 있습니다. `embeddings` 또는 `t_vdb_embedding` 매개변수 중 하나 이상을 제공해야 합니다. 둘 다 제공된 경우 `embeddings` 매개변수가 사용됩니다:

```python
conn_params = ConnectionParams(
    url="http://10.0.X.X",
    key="eC4bLRy2va******************************",
    username="root",
    timeout=20,
)

vector_db = TencentVectorDB.from_documents(
    docs, embeddings, connection_params=conn_params, t_vdb_embedding=t_vdb_embedding
)
```


```python
query = "What did the president say about Ketanji Brown Jackson"
docs = vector_db.similarity_search(query)
docs[0].page_content
```


```output
'Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.'
```


```python
vector_db = TencentVectorDB(embeddings, conn_params)

vector_db.add_texts(["Ankush went to Princeton"])
query = "Where did Ankush go to college?"
docs = vector_db.max_marginal_relevance_search(query)
docs[0].page_content
```


```output
'Ankush went to Princeton'
```


## 메타데이터 및 필터링

텐센트 벡터DB는 메타데이터 및 [필터링](https://cloud.tencent.com/document/product/1709/95099#c6f6d3a3-02c5-4891-b0a1-30fe4daf18d8)을 지원합니다. 문서에 메타데이터를 추가하고 메타데이터를 기반으로 검색 결과를 필터링할 수 있습니다.

이제 메타데이터가 포함된 새로운 텐센트 벡터DB 컬렉션을 생성하고 메타데이터를 기반으로 검색 결과를 필터링하는 방법을 보여줍니다:

```python
<!--IMPORTS:[{"imported": "ConnectionParams", "source": "langchain_community.vectorstores.tencentvectordb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.tencentvectordb.ConnectionParams.html", "title": "Tencent Cloud VectorDB"}, {"imported": "MetaField", "source": "langchain_community.vectorstores.tencentvectordb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.tencentvectordb.MetaField.html", "title": "Tencent Cloud VectorDB"}, {"imported": "TencentVectorDB", "source": "langchain_community.vectorstores.tencentvectordb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.tencentvectordb.TencentVectorDB.html", "title": "Tencent Cloud VectorDB"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Tencent Cloud VectorDB"}]-->
from langchain_community.vectorstores.tencentvectordb import (
    META_FIELD_TYPE_STRING,
    META_FIELD_TYPE_UINT64,
    ConnectionParams,
    MetaField,
    TencentVectorDB,
)
from langchain_core.documents import Document

meta_fields = [
    MetaField(name="year", data_type=META_FIELD_TYPE_UINT64, index=True),
    MetaField(name="rating", data_type=META_FIELD_TYPE_STRING, index=False),
    MetaField(name="genre", data_type=META_FIELD_TYPE_STRING, index=True),
    MetaField(name="director", data_type=META_FIELD_TYPE_STRING, index=True),
]

docs = [
    Document(
        page_content="The Shawshank Redemption is a 1994 American drama film written and directed by Frank Darabont.",
        metadata={
            "year": 1994,
            "rating": "9.3",
            "genre": "drama",
            "director": "Frank Darabont",
        },
    ),
    Document(
        page_content="The Godfather is a 1972 American crime film directed by Francis Ford Coppola.",
        metadata={
            "year": 1972,
            "rating": "9.2",
            "genre": "crime",
            "director": "Francis Ford Coppola",
        },
    ),
    Document(
        page_content="The Dark Knight is a 2008 superhero film directed by Christopher Nolan.",
        metadata={
            "year": 2008,
            "rating": "9.0",
            "genre": "superhero",
            "director": "Christopher Nolan",
        },
    ),
    Document(
        page_content="Inception is a 2010 science fiction action film written and directed by Christopher Nolan.",
        metadata={
            "year": 2010,
            "rating": "8.8",
            "genre": "science fiction",
            "director": "Christopher Nolan",
        },
    ),
]

vector_db = TencentVectorDB.from_documents(
    docs,
    None,
    connection_params=ConnectionParams(
        url="http://10.0.X.X",
        key="eC4bLRy2va******************************",
        username="root",
        timeout=20,
    ),
    collection_name="movies",
    meta_fields=meta_fields,
)

query = "film about dream by Christopher Nolan"

# you can use the tencentvectordb filtering syntax with the `expr` parameter:
result = vector_db.similarity_search(query, expr='director="Christopher Nolan"')

# you can either use the langchain filtering syntax with the `filter` parameter:
# result = vector_db.similarity_search(query, filter='eq("director", "Christopher Nolan")')

result
```


```output
[Document(page_content='The Dark Knight is a 2008 superhero film directed by Christopher Nolan.', metadata={'year': 2008, 'rating': '9.0', 'genre': 'superhero', 'director': 'Christopher Nolan'}),
 Document(page_content='The Dark Knight is a 2008 superhero film directed by Christopher Nolan.', metadata={'year': 2008, 'rating': '9.0', 'genre': 'superhero', 'director': 'Christopher Nolan'}),
 Document(page_content='The Dark Knight is a 2008 superhero film directed by Christopher Nolan.', metadata={'year': 2008, 'rating': '9.0', 'genre': 'superhero', 'director': 'Christopher Nolan'}),
 Document(page_content='Inception is a 2010 science fiction action film written and directed by Christopher Nolan.', metadata={'year': 2010, 'rating': '8.8', 'genre': 'science fiction', 'director': 'Christopher Nolan'})]
```


## 관련

- 벡터 스토어 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 스토어 [사용 방법 가이드](/docs/how_to/#vector-stores)