---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/sagemaker_tracking.ipynb
description: 이 문서는 Amazon SageMaker Experiments를 활용하여 LangChain Callback으로 LLM 하이퍼파라미터를
  기록하고 추적하는 방법을 설명합니다.
---

# SageMaker 추적

> [Amazon SageMaker](https://aws.amazon.com/sagemaker/)는 기계 학습(ML) 모델을 신속하고 쉽게 구축, 훈련 및 배포하는 데 사용되는 완전 관리형 서비스입니다.

> [Amazon SageMaker Experiments](https://docs.aws.amazon.com/sagemaker/latest/dg/experiments.html)는 ML 실험 및 모델 버전을 조직, 추적, 비교 및 평가할 수 있도록 해주는 `Amazon SageMaker`의 기능입니다.

이 노트북은 LangChain Callback을 사용하여 `SageMaker Experiments`에 프롬프트 및 기타 LLM 하이퍼파라미터를 기록하고 추적하는 방법을 보여줍니다. 여기서는 다양한 시나리오를 사용하여 이 기능을 보여줍니다:

* **시나리오 1**: *단일 LLM* - 주어진 프롬프트를 기반으로 출력을 생성하는 단일 LLM 모델을 사용하는 경우입니다.
* **시나리오 2**: *순차 체인* - 두 개의 LLM 모델의 순차 체인을 사용하는 경우입니다.
* **시나리오 3**: *도구가 있는 에이전트 (사고의 연쇄)* - LLM 외에 여러 도구(검색 및 수학)를 사용하는 경우입니다.

이 노트북에서는 각 시나리오의 프롬프트를 기록하기 위해 단일 실험을 생성합니다.

## 설치 및 설정

```python
%pip install --upgrade --quiet  sagemaker
%pip install --upgrade --quiet  langchain-openai
%pip install --upgrade --quiet  google-search-results
```


먼저, 필요한 API 키를 설정합니다.

* OpenAI: https://platform.openai.com/account/api-keys (OpenAI LLM 모델용)
* Google SERP API: https://serpapi.com/manage-api-key (Google 검색 도구용)

```python
import os

## Add your API keys below
os.environ["OPENAI_API_KEY"] = "<ADD-KEY-HERE>"
os.environ["SERPAPI_API_KEY"] = "<ADD-KEY-HERE>"
```


```python
<!--IMPORTS:[{"imported": "SageMakerCallbackHandler", "source": "langchain_community.callbacks.sagemaker_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.sagemaker_callback.SageMakerCallbackHandler.html", "title": "SageMaker Tracking"}]-->
from langchain_community.callbacks.sagemaker_callback import SageMakerCallbackHandler
```


```python
<!--IMPORTS:[{"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "SageMaker Tracking"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "SageMaker Tracking"}, {"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "SageMaker Tracking"}, {"imported": "SimpleSequentialChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.sequential.SimpleSequentialChain.html", "title": "SageMaker Tracking"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "SageMaker Tracking"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "SageMaker Tracking"}]-->
from langchain.agents import initialize_agent, load_tools
from langchain.chains import LLMChain, SimpleSequentialChain
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI
from sagemaker.analytics import ExperimentAnalytics
from sagemaker.experiments.run import Run
from sagemaker.session import Session
```


## LLM 프롬프트 추적

```python
# LLM Hyperparameters
HPARAMS = {
    "temperature": 0.1,
    "model_name": "gpt-3.5-turbo-instruct",
}

# Bucket used to save prompt logs (Use `None` is used to save the default bucket or otherwise change it)
BUCKET_NAME = None

# Experiment name
EXPERIMENT_NAME = "langchain-sagemaker-tracker"

# Create SageMaker Session with the given bucket
session = Session(default_bucket=BUCKET_NAME)
```


### 시나리오 1 - LLM

```python
RUN_NAME = "run-scenario-1"
PROMPT_TEMPLATE = "tell me a joke about {topic}"
INPUT_VARIABLES = {"topic": "fish"}
```


```python
with Run(
    experiment_name=EXPERIMENT_NAME, run_name=RUN_NAME, sagemaker_session=session
) as run:
    # Create SageMaker Callback
    sagemaker_callback = SageMakerCallbackHandler(run)

    # Define LLM model with callback
    llm = OpenAI(callbacks=[sagemaker_callback], **HPARAMS)

    # Create prompt template
    prompt = PromptTemplate.from_template(template=PROMPT_TEMPLATE)

    # Create LLM Chain
    chain = LLMChain(llm=llm, prompt=prompt, callbacks=[sagemaker_callback])

    # Run chain
    chain.run(**INPUT_VARIABLES)

    # Reset the callback
    sagemaker_callback.flush_tracker()
```


### 시나리오 2 - 순차 체인

```python
RUN_NAME = "run-scenario-2"

PROMPT_TEMPLATE_1 = """You are a playwright. Given the title of play, it is your job to write a synopsis for that title.
Title: {title}
Playwright: This is a synopsis for the above play:"""
PROMPT_TEMPLATE_2 = """You are a play critic from the New York Times. Given the synopsis of play, it is your job to write a review for that play.
Play Synopsis: {synopsis}
Review from a New York Times play critic of the above play:"""

INPUT_VARIABLES = {
    "input": "documentary about good video games that push the boundary of game design"
}
```


```python
with Run(
    experiment_name=EXPERIMENT_NAME, run_name=RUN_NAME, sagemaker_session=session
) as run:
    # Create SageMaker Callback
    sagemaker_callback = SageMakerCallbackHandler(run)

    # Create prompt templates for the chain
    prompt_template1 = PromptTemplate.from_template(template=PROMPT_TEMPLATE_1)
    prompt_template2 = PromptTemplate.from_template(template=PROMPT_TEMPLATE_2)

    # Define LLM model with callback
    llm = OpenAI(callbacks=[sagemaker_callback], **HPARAMS)

    # Create chain1
    chain1 = LLMChain(llm=llm, prompt=prompt_template1, callbacks=[sagemaker_callback])

    # Create chain2
    chain2 = LLMChain(llm=llm, prompt=prompt_template2, callbacks=[sagemaker_callback])

    # Create Sequential chain
    overall_chain = SimpleSequentialChain(
        chains=[chain1, chain2], callbacks=[sagemaker_callback]
    )

    # Run overall sequential chain
    overall_chain.run(**INPUT_VARIABLES)

    # Reset the callback
    sagemaker_callback.flush_tracker()
```


### 시나리오 3 - 도구가 있는 에이전트

```python
RUN_NAME = "run-scenario-3"
PROMPT_TEMPLATE = "Who is the oldest person alive? And what is their current age raised to the power of 1.51?"
```


```python
with Run(
    experiment_name=EXPERIMENT_NAME, run_name=RUN_NAME, sagemaker_session=session
) as run:
    # Create SageMaker Callback
    sagemaker_callback = SageMakerCallbackHandler(run)

    # Define LLM model with callback
    llm = OpenAI(callbacks=[sagemaker_callback], **HPARAMS)

    # Define tools
    tools = load_tools(["serpapi", "llm-math"], llm=llm, callbacks=[sagemaker_callback])

    # Initialize agent with all the tools
    agent = initialize_agent(
        tools, llm, agent="zero-shot-react-description", callbacks=[sagemaker_callback]
    )

    # Run agent
    agent.run(input=PROMPT_TEMPLATE)

    # Reset the callback
    sagemaker_callback.flush_tracker()
```


## 로그 데이터 로드

프롬프트가 기록되면, 다음과 같이 이를 쉽게 로드하고 Pandas DataFrame으로 변환할 수 있습니다.

```python
# Load
logs = ExperimentAnalytics(experiment_name=EXPERIMENT_NAME)

# Convert as pandas dataframe
df = logs.dataframe(force_refresh=True)

print(df.shape)
df.head()
```


위에서 볼 수 있듯이, 각 시나리오에 해당하는 세 개의 실행(행)이 실험에 있습니다. 각 실행은 프롬프트와 관련된 LLM 설정/하이퍼파라미터를 json 형식으로 기록하며 s3 버킷에 저장됩니다. 각 json 경로에서 로그 데이터를 자유롭게 로드하고 탐색해 보세요.