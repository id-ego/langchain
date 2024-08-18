---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/streamlit_chat_message_history.ipynb
description: Streamlit은 머신러닝 및 데이터 과학을 위한 아름답고 사용자 정의 가능한 웹 앱을 쉽게 만들고 공유할 수 있는 오픈
  소스 Python 라이브러리입니다.
---

# Streamlit

> [Streamlit](https://docs.streamlit.io/)는 머신러닝 및 데이터 과학을 위한 아름답고 사용자 정의 가능한 웹 앱을 쉽게 만들고 공유할 수 있게 해주는 오픈 소스 파이썬 라이브러리입니다.

이 노트북에서는 `Streamlit` 앱에서 채팅 메시지 기록을 저장하고 사용하는 방법을 다룹니다. `StreamlitChatMessageHistory`는 지정된 `key=`에서 [Streamlit 세션 상태](https://docs.streamlit.io/library/api-reference/session-state)에 메시지를 저장합니다. 기본 키는 `"langchain_messages"`입니다.

- 주의: `StreamlitChatMessageHistory`는 Streamlit 앱에서 실행될 때만 작동합니다.
- LangChain에 대한 [StreamlitCallbackHandler](/docs/integrations/callbacks/streamlit)도 관심이 있을 수 있습니다.
- Streamlit에 대한 자세한 내용은 그들의 [시작하기 문서](https://docs.streamlit.io/library/get-started)를 확인하세요.

통합은 `langchain-community` 패키지에 포함되어 있으므로 이를 설치해야 합니다. 또한 `streamlit`도 설치해야 합니다.

```
pip install -U langchain-community streamlit
```


[전체 앱 예제는 여기에서 실행 중인 것을 볼 수 있습니다](https://langchain-st-memory.streamlit.app/), 그리고 더 많은 예제는 [github.com/langchain-ai/streamlit-agent](https://github.com/langchain-ai/streamlit-agent)에서 확인할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "StreamlitChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.streamlit.StreamlitChatMessageHistory.html", "title": "Streamlit"}]-->
from langchain_community.chat_message_histories import (
    StreamlitChatMessageHistory,
)

history = StreamlitChatMessageHistory(key="chat_messages")

history.add_user_message("hi!")
history.add_ai_message("whats up?")
```


```python
history.messages
```


이 메시지 기록 클래스를 [LCEL Runnables](/docs/how_to/message_history)와 쉽게 결합할 수 있습니다.

기록은 주어진 사용자 세션 내에서 Streamlit 앱의 재실행 간에 지속됩니다. 주어진 `StreamlitChatMessageHistory`는 사용자 세션 간에 지속되거나 공유되지 않습니다.

```python
# Optionally, specify your own session_state key for storing messages
msgs = StreamlitChatMessageHistory(key="special_app_key")

if len(msgs.messages) == 0:
    msgs.add_ai_message("How can I help you?")
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Streamlit"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Streamlit"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Streamlit"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Streamlit"}]-->
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are an AI chatbot having a conversation with a human."),
        MessagesPlaceholder(variable_name="history"),
        ("human", "{question}"),
    ]
)

chain = prompt | ChatOpenAI()
```


```python
chain_with_history = RunnableWithMessageHistory(
    chain,
    lambda session_id: msgs,  # Always return the instance created earlier
    input_messages_key="question",
    history_messages_key="history",
)
```


대화형 Streamlit 앱은 종종 재실행할 때마다 이전의 각 채팅 메시지를 다시 그립니다. 이는 `StreamlitChatMessageHistory.messages`를 반복하여 쉽게 수행할 수 있습니다:

```python
import streamlit as st

for msg in msgs.messages:
    st.chat_message(msg.type).write(msg.content)

if prompt := st.chat_input():
    st.chat_message("human").write(prompt)

    # As usual, new messages are added to StreamlitChatMessageHistory when the Chain is called.
    config = {"configurable": {"session_id": "any"}}
    response = chain_with_history.invoke({"question": prompt}, config)
    st.chat_message("ai").write(response.content)
```


**[최종 앱 보기](https://langchain-st-memory.streamlit.app/).**