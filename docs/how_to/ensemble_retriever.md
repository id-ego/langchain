---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/ensemble_retriever.ipynb
description: 여러 검색기의 결과를 결합하는 방법을 설명하며, EnsembleRetriever와 그 작동 원리를 소개합니다. 하이브리드 검색의
  장점을 강조합니다.
---

# 여러 검색기에서 결과 결합하는 방법

[EnsembleRetriever](https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.ensemble.EnsembleRetriever.html)는 여러 검색기의 결과를 앙상블하는 것을 지원합니다. 이는 [BaseRetriever](https://api.python.langchain.com/en/latest/retrievers/langchain_core.retrievers.BaseRetriever.html) 객체의 목록으로 초기화됩니다. EnsembleRetrievers는 [Reciprocal Rank Fusion](https://plg.uwaterloo.ca/~gvcormac/cormacksigir09-rrf.pdf) 알고리즘에 따라 구성 요소 검색기의 결과를 재순위화합니다.

다양한 알고리즘의 강점을 활용함으로써 `EnsembleRetriever`는 단일 알고리즘보다 더 나은 성능을 달성할 수 있습니다.

가장 일반적인 패턴은 희소 검색기(BM25와 같은)와 밀집 검색기(임베딩 유사성과 같은)를 결합하는 것입니다. 이 두 검색기의 강점은 상호 보완적이기 때문입니다. 이를 "하이브리드 검색"이라고도 합니다. 희소 검색기는 키워드를 기반으로 관련 문서를 찾는 데 강하고, 밀집 검색기는 의미적 유사성을 기반으로 관련 문서를 찾는 데 강합니다.

## 기본 사용법

아래에서는 [BM25Retriever](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.bm25.BM25Retriever.html)와 [FAISS 벡터 저장소](https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html)에서 파생된 검색기를 앙상블하는 방법을 보여줍니다.

```python
%pip install --upgrade --quiet  rank_bm25 > /dev/null
```


```python
<!--IMPORTS:[{"imported": "EnsembleRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.ensemble.EnsembleRetriever.html", "title": "How to combine results from multiple retrievers"}, {"imported": "BM25Retriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.bm25.BM25Retriever.html", "title": "How to combine results from multiple retrievers"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to combine results from multiple retrievers"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to combine results from multiple retrievers"}]-->
from langchain.retrievers import EnsembleRetriever
from langchain_community.retrievers import BM25Retriever
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings

doc_list_1 = [
    "I like apples",
    "I like oranges",
    "Apples and oranges are fruits",
]

# initialize the bm25 retriever and faiss retriever
bm25_retriever = BM25Retriever.from_texts(
    doc_list_1, metadatas=[{"source": 1}] * len(doc_list_1)
)
bm25_retriever.k = 2

doc_list_2 = [
    "You like apples",
    "You like oranges",
]

embedding = OpenAIEmbeddings()
faiss_vectorstore = FAISS.from_texts(
    doc_list_2, embedding, metadatas=[{"source": 2}] * len(doc_list_2)
)
faiss_retriever = faiss_vectorstore.as_retriever(search_kwargs={"k": 2})

# initialize the ensemble retriever
ensemble_retriever = EnsembleRetriever(
    retrievers=[bm25_retriever, faiss_retriever], weights=[0.5, 0.5]
)
```


```python
docs = ensemble_retriever.invoke("apples")
docs
```


```output
[Document(page_content='I like apples', metadata={'source': 1}),
 Document(page_content='You like apples', metadata={'source': 2}),
 Document(page_content='Apples and oranges are fruits', metadata={'source': 1}),
 Document(page_content='You like oranges', metadata={'source': 2})]
```


## 런타임 구성

우리는 또한 [구성 가능한 필드](/docs/how_to/configure)를 사용하여 런타임에 개별 검색기를 구성할 수 있습니다. 아래에서는 FAISS 검색기에 대해 "top-k" 매개변수를 업데이트합니다:

```python
<!--IMPORTS:[{"imported": "ConfigurableField", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.utils.ConfigurableField.html", "title": "How to combine results from multiple retrievers"}]-->
from langchain_core.runnables import ConfigurableField

faiss_retriever = faiss_vectorstore.as_retriever(
    search_kwargs={"k": 2}
).configurable_fields(
    search_kwargs=ConfigurableField(
        id="search_kwargs_faiss",
        name="Search Kwargs",
        description="The search kwargs to use",
    )
)

ensemble_retriever = EnsembleRetriever(
    retrievers=[bm25_retriever, faiss_retriever], weights=[0.5, 0.5]
)
```


```python
config = {"configurable": {"search_kwargs_faiss": {"k": 1}}}
docs = ensemble_retriever.invoke("apples", config=config)
docs
```


```output
[Document(page_content='I like apples', metadata={'source': 1}),
 Document(page_content='You like apples', metadata={'source': 2}),
 Document(page_content='Apples and oranges are fruits', metadata={'source': 1})]
```


이것은 런타임에 관련 구성을 전달하기 때문에 FAISS 검색기에서 하나의 소스만 반환하는 것을 주의하세요.