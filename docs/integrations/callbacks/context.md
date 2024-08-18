---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/context.ipynb
description: 이 문서는 Context와의 통합 방법을 안내하며, 사용자 분석 및 경험 개선을 위한 API 설정 및 사용법을 설명합니다.
---

# 컨텍스트

> [컨텍스트](https://context.ai/)는 LLM 기반 제품 및 기능에 대한 사용자 분석을 제공합니다.

`컨텍스트`를 사용하면 30분 이내에 사용자를 이해하고 경험을 개선할 수 있습니다.

이 가이드에서는 컨텍스트와 통합하는 방법을 보여드립니다.

## 설치 및 설정

```python
%pip install --upgrade --quiet  langchain langchain-openai langchain-community context-python
```


### API 자격 증명 받기

컨텍스트 API 토큰을 받으려면:

1. 컨텍스트 계정 내의 설정 페이지로 이동합니다 (https://with.context.ai/settings).
2. 새 API 토큰을 생성합니다.
3. 이 토큰을 안전한 곳에 저장합니다.

### 컨텍스트 설정

`ContextCallbackHandler`를 사용하려면 Langchain에서 핸들러를 가져오고 컨텍스트 API 토큰으로 인스턴스화합니다.

핸들러를 사용하기 전에 `context-python` 패키지가 설치되어 있는지 확인하세요.

```python
<!--IMPORTS:[{"imported": "ContextCallbackHandler", "source": "langchain_community.callbacks.context_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.context_callback.ContextCallbackHandler.html", "title": "Context"}]-->
from langchain_community.callbacks.context_callback import ContextCallbackHandler
```


```python
import os

token = os.environ["CONTEXT_API_TOKEN"]

context_callback = ContextCallbackHandler(token)
```


## 사용법
### 채팅 모델 내의 컨텍스트 콜백

컨텍스트 콜백 핸들러는 사용자와 AI 어시스턴트 간의 전사 기록을 직접 기록하는 데 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Context"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Context"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Context"}]-->
import os

from langchain_core.messages import HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI

token = os.environ["CONTEXT_API_TOKEN"]

chat = ChatOpenAI(
    headers={"user_id": "123"}, temperature=0, callbacks=[ContextCallbackHandler(token)]
)

messages = [
    SystemMessage(
        content="You are a helpful assistant that translates English to French."
    ),
    HumanMessage(content="I love programming."),
]

print(chat(messages))
```


### 체인 내의 컨텍스트 콜백

컨텍스트 콜백 핸들러는 체인의 입력 및 출력을 기록하는 데에도 사용할 수 있습니다. 체인의 중간 단계는 기록되지 않으며, 시작 입력과 최종 출력만 기록됩니다.

**참고:** 채팅 모델과 체인에 동일한 컨텍스트 객체를 전달해야 합니다.

잘못된 예:
> ```python
> chat = ChatOpenAI(temperature=0.9, callbacks=[ContextCallbackHandler(token)])
> chain = LLMChain(llm=chat, prompt=chat_prompt_template, callbacks=[ContextCallbackHandler(token)])
> ```


올바른 예:
> ```python
> handler = ContextCallbackHandler(token)
> chat = ChatOpenAI(temperature=0.9, callbacks=[callback])
> chain = LLMChain(llm=chat, prompt=chat_prompt_template, callbacks=[callback])
> ```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Context"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Context"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Context"}, {"imported": "HumanMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.HumanMessagePromptTemplate.html", "title": "Context"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Context"}]-->
import os

from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate
from langchain_core.prompts.chat import (
    ChatPromptTemplate,
    HumanMessagePromptTemplate,
)
from langchain_openai import ChatOpenAI

token = os.environ["CONTEXT_API_TOKEN"]

human_message_prompt = HumanMessagePromptTemplate(
    prompt=PromptTemplate(
        template="What is a good name for a company that makes {product}?",
        input_variables=["product"],
    )
)
chat_prompt_template = ChatPromptTemplate.from_messages([human_message_prompt])
callback = ContextCallbackHandler(token)
chat = ChatOpenAI(temperature=0.9, callbacks=[callback])
chain = LLMChain(llm=chat, prompt=chat_prompt_template, callbacks=[callback])
print(chain.run("colorful socks"))
```