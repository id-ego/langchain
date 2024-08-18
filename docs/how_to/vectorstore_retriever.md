---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/vectorstore_retriever.ipynb
description: 벡터 저장소를 사용하여 문서를 검색하는 방법에 대한 가이드입니다. 검색기 생성, 검색 유형 지정 및 추가 검색 매개변수 설정을
  다룹니다.
sidebar_position: 0
---

# 벡터 저장소를 검색기로 사용하는 방법

벡터 저장소 검색기는 문서를 검색하기 위해 벡터 저장소를 사용하는 검색기입니다. 이는 검색기 인터페이스에 맞추기 위해 벡터 저장소 클래스 주위에 가벼운 래퍼를 제공합니다. 벡터 저장소에서 텍스트를 쿼리하기 위해 유사성 검색 및 MMR과 같은 벡터 저장소에서 구현된 검색 방법을 사용합니다.

이 가이드에서는 다음을 다룰 것입니다:

1. 벡터 저장소에서 검색기를 인스턴스화하는 방법;
2. 검색기의 검색 유형을 지정하는 방법;
3. 임계값 점수 및 top-k와 같은 추가 검색 매개변수를 지정하는 방법.

## 벡터 저장소에서 검색기 생성하기

벡터 저장소의 [.as_retriever](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html#langchain_core.vectorstores.VectorStore.as_retriever) 메서드를 사용하여 벡터 저장소에서 검색기를 구축할 수 있습니다. 예제를 살펴보겠습니다.

먼저 벡터 저장소를 인스턴스화합니다. 우리는 인메모리 [FAISS](https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html) 벡터 저장소를 사용할 것입니다:

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "How to use a vectorstore as a retriever"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to use a vectorstore as a retriever"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to use a vectorstore as a retriever"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "How to use a vectorstore as a retriever"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("state_of_the_union.txt")

documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(documents)
embeddings = OpenAIEmbeddings()
vectorstore = FAISS.from_documents(texts, embeddings)
```


그런 다음 검색기를 인스턴스화할 수 있습니다:

```python
retriever = vectorstore.as_retriever()
```


이렇게 하면 일반적인 방식으로 사용할 수 있는 검색기(특히 [VectorStoreRetriever](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStoreRetriever.html))가 생성됩니다:

```python
docs = retriever.invoke("what did the president say about ketanji brown jackson?")
```


## 최대 한계 관련성 검색
기본적으로 벡터 저장소 검색기는 유사성 검색을 사용합니다. 기본 벡터 저장소가 최대 한계 관련성 검색을 지원하는 경우, 이를 검색 유형으로 지정할 수 있습니다.

이는 기본 벡터 저장소에서 사용되는 방법을 효과적으로 지정합니다(예: `similarity_search`, `max_marginal_relevance_search` 등).

```python
retriever = vectorstore.as_retriever(search_type="mmr")
```


```python
docs = retriever.invoke("what did the president say about ketanji brown jackson?")
```


## 검색 매개변수 전달하기

`search_kwargs`를 사용하여 기본 벡터 저장소의 검색 방법에 매개변수를 전달할 수 있습니다.

### 유사성 점수 임계값 검색

예를 들어, 유사성 점수 임계값을 설정하고 해당 임계값을 초과하는 점수를 가진 문서만 반환할 수 있습니다.

```python
retriever = vectorstore.as_retriever(
    search_type="similarity_score_threshold", search_kwargs={"score_threshold": 0.5}
)
```


```python
docs = retriever.invoke("what did the president say about ketanji brown jackson?")
```


### 상위 k 지정하기

검색기가 반환하는 문서 수 `k`를 제한할 수도 있습니다.

```python
retriever = vectorstore.as_retriever(search_kwargs={"k": 1})
```


```python
docs = retriever.invoke("what did the president say about ketanji brown jackson?")
len(docs)
```


```output
1
```