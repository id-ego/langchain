---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/databricks.ipynb
description: 이 문서는 Databricks의 ChatDatabricks 클래스를 사용하여 LangChain 애플리케이션에서 채팅 모델을
  통합하는 방법을 소개합니다.
sidebar_label: Databricks
---

# ChatDatabricks

> [Databricks](https://www.databricks.com/) 레이크하우스 플랫폼은 데이터, 분석 및 AI를 하나의 플랫폼에서 통합합니다.

이 노트북은 Databricks [채팅 모델](/docs/concepts/#chat-models)을 시작하는 데 대한 간략한 개요를 제공합니다. ChatDatabricks의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html)에서 확인하세요.

## 개요

`ChatDatabricks` 클래스는 [Databricks 모델 서빙](https://docs.databricks.com/en/machine-learning/model-serving/index.html)에서 호스팅되는 채팅 모델 엔드포인트를 래핑합니다. 이 예제 노트북은 서빙 엔드포인트를 래핑하고 LangChain 애플리케이션에서 채팅 모델로 사용하는 방법을 보여줍니다.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [ChatDatabricks](https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html) | [langchain-community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ❌ | beta | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-community?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-community?style=flat-square&label=%20) |

### 모델 기능
| [도구 호출](/docs/how_to/tool_calling/) | [구조화된 출력](/docs/how_to/structured_output/) | JSON 모드 | [이미지 입력](/docs/how_to/multimodal_inputs/) | 오디오 입력 | 비디오 입력 | [토큰 수준 스트리밍](/docs/how_to/chat_streaming/) | 네이티브 비동기 | [토큰 사용](/docs/how_to/chat_token_usage_tracking/) | [로그확률](/docs/how_to/logprobs/) |
| :---: | :---: | :---: | :---: |  :---: | :---: | :---: | :---: | :---: | :---: |
| ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |  ✅ | ✅ | ✅ | ❌ | 

### 지원되는 메서드

`ChatDatabricks`는 비동기 API를 포함한 `ChatModel`의 모든 메서드를 지원합니다.

### 엔드포인트 요구 사항

`ChatDatabricks`가 래핑하는 서빙 엔드포인트는 OpenAI 호환 채팅 입력/출력 형식([참조](https://mlflow.org/docs/latest/llms/deployments/index.html#chat))을 가져야 합니다. 입력 형식이 호환되는 한, `ChatDatabricks`는 [Databricks 모델 서빙](https://docs.databricks.com/en/machine-learning/model-serving/index.html)에서 호스팅되는 모든 엔드포인트 유형에 사용할 수 있습니다:

1. 기본 모델 - DRBX, Llama3, Mixtral-8x7B 등과 같은 최첨단 기본 모델의 선별된 목록입니다. 이러한 엔드포인트는 설정 없이 Databricks 작업 공간에서 즉시 사용할 수 있습니다.
2. 사용자 정의 모델 - LangChain, Pytorch, Transformers 등과 같은 프레임워크를 통해 MLflow를 사용하여 사용자 정의 모델을 서빙 엔드포인트에 배포할 수 있습니다.
3. 외부 모델 - Databricks 엔드포인트는 OpenAI GPT4와 같은 독점 모델 서비스와 같이 Databricks 외부에 호스팅된 모델을 프록시로 제공할 수 있습니다.

## 설정

Databricks 모델에 접근하려면 Databricks 계정을 생성하고, 자격 증명을 설정해야 합니다(단, Databricks 작업 공간 외부에 있는 경우에만 해당). 

### 자격 증명 (단, Databricks 외부에 있는 경우)

Databricks 내에서 LangChain 앱을 실행 중이라면 이 단계를 건너뛸 수 있습니다.

그렇지 않으면 Databricks 작업 공간 호스트 이름과 개인 액세스 토큰을 각각 `DATABRICKS_HOST` 및 `DATABRICKS_TOKEN` 환경 변수로 수동으로 설정해야 합니다. 액세스 토큰을 얻는 방법은 [인증 문서](https://docs.databricks.com/en/dev-tools/auth/index.html#databricks-personal-access-tokens)를 참조하세요.

```python
import getpass
import os

os.environ["DATABRICKS_HOST"] = "https://your-workspace.cloud.databricks.com"
os.environ["DATABRICKS_TOKEN"] = getpass.getpass("Enter your Databricks access token: ")
```

```output
Enter your Databricks access token:  ········
```

### 설치

LangChain Databricks 통합은 `langchain-community` 패키지에 있습니다. 또한 이 노트북의 코드를 실행하려면 `mlflow >= 2.9`가 필요합니다.

```python
%pip install -qU langchain-community mlflow>=2.9.0
```


우리는 먼저 `ChatDatabricks`를 사용하여 기본 모델 엔드포인트로 호스팅된 DBRX-instruct 모델을 쿼리하는 방법을 보여줍니다.

다른 유형의 엔드포인트의 경우, 엔드포인트 자체를 설정하는 방법에 약간의 차이가 있지만, 엔드포인트가 준비되면 `ChatDatabricks`로 쿼리하는 방법에는 차이가 없습니다. 다른 유형의 엔드포인트에 대한 예는 이 노트북 하단을 참조하세요.

## 인스턴스화

```python
<!--IMPORTS:[{"imported": "ChatDatabricks", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html", "title": "ChatDatabricks"}]-->
from langchain_community.chat_models import ChatDatabricks

chat_model = ChatDatabricks(
    endpoint="databricks-dbrx-instruct",
    temperature=0.1,
    max_tokens=256,
    # See https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html for other supported parameters
)
```


## 호출

```python
chat_model.invoke("What is MLflow?")
```


```output
AIMessage(content='MLflow is an open-source platform for managing end-to-end machine learning workflows. It was introduced by Databricks in 2018. MLflow provides tools for tracking experiments, packaging and sharing code, and deploying models. It is designed to work with any machine learning library and can be used in a variety of environments, including local machines, virtual machines, and cloud-based clusters. MLflow aims to streamline the machine learning development lifecycle, making it easier for data scientists and engineers to collaborate and deploy models into production.', response_metadata={'prompt_tokens': 229, 'completion_tokens': 104, 'total_tokens': 333}, id='run-d3fb4d06-3e10-4471-83c9-c282cc62b74d-0')
```


```python
# You can also pass a list of messages
messages = [
    ("system", "You are a chatbot that can answer questions about Databricks."),
    ("user", "What is Databricks Model Serving?"),
]
chat_model.invoke(messages)
```


```output
AIMessage(content='Databricks Model Serving is a feature of the Databricks platform that allows data scientists and engineers to easily deploy machine learning models into production. With Model Serving, you can host, manage, and serve machine learning models as APIs, making it easy to integrate them into applications and business processes. It supports a variety of popular machine learning frameworks, including TensorFlow, PyTorch, and scikit-learn, and provides tools for monitoring and managing the performance of deployed models. Model Serving is designed to be scalable, secure, and easy to use, making it a great choice for organizations that want to quickly and efficiently deploy machine learning models into production.', response_metadata={'prompt_tokens': 35, 'completion_tokens': 130, 'total_tokens': 165}, id='run-b3feea21-223e-4105-8627-41d647d5ccab-0')
```


## 체이닝
다른 채팅 모델과 유사하게, `ChatDatabricks`는 복잡한 체인의 일부로 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ChatDatabricks"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a chatbot that can answer questions about {topic}.",
        ),
        ("user", "{question}"),
    ]
)

chain = prompt | chat_model
chain.invoke(
    {
        "topic": "Databricks",
        "question": "What is Unity Catalog?",
    }
)
```


```output
AIMessage(content="Unity Catalog is a new data catalog feature in Databricks that allows you to discover, manage, and govern all your data assets across your data landscape, including data lakes, data warehouses, and data marts. It provides a centralized repository for storing and managing metadata, data lineage, and access controls for all your data assets. Unity Catalog enables data teams to easily discover and access the data they need, while ensuring compliance with data privacy and security regulations. It is designed to work seamlessly with Databricks' Lakehouse platform, providing a unified experience for managing and analyzing all your data.", response_metadata={'prompt_tokens': 32, 'completion_tokens': 118, 'total_tokens': 150}, id='run-82d72624-f8df-4c0d-a976-919feec09a55-0')
```


## 호출 (스트리밍)

`ChatDatabricks`는 `langchain-community>=0.2.1`부터 `stream` 메서드를 통해 스트리밍 응답을 지원합니다.

```python
for chunk in chat_model.stream("How are you?"):
    print(chunk.content, end="|")
```

```output
I|'m| an| AI| and| don|'t| have| feelings|,| but| I|'m| here| and| ready| to| assist| you|.| How| can| I| help| you| today|?||
```

## 비동기 호출

```python
import asyncio

country = ["Japan", "Italy", "Australia"]
futures = [chat_model.ainvoke(f"Where is the capital of {c}?") for c in country]
await asyncio.gather(*futures)
```


## 사용자 정의 모델 엔드포인트 래핑

전제 조건:

* LLM이 MLflow를 통해 [Databricks 서빙 엔드포인트](https://docs.databricks.com/machine-learning/model-serving/index.html)에 등록되고 배포되었습니다. 엔드포인트는 OpenAI 호환 채팅 입력/출력 형식([참조](https://mlflow.org/docs/latest/llms/deployments/index.html#chat))을 가져야 합니다.
* 엔드포인트에 대한 ["쿼리 가능" 권한](https://docs.databricks.com/security/auth-authz/access-control/serving-endpoint-acl.html)이 있어야 합니다.

엔드포인트가 준비되면 사용 패턴은 기본 모델과 완전히 동일합니다.

```python
chat_model_custom = ChatDatabricks(
    endpoint="YOUR_ENDPOINT_NAME",
    temperature=0.1,
    max_tokens=256,
)

chat_model_custom.invoke("How are you?")
```


## 외부 모델 래핑

전제 조건: 프록시 엔드포인트 생성

먼저, 요청을 대상 외부 모델로 프록시하는 새로운 Databricks 서빙 엔드포인트를 생성합니다. 외부 모델을 프록시하기 위한 엔드포인트 생성은 매우 빠르게 이루어져야 합니다.

이것은 다음 주석과 함께 Databricks 비밀 관리자에 OpenAI API 키를 등록해야 합니다:
```sh
# Replace `<scope>` with your scope
databricks secrets create-scope <scope>
databricks secrets put-secret <scope> openai-api-key --string-value $OPENAI_API_KEY
```


Databricks CLI를 설정하고 비밀을 관리하는 방법에 대한 내용은 https://docs.databricks.com/en/security/secrets/secrets.html를 참조하세요.

```python
from mlflow.deployments import get_deploy_client

client = get_deploy_client("databricks")

secret = "secrets/<scope>/openai-api-key"  # replace `<scope>` with your scope
endpoint_name = "my-chat"  # rename this if my-chat already exists
client.create_endpoint(
    name=endpoint_name,
    config={
        "served_entities": [
            {
                "name": "my-chat",
                "external_model": {
                    "name": "gpt-3.5-turbo",
                    "provider": "openai",
                    "task": "llm/v1/chat",
                    "openai_config": {
                        "openai_api_key": "{{" + secret + "}}",
                    },
                },
            }
        ],
    },
)
```


엔드포인트 상태가 "준비 완료"가 되면 다른 유형의 엔드포인트와 동일한 방식으로 엔드포인트를 쿼리할 수 있습니다.

```python
chat_model_external = ChatDatabricks(
    endpoint=endpoint_name,
    temperature=0.1,
    max_tokens=256,
)
chat_model_external.invoke("How to use Databricks?")
```


## Databricks에서의 함수 호출

Databricks 함수 호출은 OpenAI 호환이며, 기본 모델 API의 일환으로 모델 서빙 중에만 사용할 수 있습니다.

지원되는 모델에 대한 내용은 [Databricks 함수 호출 소개](https://docs.databricks.com/en/machine-learning/model-serving/function-calling.html#supported-models)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "ChatDatabricks", "source": "langchain_community.chat_models.databricks", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html", "title": "ChatDatabricks"}]-->
from langchain_community.chat_models.databricks import ChatDatabricks

llm = ChatDatabricks(endpoint="databricks-meta-llama-3-70b-instruct")
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_current_weather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA",
                    },
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
                },
            },
        },
    }
]

# supported tool_choice values: "auto", "required", "none", function name in string format,
# or a dictionary as {"type": "function", "function": {"name": <<tool_name>>}}
model = llm.bind_tools(tools, tool_choice="auto")

messages = [{"role": "user", "content": "What is the current temperature of Chicago?"}]
print(model.invoke(messages))
```


체인에서 UC 기능을 사용하는 방법에 대한 내용은 [Databricks Unity Catalog](docs/integrations/tools/databricks.md)를 참조하세요.

## API 참조

ChatDatabricks의 모든 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.ChatDatabricks.html

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)