---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/yandex.ipynb
description: 이 문서는 Langchain을 YandexGPT 임베딩 모델과 함께 사용하는 방법에 대해 설명합니다. 서비스 계정 생성 및
  인증 옵션을 안내합니다.
---

# YandexGPT

이 노트북은 Langchain을 [YandexGPT](https://cloud.yandex.com/en/services/yandexgpt) 임베딩 모델과 함께 사용하는 방법을 설명합니다.

사용하려면 `yandexcloud` 파이썬 패키지가 설치되어 있어야 합니다.

```python
%pip install --upgrade --quiet  yandexcloud
```


먼저, `ai.languageModels.user` 역할을 가진 [서비스 계정](https://cloud.yandex.com/en/docs/iam/operations/sa/create)을 생성해야 합니다.

다음으로, 두 가지 인증 옵션이 있습니다:
- [IAM 토큰](https://cloud.yandex.com/en/docs/iam/operations/iam-token/create-for-sa).
토큰을 생성자 매개변수 `iam_token` 또는 환경 변수 `YC_IAM_TOKEN`에 지정할 수 있습니다.
- [API 키](https://cloud.yandex.com/en/docs/iam/operations/api-key/create)
키를 생성자 매개변수 `api_key` 또는 환경 변수 `YC_API_KEY`에 지정할 수 있습니다.

모델을 지정하려면 `model_uri` 매개변수를 사용할 수 있으며, 자세한 내용은 [문서](https://cloud.yandex.com/en/docs/yandexgpt/concepts/models#yandexgpt-embeddings)를 참조하십시오.

기본적으로 `folder_id` 매개변수 또는 `YC_FOLDER_ID` 환경 변수에 지정된 폴더에서 최신 버전의 `text-search-query`가 사용됩니다.

```python
<!--IMPORTS:[{"imported": "YandexGPTEmbeddings", "source": "langchain_community.embeddings.yandex", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.yandex.YandexGPTEmbeddings.html", "title": "YandexGPT"}]-->
from langchain_community.embeddings.yandex import YandexGPTEmbeddings
```


```python
embeddings = YandexGPTEmbeddings()
```


```python
text = "This is a test document."
```


```python
query_result = embeddings.embed_query(text)
```


```python
doc_result = embeddings.embed_documents([text])
```


```python
query_result[:5]
```


```output
[-0.021392822265625,
 0.096435546875,
 -0.046966552734375,
 -0.0183258056640625,
 -0.00555419921875]
```


```python
doc_result[0][:5]
```


```output
[-0.021392822265625,
 0.096435546875,
 -0.046966552734375,
 -0.0183258056640625,
 -0.00555419921875]
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)