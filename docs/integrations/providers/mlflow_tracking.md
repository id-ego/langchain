---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/mlflow_tracking.ipynb
description: MLflow는 기계 학습 생애 주기 전반에 걸쳐 워크플로우와 아티팩트를 관리하는 오픈 소스 플랫폼입니다. LangChain과
  통합하여 다양한 기능을 제공합니다.
---

# MLflow

> [MLflow](https://mlflow.org/)는 머신러닝 생애 주기 전반에 걸쳐 워크플로우와 아티팩트를 관리하기 위한 다목적 오픈 소스 플랫폼입니다. 많은 인기 있는 ML 라이브러리와의 통합이 내장되어 있지만, 모든 라이브러리, 알고리즘 또는 배포 도구와 함께 사용할 수 있습니다. 확장 가능하도록 설계되어 있어 새로운 워크플로우, 라이브러리 및 도구를 지원하는 플러그인을 작성할 수 있습니다.

LangChain 통합의 맥락에서 MLflow는 다음과 같은 기능을 제공합니다:

- **실험 추적**: MLflow는 모델, 코드, 프롬프트, 메트릭 등 LangChain 실험에서 생성된 아티팩트를 추적하고 저장합니다.
- **종속성 관리**: MLflow는 모델 종속성을 자동으로 기록하여 개발 환경과 프로덕션 환경 간의 일관성을 보장합니다.
- **모델 평가**: MLflow는 LangChain 애플리케이션을 평가하기 위한 기본 기능을 제공합니다.
- **추적**: MLflow는 LangChain 체인, 에이전트, 검색기 또는 기타 구성 요소를 통해 데이터 흐름을 시각적으로 추적할 수 있게 해줍니다.

**참고**: 추적 기능은 MLflow 버전 2.14.0 이상에서만 사용할 수 있습니다.

이 노트북은 MLflow를 사용하여 LangChain 실험을 추적하는 방법을 보여줍니다. 이 기능에 대한 자세한 정보와 MLflow와 함께 LangChain을 사용하는 튜토리얼 및 예제를 탐색하려면 [LangChain 통합을 위한 MLflow 문서](https://mlflow.org/docs/latest/llms/langchain/index.html)를 참조하십시오.

## 설정

MLflow Python 패키지를 설치합니다:

```python
%pip install google-search-results num
```


```python
%pip install mlflow -qU
```


이 예제는 OpenAI LLM을 활용합니다. 원하시면 아래 명령을 건너뛰고 다른 LLM으로 진행하셔도 됩니다.

```python
%pip install langchain-openai -qU
```


```python
import os

# Set MLflow tracking URI if you have MLflow Tracking Server running
os.environ["MLFLOW_TRACKING_URI"] = ""
os.environ["OPENAI_API_KEY"] = ""
```


시작하기 위해, 모델과 아티팩트를 추적하기 위해 전용 MLflow 실험을 생성합시다. 이 단계를 건너뛰고 기본 실험을 사용할 수도 있지만, 혼잡을 피하고 깔끔하고 구조화된 워크플로우를 유지하기 위해 실행 및 아티팩트를 별도의 실험으로 조직하는 것을 강력히 권장합니다.

```python
import mlflow

mlflow.set_experiment("LangChain MLflow Integration")
```


## 개요

다음 방법 중 하나를 사용하여 MLflow를 LangChain 애플리케이션과 통합합니다:

1. **자동 로깅**: `mlflow.langchain.autolog()` 명령으로 원활한 추적을 활성화하며, 이는 LangChain MLflow 통합을 활용하기 위한 추천 첫 번째 옵션입니다.
2. **수동 로깅**: MLflow API를 사용하여 LangChain 체인 및 에이전트를 로깅하여 실험에서 추적할 항목에 대한 세밀한 제어를 제공합니다.
3. **사용자 정의 콜백**: 체인을 호출할 때 MLflow 콜백을 수동으로 전달하여 특정 호출을 추적하는 등의 작업을 반자동으로 사용자 정의할 수 있습니다.

## 시나리오 1: MLFlow 자동 로깅

자동 로깅을 시작하려면 `mlflow.langchain.autolog()`를 호출하기만 하면 됩니다. 이 예제에서는 `log_models` 매개변수를 `True`로 설정하여 체인 정의와 그 종속 라이브러리를 MLflow 모델로 기록할 수 있게 하여 포괄적인 추적 경험을 제공합니다.

```python
import mlflow

mlflow.langchain.autolog(
    # These are optional configurations to control what information should be logged automatically (default: False)
    # For the full list of the arguments, refer to https://mlflow.org/docs/latest/llms/langchain/autologging.html#id1
    log_models=True,
    log_input_examples=True,
    log_model_signatures=True,
)
```


### 체인 정의

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "MLflow"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "MLflow"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "MLflow"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model_name="gpt-4o", temperature=0)
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant that translates {input_language} to {output_language}.",
        ),
        ("human", "{input}"),
    ]
)
parser = StrOutputParser()

