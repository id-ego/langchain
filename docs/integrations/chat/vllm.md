---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/vllm.ipynb
description: vLLM은 OpenAI API 프로토콜을 모방하는 서버로, OpenAI API를 사용하는 애플리케이션의 대체로 사용될 수 있습니다.
sidebar_label: vLLM Chat
---

# vLLM 채팅

vLLM은 OpenAI API 프로토콜을 모방하는 서버로 배포될 수 있습니다. 이를 통해 vLLM은 OpenAI API를 사용하는 애플리케이션의 드롭인 대체로 사용될 수 있습니다. 이 서버는 OpenAI API와 동일한 형식으로 쿼리할 수 있습니다.

## 개요
이 문서는 `langchain-openai` 패키지를 활용하는 vLLM [채팅 모델](/docs/concepts/#chat-models) 시작하는 데 도움이 될 것입니다. 모든 `ChatOpenAI` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html)에서 확인하세요.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: | :---: |
| [ChatOpenAI](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html) | [langchain_openai](https://api.python.langchain.com/en/latest/langchain_openai.html) | ✅ | beta | ❌ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_openai?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_openai?style=flat-square&label=%20) |

### 모델 기능
도구 호출, 다중 모드 입력 지원, 토큰 수준 스트리밍 지원 등과 같은 특정 모델 기능은 호스팅된 모델에 따라 달라집니다.

## 설정

vLLM 문서는 [여기](https://docs.vllm.ai/en/latest/)에서 확인하세요.

LangChain을 통해 vLLM 모델에 접근하려면 `langchain-openai` 통합 패키지를 설치해야 합니다.

### 자격 증명

인증은 추론 서버의 세부 사항에 따라 달라집니다.

모델 호출의 자동 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
```


### 설치

LangChain vLLM 통합은 `langchain-openai` 패키지를 통해 접근할 수 있습니다:

```python
%pip install -qU langchain-openai
```


## 인스턴스화

이제 모델 객체를 인스턴스화하고 채팅 완성을 생성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "vLLM Chat"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "vLLM Chat"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "vLLM Chat"}, {"imported": "HumanMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.HumanMessagePromptTemplate.html", "title": "vLLM Chat"}, {"imported": "SystemMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.SystemMessagePromptTemplate.html", "title": "vLLM Chat"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "vLLM Chat"}]-->
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_core.prompts.chat import (
    ChatPromptTemplate,
    HumanMessagePromptTemplate,
    SystemMessagePromptTemplate,
)
from langchain_openai import ChatOpenAI
```


```python
inference_server_url = "http://localhost:8000/v1"

llm = ChatOpenAI(
    model="mosaicml/mpt-7b",
    openai_api_key="EMPTY",
    openai_api_base=inference_server_url,
    max_tokens=5,
    temperature=0,
)
```


## 호출

```python
messages = [
    SystemMessage(
        content="You are a helpful assistant that translates English to Italian."
    ),
    HumanMessage(
        content="Translate the following sentence from English to Italian: I love programming."
    ),
]
llm.invoke(messages)
```


```output
AIMessage(content=' Io amo programmare', additional_kwargs={}, example=False)
```


## 체이닝

프롬프트 템플릿과 함께 모델을 [체인](/docs/how_to/sequence/)할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "vLLM Chat"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate(
    [
        (
            "system",
            "You are a helpful assistant that translates {input_language} to {output_language}.",
        ),
        ("human", "{input}"),
    ]
)

chain = prompt | llm
chain.invoke(
    {
        "input_language": "English",
        "output_language": "German",
        "input": "I love programming.",
    }
)
```


## API 참조

`langchain-openai`를 통해 노출된 모든 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인하세요: https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html

vLLM [문서](https://docs.vllm.ai/en/latest/)도 참조하세요.

## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)