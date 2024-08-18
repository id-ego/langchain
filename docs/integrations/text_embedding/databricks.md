---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/databricks.ipynb
description: 이 문서는 Databricks Lakehouse Platform에서 모델 서빙을 통해 LangChain 애플리케이션에서 임베딩
  모델을 사용하는 방법을 소개합니다.
---

# Databricks

> [Databricks](https://www.databricks.com/) 레이크하우스 플랫폼은 데이터, 분석 및 AI를 하나의 플랫폼에서 통합합니다.

이 노트북은 Databricks [임베딩 모델](/docs/concepts/#embedding-models) 시작을 위한 간단한 개요를 제공합니다. 모든 DatabricksEmbeddings 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.databricks.DatabricksEmbeddings.html)로 이동하십시오.

## 개요

`DatabricksEmbeddings` 클래스는 [Databricks 모델 서빙](https://docs.databricks.com/en/machine-learning/model-serving/index.html)에서 호스팅되는 임베딩 모델 엔드포인트를 래핑합니다. 이 예제 노트북은 서빙 엔드포인트를 래핑하고 LangChain 애플리케이션에서 임베딩 모델로 사용하는 방법을 보여줍니다.

### 지원되는 메서드

`DatabricksEmbeddings`는 비동기 API를 포함하여 `Embeddings` 클래스의 모든 메서드를 지원합니다.

### 엔드포인트 요구 사항

래핑된 서빙 엔드포인트 `DatabricksEmbeddings`는 OpenAI 호환 임베딩 입력/출력 형식이 있어야 합니다 ([참조](https://mlflow.org/docs/latest/llms/deployments/index.html#embeddings)). 입력 형식이 호환되는 한, `DatabricksEmbeddings`는 [Databricks 모델 서빙](https://docs.databricks.com/en/machine-learning/model-serving/index.html)에서 호스팅되는 모든 엔드포인트 유형에 사용할 수 있습니다:

1. 기초 모델 - BAAI 일반 임베딩(BGE)과 같은 최첨단 기초 모델의 선별된 목록. 이러한 엔드포인트는 설정 없이 Databricks 작업 공간에서 바로 사용할 수 있습니다.
2. 사용자 정의 모델 - LangChain, Pytorch, Transformers 등과 같은 프레임워크를 통해 MLflow를 사용하여 사용자 정의 임베딩 모델을 서빙 엔드포인트에 배포할 수 있습니다.
3. 외부 모델 - Databricks 엔드포인트는 OpenAI text-embedding-3과 같은 독점 모델 서비스와 같은 Databricks 외부에 호스팅된 모델을 프록시로 제공할 수 있습니다.

## 설정

Databricks 모델에 접근하려면 Databricks 계정을 생성하고, 자격 증명을 설정(단, Databricks 작업 공간 외부에 있는 경우에만)하고, 필요한 패키지를 설치해야 합니다.

### 자격 증명 (Databricks 외부에 있는 경우에만)

Databricks 내에서 LangChain 앱을 실행하는 경우 이 단계를 건너뛸 수 있습니다.

그렇지 않으면 Databricks 작업 공간 호스트 이름과 개인 액세스 토큰을 각각 `DATABRICKS_HOST` 및 `DATABRICKS_TOKEN` 환경 변수에 수동으로 설정해야 합니다. 액세스 토큰을 얻는 방법은 [인증 문서](https://docs.databricks.com/en/dev-tools/auth/index.html#databricks-personal-access-tokens)를 참조하십시오.

```python
import getpass
import os

os.environ["DATABRICKS_HOST"] = "https://your-workspace.cloud.databricks.com"
os.environ["DATABRICKS_TOKEN"] = getpass.getpass("Enter your Databricks access token: ")
```


### 설치

LangChain Databricks 통합은 `langchain-community` 패키지에 있습니다. 또한, 이 노트북의 코드를 실행하려면 `mlflow >= 2.9`가 필요합니다.

```python
%pip install -qU langchain-community mlflow>=2.9.0
```


우리는 먼저 `DatabricksEmbeddings`를 사용하여 기초 모델 엔드포인트로 호스팅되는 BGE 모델을 쿼리하는 방법을 보여줍니다.

다른 유형의 엔드포인트의 경우 엔드포인트 자체를 설정하는 방법에 약간의 차이가 있지만, 엔드포인트가 준비되면 쿼리하는 방법에는 차이가 없습니다.

## 인스턴스화

```python
<!--IMPORTS:[{"imported": "DatabricksEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.databricks.DatabricksEmbeddings.html", "title": "Databricks"}]-->
from langchain_community.embeddings import DatabricksEmbeddings

embeddings = DatabricksEmbeddings(
    endpoint="databricks-bge-large-en",
    # Specify parameters for embedding queries and documents if needed
    # query_params={...},
    # document_params={...},
)
```


## 단일 텍스트 임베드

```python
embeddings.embed_query("hello")[:3]
```

```output
[0.051055908203125, 0.007221221923828125, 0.003879547119140625]
```

## 문서 임베드

```python
documents = ["This is a dummy document.", "This is another dummy document."]
response = embeddings.embed_documents(documents)
print([e[:3] for e in response])  # Show first 3 elements of each embedding
```


## 다른 유형의 엔드포인트 래핑

위의 예제는 기초 모델 API로 호스팅되는 임베딩 모델을 사용합니다. 다른 엔드포인트 유형을 사용하는 방법에 대한 정보는 `ChatDatabricks` 문서를 참조하십시오. 모델 유형은 다르지만 필요한 단계는 동일합니다.

* [사용자 정의 모델 엔드포인트](https://python.langchain.com/v0.2/docs/integrations/chat/databricks/#wrapping-custom-model-endpoint)
* [외부 모델](https://python.langchain.com/v0.2/docs/integrations/chat/databricks/#wrapping-external-models)

## API 참조

모든 ChatDatabricks 기능 및 구성에 대한 자세한 문서는 API 참조로 이동하십시오: https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.databricks.DatabricksEmbeddings.html

## 관련

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)