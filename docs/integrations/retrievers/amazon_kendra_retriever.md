---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/amazon_kendra_retriever.ipynb
description: Amazon Kendra는 고급 자연어 처리 및 기계 학습 알고리즘을 활용하여 조직 내 다양한 데이터 소스에서 정보를 신속하게
  검색할 수 있게 합니다.
---

# 아마존 켄드라

> [아마존 켄드라](https://docs.aws.amazon.com/kendra/latest/dg/what-is-kendra.html)는 `아마존 웹 서비스`(`AWS`)에서 제공하는 지능형 검색 서비스입니다. 이는 고급 자연어 처리(NLP) 및 기계 학습 알고리즘을 활용하여 조직 내 다양한 데이터 소스에서 강력한 검색 기능을 가능하게 합니다. `켄드라`는 사용자가 필요한 정보를 신속하고 정확하게 찾을 수 있도록 설계되어 생산성과 의사 결정을 향상시킵니다.

> `켄드라`를 사용하면 사용자는 문서, FAQ, 지식 베이스, 매뉴얼 및 웹사이트를 포함한 다양한 콘텐츠 유형에서 검색할 수 있습니다. 여러 언어를 지원하며 복잡한 쿼리, 동의어 및 맥락적 의미를 이해하여 매우 관련성 높은 검색 결과를 제공합니다.

## 아마존 켄드라 인덱스 검색기 사용하기

```python
%pip install --upgrade --quiet  boto3
```


```python
<!--IMPORTS:[{"imported": "AmazonKendraRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.kendra.AmazonKendraRetriever.html", "title": "Amazon Kendra"}]-->
from langchain_community.retrievers import AmazonKendraRetriever
```


새 검색기 만들기

```python
retriever = AmazonKendraRetriever(index_id="c0806df7-e76b-4bce-9b5c-d5582f6b1a03")
```


이제 켄드라 인덱스에서 검색된 문서를 사용할 수 있습니다.

```python
retriever.invoke("what is langchain")
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)