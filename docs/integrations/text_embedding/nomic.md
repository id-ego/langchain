---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/nomic.ipynb
description: Nomic Embeddings를 LangChain과 함께 사용하여 텍스트 임베딩 모델을 시작하는 방법을 안내합니다. API
  참조를 통해 자세한 내용을 확인하세요.
sidebar_label: Nomic
---

# NomicEmbeddings

이 문서는 LangChain을 사용하여 Nomic 임베딩 모델을 시작하는 데 도움이 됩니다. `NomicEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_nomic.embeddings.NomicEmbeddings.html)를 참조하십시오.

## 개요
### 통합 세부정보

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="Nomic" />


## 설정

Nomic 임베딩 모델에 접근하려면 Nomic 계정을 생성하고, API 키를 얻고, `langchain-nomic` 통합 패키지를 설치해야 합니다.

### 자격 증명

[Nomic에 가입하고 API 키를 생성하려면](https://atlas.nomic.ai/)로 이동하십시오. 이 작업을 완료한 후 `NOMIC_API_KEY` 환경 변수를 설정하십시오:

```python
import getpass
import os

if not os.getenv("NOMIC_API_KEY"):
    os.environ["NOMIC_API_KEY"] = getpass.getpass("Enter your Nomic API key: ")
```


모델 호출의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키 주석을 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```


### 설치

LangChain Nomic 통합은 `langchain-nomic` 패키지에 있습니다:

```python
%pip install -qU langchain-nomic
```

```output
Note: you may need to restart the kernel to use updated packages.
```

## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "NomicEmbeddings", "source": "langchain_nomic", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_nomic.embeddings.NomicEmbeddings.html", "title": "NomicEmbeddings"}]-->
from langchain_nomic import NomicEmbeddings

embeddings = NomicEmbeddings(
    model="nomic-embed-text-v1.5",
    # dimensionality=256,
    # Nomic's `nomic-embed-text-v1.5` model was [trained with Matryoshka learning](https://blog.nomic.ai/posts/nomic-embed-matryoshka)
    # to enable variable-length embeddings with a single model.
    # This means that you can specify the dimensionality of the embeddings at inference time.
    # The model supports dimensionality from 64 to 768.
    # inference_mode="remote",
    # One of `remote`, `local` (Embed4All), or `dynamic` (automatic). Defaults to `remote`.
    # api_key=... , # if using remote inference,
    # device="cpu",
    # The device to use for local embeddings. Choices include
    # `cpu`, `gpu`, `nvidia`, `amd`, or a specific device name. See
    # the docstring for `GPT4All.__init__` for more info. Typically
    # defaults to CPU. Do not use on macOS.
)
```


## 인덱싱 및 검색

임베딩 모델은 종종 검색 증강 생성(RAG) 흐름에서 데이터 인덱싱의 일환으로 사용되며, 이후 데이터를 검색하는 데 사용됩니다. 자세한 지침은 [외부 지식 작업하기 튜토리얼](/docs/tutorials/#working-with-external-knowledge)에서 확인하십시오.

아래에서는 위에서 초기화한 `embeddings` 객체를 사용하여 데이터를 인덱싱하고 검색하는 방법을 보여줍니다. 이 예제에서는 `InMemoryVectorStore`에서 샘플 문서를 인덱싱하고 검색합니다.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "NomicEmbeddings"}]-->
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

내부적으로 벡터 저장소 및 검색기 구현은 각각 `embeddings.embed_documents(...)` 및 `embeddings.embed_query(...)`를 호출하여 `from_texts` 및 검색 `invoke` 작업에 사용되는 텍스트의 임베딩을 생성합니다.

이 메서드를 직접 호출하여 자신의 사용 사례에 대한 임베딩을 얻을 수 있습니다.

### 단일 텍스트 임베딩

`embed_query`를 사용하여 단일 텍스트 또는 문서를 임베딩할 수 있습니다:

```python
single_vector = embeddings.embed_query(text)
print(str(single_vector)[:100])  # Show the first 100 characters of the vector
```

```output
[0.024642944, 0.029083252, -0.14013672, -0.09082031, 0.058898926, -0.07489014, -0.0138168335, 0.0037
```

### 다중 텍스트 임베딩

`embed_documents`를 사용하여 여러 텍스트를 임베딩할 수 있습니다:

```python
text2 = (
    "LangGraph is a library for building stateful, multi-actor applications with LLMs"
)
two_vectors = embeddings.embed_documents([text, text2])
for vector in two_vectors:
    print(str(vector)[:100])  # Show the first 100 characters of the vector
```

```output
[0.012771606, 0.023727417, -0.12365723, -0.083740234, 0.06530762, -0.07110596, -0.021896362, -0.0068
[-0.019058228, 0.04058838, -0.15222168, -0.06842041, -0.012130737, -0.07128906, -0.04534912, 0.00522
```

## API 참조

`NomicEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_nomic.embeddings.NomicEmbeddings.html)를 참조하십시오.

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)