chain = prompt | llm | parser
```


### 체인 호출

이 단계는 MLflow가 모델, 추적 및 아티팩트를 추적 서버에 기록하기 위해 여러 백그라운드 작업을 실행하므로 평소보다 몇 초 더 걸릴 수 있습니다.

```python
test_input = {
    "input_language": "English",
    "output_language": "German",
    "input": "I love programming.",
}

chain.invoke(test_input)
```


```output
'Ich liebe das Programmieren.'
```


MLflow 추적 UI를 탐색하여 어떤 정보가 기록되고 있는지 더 깊이 이해해 보십시오.
* **추적** - 실험의 "추적" 탭으로 이동하여 첫 번째 행의 요청 ID 링크를 클릭합니다. 표시된 추적 트리는 체인 호출 스택을 시각화하여 각 구성 요소가 체인 내에서 어떻게 실행되는지에 대한 깊은 통찰력을 제공합니다.
* **MLflow 모델** - `log_model=True`로 설정했으므로 MLflow는 체인 정의를 추적하기 위해 자동으로 MLflow Run을 생성합니다. 최신 Run 페이지로 이동하여 "아티팩트" 탭을 열면 종속성, 입력 예제, 모델 서명 등을 포함하여 MLflow 모델로 기록된 파일 아티팩트 목록을 볼 수 있습니다.

### 기록된 체인 호출

다음으로, 모델을 다시 로드하고 동일한 예측을 재현할 수 있는지 확인하여 일관성과 신뢰성을 보장합니다.

모델을 로드하는 방법은 두 가지입니다.
1. `mlflow.langchain.load_model(MODEL_URI)` - 원래 LangChain 객체로 모델을 로드합니다.
2. `mlflow.pyfunc.load_model(MODEL_URI)` - `PythonModel` 래퍼 내에서 모델을 로드하고 `predict()` API로 예측 로직을 캡슐화하며, 스키마 강제화와 같은 추가 로직을 포함합니다.

```python
# Replace YOUR_RUN_ID with the Run ID displayed on the MLflow UI
loaded_model = mlflow.langchain.load_model("runs:/{YOUR_RUN_ID}/model")
loaded_model.invoke(test_input)
```


```output
'Ich liebe Programmieren.'
```


```python
pyfunc_model = mlflow.pyfunc.load_model("runs:/{YOUR_RUN_ID}/model")
pyfunc_model.predict(test_input)
```


```output
['Ich liebe das Programmieren.']
```


### 자동 로깅 구성

`mlflow.langchain.autolog()` 함수는 MLflow에 기록되는 아티팩트에 대한 세밀한 제어를 허용하는 여러 매개변수를 제공합니다. 사용 가능한 구성의 포괄적인 목록은 최신 [MLflow LangChain 자동 로깅 문서](https://mlflow.org/docs/latest/llms/langchain/autologging.html)를 참조하십시오.

## 시나리오 2: 코드에서 에이전트 수동 로깅

#### 전제 조건

이 예제는 에이전트가 Google 검색 결과를 검색하기 위한 도구로 `SerpAPI`라는 검색 엔진 API를 사용합니다. LangChain은 `SerpAPI`와 기본적으로 통합되어 있어 한 줄의 코드로 에이전트를 위한 도구를 구성할 수 있습니다.

시작하려면:

* 필요한 Python 패키지를 pip를 통해 설치합니다: `pip install google-search-results numexpr`.
* [SerpAPI 공식 웹사이트](https://serpapi.com/)에서 계정을 만들고 API 키를 가져옵니다.
* 환경 변수에 API 키를 설정합니다: `os.environ["SERPAPI_API_KEY"] = "YOUR_API_KEY"`

### 에이전트 정의

이 예제에서는 Python 객체를 직접 제공하고 직렬화된 형식으로 저장하는 대신 **코드로서** 에이전트 정의를 로깅합니다. 이 접근 방식은 여러 가지 이점을 제공합니다:

1. **직렬화 필요 없음**: 모델을 코드로 저장함으로써 직렬화의 필요성을 피할 수 있으며, 이는 기본적으로 지원하지 않는 구성 요소와 작업할 때 문제가 될 수 있습니다. 이 접근 방식은 또한 다른 환경에서 모델을 역직렬화할 때 발생할 수 있는 호환성 문제의 위험을 제거합니다.
2. **더 나은 투명성**: 저장된 코드 파일을 검사함으로써 모델이 수행하는 작업에 대한 귀중한 통찰력을 얻을 수 있습니다. 이는 pickle과 같은 직렬화 형식과 대조적이며, 모델의 동작은 다시 로드될 때까지 불투명하게 유지되어 원격 코드 실행과 같은 보안 위험을 노출할 수 있습니다.

먼저 에이전트 인스턴스를 정의하는 별도의 `.py` 파일을 생성합니다.

시간을 절약하기 위해 다음 셀을 실행하여 에이전트 정의 코드가 포함된 Python 파일 `agent.py`를 생성할 수 있습니다. 실제 개발 시나리오에서는 다른 노트북이나 수작업으로 작성된 Python 스크립트에서 정의합니다.

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "MLflow"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "MLflow"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "MLflow"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "MLflow"}]-->
script_content = """
from langchain.agents import AgentType, initialize_agent, load_tools
from langchain_openai import ChatOpenAI
import mlflow

llm = ChatOpenAI(model_name="gpt-4o", temperature=0)
tools = load_tools(["serpapi", "llm-math"], llm=llm)
agent = initialize_agent(tools, llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION)

# IMPORTANT: call set_model() to register the instance to be logged.
mlflow.models.set_model(agent)
"""

with open("agent.py", "w") as f:
    f.write(script_content)
```


