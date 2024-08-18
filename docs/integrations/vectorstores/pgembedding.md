---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/pgembedding.ipynb
description: Postgres Embedding은 HNSW를 사용하여 Postgres에서 벡터 유사성 검색을 지원하는 오픈 소스 도구입니다.
  정확하고 근사적인 이웃 검색을 제공합니다.
---

# Postgres Embedding

> [Postgres Embedding](https://github.com/neondatabase/pg_embedding)는 `Postgres`를 위한 오픈 소스 벡터 유사성 검색으로, 근사 최근접 이웃 검색을 위해 `Hierarchical Navigable Small Worlds (HNSW)`를 사용합니다.

> 지원하는 기능:
> - HNSW를 사용한 정확하고 근사적인 최근접 이웃 검색
> - L2 거리

이 노트북은 Postgres 벡터 데이터베이스(`PGEmbedding`)를 사용하는 방법을 보여줍니다.

> PGEmbedding 통합은 pg_embedding 확장을 생성하지만, 다음 Postgres 쿼리를 실행하여 추가해야 합니다:
```sql
CREATE EXTENSION embedding;
```


```python
# Pip install necessary package
%pip install --upgrade --quiet  langchain-openai langchain-community
%pip install --upgrade --quiet  psycopg2-binary
%pip install --upgrade --quiet  tiktoken
```


`OpenAIEmbeddings`를 사용하기 위해 OpenAI API 키를 환경 변수에 추가하세요.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```

```output
OpenAI API Key:········
```


```python
## Loading Environment Variables
from typing import List, Tuple
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Postgres Embedding"}, {"imported": "PGEmbedding", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.pgembedding.PGEmbedding.html", "title": "Postgres Embedding"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Postgres Embedding"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Postgres Embedding"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Postgres Embedding"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import PGEmbedding
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
os.environ["DATABASE_URL"] = getpass.getpass("Database Url:")
```

```output
Database Url:········
```


```python
loader = TextLoader("state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
connection_string = os.environ.get("DATABASE_URL")
collection_name = "state_of_the_union"
```


```python
db = PGEmbedding.from_documents(
    embedding=embeddings,
    documents=docs,
    collection_name=collection_name,
    connection_string=connection_string,
)

query = "What did the president say about Ketanji Brown Jackson"
docs_with_score: List[Tuple[Document, float]] = db.similarity_search_with_score(query)
```


```python
for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print(doc.page_content)
    print("-" * 80)
```


## Postgres에서 벡터 저장소 작업하기

### PG에 벡터 저장소 업로드

```python
db = PGEmbedding.from_documents(
    embedding=embeddings,
    documents=docs,
    collection_name=collection_name,
    connection_string=connection_string,
    pre_delete_collection=False,
)
```


### HNSW 인덱스 생성
기본적으로, 이 확장은 100% 재현율로 순차 스캔 검색을 수행합니다. `similarity_search_with_score` 실행 시간을 단축하기 위해 근사 최근접 이웃(ANN) 검색을 위한 HNSW 인덱스를 생성하는 것을 고려할 수 있습니다. 벡터 열에 HNSW 인덱스를 생성하려면 `create_hnsw_index` 함수를 사용하세요:

```python
PGEmbedding.create_hnsw_index(
    max_elements=10000, dims=1536, m=8, ef_construction=16, ef_search=16
)
```


위의 함수는 아래 SQL 쿼리를 실행하는 것과 같습니다:
```sql
CREATE INDEX ON vectors USING hnsw(vec) WITH (maxelements=10000, dims=1536, m=3, efconstruction=16, efsearch=16);
```

위의 문장에서 사용된 HNSW 인덱스 옵션은 다음과 같습니다:

- maxelements: 인덱싱된 최대 요소 수를 정의합니다. 필수 매개변수입니다. 위의 예에서는 값이 3입니다. 실제 예제에서는 1000000과 같은 훨씬 큰 값을 가질 것입니다. "요소"는 데이터 세트의 데이터 포인트(벡터)를 나타내며, HNSW 그래프에서 노드로 표현됩니다. 일반적으로 이 옵션은 데이터 세트의 행 수를 수용할 수 있는 값으로 설정합니다.
- dims: 벡터 데이터의 차원 수를 정의합니다. 필수 매개변수입니다. 위의 예에서는 작은 값이 사용됩니다. OpenAI의 text-embedding-ada-002 모델을 사용하여 생성된 데이터를 저장하는 경우, 1536 차원을 지원하므로 예를 들어 1536으로 정의합니다.
- m: 그래프 구성 중 각 노드에 대해 생성되는 양방향 링크(또는 "엣지")의 최대 수를 정의합니다.
다음 추가 인덱스 옵션이 지원됩니다:
- efConstruction: 인덱스 구성 중 고려되는 최근접 이웃의 수를 정의합니다. 기본값은 32입니다.
- efsearch: 인덱스 검색 중 고려되는 최근접 이웃의 수를 정의합니다. 기본값은 32입니다.
HNSW 알고리즘에 영향을 주기 위해 이러한 옵션을 구성하는 방법에 대한 정보는 [HNSW 알고리즘 조정](https://neon.tech/docs/extensions/pg_embedding#tuning-the-hnsw-algorithm)을 참조하세요.

### PG에서 벡터 저장소 검색하기

```python
store = PGEmbedding(
    connection_string=connection_string,
    embedding_function=embeddings,
    collection_name=collection_name,
)

retriever = store.as_retriever()
```


```python
retriever
```


```output
VectorStoreRetriever(vectorstore=<langchain_community.vectorstores.pghnsw.HNSWVectoreStore object at 0x121d3c8b0>, search_type='similarity', search_kwargs={})
```


```python
db1 = PGEmbedding.from_existing_index(
    embedding=embeddings,
    collection_name=collection_name,
    pre_delete_collection=False,
    connection_string=connection_string,
)

query = "What did the president say about Ketanji Brown Jackson"
docs_with_score: List[Tuple[Document, float]] = db1.similarity_search_with_score(query)
```


```python
for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print(doc.page_content)
    print("-" * 80)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)