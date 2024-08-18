---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/conversation_chain.ipynb
description: 이 문서는 `ConversationChain`과 `RunnableWithMessageHistory`의 차이점과 장점을 설명하며,
  상태 유지 대화 구현에 대한 정보를 제공합니다.
title: Migrating from ConversationalChain
---

[`ConversationChain`](https://api.python.langchain.com/en/latest/chains/langchain.chains.conversation.base.ConversationChain.html)은 이전 메시지의 메모리를 통합하여 상태를 유지하는 대화를 지원합니다.

LCEL 구현으로 전환하는 몇 가지 장점은 다음과 같습니다:

- 스레드/별도 세션에 대한 본질적인 지원. `ConversationChain`과 함께 작동하려면 체인 외부에서 별도의 메모리 클래스를 인스턴스화해야 합니다.
- 더 명시적인 매개변수. `ConversationChain`은 숨겨진 기본 프롬프트를 포함하고 있어 혼란을 초래할 수 있습니다.
- 스트리밍 지원. `ConversationChain`은 콜백을 통해서만 스트리밍을 지원합니다.

`RunnableWithMessageHistory`는 구성 매개변수를 통해 세션을 구현합니다. 이는 [채팅 메시지 기록](https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.BaseChatMessageHistory.html)을 반환하는 호출 가능 객체로 인스턴스화되어야 합니다. 기본적으로 이 함수는 단일 인수 `session_id`를 받는 것으로 예상됩니다.

```python
%pip install --upgrade --quiet langchain langchain-openai
```


```python
import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


## 레거시

<details open>

```python
<!--IMPORTS:[{"imported": "ConversationChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.conversation.base.ConversationChain.html", "title": "# Legacy"}, {"imported": "ConversationBufferMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer.ConversationBufferMemory.html", "title": "# Legacy"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from langchain.chains import ConversationChain
from langchain.memory import ConversationBufferMemory
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI

template = """
You are a pirate. Answer the following questions as best you can.
Chat history: {history}
Question: {input}
"""

prompt = ChatPromptTemplate.from_template(template)

memory = ConversationBufferMemory()

chain = ConversationChain(
    llm=ChatOpenAI(),
    memory=memory,
    prompt=prompt,
)

chain({"input": "how are you?"})
```


```output
{'input': 'how are you?',
 'history': '',
 'response': "Arr matey, I be doin' well on the high seas, plunderin' and pillagin' as usual. How be ye?"}
```


</details>

## LCEL

<details open>

```python
<!--IMPORTS:[{"imported": "InMemoryChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.InMemoryChatMessageHistory.html", "title": "# Legacy"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "# Legacy"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Legacy"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "# Legacy"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "# Legacy"}]-->
from langchain_core.chat_history import InMemoryChatMessageHistory
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a pirate. Answer the following questions as best you can."),
        ("placeholder", "{chat_history}"),
        ("human", "{input}"),
    ]
)

history = InMemoryChatMessageHistory()


def get_history():
    return history


chain = prompt | ChatOpenAI() | StrOutputParser()

wrapped_chain = RunnableWithMessageHistory(
    chain,
    get_history,
    history_messages_key="chat_history",
)

wrapped_chain.invoke({"input": "how are you?"})
```


```output
"Arr, me matey! I be doin' well, sailin' the high seas and searchin' for treasure. How be ye?"
```


위의 예제는 모든 세션에 대해 동일한 `history`를 사용합니다. 아래 예제는 각 세션에 대해 다른 채팅 기록을 사용하는 방법을 보여줍니다.

```python
<!--IMPORTS:[{"imported": "BaseChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.BaseChatMessageHistory.html", "title": "# Legacy"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "# Legacy"}]-->
from langchain_core.chat_history import BaseChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory

store = {}


def get_session_history(session_id: str) -> BaseChatMessageHistory:
    if session_id not in store:
        store[session_id] = InMemoryChatMessageHistory()
    return store[session_id]


chain = prompt | ChatOpenAI() | StrOutputParser()

wrapped_chain = RunnableWithMessageHistory(
    chain,
    get_session_history,
    history_messages_key="chat_history",
)

wrapped_chain.invoke(
    {"input": "Hello!"},
    config={"configurable": {"session_id": "abc123"}},
)
```


```output
'Ahoy there, me hearty! What can this old pirate do for ye today?'
```


</details>

## 다음 단계

[`RunnableWithMessageHistory`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html)로 구축하는 데 대한 보다 포괄적인 가이드는 [이 튜토리얼](/docs/tutorials/chatbot)을 참조하세요.

더 많은 배경 정보를 원하시면 [LCEL 개념 문서](/docs/concepts/#langchain-expression-language-lcel)를 확인하세요.