### 에이전트 로깅

원래 노트북으로 돌아가서 `agent.py` 파일에 정의된 에이전트를 로깅하기 위해 다음 셀을 실행합니다.

```python
question = "How long would it take to drive to the Moon with F1 racing cars?"

with mlflow.start_run(run_name="search-math-agent") as run:
    info = mlflow.langchain.log_model(
        lc_model="agent.py",  # Specify the relative code path to the agent definition
        artifact_path="model",
        input_example=question,
    )

print("The agent is successfully logged to MLflow!")
```

```output
The agent is successfully logged to MLflow!
```

이제 MLflow UI를 열고 Run 세부 페이지의 "아티팩트" 탭으로 이동하십시오. `agent.py` 파일이 다른 모델 아티팩트(종속성, 입력 예제 등)와 함께 성공적으로 로깅된 것을 확인할 수 있습니다.

### 기록된 에이전트 호출

이제 에이전트를 다시 로드하고 호출합니다. 모델을 로드하는 방법은 두 가지입니다.

```python
# Let's turn on the autologging with default configuration, so we can see the trace for the agent invocation.
mlflow.langchain.autolog()

# Load the model back
agent = mlflow.pyfunc.load_model(info.model_uri)

# Invoke
agent.predict(question)
```

```output
Downloading artifacts: 100%|██████████| 10/10 [00:00<00:00, 331.57it/s]
```


```output
['It would take approximately 1194.5 hours to drive to the Moon with an F1 racing car.']
```


실험의 **"추적"** 탭으로 이동하여 첫 번째 행의 요청 ID 링크를 클릭합니다. 추적은 에이전트가 단일 예측 호출 내에서 여러 작업을 수행하는 방식을 시각화합니다:
1. 질문에 답하기 위해 필요한 하위 작업을 결정합니다.
2. F1 레이싱 카의 속도를 검색합니다.
3. 지구에서 달까지의 거리를 검색합니다.
4. LLM을 사용하여 나눗셈을 계산합니다.

## 시나리오 3. MLflow 콜백 사용

**MLflow 콜백**은 MLflow에서 LangChain 애플리케이션을 추적하는 반자동 방법을 제공합니다. 두 가지 주요 콜백이 있습니다:

1. **`MlflowLangchainTracer`:** 주로 추적 생성을 위해 사용되며, `mlflow >= 2.14.0`에서 사용할 수 있습니다.
2. **`MLflowCallbackHandler`:** MLflow 추적 서버에 메트릭 및 아티팩트를 기록합니다.

### MlflowLangchainTracer

체인 또는 에이전트가 `MlflowLangchainTracer` 콜백으로 호출되면, MLflow는 호출 스택에 대한 추적을 자동으로 생성하고 이를 MLflow 추적 서버에 기록합니다. 결과는 `mlflow.langchain.autolog()`와 동일하지만, 특정 호출만 추적하고 싶을 때 특히 유용합니다. 자동 로깅은 동일한 노트북/스크립트 내의 모든 호출에 적용됩니다.

