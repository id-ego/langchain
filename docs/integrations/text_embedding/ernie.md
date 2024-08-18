---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/ernie.ipynb
description: ERNIE는 텍스트를 벡터 형태로 변환하는 모델로, 정보 검색 및 추천에 사용됩니다. QianfanEmbeddingsEndpoint로의
  전환을 권장합니다.
---

# ERNIE

[ERNIE Embedding-V1](https://cloud.baidu.com/doc/WENXINWORKSHOP/s/alj562vvu)는 `Baidu Wenxin` 대규모 모델 기술을 기반으로 한 텍스트 표현 모델로, 텍스트를 숫자 값으로 표현된 벡터 형태로 변환하며, 텍스트 검색, 정보 추천, 지식 마이닝 및 기타 시나리오에 사용됩니다.

**사용 중단 경고**

사용자에게 `langchain_community.embeddings.ErnieEmbeddings` 대신 `langchain_community.embeddings.QianfanEmbeddingsEndpoint`를 사용할 것을 권장합니다.

`QianfanEmbeddingsEndpoint`에 대한 문서는 [여기](/docs/integrations/text_embedding/baidu_qianfan_endpoint/)에서 확인할 수 있습니다.

사용자에게 `QianfanEmbeddingsEndpoint`를 사용할 것을 권장하는 이유는 다음과 같습니다:

1. `QianfanEmbeddingsEndpoint`는 Qianfan 플랫폼에서 더 많은 임베딩 모델을 지원합니다.
2. `ErnieEmbeddings`는 유지 관리가 부족하고 사용 중단되었습니다.

마이그레이션을 위한 몇 가지 팁:

```python
<!--IMPORTS:[{"imported": "QianfanEmbeddingsEndpoint", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.baidu_qianfan_endpoint.QianfanEmbeddingsEndpoint.html", "title": "ERNIE"}]-->
from langchain_community.embeddings import QianfanEmbeddingsEndpoint

embeddings = QianfanEmbeddingsEndpoint(
    qianfan_ak="your qianfan ak",
    qianfan_sk="your qianfan sk",
)
```


## 사용법

```python
<!--IMPORTS:[{"imported": "ErnieEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.ernie.ErnieEmbeddings.html", "title": "ERNIE"}]-->
from langchain_community.embeddings import ErnieEmbeddings
```


```python
embeddings = ErnieEmbeddings()
```


```python
query_result = embeddings.embed_query("foo")
```


```python
doc_results = embeddings.embed_documents(["foo"])
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)