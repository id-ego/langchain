---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/chroma.ipynb
description: 이 문서는 `Chroma` 벡터 저장소를 시작하는 방법과 설정, 초기화 과정을 다룹니다. AI-native 오픈소스 데이터베이스에
  대해 알아보세요.
---

# Chroma

이 노트북은 `Chroma` 벡터 저장소를 시작하는 방법을 다룹니다.

> [Chroma](https://docs.trychroma.com/getting-started)는 개발자 생산성과 행복에 중점을 둔 AI 네이티브 오픈 소스 벡터 데이터베이스입니다. Chroma는 Apache 2.0 라이센스 하에 배포됩니다. `Chroma`의 전체 문서는 [이 페이지](https://docs.trychroma.com/reference/py-collection)에서 확인할 수 있으며, LangChain 통합에 대한 API 참조는 [이 페이지](https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html)에서 찾을 수 있습니다.

## 설정

`Chroma` 벡터 저장소에 접근하려면 `langchain-chroma` 통합 패키지를 설치해야 합니다.

```python
pip install -qU "langchain-chroma>=0.1.2"
```


### 자격 증명

자격 증명 없이 `Chroma` 벡터 저장소를 사용할 수 있으며, 위의 패키지를 설치하는 것만으로 충분합니다!

모델 호출에 대한 최상의 자동 추적을 원하신다면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 초기화

### 기본 초기화

아래는 데이터를 로컬에 저장하기 위한 디렉토리 사용을 포함한 기본 초기화입니다.

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Chroma"}]-->
from langchain_chroma import Chroma

vector_store = Chroma(
    collection_name="example_collection",
    embedding_function=embeddings,
    persist_directory="./chroma_langchain_db",  # Where to save data locally, remove if not neccesary
)
```


### 클라이언트에서 초기화

`Chroma` 클라이언트에서 초기화할 수도 있으며, 이는 기본 데이터베이스에 더 쉽게 접근하고자 할 때 유용합니다.

```python
import chromadb

persistent_client = chromadb.PersistentClient()
collection = persistent_client.get_or_create_collection("collection_name")
collection.add(ids=["1", "2", "3"], documents=["a", "b", "c"])

vector_store_from_client = Chroma(
    client=persistent_client,
    collection_name="collection_name",
    embedding_function=embeddings,
)
```


## 벡터 저장소 관리

벡터 저장소를 생성한 후에는 다양한 항목을 추가하고 삭제하여 상호작용할 수 있습니다.

### 벡터 저장소에 항목 추가

`add_documents` 함수를 사용하여 벡터 저장소에 항목을 추가할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Chroma"}]-->
from uuid import uuid4

from langchain_core.documents import Document

document_1 = Document(
    page_content="I had chocalate chip pancakes and scrambled eggs for breakfast this morning.",
    metadata={"source": "tweet"},
    id=1,
)

document_2 = Document(
    page_content="The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees.",
    metadata={"source": "news"},
    id=2,
)

document_3 = Document(
    page_content="Building an exciting new project with LangChain - come check it out!",
    metadata={"source": "tweet"},
    id=3,
)

document_4 = Document(
    page_content="Robbers broke into the city bank and stole $1 million in cash.",
    metadata={"source": "news"},
    id=4,
)

document_5 = Document(
    page_content="Wow! That was an amazing movie. I can't wait to see it again.",
    metadata={"source": "tweet"},
    id=5,
)

document_6 = Document(
    page_content="Is the new iPhone worth the price? Read this review to find out.",
    metadata={"source": "website"},
    id=6,
)

document_7 = Document(
    page_content="The top 10 soccer players in the world right now.",
    metadata={"source": "website"},
    id=7,
)

document_8 = Document(
    page_content="LangGraph is the best framework for building stateful, agentic applications!",
    metadata={"source": "tweet"},
    id=8,
)

document_9 = Document(
    page_content="The stock market is down 500 points today due to fears of a recession.",
    metadata={"source": "news"},
    id=9,
)

document_10 = Document(
    page_content="I have a bad feeling I am going to get deleted :(",
    metadata={"source": "tweet"},
    id=10,
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
['f22ed484-6db3-4b76-adb1-18a777426cd6',
 'e0d5bab4-6453-4511-9a37-023d9d288faa',
 '877d76b8-3580-4d9e-a13f-eed0fa3d134a',
 '26eaccab-81ce-4c0a-8e76-bf542647df18',
 'bcaa8239-7986-4050-bf40-e14fb7dab997',
 'cdc44b38-a83f-4e49-b249-7765b334e09d',
 'a7a35354-2687-4bc2-8242-3849a4d18d34',
 '8780caf1-d946-4f27-a707-67d037e9e1d8',
 'dec6af2a-7326-408f-893d-7d7d717dfda9',
 '3b18e210-bb59-47a0-8e17-c8e51176ea5e']
```


### 벡터 저장소의 항목 업데이트

벡터 저장소에 문서를 추가한 후, `update_documents` 함수를 사용하여 기존 문서를 업데이트할 수 있습니다.

```python
updated_document_1 = Document(
    page_content="I had chocalate chip pancakes and fried eggs for breakfast this morning.",
    metadata={"source": "tweet"},
    id=1,
)

updated_document_2 = Document(
    page_content="The weather forecast for tomorrow is sunny and warm, with a high of 82 degrees.",
    metadata={"source": "news"},
    id=2,
)

vector_store.update_document(document_id=uuids[0], document=updated_document_1)
# You can also update multiple documents at once
vector_store.update_documents(
    ids=uuids[:2], documents=[updated_document_1, updated_document_1]
)
```


### 벡터 저장소에서 항목 삭제

다음과 같이 벡터 저장소에서 항목을 삭제할 수 있습니다:

```python
vector_store.delete(ids=uuids[-1])
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인이나 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다.

### 직접 쿼리

#### 유사성 검색

간단한 유사성 검색은 다음과 같이 수행할 수 있습니다:

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


#### 점수가 포함된 유사성 검색

유사성 검색을 실행하고 해당 점수를 받으려면 다음을 실행할 수 있습니다:

```python
results = vector_store.similarity_search_with_score(
    "Will it be hot tomorrow?", k=1, filter={"source": "news"}
)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```

```output
* [SIM=1.726390] The stock market is down 500 points today due to fears of a recession. [{'source': 'news'}]
```


#### 벡터로 검색

벡터로 검색할 수도 있습니다:

```python
results = vector_store.similarity_search_by_vector(
    embedding=embeddings.embed_query("I love green eggs and ham!"), k=1
)
for doc in results:
    print(f"* {doc.page_content} [{doc.metadata}]")
```

```output
* I had chocalate chip pancakes and fried eggs for breakfast this morning. [{'source': 'tweet'}]
```


#### 기타 검색 방법

MMR 검색이나 벡터로 검색하는 것과 같이 이 노트북에서 다루지 않는 다양한 다른 검색 방법이 있습니다. `AstraDBVectorStore`에 대한 검색 기능의 전체 목록은 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_astradb.vectorstores.AstraDBVectorStore.html)에서 확인하세요.

### 검색기로 변환하여 쿼리하기

벡터 저장소를 검색기로 변환하여 체인에서 더 쉽게 사용할 수 있습니다. 다양한 검색 유형 및 전달할 수 있는 kwargs에 대한 자세한 정보는 [여기](https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html#langchain_chroma.vectorstores.Chroma.as_retriever)에서 API 참조를 방문하세요.

```python
retriever = vector_store.as_retriever(
    search_type="mmr", search_kwargs={"k": 1, "fetch_k": 5}
)
retriever.invoke("Stealing from the bank is a crime", filter={"source": "news"})
```


```output
[Document(metadata={'source': 'news'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```


## 검색 보강 생성 사용법

이 벡터 저장소를 검색 보강 생성(RAG)에 사용하는 방법에 대한 가이드는 다음 섹션을 참조하세요:

- [튜토리얼: 외부 지식과 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG를 통한 질문과 답변](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

## API 참조

모든 `Chroma` 벡터 저장소 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인하세요: https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)