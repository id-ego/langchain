---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/pinecone.ipynb
description: 이 문서는 Pinecone 벡터 데이터베이스의 기능 사용법을 설명하며, 설정 및 초기화 과정을 안내합니다.
---

# 파인콘

> [파인콘](https://docs.pinecone.io/docs/overview)은 폭넓은 기능을 가진 벡터 데이터베이스입니다.

이 노트북은 `Pinecone` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

## 설정

`PineconeVectorStore`를 사용하려면 먼저 파트너 패키지와 이 노트북 전반에서 사용되는 다른 패키지를 설치해야 합니다.

```python
%pip install -qU langchain-pinecone pinecone-notebooks
```


마이그레이션 노트: `langchain_community.vectorstores`의 파인콘 구현에서 마이그레이션하는 경우, `langchain-pinecone`를 설치하기 전에 `pinecone-client` v2 의존성을 제거해야 할 수 있습니다. 이는 `pinecone-client` v3에 의존합니다.

### 자격 증명

새로운 파인콘 계정을 생성하거나 기존 계정에 로그인하고 이 노트북에서 사용할 API 키를 생성합니다.

```python
import getpass
import os
import time

from pinecone import Pinecone, ServerlessSpec

if not os.getenv("PINECONE_API_KEY"):
    os.environ["PINECONE_API_KEY"] = getpass.getpass("Enter your Pinecone API key: ")

pinecone_api_key = os.environ.get("PINECONE_API_KEY")

pc = Pinecone(api_key=pinecone_api_key)
```


모델 호출의 자동 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


## 초기화

벡터 저장소를 초기화하기 전에 파인콘 인덱스에 연결합시다. `index_name`이라는 이름의 인덱스가 존재하지 않으면 생성됩니다.

```python
import time

index_name = "langchain-test-index"  # change if desired

existing_indexes = [index_info["name"] for index_info in pc.list_indexes()]

if index_name not in existing_indexes:
    pc.create_index(
        name=index_name,
        dimension=3072,
        metric="cosine",
        spec=ServerlessSpec(cloud="aws", region="us-east-1"),
    )
    while not pc.describe_index(index_name).status["ready"]:
        time.sleep(1)

index = pc.Index(index_name)
```


이제 파인콘 인덱스가 설정되었으므로 벡터 저장소를 초기화할 수 있습니다.

import EmbeddingTabs from "@theme/EmbeddingTabs";

<EmbeddingTabs/>

```python
<!--IMPORTS:[{"imported": "PineconeVectorStore", "source": "langchain_pinecone", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_pinecone.vectorstores.PineconeVectorStore.html", "title": "Pinecone"}]-->
from langchain_pinecone import PineconeVectorStore

vector_store = PineconeVectorStore(index=index, embedding=embeddings)
```


## 벡터 저장소 관리

벡터 저장소를 생성한 후에는 다양한 항목을 추가하고 삭제하여 상호작용할 수 있습니다.

### 벡터 저장소에 항목 추가

`add_documents` 함수를 사용하여 벡터 저장소에 항목을 추가할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Pinecone"}]-->
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
['167b8681-5974-467f-adcb-6e987a18df01',
 'd16010fd-41f8-4d49-9c22-c66d5555a3fe',
 'ffcacfb3-2bc2-44c3-a039-c2256a905c0e',
 'cf3bfc9f-5dc7-4f5e-bb41-edb957394126',
 'e99b07eb-fdff-4cb9-baa8-619fd8efeed3',
 '68c93033-a24f-40bd-8492-92fa26b631a4',
 'b27a4ecb-b505-4c5d-89ff-526e3d103558',
 '4868a9e6-e6fb-4079-b400-4a1dfbf0d4c4',
 '921c0e9c-0550-4eb5-9a6c-ed44410788b2',
 'c446fc23-64e8-47e7-8c19-ecf985e9411e']
```


### 벡터 저장소에서 항목 삭제

```python
vector_store.delete(ids=[uuids[-1]])
```


## 벡터 저장소 쿼리

벡터 저장소가 생성되고 관련 문서가 추가되면 체인이나 에이전트를 실행하는 동안 쿼리하고 싶을 것입니다.

### 직접 쿼리

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

#### 점수를 포함한 유사성 검색

점수를 포함하여 검색할 수도 있습니다:

```python
results = vector_store.similarity_search_with_score(
    "Will it be hot tomorrow?", k=1, filter={"source": "news"}
)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```

```output
* [SIM=0.553187] The weather forecast for tomorrow is cloudy and overcast, with a high of 62 degrees. [{'source': 'news'}]
```

#### 기타 검색 방법

이 노트북에 나열되지 않은 더 많은 검색 방법(예: MMR)이 있으며, 모든 방법을 찾으려면 [API 참조](https://api.python.langchain.com/en/latest/vectorstores/langchain_pinecone.vectorstores.PineconeVectorStore.html)를 반드시 읽어보세요.

### 검색기로 변환하여 쿼리

벡터 저장소를 체인에서 더 쉽게 사용할 수 있도록 검색기로 변환할 수도 있습니다.

```python
retriever = vector_store.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"k": 1, "score_threshold": 0.5},
)
retriever.invoke("Stealing from the bank is a crime", filter={"source": "news"})
```


```output
[Document(metadata={'source': 'news'}, page_content='Robbers broke into the city bank and stole $1 million in cash.')]
```


## 검색 증강 생성 사용법

검색 증강 생성(RAG)을 위해 이 벡터 저장소를 사용하는 방법에 대한 가이드는 다음 섹션을 참조하세요:

- [튜토리얼: 외부 지식 작업하기](https://python.langchain.com/v0.2/docs/tutorials/#working-with-external-knowledge)
- [방법: RAG로 질문 및 답변](https://python.langchain.com/v0.2/docs/how_to/#qa-with-rag)
- [검색 개념 문서](https://python.langchain.com/v0.2/docs/concepts/#retrieval)

## API 참조

모든 __ModuleName__VectorStore 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/vectorstores/langchain_pinecone.vectorstores.PineconeVectorStore.html

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [방법 가이드](/docs/how_to/#vector-stores)