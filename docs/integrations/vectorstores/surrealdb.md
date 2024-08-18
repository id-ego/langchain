---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/surrealdb.ipynb
description: SurrealDB는 현대 애플리케이션을 위한 클라우드 네이티브 데이터베이스로, 개발 시간을 단축하고 안전하고 성능 높은 앱을
  빠르게 구축할 수 있습니다.
---

# SurrealDB

> [SurrealDB](https://surrealdb.com/)는 웹, 모바일, 서버리스, Jamstack, 백엔드 및 전통적인 애플리케이션을 포함한 현대 애플리케이션을 위해 설계된 엔드 투 엔드 클라우드 네이티브 데이터베이스입니다. SurrealDB를 사용하면 데이터베이스 및 API 인프라를 단순화하고 개발 시간을 줄이며 안전하고 성능이 뛰어난 애플리케이션을 빠르고 비용 효율적으로 구축할 수 있습니다.
> 
> **SurrealDB의 주요 기능:**
> 
> * **개발 시간 단축:** SurrealDB는 대부분의 서버 측 구성 요소를 제거하여 데이터베이스 및 API 스택을 단순화하므로 안전하고 성능이 뛰어난 애플리케이션을 더 빠르고 저렴하게 구축할 수 있습니다.
> * **실시간 협업 API 백엔드 서비스:** SurrealDB는 데이터베이스와 API 백엔드 서비스로 기능하여 실시간 협업을 가능하게 합니다.
> * **다양한 쿼리 언어 지원:** SurrealDB는 클라이언트 장치에서 SQL 쿼리, GraphQL, ACID 트랜잭션, WebSocket 연결, 구조화된 및 비구조화된 데이터, 그래프 쿼리, 전체 텍스트 인덱싱 및 지리 공간 쿼리를 지원합니다.
> * **세분화된 접근 제어:** SurrealDB는 행 수준의 권한 기반 접근 제어를 제공하여 데이터 접근을 정밀하게 관리할 수 있는 능력을 부여합니다.
> 
> [기능](https://surrealdb.com/features), 최신 [릴리스](https://surrealdb.com/releases), 및 [문서](https://surrealdb.com/docs)를 확인하세요.

이 노트북은 `SurrealDBStore`와 관련된 기능을 사용하는 방법을 보여줍니다.

## 설정

아래 셀의 주석을 제거하여 surrealdb를 설치하세요.

```python
# %pip install --upgrade --quiet  surrealdb langchain langchain-community
```


## SurrealDBStore 사용하기

```python
# add this import for running in jupyter notebook
import nest_asyncio

nest_asyncio.apply()
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "SurrealDB"}, {"imported": "SurrealDBStore", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.surrealdb.SurrealDBStore.html", "title": "SurrealDB"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "SurrealDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "SurrealDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import SurrealDBStore
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
documents = TextLoader("../../how_to/state_of_the_union.txt").load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = HuggingFaceEmbeddings()
```


### SurrealDBStore 객체 생성

```python
db = SurrealDBStore(
    dburl="ws://localhost:8000/rpc",  # url for the hosted SurrealDB database
    embedding_function=embeddings,
    db_user="root",  # SurrealDB credentials if needed: db username
    db_pass="root",  # SurrealDB credentials if needed: db password
    # ns="langchain", # namespace to use for vectorstore
    # db="database",  # database to use for vectorstore
    # collection="documents", #collection to use for vectorstore
)

# this is needed to initialize the underlying async library for SurrealDB
await db.initialize()

# delete all existing documents from the vectorstore collection
await db.adelete()

# add documents to the vectorstore
ids = await db.aadd_documents(docs)

# document ids of the added documents
ids[:5]
```


```output
['documents:38hz49bv1p58f5lrvrdc',
 'documents:niayw63vzwm2vcbh6w2s',
 'documents:it1fa3ktplbuye43n0ch',
 'documents:il8f7vgbbp9tywmsn98c',
 'documents:vza4c6cqje0avqd58gal']
```


### (대안으로) SurrealDBStore 객체를 생성하고 문서 추가

```python
await db.adelete()

db = await SurrealDBStore.afrom_documents(
    dburl="ws://localhost:8000/rpc",  # url for the hosted SurrealDB database
    embedding=embeddings,
    documents=docs,
    db_user="root",  # SurrealDB credentials if needed: db username
    db_pass="root",  # SurrealDB credentials if needed: db password
    # ns="langchain", # namespace to use for vectorstore
    # db="database",  # database to use for vectorstore
    # collection="documents", #collection to use for vectorstore
)
```


### 유사성 검색

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = await db.asimilarity_search(query)
```


```python
print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

### 점수가 있는 유사성 검색

반환된 거리 점수는 코사인 거리입니다. 따라서 낮은 점수가 더 좋습니다.

```python
docs = await db.asimilarity_search_with_score(query)
```


```python
docs[0]
```


```output
(Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'id': 'documents:slgdlhjkfknhqo15xz0w', 'source': '../../how_to/state_of_the_union.txt'}),
 0.39839531721941895)
```


## 관련

- 벡터 스토어 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 스토어 [사용 방법 가이드](/docs/how_to/#vector-stores)