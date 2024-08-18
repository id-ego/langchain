---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/openai.ipynb
description: OpenAI 임베딩 모델을 LangChain으로 시작하는 방법을 안내합니다. API 키 설정 및 통합 패키지 설치 방법을 포함합니다.
keywords:
- openaiembeddings
sidebar_label: OpenAI
---

# OpenAIEmbeddings

이 문서는 LangChain을 사용하여 OpenAI 임베딩 모델을 시작하는 데 도움이 됩니다. `OpenAIEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html)를 참조하십시오.

## 개요
### 통합 세부정보

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="OpenAI" />


## 설정

OpenAI 임베딩 모델에 접근하려면 OpenAI 계정을 생성하고, API 키를 얻고, `langchain-openai` 통합 패키지를 설치해야 합니다.

### 자격 증명

[platform.openai.com](https://platform.openai.com)로 이동하여 OpenAI에 가입하고 API 키를 생성하십시오. 이 작업을 완료한 후 OPENAI_API_KEY 환경 변수를 설정하십시오:

```python
import getpass
import os

if not os.getenv("OPENAI_API_KEY"):
    os.environ["OPENAI_API_KEY"] = getpass.getpass("Enter your OpenAI API key: ")
```


모델 호출의 자동 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수도 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```


### 설치

LangChain OpenAI 통합은 `langchain-openai` 패키지에 있습니다:

```python
%pip install -qU langchain-openai
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "OpenAIEmbeddings"}]-->
from langchain_openai import OpenAIEmbeddings

embeddings = OpenAIEmbeddings(
    model="text-embedding-3-large",
    # With the `text-embedding-3` class
    # of models, you can specify the size
    # of the embeddings you want returned.
    # dimensions=1024
)
```


## 인덱싱 및 검색

임베딩 모델은 종종 검색 보강 생성(RAG) 흐름에서 사용되며, 데이터 인덱싱의 일부로 사용되거나 나중에 검색하는 데 사용됩니다. 더 자세한 지침은 [외부 지식 작업하기 튜토리얼](/docs/tutorials/#working-with-external-knowledge)에서 RAG 튜토리얼을 참조하십시오.

아래에서 위에서 초기화한 `embeddings` 객체를 사용하여 데이터를 인덱싱하고 검색하는 방법을 확인하십시오. 이 예제에서는 `InMemoryVectorStore`에서 샘플 문서를 인덱싱하고 검색합니다.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "OpenAIEmbeddings"}]-->
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

내부적으로 벡터 저장소 및 검색기 구현은 `embeddings.embed_documents(...)` 및 `embeddings.embed_query(...)`를 호출하여 각각 `from_texts` 및 검색 `invoke` 작업에 사용된 텍스트에 대한 임베딩을 생성합니다.

이러한 메서드를 직접 호출하여 자신의 사용 사례에 대한 임베딩을 얻을 수 있습니다.

### 단일 텍스트 임베드

`embed_query`를 사용하여 단일 텍스트 또는 문서를 임베드할 수 있습니다:

```python
single_vector = embeddings.embed_query(text)
print(str(single_vector)[:100])  # Show the first 100 characters of the vector
```

```output
[-0.019276829436421394, 0.0037708976306021214, -0.03294256329536438, 0.0037671267054975033, 0.008175
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
[-0.019260549917817116, 0.0037612367887049913, -0.03291035071015358, 0.003757466096431017, 0.0082049
[-0.010181212797760963, 0.023419594392180443, -0.04215526953339577, -0.001532090245746076, -0.023573
```

## API 참조

`OpenAIEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html)를 참조하십시오.

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)