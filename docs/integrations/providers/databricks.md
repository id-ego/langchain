---
description: Databricks는 생성 AI로 구동되는 데이터 인텔리전스 플랫폼으로, LangChain 생태계를 통해 모델 제공 및 벡터
  검색을 지원합니다.
---

# Databricks

> [Databricks](https://www.databricks.com/) 인텔리전스 플랫폼은 생성 AI로 구동되는 세계 최초의 데이터 인텔리전스 플랫폼입니다. 비즈니스의 모든 측면에 AI를 주입하세요.

Databricks는 다양한 방식으로 LangChain 생태계를 수용합니다:

1. 🚀 **모델 서빙** - [Databricks Model Serving](https://www.databricks.com/product/model-serving)에서 DBRX, Llama3, Mixtral 또는 여러분의 세밀하게 조정된 모델과 같은 최첨단 LLM에 접근할 수 있는 고가용성 및 저지연 추론 엔드포인트를 제공합니다. LangChain은 LLM(`Databricks`), 채팅 모델(`ChatDatabricks`), 및 임베딩(`DatabricksEmbeddings`) 구현을 제공하여 Databricks Model Serving에 호스팅된 모델을 LangChain 애플리케이션과 통합하는 과정을 간소화합니다.
2. 📃 **벡터 검색** - [Databricks Vector Search](https://www.databricks.com/product/machine-learning/vector-search)는 Databricks 플랫폼 내에 원활하게 통합된 서버리스 벡터 데이터베이스입니다. `DatabricksVectorSearch`를 사용하여 LangChain 애플리케이션에 고도로 확장 가능하고 신뢰할 수 있는 유사성 검색 엔진을 통합할 수 있습니다.
3. 📊 **MLflow** - [MLflow](https://mlflow.org/)는 실험 관리, 평가, 추적, 배포 등을 포함한 ML 라이프사이클 전체를 관리하기 위한 오픈 소스 플랫폼입니다. [MLflow의 LangChain 통합](/docs/integrations/providers/mlflow_tracking)은 현대 복합 ML 시스템을 개발하고 운영하는 과정을 간소화합니다.
4. 🌐 **SQL 데이터베이스** - [Databricks SQL](https://www.databricks.com/product/databricks-sql)은 LangChain의 `SQLDatabase`와 통합되어 자동 최적화되고 뛰어난 성능의 데이터 웨어하우스에 접근할 수 있습니다.
5. 💡 **오픈 모델** - Databricks는 [DBRX](https://www.databricks.com/blog/introducing-dbrx-new-state-art-open-llm)와 같은 모델을 오픈 소스로 제공하며, 이는 [Hugging Face Hub](https://huggingface.co/databricks/dbrx-instruct)를 통해 이용할 수 있습니다. 이러한 모델은 `transformers` 라이브러리와의 통합을 활용하여 LangChain과 직접 사용할 수 있습니다.

## 채팅 모델

`ChatDatabricks`는 Llama3, Mixtral, DBRX와 같은 최첨단 모델 및 여러분의 세밀하게 조정된 모델을 포함하여 Databricks에 호스팅된 채팅 엔드포인트에 접근하기 위한 채팅 모델 클래스입니다.

```
from langchain_community.chat_models.databricks import ChatDatabricks

chat_model = ChatDatabricks(endpoint="databricks-meta-llama-3-70b-instruct")
```


LangChain 애플리케이션 내에서 사용하는 방법에 대한 추가 안내는 [사용 예제](/docs/integrations/chat/databricks)를 참조하세요.

## LLM

`Databricks`는 Databricks에 호스팅된 완성 엔드포인트에 접근하기 위한 LLM 클래스입니다.

```
from langchain_community.llm.databricks import Databricks

llm = Databricks(endpoint="your-completion-endpoint")
```


LangChain 애플리케이션 내에서 사용하는 방법에 대한 추가 안내는 [사용 예제](/docs/integrations/llms/databricks)를 참조하세요.

## 임베딩

`DatabricksEmbeddings`는 BGE와 같은 최첨단 모델 및 여러분의 세밀하게 조정된 모델을 포함하여 Databricks에 호스팅된 텍스트 임베딩 엔드포인트에 접근하기 위한 임베딩 클래스입니다.

```
from langchain_community.embeddings import DatabricksEmbeddings

embeddings = DatabricksEmbeddings(endpoint="databricks-bge-large-en")
```


LangChain 애플리케이션 내에서 사용하는 방법에 대한 추가 안내는 [사용 예제](/docs/integrations/text_embedding/databricks)를 참조하세요.

## 벡터 검색

Databricks Vector Search는 메타데이터를 포함한 데이터의 벡터 표현을 벡터 데이터베이스에 저장할 수 있는 서버리스 유사성 검색 엔진입니다. Vector Search를 사용하면 [Unity Catalog](https://www.databricks.com/product/unity-catalog)에서 관리하는 [Delta](https://docs.databricks.com/en/introduction/delta-comparison.html) 테이블로부터 자동 업데이트되는 벡터 검색 인덱스를 생성하고, 간단한 API로 쿼리하여 가장 유사한 벡터를 반환할 수 있습니다.

```
from langchain_community.vectorstores import DatabricksVectorSearch

dvs = DatabricksVectorSearch(
    index, text_column="text", embedding=embeddings, columns=["source"]
)
docs = dvs.similarity_search("What is vector search?)
```


벡터 인덱스를 설정하고 LangChain과 통합하는 방법에 대한 [사용 예제](/docs/integrations/vectorstores/databricks_vector_search)를 참조하세요.

## MLflow 통합

LangChain 통합의 맥락에서 MLflow는 다음과 같은 기능을 제공합니다:

- **실험 추적**: LangChain 실험에서 모델, 아티팩트 및 추적을 추적하고 저장합니다.
- **종속성 관리**: 종속성 라이브러리를 자동으로 기록하여 개발, 스테이징 및 프로덕션 환경 간의 일관성을 보장합니다.
- **모델 평가**: LangChain 애플리케이션을 평가하기 위한 기본 기능을 제공합니다.
- **추적**: LangChain 애플리케이션을 통한 데이터 흐름을 시각적으로 추적합니다.

MLflow를 LangChain과 함께 사용하는 전체 기능에 대해 자세히 알아보려면 [MLflow LangChain 통합](/docs/integrations/providers/mlflow_tracking)을 참조하세요.

## SQLDatabase
LangChain의 SQLDatabase 래퍼를 사용하여 Databricks SQL에 연결할 수 있습니다.
```
from langchain.sql_database import SQLDatabase

db = SQLDatabase.from_databricks(catalog="samples", schema="nyctaxi")
```


강력한 쿼리 도구로서 LangChain 에이전트와 Databricks SQL을 연결하는 방법에 대한 내용은 [Databricks SQL 에이전트](https://docs.databricks.com/en/large-language-models/langchain.html#databricks-sql-agent)를 참조하세요.

## 오픈 모델

HuggingFace에 호스팅된 Databricks의 오픈 모델을 직접 통합하려면 LangChain의 [HuggingFace 통합](/docs/integrations/platforms/huggingface)을 사용할 수 있습니다.

```
from langchain_huggingface import HuggingFaceEndpoint

llm = HuggingFaceEndpoint(
    repo_id="databricks/dbrx-instruct",
    task="text-generation",
    max_new_tokens=512,
    do_sample=False,
    repetition_penalty=1.03,
)
llm.invoke("What is DBRX model?")
```