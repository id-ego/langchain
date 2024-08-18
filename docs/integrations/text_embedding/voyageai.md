---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/voyageai.ipynb
description: Voyage AI는 최첨단 임베딩 모델을 제공하며, API 키를 통해 사용량을 모니터링하고 권한을 관리합니다. 다양한 모델을
  지원합니다.
---

# Voyage AI

> [Voyage AI](https://www.voyageai.com/)는 최첨단 임베딩/벡터화 모델을 제공합니다.

Voyage AI Embedding 클래스를 로드해 봅시다. (`pip install langchain-voyageai`로 LangChain 파트너 패키지를 설치하세요)

```python
<!--IMPORTS:[{"imported": "VoyageAIEmbeddings", "source": "langchain_voyageai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_voyageai.embeddings.VoyageAIEmbeddings.html", "title": "Voyage AI"}]-->
from langchain_voyageai import VoyageAIEmbeddings
```


Voyage AI는 API 키를 사용하여 사용량을 모니터링하고 권한을 관리합니다. 키를 얻으려면 [홈페이지](https://www.voyageai.com)에서 계정을 생성하세요. 그런 다음 API 키로 VoyageEmbeddings 모델을 생성하세요. 다음 모델 중 하나를 사용할 수 있습니다: ([source](https://docs.voyageai.com/docs/embeddings)):

- `voyage-large-2` (기본값)
- `voyage-code-2`
- `voyage-2`
- `voyage-law-2`
- `voyage-large-2-instruct`
- `voyage-finance-2`
- `voyage-multilingual-2`

```python
embeddings = VoyageAIEmbeddings(
    voyage_api_key="[ Your Voyage API key ]", model="voyage-law-2"
)
```


문서를 준비하고 `embed_documents`를 사용하여 임베딩을 가져옵니다.

```python
documents = [
    "Caching embeddings enables the storage or temporary caching of embeddings, eliminating the necessity to recompute them each time.",
    "An LLMChain is a chain that composes basic LLM functionality. It consists of a PromptTemplate and a language model (either an LLM or chat model). It formats the prompt template using the input key values provided (and also memory key values, if available), passes the formatted string to LLM and returns the LLM output.",
    "A Runnable represents a generic unit of work that can be invoked, batched, streamed, and/or transformed.",
]
```


```python
documents_embds = embeddings.embed_documents(documents)
```


```python
documents_embds[0][:5]
```


```output
[0.0562174916267395,
 0.018221192061901093,
 0.0025736060924828053,
 -0.009720131754875183,
 0.04108370840549469]
```


유사하게, `embed_query`를 사용하여 쿼리를 임베딩합니다.

```python
query = "What's an LLMChain?"
```


```python
query_embd = embeddings.embed_query(query)
```


```python
query_embd[:5]
```


```output
[-0.0052348352037370205,
 -0.040072452276945114,
 0.0033957737032324076,
 0.01763271726667881,
 -0.019235141575336456]
```


## 미니멀리스트 검색 시스템

임베딩의 주요 특징은 두 임베딩 간의 코사인 유사성이 해당 원본 구문 간의 의미적 관련성을 포착한다는 것입니다. 이를 통해 임베딩을 사용하여 의미적 검색을 수행할 수 있습니다.

우리는 코사인 유사성을 기반으로 문서 임베딩에서 몇 개의 가장 가까운 임베딩을 찾고, LangChain의 `KNNRetriever` 클래스를 사용하여 해당 문서를 검색할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "KNNRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.knn.KNNRetriever.html", "title": "Voyage AI"}]-->
from langchain_community.retrievers import KNNRetriever

retriever = KNNRetriever.from_texts(documents, embeddings)

# retrieve the most relevant documents
result = retriever.invoke(query)
top1_retrieved_doc = result[0].page_content  # return the top1 retrieved result

print(top1_retrieved_doc)
```

```output
An LLMChain is a chain that composes basic LLM functionality. It consists of a PromptTemplate and a language model (either an LLM or chat model). It formats the prompt template using the input key values provided (and also memory key values, if available), passes the formatted string to LLM and returns the LLM output.
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)