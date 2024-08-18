---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/azureopenai.ipynb
description: AzureOpenAI 임베딩 모델을 LangChain과 함께 사용하는 방법을 안내합니다. 설정, 자격 증명 및 통합 세부정보를
  포함합니다.
sidebar_label: AzureOpenAI
---

# AzureOpenAIEmbeddings

이 문서는 LangChain을 사용하여 AzureOpenAI 임베딩 모델을 시작하는 데 도움이 됩니다. `AzureOpenAIEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.azure.AzureOpenAIEmbeddings.html)를 참조하십시오.

## 개요
### 통합 세부정보

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="AzureOpenAI" />

## 설정

AzureOpenAI 임베딩 모델에 접근하려면 Azure 계정을 생성하고, API 키를 얻고, `langchain-openai` 통합 패키지를 설치해야 합니다.

### 자격 증명

Azure OpenAI 인스턴스가 배포되어 있어야 합니다. 이 [가이드](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to-create-resource?pivots=web-portal)를 따라 Azure Portal에서 버전을 배포할 수 있습니다.

인스턴스가 실행 중이면 인스턴스의 이름과 키를 확인하십시오. 키는 Azure Portal의 “Keys and Endpoint” 섹션에서 찾을 수 있습니다.

```bash
AZURE_OPENAI_ENDPOINT=<YOUR API ENDPOINT>
AZURE_OPENAI_API_KEY=<YOUR_KEY>
AZURE_OPENAI_API_VERSION="2024-02-01"
```


```python
import getpass
import os

if not os.getenv("OPENAI_API_KEY"):
    os.environ["OPENAI_API_KEY"] = getpass.getpass("Enter your AzureOpenAI API key: ")
```


모델 호출에 대한 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```


### 설치

LangChain AzureOpenAI 통합은 `langchain-openai` 패키지에 있습니다:

```python
%pip install -qU langchain-openai
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완료를 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "AzureOpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.azure.AzureOpenAIEmbeddings.html", "title": "AzureOpenAIEmbeddings"}]-->
from langchain_openai import AzureOpenAIEmbeddings

embeddings = AzureOpenAIEmbeddings(
    model="text-embedding-3-large",
    # dimensions: Optional[int] = None, # Can specify dimensions with new text-embedding-3 models
    # azure_endpoint="https://<your-endpoint>.openai.azure.com/", If not provided, will read env variable AZURE_OPENAI_ENDPOINT
    # api_key=... # Can provide an API key directly. If missing read env variable AZURE_OPENAI_API_KEY
    # openai_api_version=..., # If not provided, will read env variable AZURE_OPENAI_API_VERSION
)
```


## 인덱싱 및 검색

임베딩 모델은 종종 검색 증강 생성(RAG) 흐름에서 데이터 인덱싱의 일부로 사용되며, 이후 데이터를 검색하는 데 사용됩니다. 더 자세한 지침은 [외부 지식 작업하기 튜토리얼](/docs/tutorials/#working-with-external-knowledge)에서 확인하십시오.

아래에서 위에서 초기화한 `embeddings` 객체를 사용하여 데이터를 인덱싱하고 검색하는 방법을 확인하십시오. 이 예제에서는 `InMemoryVectorStore`에서 샘플 문서를 인덱싱하고 검색합니다.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "AzureOpenAIEmbeddings"}]-->
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

내부적으로 벡터 저장소 및 검색기 구현은 각각 `embeddings.embed_documents(...)` 및 `embeddings.embed_query(...)`를 호출하여 `from_texts` 및 검색 `invoke` 작업에 사용되는 텍스트에 대한 임베딩을 생성합니다.

이 메서드를 직접 호출하여 자신의 사용 사례에 대한 임베딩을 얻을 수 있습니다.

### 단일 텍스트 임베드

`embed_query`를 사용하여 단일 텍스트 또는 문서를 임베드할 수 있습니다:

```python
single_vector = embeddings.embed_query(text)
print(str(single_vector)[:100])  # Show the first 100 characters of the vector
```

```output
[-0.0011676070280373096, 0.007125577889382839, -0.014674457721412182, -0.034061674028635025, 0.01128
```


### 다수의 텍스트 임베드

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
[-0.0011966148158535361, 0.007160289213061333, -0.014659193344414234, -0.03403077274560928, 0.011280
[-0.005595256108790636, 0.016757294535636902, -0.011055258102715015, -0.031094247475266457, -0.00363
```


## API 참조

`AzureOpenAIEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.azure.AzureOpenAIEmbeddings.html)를 참조하십시오.

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)