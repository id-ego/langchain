---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/elastic_search_bm25.ipynb
description: Elasticsearch는 RESTful 검색 엔진으로, BM25는 검색 쿼리에 대한 문서의 관련성을 평가하는 랭킹 함수입니다.
---

# ElasticSearch BM25

> [Elasticsearch](https://www.elastic.co/elasticsearch/)는 분산형 RESTful 검색 및 분석 엔진입니다. HTTP 웹 인터페이스와 스키마 없는 JSON 문서를 갖춘 분산형 다중 테넌트 지원 전체 텍스트 검색 엔진을 제공합니다.

> 정보 검색에서 [Okapi BM25](https://en.wikipedia.org/wiki/Okapi_BM25) (BM은 best matching의 약자)는 검색 엔진이 주어진 검색 쿼리에 대한 문서의 관련성을 추정하는 데 사용하는 순위 함수입니다. 이는 1970년대와 1980년대에 Stephen E. Robertson, Karen Spärck Jones 및 기타 사람들이 개발한 확률적 검색 프레임워크에 기반하고 있습니다.

> 실제 순위 함수의 이름은 BM25입니다. 전체 이름인 Okapi BM25는 1980년대와 1990년대에 런던 시티 대학교에서 구현된 Okapi 정보 검색 시스템의 이름을 포함합니다. BM25와 그 새로운 변형들, 예를 들어 문서 구조와 앵커 텍스트를 고려할 수 있는 BM25F(버전의 BM25)는 문서 검색에 사용되는 TF-IDF 유사 검색 함수를 나타냅니다.

이 노트북은 `ElasticSearch`와 `BM25`를 사용하는 검색기를 사용하는 방법을 보여줍니다.

BM25의 세부 사항에 대한 더 많은 정보는 [이 블로그 게시물](https://www.elastic.co/blog/practical-bm25-part-2-the-bm25-algorithm-and-its-variables)을 참조하십시오.

```python
%pip install --upgrade --quiet  elasticsearch
```


```python
<!--IMPORTS:[{"imported": "ElasticSearchBM25Retriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.elastic_search_bm25.ElasticSearchBM25Retriever.html", "title": "ElasticSearch BM25"}]-->
from langchain_community.retrievers import (
    ElasticSearchBM25Retriever,
)
```


## 새 검색기 만들기

```python
elasticsearch_url = "http://localhost:9200"
retriever = ElasticSearchBM25Retriever.create(elasticsearch_url, "langchain-index-4")
```


```python
# Alternatively, you can load an existing index
# import elasticsearch
# elasticsearch_url="http://localhost:9200"
# retriever = ElasticSearchBM25Retriever(elasticsearch.Elasticsearch(elasticsearch_url), "langchain-index")
```


## 텍스트 추가 (필요한 경우)

검색기에 텍스트를 추가할 수 있습니다 (이미 포함되어 있지 않은 경우).

```python
retriever.add_texts(["foo", "bar", "world", "hello", "foo bar"])
```


```output
['cbd4cb47-8d9f-4f34-b80e-ea871bc49856',
 'f3bd2e24-76d1-4f9b-826b-ec4c0e8c7365',
 '8631bfc8-7c12-48ee-ab56-8ad5f373676e',
 '8be8374c-3253-4d87-928d-d73550a2ecf0',
 'd79f457b-2842-4eab-ae10-77aa420b53d7']
```


## 검색기 사용하기

이제 검색기를 사용할 수 있습니다!

```python
result = retriever.invoke("foo")
```


```python
result
```


```output
[Document(page_content='foo', metadata={}),
 Document(page_content='foo bar', metadata={})]
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)