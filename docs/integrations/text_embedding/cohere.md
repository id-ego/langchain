---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/cohere.ipynb
description: Cohere 임베딩 모델을 LangChain과 함께 사용하는 방법을 안내합니다. API 키 생성 및 설치 방법에 대한 정보를
  포함합니다.
sidebar_label: Cohere
---

# CohereEmbeddings

이 문서는 LangChain을 사용하여 Cohere 임베딩 모델을 시작하는 데 도움이 됩니다. `CohereEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_cohere.embeddings.CohereEmbeddings.html)를 참조하십시오.

## 개요
### 통합 세부정보

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="Cohere" />

## 설정

Cohere 임베딩 모델에 접근하려면 Cohere 계정을 생성하고, API 키를 얻고, `langchain-cohere` 통합 패키지를 설치해야 합니다.

### 자격 증명

[Cohere.com](https://cohere.com)으로 가서 Cohere에 가입하고 API 키를 생성하십시오. 이 작업을 완료한 후 COHERE_API_KEY 환경 변수를 설정하십시오:

```python
import getpass
import os

if not os.getenv("COHERE_API_KEY"):
    os.environ["COHERE_API_KEY"] = getpass.getpass("Enter your Cohere API key: ")
```


모델 호출의 자동 추적을 원하신다면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```


### 설치

LangChain Cohere 통합은 `langchain-cohere` 패키지에 있습니다:

```python
%pip install -qU langchain-cohere
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "CohereEmbeddings", "source": "langchain_cohere", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_cohere.embeddings.CohereEmbeddings.html", "title": "CohereEmbeddings"}]-->
from langchain_cohere import CohereEmbeddings

embeddings = CohereEmbeddings(
    model="embed-english-v3.0",
)
```


## 인덱싱 및 검색

임베딩 모델은 종종 검색 증강 생성(RAG) 흐름에서 사용되며, 데이터 인덱싱의 일부로 사용되거나 나중에 검색하는 데 사용됩니다. 더 자세한 지침은 [외부 지식 작업하기 튜토리얼](/docs/tutorials/#working-with-external-knowledge)에서 확인하십시오.

아래에서는 위에서 초기화한 `embeddings` 객체를 사용하여 데이터를 인덱싱하고 검색하는 방법을 보여줍니다. 이 예에서는 `InMemoryVectorStore`에서 샘플 문서를 인덱싱하고 검색할 것입니다.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "CohereEmbeddings"}]-->
# Create a vector store with a sample text
from langchain_core.vectorstores import InMemoryVectorStore

text = "LangChain is the framework for building context-aware reasoning applications"

vectorstore = InMemoryVectorStore.from_texts(
    [text],
    embedding=embeddings,
)

# Use the vectorstore as a retriever
retriever = vectorstore.as_retriever()

# Retrieve the most similar text
retrieved_documents = retriever.invoke("What is LangChain?")

# show the retrieved document's content
retrieved_documents[0].page_content
```


```output
'LangChain is the framework for building context-aware reasoning applications'
```


## 직접 사용

내부적으로 벡터 저장소 및 검색기 구현은 `embeddings.embed_documents(...)` 및 `embeddings.embed_query(...)`를 호출하여 `from_texts` 및 검색 `invoke` 작업에 사용된 텍스트의 임베딩을 생성합니다.

이러한 메서드를 직접 호출하여 자신의 사용 사례에 대한 임베딩을 얻을 수 있습니다.

### 단일 텍스트 임베딩

단일 텍스트 또는 문서를 `embed_query`로 임베딩할 수 있습니다:

```python
single_vector = embeddings.embed_query(text)
print(str(single_vector)[:100])  # Show the first 100 characters of the vector
```

```output
[-0.022979736, -0.030212402, -0.08886719, -0.08569336, 0.007030487, -0.0010671616, -0.033813477, 0.0
```

### 여러 텍스트 임베딩

여러 텍스트를 `embed_documents`로 임베딩할 수 있습니다:

```python
text2 = (
    "LangGraph is a library for building stateful, multi-actor applications with LLMs"
)
two_vectors = embeddings.embed_documents([text, text2])
for vector in two_vectors:
    print(str(vector)[:100])  # Show the first 100 characters of the vector
```

```output
[-0.028869629, -0.030410767, -0.099121094, -0.07116699, -0.012748718, -0.0059432983, -0.04360962, 0.
[-0.047332764, -0.049957275, -0.07458496, -0.034332275, -0.057922363, -0.0112838745, -0.06994629, 0.
```

## API 참조

`CohereEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_cohere.embeddings.CohereEmbeddings.html)를 참조하십시오.

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)