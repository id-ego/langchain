---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/xinference.ipynb
description: 이 문서는 LangChain에서 Xinference 임베딩을 사용하는 방법과 설치, 배포 및 래퍼 사용법에 대해 설명합니다.
---

# Xorbits 추론 (Xinference)

이 노트북은 LangChain 내에서 Xinference 임베딩을 사용하는 방법에 대해 설명합니다.

## 설치

PyPI를 통해 `Xinference`를 설치합니다:

```python
%pip install --upgrade --quiet  "xinference[all]"
```


## Xinference를 로컬 또는 분산 클러스터에 배포하기

로컬 배포를 위해 `xinference`를 실행합니다.

클러스터에 Xinference를 배포하려면 먼저 `xinference-supervisor`를 사용하여 Xinference 감독자를 시작합니다. -p 옵션을 사용하여 포트를 지정하고 -H 옵션을 사용하여 호스트를 지정할 수 있습니다. 기본 포트는 9997입니다.

그런 다음, 각 서버에서 `xinference-worker`를 사용하여 Xinference 작업자를 시작합니다.

자세한 정보는 [Xinference](https://github.com/xorbitsai/inference)에서 README 파일을 참조하십시오.

## 래퍼

LangChain과 함께 Xinference를 사용하려면 먼저 모델을 시작해야 합니다. 이를 위해 명령줄 인터페이스(CLI)를 사용할 수 있습니다:

```python
!xinference launch -n vicuna-v1.3 -f ggmlv3 -q q4_0
```

```output
Model uid: 915845ee-2a04-11ee-8ed4-d29396a3f064
```

모델 UID가 반환되어 사용 가능합니다. 이제 LangChain과 함께 Xinference 임베딩을 사용할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "XinferenceEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.xinference.XinferenceEmbeddings.html", "title": "Xorbits inference (Xinference)"}]-->
from langchain_community.embeddings import XinferenceEmbeddings

xinference = XinferenceEmbeddings(
    server_url="http://0.0.0.0:9997", model_uid="915845ee-2a04-11ee-8ed4-d29396a3f064"
)
```


```python
query_result = xinference.embed_query("This is a test query")
```


```python
doc_result = xinference.embed_documents(["text A", "text B"])
```


마지막으로, 더 이상 사용할 필요가 없을 때 모델을 종료합니다:

```python
!xinference terminate --model-uid "915845ee-2a04-11ee-8ed4-d29396a3f064"
```


## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)