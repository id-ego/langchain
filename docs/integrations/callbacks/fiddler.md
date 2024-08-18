---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/fiddler.ipynb
description: Fiddler는 데이터 과학, MLOps, 리스크 및 분석 팀이 ML 배포를 모니터링하고 개선할 수 있도록 지원하는 통합 플랫폼입니다.
---

# Fiddler

> [Fiddler](https://www.fiddler.ai/)는 기업의 생성 및 예측 시스템 운영의 선구자로, 데이터 과학, MLOps, 리스크, 규정 준수, 분석 및 기타 LOB 팀이 기업 규모의 ML 배포를 모니터링, 설명, 분석 및 개선할 수 있도록 하는 통합 플랫폼을 제공합니다.

## 1. 설치 및 설정

```python
#!pip install langchain langchain-community langchain-openai fiddler-client
```


## 2. Fiddler 연결 세부정보

*Fiddler에 모델 정보를 추가하기 전에*

1. Fiddler에 연결하는 데 사용하는 URL
2. 귀하의 조직 ID
3. 귀하의 인증 토큰

이 정보는 Fiddler 환경의 *설정* 페이지에서 찾을 수 있습니다.

```python
URL = ""  # Your Fiddler instance URL, Make sure to include the full URL (including https://). For example: https://demo.fiddler.ai
ORG_NAME = ""
AUTH_TOKEN = ""  # Your Fiddler instance auth token

# Fiddler project and model names, used for model registration
PROJECT_NAME = ""
MODEL_NAME = ""  # Model name in Fiddler
```


## 3. Fiddler 콜백 핸들러 인스턴스 생성

```python
<!--IMPORTS:[{"imported": "FiddlerCallbackHandler", "source": "langchain_community.callbacks.fiddler_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.fiddler_callback.FiddlerCallbackHandler.html", "title": "Fiddler"}]-->
from langchain_community.callbacks.fiddler_callback import FiddlerCallbackHandler

fiddler_handler = FiddlerCallbackHandler(
    url=URL,
    org=ORG_NAME,
    project=PROJECT_NAME,
    model=MODEL_NAME,
    api_key=AUTH_TOKEN,
)
```


## 예제 1 : 기본 체인

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Fiddler"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Fiddler"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import OpenAI

# Note : Make sure openai API key is set in the environment variable OPENAI_API_KEY
llm = OpenAI(temperature=0, streaming=True, callbacks=[fiddler_handler])
output_parser = StrOutputParser()

chain = llm | output_parser

# Invoke the chain. Invocation will be logged to Fiddler, and metrics automatically generated
chain.invoke("How far is moon from earth?")
```


```python
# Few more invocations
chain.invoke("What is the temperature on Mars?")
chain.invoke("How much is 2 + 200000?")
chain.invoke("Which movie won the oscars this year?")
chain.invoke("Can you write me a poem about insomnia?")
chain.invoke("How are you doing today?")
chain.invoke("What is the meaning of life?")
```


## 예제 2 : 프롬프트 템플릿이 있는 체인

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Fiddler"}, {"imported": "FewShotChatMessagePromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotChatMessagePromptTemplate.html", "title": "Fiddler"}]-->
from langchain_core.prompts import (
    ChatPromptTemplate,
    FewShotChatMessagePromptTemplate,
)

examples = [
    {"input": "2+2", "output": "4"},
    {"input": "2+3", "output": "5"},
]

example_prompt = ChatPromptTemplate.from_messages(
    [
        ("human", "{input}"),
        ("ai", "{output}"),
    ]
)

few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples,
)

final_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a wondrous wizard of math."),
        few_shot_prompt,
        ("human", "{input}"),
    ]
)

# Note : Make sure openai API key is set in the environment variable OPENAI_API_KEY
llm = OpenAI(temperature=0, streaming=True, callbacks=[fiddler_handler])

chain = final_prompt | llm

# Invoke the chain. Invocation will be logged to Fiddler, and metrics automatically generated
chain.invoke({"input": "What's the square of a triangle?"})
```