---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/gradient.ipynb
description: Gradient를 사용하여 Embeddings를 생성하고 LLM을 조정 및 완성하는 방법을 Langchain과 함께 설명합니다.
---

# 그래디언트

`Gradient`는 간단한 웹 API를 통해 `Embeddings`를 생성하고 LLM에서 완성을 조정하고 얻을 수 있게 해줍니다.

이 노트북은 [Gradient](https://gradient.ai/)의 Embeddings와 함께 Langchain을 사용하는 방법을 다룹니다.

## 임포트

```python
<!--IMPORTS:[{"imported": "GradientEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.gradient_ai.GradientEmbeddings.html", "title": "Gradient"}]-->
from langchain_community.embeddings import GradientEmbeddings
```


## 환경 API 키 설정
Gradient AI에서 API 키를 반드시 받아야 합니다. 다양한 모델을 테스트하고 조정하기 위해 $10의 무료 크레딧이 제공됩니다.

```python
import os
from getpass import getpass

if not os.environ.get("GRADIENT_ACCESS_TOKEN", None):
    # Access token under https://auth.gradient.ai/select-workspace
    os.environ["GRADIENT_ACCESS_TOKEN"] = getpass("gradient.ai access token:")
if not os.environ.get("GRADIENT_WORKSPACE_ID", None):
    # `ID` listed in `$ gradient workspace list`
    # also displayed after login at at https://auth.gradient.ai/select-workspace
    os.environ["GRADIENT_WORKSPACE_ID"] = getpass("gradient.ai workspace id:")
```


선택 사항: 현재 배포된 모델을 얻기 위해 환경 변수 `GRADIENT_ACCESS_TOKEN` 및 `GRADIENT_WORKSPACE_ID`를 검증합니다. `gradientai` Python 패키지를 사용합니다.

```python
%pip install --upgrade --quiet  gradientai
```


## Gradient 인스턴스 생성

```python
documents = [
    "Pizza is a dish.",
    "Paris is the capital of France",
    "numpy is a lib for linear algebra",
]
query = "Where is Paris?"
```


```python
embeddings = GradientEmbeddings(model="bge-large")

documents_embedded = embeddings.embed_documents(documents)
query_result = embeddings.embed_query(query)
```


```python
# (demo) compute similarity
import numpy as np

scores = np.array(documents_embedded) @ np.array(query_result).T
dict(zip(documents, scores))
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)