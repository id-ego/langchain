---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/faiss.ipynb
description: FAISS는 밀집 벡터의 효율적인 유사성 검색 및 클러스터링을 위한 라이브러리로, 대규모 벡터 집합에서 검색을 지원합니다.
---

# Faiss

> [페이스북 AI 유사도 검색 (FAISS)](https://engineering.fb.com/2017/03/29/data-infrastructure/faiss-a-library-for-efficient-similarity-search/)는 밀집 벡터의 효율적인 유사도 검색 및 클러스터링을 위한 라이브러리입니다. 이 라이브러리는 RAM에 맞지 않을 수도 있는 크기의 벡터 집합에서 검색하는 알고리즘을 포함하고 있습니다. 또한 평가 및 매개변수 조정을 위한 지원 코드를 포함하고 있습니다.

FAISS 문서는 [이 페이지](https://faiss.ai/)에서 확인할 수 있습니다.

이 노트북은 `FAISS` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다. 이 통합에 특정한 기능을 보여줄 것입니다. 진행한 후, 이 벡터 저장소를 더 큰 체인의 일부로 사용하는 방법을 배우기 위해 [관련 사용 사례 페이지](/docs/how_to#qa-with-rag)를 탐색하는 것이 유용할 수 있습니다.

## 설정

이 통합은 `langchain-community` 패키지에 있습니다. 우리는 또한 `faiss` 패키지 자체를 설치해야 합니다. 다음과 같이 설치할 수 있습니다:

GPU 지원 버전을 사용하려면 `faiss-gpu`를 설치할 수도 있습니다.

```python
pip install -qU langchain-community faiss-cpu
```


모델 호출에 대한 최상의 자동 추적을 얻으려면 아래의 주석을 제거하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 초기화

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "InMemoryDocstore", "source": "langchain_community.docstore.in_memory", "docs": "https://api.python.langchain.com/en/latest/docstore/langchain_community.docstore.in_memory.InMemoryDocstore.html", "title": "Faiss"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "Faiss"}]-->
import faiss
from langchain_community.docstore.in_memory import InMemoryDocstore
from langchain_community.vectorstores import FAISS

index = faiss.IndexFlatL2(len(embeddings.embed_query("hello world")))

vector_store = FAISS(
    embedding_function=embeddings,
    index=index,
    docstore=InMemoryDocstore(),
    index_to_docstore_id={},
)
```


## 벡터 저장소 관리

### 벡터 저장소에 항목 추가

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Faiss"}]-->
from uuid import uuid4

from langchain_core.documents import Document

document_1 = Document(
    page_content="I had chocalate chip pancakes and scrambled eggs for breakfast this morning.",
    metadata={"source": "tweet"},
)

document_2 = Document(
    page_content="The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees.",
    metadata={"source": "news"},
)

document_3 = Document(
    page_content="Building an exciting new project with LangChain - come check it out!",
    metadata={"source": "tweet"},
)

document_4 = Document(
    page_content="Robbers broke into the city bank and stole $1 million in cash.",
    metadata={"source": "news"},
)

document_5 = Document(
    page_content="Wow! That was an amazing movie. I can't wait to see it again.",
    metadata={"source": "tweet"},
)

document_6 = Document(
    page_content="Is the new iPhone worth the price? Read this review to find out.",
    metadata={"source": "website"},
)

document_7 = Document(
    page_content="The top 10 soccer players in the world right now.",
    metadata={"source": "website"},
)

document_8 = Document(
    page_content="LangGraph is the best framework for building stateful, agentic applications!",
    metadata={"source": "tweet"},
)

document_9 = Document(
    page_content="The stock market is down 500 points today due to fears of a recession.",
    metadata={"source": "news"},
)

document_10 = Document(
    page_content="I have a bad feeling I am going to get deleted :(",
    metadata={"source": "tweet"},
)

documents = [
    document_1,
    document_2,
    document_3,
    document_4,
    document_5,
    document_6,
    document_7,
    document_8,
    document_9,
    document_10,
]
uuids = [str(uuid4()) for _ in range(len(documents))]

vector_store.add_documents(documents=documents, ids=uuids)
```


```output
['22f5ce99-cd6f-4e0c-8dab-664128307c72',
 'dc3f061b-5f88-4fa1-a966-413550c51891',
 'd33d890b-baad-47f7-b7c1-175f5f7b4e59',
 '6e6c01d2-6020-4a7b-95da-ef43d43f01b5',
 'e677223d-ad75-4c1a-bef6-b5912bd1de03',
 '47e2a168-6462-4ed2-b1d9-d9edfd7391d6',
 '1e4d66d6-e155-4891-9212-f7be97f36c6a',
 'c0663096-e1a5-4665-b245-1c2e6c4fb653',
 '8297474a-7f7c-4006-9865-398c1781b1bc',
 '44e4be03-0a8d-4316-b3c4-f35f4bb2b532']
```


### 벡터 저장소에서 항목 삭제

```python
vector_store.delete(ids=[uuids[-1]])
```


```output
True
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인이나 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다.

### 직접 쿼리

#### 유사도 검색

메타데이터 필터링을 통해 간단한 유사도 검색을 수행할 수 있습니다:

```python
results = vector_store.similarity_search(
    "LangChain provides abstractions to make working with LLMs easy",
    k=2,
    filter={"source": "tweet"},
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```

```output
* Building an exciting new project with LangChain - come check it out! [{'source': 'tweet'}]
* LangGraph is the best framework for building stateful, agentic applications! [{'source': 'tweet'}]
```


#### 점수와 함께 유사도 검색

점수와 함께 검색할 수도 있습니다:

```python
results = vector_store.similarity_search_with_score(
    "Will it be hot tomorrow?", k=1, filter={"source": "news"}
)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```

```output
* [SIM=0.893688] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'source': 'news'}]
```


#### 기타 검색 방법

FAISS 벡터 저장소를 검색하는 다양한 방법이 있습니다. 이러한 방법의 전체 목록은 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html)를 참조하십시오.

### 검색기로 변환하여 쿼리

벡터 저장소를 체인에서 더 쉽게 사용할 수 있도록 검색기로 변환할 수도 있습니다.

```python
retriever = vector_store.as_retriever(search_type="mmr", search_kwargs={"k": 1})
retriever.invoke("Stealing from the bank is a crime", filter={"source": "news"})
```


```output
[Document(metadata={'source': 'news'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```


## 검색 증강 생성 사용법

검색 증강 생성(RAG)을 위해 이 벡터 저장소를 사용하는 방법에 대한 가이드는 다음 섹션을 참조하십시오:

- [튜토리얼: 외부 지식 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG로 질문 및 답변하기](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

## 저장 및 로드
FAISS 인덱스를 저장하고 로드할 수도 있습니다. 이는 사용할 때마다 다시 생성할 필요가 없도록 유용합니다.

```python
vector_store.save_local("faiss_index")

new_vector_store = FAISS.load_local(
    "faiss_index", embeddings, allow_dangerous_deserialization=True
)

docs = new_vector_store.similarity_search("qux")
```


```python
docs[0]
```


```output
Document(metadata={'source': 'tweet'}, page_content='Building an exciting new project with LangChain - come check it out!')
```


## 병합
두 개의 FAISS 벡터 저장소를 병합할 수도 있습니다.

```python
db1 = FAISS.from_texts(["foo"], embeddings)
db2 = FAISS.from_texts(["bar"], embeddings)

db1.docstore._dict
```


```output
{'b752e805-350e-4cf5-ba54-0883d46a3a44': Document(page_content='foo')}
```


```python
db2.docstore._dict
```


```output
{'08192d92-746d-4cd1-b681-bdfba411f459': Document(page_content='bar')}
```


```python
db1.merge_from(db2)
```


```python
db1.docstore._dict
```


```output
{'b752e805-350e-4cf5-ba54-0883d46a3a44': Document(page_content='foo'),
 '08192d92-746d-4cd1-b681-bdfba411f459': Document(page_content='bar')}
```


## API 참조

모든 `FAISS` 벡터 저장소 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하십시오: https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)