---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/ollama.ipynb
description: Ollama 임베딩 모델을 LangChain과 함께 사용하는 방법을 안내하며, 설정 및 통합 세부정보를 제공합니다.
sidebar_label: Ollama
---

# OllamaEmbeddings

이 문서는 LangChain을 사용하여 Ollama 임베딩 모델을 시작하는 데 도움이 됩니다. `OllamaEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_ollama.embeddings.OllamaEmbeddings.html)를 참조하십시오.

## 개요
### 통합 세부정보

import { ItemTable } from "@theme/FeatureTables";

<ItemTable category="text_embedding" item="Ollama" />

## 설정

먼저 [이 지침](https://github.com/jmorganca/ollama)을 따라 로컬 Ollama 인스턴스를 설정하고 실행하십시오:

* [다운로드](https://ollama.ai/download)하여 지원되는 플랫폼(Windows Subsystem for Linux 포함)에 Ollama를 설치합니다.
* `ollama pull <모델 이름>`을 통해 사용 가능한 LLM 모델을 가져옵니다.
  * [모델 라이브러리](https://ollama.ai/library)에서 사용 가능한 모델 목록을 확인합니다.
  * 예: `ollama pull llama3`
* 이렇게 하면 모델의 기본 태그 버전이 다운로드됩니다. 일반적으로 기본은 최신의 가장 작은 크기 매개변수 모델을 가리킵니다.

> Mac에서는 모델이 `~/.ollama/models`에 다운로드됩니다.
> 
> Linux(또는 WSL)에서는 모델이 `/usr/share/ollama/.ollama/models`에 저장됩니다.

* 관심 있는 모델의 정확한 버전을 `ollama pull vicuna:13b-v1.5-16k-q4_0`와 같이 지정합니다. (이 경우 [Vicuna](https://ollama.ai/library/vicuna/tags) 모델의 다양한 태그를 확인하십시오.)
* 모든 가져온 모델을 보려면 `ollama list`를 사용합니다.
* 명령줄에서 모델과 직접 채팅하려면 `ollama run <모델 이름>`을 사용합니다.
* 더 많은 명령은 [Ollama 문서](https://github.com/jmorganca/ollama)를 참조하십시오. 터미널에서 `ollama help`를 실행하여 사용 가능한 명령도 확인하십시오.

### 자격 증명

Ollama에는 내장 인증 메커니즘이 없습니다.

모델 호출의 자동 추적을 원하시면 아래의 주석을 제거하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```


### 설치

LangChain Ollama 통합은 `langchain-ollama` 패키지에 있습니다:

```python
%pip install -qU langchain-ollama
```

```output
Note: you may need to restart the kernel to use updated packages.
```

## 인스턴스화

이제 모델 객체를 인스턴스화하고 임베딩을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "OllamaEmbeddings", "source": "langchain_ollama", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_ollama.embeddings.OllamaEmbeddings.html", "title": "OllamaEmbeddings"}]-->
from langchain_ollama import OllamaEmbeddings

embeddings = OllamaEmbeddings(
    model="llama3",
)
```


## 인덱싱 및 검색

임베딩 모델은 종종 검색 증강 생성(RAG) 흐름에서 사용되며, 데이터 인덱싱의 일부로 사용되거나 나중에 검색됩니다. 더 자세한 지침은 [외부 지식 작업 튜토리얼](/docs/tutorials/#working-with-external-knowledge)에서 RAG 튜토리얼을 참조하십시오.

아래에서 위에서 초기화한 `embeddings` 객체를 사용하여 데이터를 인덱싱하고 검색하는 방법을 확인하십시오. 이 예제에서는 `InMemoryVectorStore`에서 샘플 문서를 인덱싱하고 검색합니다.

```python
<!--IMPORTS:[{"imported": "InMemoryVectorStore", "source": "langchain_core.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.in_memory.InMemoryVectorStore.html", "title": "OllamaEmbeddings"}]-->
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

내부적으로 벡터 저장소 및 검색기 구현은 각각 `embeddings.embed_documents(...)` 및 `embeddings.embed_query(...)`를 호출하여 `from_texts` 및 검색 `invoke` 작업에 사용된 텍스트에 대한 임베딩을 생성합니다.

이러한 메서드를 직접 호출하여 자신의 사용 사례에 대한 임베딩을 얻을 수 있습니다.

### 단일 텍스트 임베드

`embed_query`를 사용하여 단일 텍스트 또는 문서를 임베드할 수 있습니다:

```python
single_vector = embeddings.embed_query(text)
print(str(single_vector)[:100])  # Show the first 100 characters of the vector
```

```output
[-0.001288981, 0.006547121, 0.018376578, 0.025603496, 0.009599175, -0.0042578303, -0.023250086, -0.0
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
[-0.0013138362, 0.006438795, 0.018304596, 0.025530428, 0.009717592, -0.004225636, -0.023363983, -0.0
[-0.010317663, 0.01632489, 0.0070348927, 0.017076202, 0.008924255, 0.007399284, -0.023064945, -0.003
```

## API 참조

`OllamaEmbeddings` 기능 및 구성 옵션에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_ollama.embeddings.OllamaEmbeddings.html)를 참조하십시오.

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)