```python
from mlflow.langchain.langchain_tracer import MlflowLangchainTracer

mlflow_tracer = MlflowLangchainTracer()

# This call generates a trace
chain.invoke(test_input, config={"callbacks": [mlflow_tracer]})

# This call does not generate a trace
chain.invoke(test_input)
```


#### 콜백 전달 위치
LangChain은 콜백 인스턴스를 전달하는 두 가지 방법을 지원합니다: (1) 요청 시간 콜백 - `invoke` 메서드에 전달하거나 `with_config()`와 바인딩 (2) 생성자 콜백 - 체인 생성자에 설정합니다. `MlflowLangchainTracer`를 콜백으로 사용할 때는 **요청 시간 콜백을 사용해야** 합니다. 생성자에 설정하면 콜백이 최상위 객체에만 적용되어 자식 구성 요소로 전파되지 않아 불완전한 추적이 발생합니다. 이 동작에 대한 자세한 내용은 [콜백 문서](https://python.langchain.com/v0.2/docs/concepts/#callbacks)를 참조하십시오.

```python
# OK
chain.invoke(test_input, config={"callbacks": [mlflow_tracer]})
chain.with_config(callbacks=[mlflow_tracer])
# NG
chain = TheNameOfSomeChain(callbacks=[mlflow_tracer])
```


#### 지원되는 메서드

`MlflowLangchainTracer`는 [Runnable Interfaces](https://python.langchain.com/v0.1/docs/expression_language/interface/)의 다음 호출 메서드를 지원합니다.
- 표준 인터페이스: `invoke`, `stream`, `batch`
- 비동기 인터페이스: `astream`, `ainvoke`, `abatch`, `astream_log`, `astream_events`

기타 메서드는 완전한 호환성을 보장하지 않습니다.

### MlflowCallbackHandler

`MlflowCallbackHandler`는 LangChain 커뮤니티 코드베이스에 있는 콜백 핸들러입니다.

이 콜백은 체인/에이전트 호출에 전달될 수 있지만, `flush_tracker()` 메서드를 호출하여 명시적으로 완료해야 합니다.

콜백으로 호출된 체인은 다음 작업을 수행합니다:

1. 새로운 MLflow Run을 생성하거나 활성 MLflow 실험 내에서 사용 가능한 경우 활성 Run을 검색합니다.
2. LLM 호출 수, 토큰 사용량 및 기타 관련 메트릭과 같은 메트릭을 기록합니다. 체인/에이전트에 LLM 호출이 포함되고 `spacy` 라이브러리가 설치되어 있는 경우, `flesch_kincaid_grade`와 같은 텍스트 복잡성 메트릭을 기록합니다.
3. 내부 단계를 JSON 파일로 기록합니다(이는 추적의 레거시 버전입니다).
4. 체인 입력 및 출력을 Pandas DataFrame으로 기록합니다.
5. 체인/에이전트 인스턴스와 함께 `flush_tracker()` 메서드를 호출하여 체인/에이전트를 MLflow 모델로 기록합니다.

```python
<!--IMPORTS:[{"imported": "MlflowCallbackHandler", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.mlflow_callback.MlflowCallbackHandler.html", "title": "MLflow"}]-->
from langchain_community.callbacks import MlflowCallbackHandler

mlflow_callback = MlflowCallbackHandler()

chain.invoke("What is LangChain callback?", config={"callbacks": [mlflow_callback]})

mlflow_callback.flush_tracker()
```


## 참고 문헌
이 기능에 대해 더 알아보고 MLflow와 함께 LangChain을 사용하는 튜토리얼 및 예제를 방문하려면 [LangChain 통합을 위한 MLflow 문서](https://mlflow.org/docs/latest/llms/langchain/index.html)를 참조하십시오.

`MLflow`는 또한 `LangChain` 통합을 위한 여러 [튜토리얼](https://mlflow.org/docs/latest/llms/langchain/index.html#getting-started-with-the-mlflow-langchain-flavor-tutorials-and-guides) 및 [예제](https://github.com/mlflow/mlflow/tree/master/examples/langchain)를 제공합니다:
- [빠른 시작](https://mlflow.org/docs/latest/llms/langchain/notebooks/langchain-quickstart.html)
- [RAG 튜토리얼](https://mlflow.org/docs/latest/llms/langchain/notebooks/langchain-retriever.html)
- [에이전트 예제](https://github.com/mlflow/mlflow/blob/master/examples/langchain/simple_agent.py)