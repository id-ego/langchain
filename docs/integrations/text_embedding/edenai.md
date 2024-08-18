---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/edenai.ipynb
description: 에덴 AI는 최고의 AI 제공업체를 통합하여 사용자가 인공지능의 무한한 가능성을 활용할 수 있도록 지원하는 플랫폼입니다.
---

# EDEN AI

Eden AI는 최고의 AI 제공업체를 통합하여 AI 환경을 혁신하고, 사용자가 무한한 가능성을 열고 인공지능의 진정한 잠재력을 활용할 수 있도록 합니다. 올인원 종합 플랫폼을 통해 사용자는 AI 기능을 신속하게 배포할 수 있으며, 단일 API를 통해 AI 기능의 전체 범위에 쉽게 접근할 수 있습니다. (웹사이트: https://edenai.co/)

이 예제는 LangChain을 사용하여 Eden AI 임베딩 모델과 상호작용하는 방법을 설명합니다.

* * *

EDENAI의 API에 접근하려면 API 키가 필요합니다.

API 키는 계정을 생성하여 https://app.edenai.run/user/register 에서 얻을 수 있으며, 여기로 가서 https://app.edenai.run/admin/account/settings 설정을 확인하세요.

키를 얻은 후에는 다음과 같이 환경 변수로 설정해야 합니다:

```shell
export EDENAI_API_KEY="..."
```


환경 변수를 설정하고 싶지 않다면 EdenAI 임베딩 클래스를 초기화할 때 edenai_api_key라는 매개변수를 통해 키를 직접 전달할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "EdenAiEmbeddings", "source": "langchain_community.embeddings.edenai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.edenai.EdenAiEmbeddings.html", "title": "EDEN AI"}]-->
from langchain_community.embeddings.edenai import EdenAiEmbeddings
```


```python
embeddings = EdenAiEmbeddings(edenai_api_key="...", provider="...")
```


## 모델 호출하기

EdenAI API는 다양한 제공업체를 통합합니다.

특정 모델에 접근하려면 호출할 때 "provider"를 간단히 사용하면 됩니다.

```python
embeddings = EdenAiEmbeddings(provider="openai")
```


```python
docs = ["It's raining right now", "cats are cute"]
document_result = embeddings.embed_documents(docs)
```


```python
query = "my umbrella is broken"
query_result = embeddings.embed_query(query)
```


```python
import numpy as np

query_numpy = np.array(query_result)
for doc_res, doc in zip(document_result, docs):
    document_numpy = np.array(doc_res)
    similarity = np.dot(query_numpy, document_numpy) / (
        np.linalg.norm(query_numpy) * np.linalg.norm(document_numpy)
    )
    print(f'Cosine similarity between "{doc}" and query: {similarity}')
```

```output
Cosine similarity between "It's raining right now" and query: 0.849261496107252
Cosine similarity between "cats are cute" and query: 0.7525900655705218
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)