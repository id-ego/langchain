---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/databricks.ipynb
description: Databricks LLM 모델을 사용하여 데이터, 분석 및 AI를 통합하는 플랫폼을 소개하는 노트북입니다.
---

# Databricks

> [Databricks](https://www.databricks.com/) 레이크하우스 플랫폼은 데이터, 분석 및 AI를 하나의 플랫폼에서 통합합니다.

이 노트북은 Databricks [LLM 모델](https://python.langchain.com/v0.2/docs/concepts/#llms)을 시작하는 데 대한 간단한 개요를 제공합니다. 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/llms/langchain_community.llms.databricks.Databricks.html)로 이동하십시오.

## 개요

`Databricks` LLM 클래스는 다음 두 가지 엔드포인트 유형 중 하나로 호스팅되는 완료 엔드포인트를 래핑합니다:

* [Databricks 모델 제공](https://docs.databricks.com/en/machine-learning/model-serving/index.html), 프로덕션 및 개발에 권장됨,
* 클러스터 드라이버 프록시 앱, 대화형 개발에 권장됨.

이 예제 노트북은 LLM 엔드포인트를 래핑하고 LangChain 애플리케이션에서 LLM으로 사용하는 방법을 보여줍니다.

## 제한 사항

`Databricks` LLM 클래스는 *레거시* 구현이며 기능 호환성에 여러 가지 제한 사항이 있습니다.

* 동기 호출만 지원합니다. 스트리밍 또는 비동기 API는 지원되지 않습니다.
* `batch` API는 지원되지 않습니다.

이러한 기능을 사용하려면 새 [ChatDatabricks](https://python.langchain.com/v0.2/docs/integrations/chat/databricks) 클래스를 대신 사용하십시오. `ChatDatabricks`는 스트리밍, 비동기, 배치 등 `ChatModel`의 모든 API를 지원합니다.

## 설정

Databricks 모델에 접근하려면 Databricks 계정을 생성하고, 자격 증명을 설정(단, Databricks 작업 공간 외부에 있는 경우에만)하고, 필요한 패키지를 설치해야 합니다.

### 자격 증명 (단, Databricks 외부에 있는 경우)

Databricks 내에서 LangChain 앱을 실행하는 경우 이 단계를 건너뛸 수 있습니다.

그렇지 않으면 Databricks 작업 공간 호스트 이름과 개인 액세스 토큰을 각각 `DATABRICKS_HOST` 및 `DATABRICKS_TOKEN` 환경 변수에 수동으로 설정해야 합니다. 액세스 토큰을 얻는 방법은 [인증 문서](https://docs.databricks.com/en/dev-tools/auth/index.html#databricks-personal-access-tokens)를 참조하십시오.

```python
import getpass
import os

os.environ["DATABRICKS_HOST"] = "https://your-workspace.cloud.databricks.com"
if "DATABRICKS_TOKEN" not in os.environ:
    os.environ["DATABRICKS_TOKEN"] = getpass.getpass(
        "Enter your Databricks access token: "
    )
```


또는 `Databricks` 클래스를 초기화할 때 이러한 매개변수를 전달할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Databricks", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.databricks.Databricks.html", "title": "Databricks"}]-->
from langchain_community.llms import Databricks

databricks = Databricks(
    host="https://your-workspace.cloud.databricks.com",
    # We strongly recommend NOT to hardcode your access token in your code, instead use secret management tools
    # or environment variables to store your access token securely. The following example uses Databricks Secrets
    # to retrieve the access token that is available within the Databricks notebook.
    token=dbutils.secrets.get(scope="YOUR_SECRET_SCOPE", key="databricks-token"),  # noqa: F821
)
```


### 설치

LangChain Databricks 통합은 `langchain-community` 패키지에 있습니다. 또한, 이 노트북의 코드를 실행하려면 `mlflow >= 2.9`가 필요합니다.

```python
%pip install -qU langchain-community mlflow>=2.9.0
```


## 모델 제공 엔드포인트 래핑

### 전제 조건:

* LLM이 [Databricks 제공 엔드포인트](https://docs.databricks.com/machine-learning/model-serving/index.html)에 등록되고 배포되었습니다.
* 엔드포인트에 대한 ["쿼리 가능" 권한](https://docs.databricks.com/security/auth-authz/access-control/serving-endpoint-acl.html)이 있습니다.

예상되는 MLflow 모델 서명은 다음과 같습니다:

* 입력: `[{"name": "prompt", "type": "string"}, {"name": "stop", "type": "list[string]"}]`
* 출력: `[{"type": "string"}]`

### 호출

```python
<!--IMPORTS:[{"imported": "Databricks", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.databricks.Databricks.html", "title": "Databricks"}]-->
from langchain_community.llms import Databricks

llm = Databricks(endpoint_name="YOUR_ENDPOINT_NAME")
llm.invoke("How are you?")
```


```output
'I am happy to hear that you are in good health and as always, you are appreciated.'
```


```python
llm.invoke("How are you?", stop=["."])
```


```output
'Good'
```


### 입력 및 출력 변환

때때로 호환되지 않는 모델 서명이 있는 제공 엔드포인트를 래핑하거나 추가 구성을 삽입하고 싶을 수 있습니다. `transform_input_fn` 및 `transform_output_fn` 인수를 사용하여 추가 전/후 처리를 정의할 수 있습니다.

```python
# Use `transform_input_fn` and `transform_output_fn` if the serving endpoint
# expects a different input schema and does not return a JSON string,
# respectively, or you want to apply a prompt template on top.


def transform_input(**request):
    full_prompt = f"""{request["prompt"]}
    Be Concise.
    """
    request["prompt"] = full_prompt
    return request


def transform_output(response):
    return response.upper()


llm = Databricks(
    endpoint_name="YOUR_ENDPOINT_NAME",
    transform_input_fn=transform_input,
    transform_output_fn=transform_output,
)

llm.invoke("How are you?")
```


```output
'I AM DOING GREAT THANK YOU.'
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)