---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/fireworks.ipynb
description: Fireworks 임베딩 모델을 LangChain과 함께 사용하는 방법을 안내합니다. API 키 설정 및 통합 패키지 설치
  방법을 포함합니다.
sidebar_label: Fireworks
---

# FireworksEmbeddings

이 문서는 LangChain을 사용하여 Fireworks 임베딩 모델을 시작하는 데 도움이 됩니다. `FireworksEmbeddings`의 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_fireworks.embeddings.FireworksEmbeddings.html)를 참조하십시오.

## 개요

### 통합 세부정보

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="Fireworks" />


## 설정

Fireworks 임베딩 모델에 접근하려면 Fireworks 계정을 생성하고, API 키를 얻고, `langchain-fireworks` 통합 패키지를 설치해야 합니다.

### 자격 증명

[fireworks.ai](https://fireworks.ai/)로 이동하여 Fireworks에 가입하고 API 키를 생성하십시오. 이 작업을 완료한 후 FIREWORKS_API_KEY 환경 변수를 설정하십시오:

```python
import getpass
import os

if not os.getenv("FIREWORKS_API_KEY"):
    os.environ["FIREWORKS_API_KEY"] = getpass.getpass("Enter your Fireworks API key: ")
```


모델 호출에 대한 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 제거하여 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```


### 설치

LangChain Fireworks 통합은 `langchain-fireworks` 패키지에 있습니다:

```python
%pip install -qU langchain-fireworks
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "FireworksEmbeddings", "source": "langchain_fireworks", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_fireworks.embeddings.FireworksEmbeddings.html", "title": "FireworksEmbeddings"}]-->
from langchain_fireworks import FireworksEmbeddings

embeddings = FireworksEmbeddings(
    model="nomic-ai/nomic-embed-text-v1.5",
)
```


## 인덱싱 및 검색

임베딩 모델은 종종 검색 보강 생성(RAG) 흐름에서 사용되며, 데이터 인덱싱의 일부로 사용되거나 나중에 검색하는 데 사용됩니다. 자세한 지침은 [외부 지식 사용 튜토리얼](/docs/tutorials/#working-with-external-knowledge)에서 RAG 튜토리얼을 참조하십시오.

아래에서는 위에서 초기화한 `embeddings` 객체를 사용하여 데이터를 인덱싱하고 검색하는 방법을 보여줍니다. 이 예제에서는 `InMemoryVectorStore`에서 샘플 문서를 인덱싱하고 검색할 것입니다.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "FireworksEmbeddings"}]-->
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

내부적으로 벡터 저장소 및 검색기 구현은 `embeddings.embed_documents(...)` 및 `embeddings.embed_query(...)`를 호출하여 `from_texts` 및 검색 `invoke` 작업에 사용된 텍스트에 대한 임베딩을 생성합니다.

이러한 메서드를 직접 호출하여 자신의 사용 사례에 대한 임베딩을 얻을 수 있습니다.

### 단일 텍스트 임베드

`embed_query`를 사용하여 단일 텍스트 또는 문서를 임베드할 수 있습니다:

```python
single_vector = embeddings.embed_query(text)
print(str(single_vector)[:100])  # Show the first 100 characters of the vector
```

```output
[0.01666259765625, 0.011688232421875, -0.1181640625, -0.10205078125, 0.05438232421875, -0.0890502929
```

### 다중 텍스트 임베드

`embed_documents`를 사용하여 여러 텍스트를 임베드할 수 있습니다:

```python
text2 = (
    "LangGraph is a library for building stateful, multi-actor applications with LLMs"
)
two_vectors = embeddings.embed_documents([text, text2])
for vector in two_vectors:
    print(str(vector)[:100])  # Show the first 100 characters of the vector
```

```output
[0.016632080078125, 0.01165008544921875, -0.1181640625, -0.10186767578125, 0.05438232421875, -0.0890
[-0.02667236328125, 0.036651611328125, -0.1630859375, -0.0904541015625, -0.022430419921875, -0.09545
```

## API 참조

모든 `FireworksEmbeddings` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_fireworks.embeddings.FireworksEmbeddings.html)를 참조하십시오.

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)