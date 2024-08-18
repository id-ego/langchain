---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/chatbot.ipynb
description: 이 문서는 LLM 기반 챗봇을 설계하고 구현하는 방법을 안내하며, 대화 및 이전 상호작용 기억 기능을 포함합니다.
keywords:
- conversationchain
sidebar_position: 1
---

# 챗봇 구축하기

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [챗 모델](/docs/concepts/#chat-models)
- [프롬프트 템플릿](/docs/concepts/#prompt-templates)
- [챗 기록](/docs/concepts/#chat-history)

:::

## 개요

LLM 기반 챗봇을 설계하고 구현하는 예제를 살펴보겠습니다.
이 챗봇은 대화를 나누고 이전 상호작용을 기억할 수 있습니다.

우리가 구축할 이 챗봇은 대화를 나누기 위해 언어 모델만 사용할 것입니다.
찾고 있을 수 있는 몇 가지 관련 개념은 다음과 같습니다:

- [대화형 RAG](/docs/tutorials/qa_chat_history): 외부 데이터 소스에서 챗봇 경험 활성화
- [에이전트](/docs/tutorials/agents): 행동을 취할 수 있는 챗봇 구축

이 튜토리얼은 두 가지 더 고급 주제에 유용한 기본 사항을 다룰 것이지만, 원하신다면 직접 그곳으로 건너뛰셔도 됩니다.

## 설정

### 주피터 노트북

이 가이드(및 문서의 대부분의 다른 가이드)는 [주피터 노트북](https://jupyter.org/)을 사용하며, 독자가 주피터 노트북을 사용할 것이라고 가정합니다. 주피터 노트북은 LLM 시스템을 다루는 방법을 배우기에 완벽합니다. 왜냐하면 종종 문제가 발생할 수 있기 때문입니다(예상치 못한 출력, API 다운 등) 그리고 대화형 환경에서 가이드를 진행하는 것은 이를 더 잘 이해하는 좋은 방법입니다.

이 튜토리얼과 다른 튜토리얼은 주피터 노트북에서 가장 편리하게 실행됩니다. 설치 방법에 대한 지침은 [여기](https://jupyter.org/install)를 참조하세요.

### 설치

LangChain을 설치하려면 다음을 실행하세요:

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import CodeBlock from "@theme/CodeBlock";

<Tabs>
  <TabItem value="pip" label="Pip" default>
    <CodeBlock language="bash">pip install langchain</CodeBlock>
  </TabItem>
  <TabItem value="conda" label="Conda">
    <CodeBlock language="bash">conda install langchain -c conda-forge</CodeBlock>
  </TabItem>
</Tabs>

자세한 내용은 [설치 가이드](/docs/how_to/installation)를 참조하세요.

### LangSmith

LangChain으로 구축하는 많은 애플리케이션은 여러 단계와 여러 번의 LLM 호출을 포함합니다.
이러한 애플리케이션이 점점 더 복잡해짐에 따라 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지를 검사할 수 있는 것이 중요해집니다.
이를 가장 잘 수행하는 방법은 [LangSmith](https://smith.langchain.com)입니다.

위 링크에서 가입한 후, 환경 변수를 설정하여 추적 로그를 시작하세요:

```shell
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_API_KEY="..."
```


또는, 노트북에서 다음과 같이 설정할 수 있습니다:

```python
import getpass
import os

os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 빠른 시작

먼저, 언어 모델을 단독으로 사용하는 방법을 배워봅시다. LangChain은 서로 교환 가능하게 사용할 수 있는 다양한 언어 모델을 지원합니다 - 아래에서 사용하고 싶은 모델을 선택하세요!

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs openaiParams={`model="gpt-3.5-turbo"`} />

먼저 모델을 직접 사용해 보겠습니다. `ChatModel`은 LangChain "Runnable"의 인스턴스이며, 이는 상호작용을 위한 표준 인터페이스를 노출합니다. 모델을 간단히 호출하려면, 메시지 목록을 `.invoke` 메서드에 전달할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Build a Chatbot"}]-->
from langchain_core.messages import HumanMessage

model.invoke([HumanMessage(content="Hi! I'm Bob")])
```


```output
AIMessage(content='Hello Bob! How can I assist you today?', response_metadata={'token_usage': {'completion_tokens': 10, 'prompt_tokens': 12, 'total_tokens': 22}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-d939617f-0c3b-45e9-a93f-13dafecbd4b5-0', usage_metadata={'input_tokens': 12, 'output_tokens': 10, 'total_tokens': 22})
```


모델 자체는 상태 개념이 없습니다. 예를 들어, 후속 질문을 하면:

```python
model.invoke([HumanMessage(content="What's my name?")])
```


```output
AIMessage(content="I'm sorry, I don't have access to personal information unless you provide it to me. How may I assist you today?", response_metadata={'token_usage': {'completion_tokens': 26, 'prompt_tokens': 12, 'total_tokens': 38}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-47bc8c20-af7b-4fd2-9345-f0e9fdf18ce3-0', usage_metadata={'input_tokens': 12, 'output_tokens': 26, 'total_tokens': 38})
```


예제 [LangSmith 추적](https://smith.langchain.com/public/5c21cb92-2814-4119-bae9-d02b8db577ac/r)을 살펴보겠습니다.

이전 대화 턴을 컨텍스트로 사용하지 않으며 질문에 답할 수 없음을 알 수 있습니다.
이는 끔찍한 챗봇 경험을 만듭니다!

이를 해결하기 위해서는 전체 대화 기록을 모델에 전달해야 합니다. 그렇게 했을 때 어떤 일이 발생하는지 살펴보겠습니다:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Build a Chatbot"}]-->
from langchain_core.messages import AIMessage

model.invoke(
    [
        HumanMessage(content="Hi! I'm Bob"),
        AIMessage(content="Hello Bob! How can I assist you today?"),
        HumanMessage(content="What's my name?"),
    ]
)
```


```output
AIMessage(content='Your name is Bob. How can I help you, Bob?', response_metadata={'token_usage': {'completion_tokens': 13, 'prompt_tokens': 35, 'total_tokens': 48}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-9f90291b-4df9-41dc-9ecf-1ee1081f4490-0', usage_metadata={'input_tokens': 35, 'output_tokens': 13, 'total_tokens': 48})
```


이제 좋은 응답을 받을 수 있음을 알 수 있습니다!

이것이 챗봇이 대화식으로 상호작용할 수 있는 기본 아이디어입니다.
그렇다면 이를 어떻게 최적으로 구현할 수 있을까요?

## 메시지 기록

메시지 기록 클래스를 사용하여 모델을 감싸고 상태를 유지할 수 있습니다.
이것은 모델의 입력 및 출력을 추적하고 이를 일부 데이터 저장소에 저장합니다.
향후 상호작용은 이러한 메시지를 로드하여 입력의 일부로 체인에 전달합니다.
사용하는 방법을 살펴보겠습니다!

먼저, 메시지 기록을 저장하기 위해 통합을 사용할 것이므로 `langchain-community`를 설치해야 합니다.

```python
# ! pip install langchain_community
```


그 후, 관련 클래스를 가져오고 모델을 감싸고 이 메시지 기록을 추가하는 체인을 설정할 수 있습니다. 여기서 중요한 부분은 `get_session_history`로 전달하는 함수입니다. 이 함수는 `session_id`를 받아 메시지 기록 객체를 반환해야 합니다. 이 `session_id`는 별도의 대화를 구분하는 데 사용되며, 새로운 체인을 호출할 때 구성의 일부로 전달되어야 합니다(그 방법을 보여드리겠습니다).

```python
<!--IMPORTS:[{"imported": "BaseChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.BaseChatMessageHistory.html", "title": "Build a Chatbot"}, {"imported": "InMemoryChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.InMemoryChatMessageHistory.html", "title": "Build a Chatbot"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Build a Chatbot"}]-->
from langchain_core.chat_history import (
    BaseChatMessageHistory,
    InMemoryChatMessageHistory,
)
from langchain_core.runnables.history import RunnableWithMessageHistory

store = {}


def get_session_history(session_id: str) -> BaseChatMessageHistory:
    if session_id not in store:
        store[session_id] = InMemoryChatMessageHistory()
    return store[session_id]


with_message_history = RunnableWithMessageHistory(model, get_session_history)
```


이제 매번 실행 가능한 항목에 전달할 `config`를 생성해야 합니다. 이 구성은 입력의 일부가 아닌 정보를 포함하지만 여전히 유용합니다. 이 경우, `session_id`를 포함하고 싶습니다. 이는 다음과 같아야 합니다:

```python
config = {"configurable": {"session_id": "abc2"}}
```


```python
response = with_message_history.invoke(
    [HumanMessage(content="Hi! I'm Bob")],
    config=config,
)

response.content
```


```output
'Hi Bob! How can I assist you today?'
```


```python
response = with_message_history.invoke(
    [HumanMessage(content="What's my name?")],
    config=config,
)

response.content
```


```output
'Your name is Bob. How can I help you today, Bob?'
```


좋습니다! 이제 우리의 챗봇은 우리에 대한 정보를 기억합니다. 구성을 다른 `session_id`를 참조하도록 변경하면 대화가 새로 시작되는 것을 볼 수 있습니다.

```python
config = {"configurable": {"session_id": "abc3"}}

response = with_message_history.invoke(
    [HumanMessage(content="What's my name?")],
    config=config,
)

response.content
```


```output
"I'm sorry, I cannot determine your name as I am an AI assistant and do not have access to that information."
```


그러나 우리는 항상 원래 대화로 돌아갈 수 있습니다(데이터베이스에 이를 지속적으로 저장하고 있으므로).

```python
config = {"configurable": {"session_id": "abc2"}}

response = with_message_history.invoke(
    [HumanMessage(content="What's my name?")],
    config=config,
)

response.content
```


```output
'Your name is Bob. How can I assist you today, Bob?'
```


이것이 여러 사용자와 대화를 나누는 챗봇을 지원하는 방법입니다!

지금까지 우리는 모델 주위에 간단한 지속성 계층을 추가한 것뿐입니다. 프롬프트 템플릿을 추가하여 더 복잡하고 개인화된 챗봇을 만들 수 있습니다.

## 프롬프트 템플릿

프롬프트 템플릿은 원시 사용자 정보를 LLM이 작업할 수 있는 형식으로 변환하는 데 도움을 줍니다. 이 경우, 원시 사용자 입력은 단순한 메시지로, 이를 LLM에 전달하고 있습니다. 이제 이를 좀 더 복잡하게 만들어 보겠습니다. 먼저, 사용자 메시지를 입력으로 받으면서 몇 가지 사용자 정의 지침이 포함된 시스템 메시지를 추가하겠습니다. 다음으로, 메시지 외에 더 많은 입력을 추가하겠습니다.

먼저 시스템 메시지를 추가해 보겠습니다. 이를 위해 ChatPromptTemplate을 생성하겠습니다. `MessagesPlaceholder`를 활용하여 모든 메시지를 전달하겠습니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Build a Chatbot"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Build a Chatbot"}]-->
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant. Answer all questions to the best of your ability.",
        ),
        MessagesPlaceholder(variable_name="messages"),
    ]
)

chain = prompt | model
```


이것은 입력 유형을 약간 변경합니다 - 이제 메시지 목록을 전달하는 대신, `messages` 키가 있는 사전을 전달하고 있습니다. 

```python
response = chain.invoke({"messages": [HumanMessage(content="hi! I'm bob")]})

response.content
```


```output
'Hello Bob! How can I assist you today?'
```


이제 이전과 동일한 메시지 기록 객체로 이를 감쌀 수 있습니다.

```python
with_message_history = RunnableWithMessageHistory(chain, get_session_history)
```


```python
config = {"configurable": {"session_id": "abc5"}}
```


```python
response = with_message_history.invoke(
    [HumanMessage(content="Hi! I'm Jim")],
    config=config,
)

response.content
```


```output
'Hello, Jim! How can I assist you today?'
```


```python
response = with_message_history.invoke(
    [HumanMessage(content="What's my name?")],
    config=config,
)

response.content
```


```output
'Your name is Jim.'
```


멋집니다! 이제 프롬프트를 조금 더 복잡하게 만들어 보겠습니다. 프롬프트 템플릿이 이제 다음과 같은 형태라고 가정해 보겠습니다:

```python
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant. Answer all questions to the best of your ability in {language}.",
        ),
        MessagesPlaceholder(variable_name="messages"),
    ]
)

chain = prompt | model
```


프롬프트에 새로운 `language` 입력을 추가했습니다. 이제 체인을 호출하고 원하는 언어를 전달할 수 있습니다.

```python
response = chain.invoke(
    {"messages": [HumanMessage(content="hi! I'm bob")], "language": "Spanish"}
)

response.content
```


```output
'¡Hola, Bob! ¿En qué puedo ayudarte hoy?'
```


이제 이 더 복잡한 체인을 메시지 기록 클래스로 감쌀 수 있습니다. 이번에는 입력에 여러 키가 있으므로, 채팅 기록을 저장하는 데 사용할 올바른 키를 지정해야 합니다.

```python
with_message_history = RunnableWithMessageHistory(
    chain,
    get_session_history,
    input_messages_key="messages",
)
```


```python
config = {"configurable": {"session_id": "abc11"}}
```


```python
response = with_message_history.invoke(
    {"messages": [HumanMessage(content="hi! I'm todd")], "language": "Spanish"},
    config=config,
)

response.content
```


```output
'¡Hola Todd! ¿En qué puedo ayudarte hoy?'
```


```python
response = with_message_history.invoke(
    {"messages": [HumanMessage(content="whats my name?")], "language": "Spanish"},
    config=config,
)

response.content
```


```output
'Tu nombre es Todd.'
```


내부에서 무슨 일이 일어나고 있는지 이해하는 데 도움이 되도록 [이 LangSmith 추적](https://smith.langchain.com/public/f48fabb6-6502-43ec-8242-afc352b769ed/r)을 확인하세요.

## 대화 기록 관리

챗봇을 구축할 때 이해해야 할 중요한 개념 중 하나는 대화 기록을 관리하는 방법입니다. 관리되지 않으면 메시지 목록이 무한히 증가하고 LLM의 컨텍스트 창을 초과할 수 있습니다. 따라서 전달하는 메시지의 크기를 제한하는 단계를 추가하는 것이 중요합니다.

**중요하게도, 이전 메시지를 메시지 기록에서 로드한 후 프롬프트 템플릿 전에 이 작업을 수행해야 합니다.**

프롬프트 앞에 간단한 단계를 추가하여 `messages` 키를 적절하게 수정한 다음, 그 새로운 체인을 메시지 기록 클래스로 감쌀 수 있습니다.

LangChain은 [메시지 목록 관리](/docs/how_to/#messages)를 위한 몇 가지 내장 도우미를 제공합니다. 이 경우 [trim_messages](/docs/how_to/trim_messages/) 도우미를 사용하여 모델에 보내는 메시지 수를 줄일 것입니다. 트리머를 사용하면 유지할 토큰 수를 지정할 수 있으며, 시스템 메시지를 항상 유지할지 여부 및 부분 메시지를 허용할지 여부와 같은 다른 매개변수도 지정할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Build a Chatbot"}, {"imported": "trim_messages", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.utils.trim_messages.html", "title": "Build a Chatbot"}]-->
from langchain_core.messages import SystemMessage, trim_messages

trimmer = trim_messages(
    max_tokens=65,
    strategy="last",
    token_counter=model,
    include_system=True,
    allow_partial=False,
    start_on="human",
)

messages = [
    SystemMessage(content="you're a good assistant"),
    HumanMessage(content="hi! I'm bob"),
    AIMessage(content="hi!"),
    HumanMessage(content="I like vanilla ice cream"),
    AIMessage(content="nice"),
    HumanMessage(content="whats 2 + 2"),
    AIMessage(content="4"),
    HumanMessage(content="thanks"),
    AIMessage(content="no problem!"),
    HumanMessage(content="having fun?"),
    AIMessage(content="yes!"),
]

trimmer.invoke(messages)
```


```output
[SystemMessage(content="you're a good assistant"),
 HumanMessage(content='whats 2 + 2'),
 AIMessage(content='4'),
 HumanMessage(content='thanks'),
 AIMessage(content='no problem!'),
 HumanMessage(content='having fun?'),
 AIMessage(content='yes!')]
```


체인에서 이를 사용하려면, `messages` 입력을 프롬프트에 전달하기 전에 트리머를 실행하면 됩니다.

이제 모델에게 우리의 이름을 물어보면, 우리는 그 부분이 대화 기록에서 잘린 상태이므로 알지 못합니다:

```python
<!--IMPORTS:[{"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Build a Chatbot"}]-->
from operator import itemgetter

from langchain_core.runnables import RunnablePassthrough

chain = (
    RunnablePassthrough.assign(messages=itemgetter("messages") | trimmer)
    | prompt
    | model
)

response = chain.invoke(
    {
        "messages": messages + [HumanMessage(content="what's my name?")],
        "language": "English",
    }
)
response.content
```


```output
"I'm sorry, but I don't have access to your personal information. How can I assist you today?"
```


하지만 최근 몇 개의 메시지 내에서 정보를 물어보면 기억합니다:

```python
response = chain.invoke(
    {
        "messages": messages + [HumanMessage(content="what math problem did i ask")],
        "language": "English",
    }
)
response.content
```


```output
'You asked "what\'s 2 + 2?"'
```


이제 이를 메시지 기록으로 감쌉니다.

```python
with_message_history = RunnableWithMessageHistory(
    chain,
    get_session_history,
    input_messages_key="messages",
)

config = {"configurable": {"session_id": "abc20"}}
```


```python
response = with_message_history.invoke(
    {
        "messages": messages + [HumanMessage(content="whats my name?")],
        "language": "English",
    },
    config=config,
)

response.content
```


```output
"I'm sorry, I don't have access to that information. How can I assist you today?"
```


예상대로, 우리가 이름을 언급한 첫 번째 메시지는 잘렸습니다. 또한 채팅 기록에 두 개의 새로운 메시지가 추가되었습니다(우리의 최신 질문과 최신 응답). 이는 대화 기록에서 접근할 수 있었던 더 많은 정보가 더 이상 사용 가능하지 않음을 의미합니다! 이 경우, 우리의 초기 수학 질문도 기록에서 잘렸으므로 모델은 더 이상 이를 알지 못합니다:

```python
response = with_message_history.invoke(
    {
        "messages": [HumanMessage(content="what math problem did i ask?")],
        "language": "English",
    },
    config=config,
)

response.content
```


```output
"You haven't asked a math problem yet. Feel free to ask any math-related question you have, and I'll be happy to help you with it."
```


LangSmith를 확인하면, [LangSmith 추적](https://smith.langchain.com/public/a64b8b7c-1fd6-4dbb-b11a-47cd09a5e4f1/r)에서 내부에서 무슨 일이 일어나고 있는지 정확히 확인할 수 있습니다.

## 스트리밍

이제 우리는 기능이 있는 챗봇을 갖추었습니다. 그러나 챗봇 애플리케이션에서 정말 중요한 UX 고려 사항 중 하나는 스트리밍입니다. LLM은 응답하는 데 시간이 걸릴 수 있으므로, 사용자 경험을 개선하기 위해 대부분의 애플리케이션에서는 생성되는 각 토큰을 스트리밍하여 반환합니다. 이를 통해 사용자는 진행 상황을 볼 수 있습니다.

사실, 이를 수행하는 것은 매우 쉽습니다!

모든 체인은 `.stream` 메서드를 노출하며, 메시지 기록을 사용하는 것도 다르지 않습니다. 우리는 단순히 그 메서드를 사용하여 스트리밍 응답을 받을 수 있습니다.

```python
config = {"configurable": {"session_id": "abc15"}}
for r in with_message_history.stream(
    {
        "messages": [HumanMessage(content="hi! I'm todd. tell me a joke")],
        "language": "English",
    },
    config=config,
):
    print(r.content, end="|")
```

```output
|Hi| Todd|!| Sure|,| here|'s| a| joke| for| you|:| Why| couldn|'t| the| bicycle| find| its| way| home|?| Because| it| lost| its| bearings|!| 😄||
```


## 다음 단계

LangChain에서 챗봇을 만드는 기본 사항을 이해했으므로, 관심이 있을 수 있는 더 고급 튜토리얼은 다음과 같습니다:

- [대화형 RAG](/docs/tutorials/qa_chat_history): 외부 데이터 소스에서 챗봇 경험 활성화
- [에이전트](/docs/tutorials/agents): 행동을 취할 수 있는 챗봇 구축

구체적인 내용에 대해 더 깊이 파고들고 싶다면, 확인할 가치가 있는 몇 가지 사항은 다음과 같습니다:

- [스트리밍](/docs/how_to/streaming): 스트리밍은 *챗 애플리케이션*에 *중요*합니다
- [메시지 기록 추가 방법](/docs/how_to/message_history): 메시지 기록과 관련된 모든 것에 대한 깊이 있는 탐구
- [대규모 메시지 기록 관리 방법](/docs/how_to/trim_messages/): 대규모 채팅 기록 관리를 위한 추가 기술