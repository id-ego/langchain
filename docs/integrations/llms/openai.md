---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/openai.ipynb
description: OpenAI 모델을 사용하여 LangChain과 상호작용하는 방법을 설명하는 문서입니다. 다양한 작업에 적합한 모델을 다룹니다.
---

# OpenAI

:::caution
현재 OpenAI [텍스트 완성 모델](/docs/concepts/#llms) 사용에 대한 문서 페이지에 있습니다. 최신의 가장 인기 있는 OpenAI 모델은 [채팅 완성 모델](/docs/concepts/#chat-models)입니다.

특히 `gpt-3.5-turbo-instruct`를 사용하지 않는 한, 아마도 [대신 이 페이지](/docs/integrations/chat/openai/)를 찾고 있을 것입니다.
:::

[OpenAI](https://platform.openai.com/docs/introduction)는 다양한 작업에 적합한 다양한 수준의 성능을 가진 모델을 제공합니다.

이 예제는 LangChain을 사용하여 `OpenAI` [모델](https://platform.openai.com/docs/models)과 상호 작용하는 방법을 설명합니다.

## 개요

### 통합 세부정보
| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/chat/openai) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatOpenAI](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html) | [langchain-openai](https://api.python.langchain.com/en/latest/openai_api_reference.html) | ❌ | beta | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain-openai?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain-openai?style=flat-square&label=%20) |

## 설정

OpenAI 모델에 접근하려면 OpenAI 계정을 생성하고, API 키를 얻고, `langchain-openai` 통합 패키지를 설치해야 합니다.

### 자격 증명

https://platform.openai.com로 이동하여 OpenAI에 가입하고 API 키를 생성하세요. 이 작업을 마친 후 OPENAI_API_KEY 환경 변수를 설정하세요:

```python
import getpass
import os

if "OPENAI_API_KEY" not in os.environ:
    os.environ["OPENAI_API_KEY"] = getpass.getpass("Enter your OpenAI API key: ")
```

```output
Enter your OpenAI API key:  ········
```

모델 호출의 자동 최적 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

LangChain OpenAI 통합은 `langchain-openai` 패키지에 있습니다:

```python
%pip install -qU langchain-openai
```


조직 ID를 지정해야 하는 경우 다음 셀을 사용할 수 있습니다. 그러나 단일 조직의 일원인 경우 또는 기본 조직을 사용할 경우에는 필요하지 않습니다. 기본 조직은 [여기](https://platform.openai.com/account/api-keys)에서 확인할 수 있습니다.

조직을 지정하려면 다음을 사용할 수 있습니다:
```python
OPENAI_ORGANIZATION = getpass()

os.environ["OPENAI_ORGANIZATION"] = OPENAI_ORGANIZATION
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "OpenAI"}]-->
from langchain_openai import OpenAI

llm = OpenAI()
```


## 호출

```python
llm.invoke("Hello how are you?")
```


```output
"\n\nI'm an AI language model created by OpenAI, so I don't have feelings or emotions. But thank you for asking! How can I assist you today?"
```


## 체이닝

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "OpenAI"}]-->
from langchain_core.prompts import PromptTemplate

prompt = PromptTemplate("How to say {input} in {output_language}:\n")

chain = prompt | llm
chain.invoke(
    {
        "output_language": "German",
        "input": "I love programming.",
    }
)
```


## 프록시 사용

명시적 프록시 뒤에 있는 경우, 통과할 http_client를 지정할 수 있습니다.

```python
%pip install httpx

import httpx

openai = OpenAI(
    model_name="gpt-3.5-turbo-instruct",
    http_client=httpx.Client(proxies="http://proxy.yourcompany.com:8080"),
)
```


## API 참조

모든 `OpenAI` llm 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)