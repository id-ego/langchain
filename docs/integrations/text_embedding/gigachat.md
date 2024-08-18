---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/gigachat.ipynb
description: 이 문서는 LangChain과 GigaChat 임베딩을 사용하는 방법을 보여줍니다. GigaChat API 사용을 위한 설치
  및 인증 과정이 포함되어 있습니다.
---

# GigaChat
이 노트북은 LangChain을 [GigaChat 임베딩](https://developers.sber.ru/portal/products/gigachat)과 함께 사용하는 방법을 보여줍니다. 사용하려면 `gigachat` 파이썬 패키지를 설치해야 합니다.

```python
%pip install --upgrade --quiet  gigachat
```


GigaChat 자격 증명을 얻으려면 [계정을 생성](https://developers.sber.ru/studio/login)하고 [API에 대한 액세스를 얻어야](https://developers.sber.ru/docs/ru/gigachat/individuals-quickstart) 합니다.

## 예시

```python
import os
from getpass import getpass

os.environ["GIGACHAT_CREDENTIALS"] = getpass()
```


```python
<!--IMPORTS:[{"imported": "GigaChatEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.gigachat.GigaChatEmbeddings.html", "title": "GigaChat"}]-->
from langchain_community.embeddings import GigaChatEmbeddings

embeddings = GigaChatEmbeddings(verify_ssl_certs=False, scope="GIGACHAT_API_PERS")
```


```python
query_result = embeddings.embed_query("The quick brown fox jumps over the lazy dog")
```


```python
query_result[:5]
```


```output
[0.8398333191871643,
 -0.14180311560630798,
 -0.6161925792694092,
 -0.17103666067123413,
 1.2884578704833984]
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)