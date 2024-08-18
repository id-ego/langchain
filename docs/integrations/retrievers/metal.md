---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/metal.ipynb
description: Metal은 ML 임베딩을 위한 관리형 서비스로, 문서 검색을 위한 리트리버 사용법을 소개하는 노트북입니다.
---

# 메탈

> [메탈](https://github.com/getmetal/metal-python)은 ML 임베딩을 위한 관리형 서비스입니다.

이 노트북은 [메탈](https://docs.getmetal.io/introduction)의 검색기를 사용하는 방법을 보여줍니다.

먼저, 메탈에 가입하고 API 키를 받아야 합니다. [여기](https://docs.getmetal.io/misc-create-app)에서 할 수 있습니다.

```python
%pip install --upgrade --quiet  metal_sdk
```


```python
from metal_sdk.metal import Metal

API_KEY = ""
CLIENT_ID = ""
INDEX_ID = ""

metal = Metal(API_KEY, CLIENT_ID, INDEX_ID)
```


## 문서 수집

인덱스를 아직 설정하지 않았다면 이 작업을 수행해야 합니다.

```python
metal.index({"text": "foo1"})
metal.index({"text": "foo"})
```


```output
{'data': {'id': '642739aa7559b026b4430e42',
  'text': 'foo',
  'createdAt': '2023-03-31T19:51:06.748Z'}}
```


## 쿼리

이제 인덱스가 설정되었으므로 검색기를 설정하고 쿼리를 시작할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "MetalRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.metal.MetalRetriever.html", "title": "Metal"}]-->
from langchain_community.retrievers import MetalRetriever
```


```python
retriever = MetalRetriever(metal, params={"limit": 2})
```


```python
retriever.invoke("foo1")
```


```output
[Document(page_content='foo1', metadata={'dist': '1.19209289551e-07', 'id': '642739a17559b026b4430e40', 'createdAt': '2023-03-31T19:50:57.853Z'}),
 Document(page_content='foo1', metadata={'dist': '4.05311584473e-06', 'id': '642738f67559b026b4430e3c', 'createdAt': '2023-03-31T19:48:06.769Z'})]
```


## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)