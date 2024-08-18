---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/zep_cloud_chat_message_history.ipynb
description: ZepCloudChatMessageHistory는 AI 비서의 대화 기록을 기억하고 이해하여 개인화된 AI 경험을 제공합니다.
---

# ZepCloudChatMessageHistory
> 대화 기록에서 데이터를 기억하고 이해하며 추출합니다. 개인화된 AI 경험을 강화합니다.

> [Zep](https://www.getzep.com)는 AI 어시스턴트 앱을 위한 장기 기억 서비스입니다.
Zep를 사용하면 AI 어시스턴트가 과거의 대화를 기억할 수 있는 능력을 제공하며, 이는 얼마나 먼 대화라도 상관없습니다.
또한 환각, 지연 및 비용을 줄이는 데 도움을 줍니다.

> [Zep Cloud 설치 가이드](https://help.getzep.com/sdks)와 더 많은 [Zep Cloud Langchain 예제](https://github.com/getzep/zep-python/tree/main/examples)를 참조하세요.

## 예제

이 노트북은 [Zep](https://www.getzep.com/)를 사용하여 대화 기록을 지속하고 Zep 메모리를 체인과 함께 사용하는 방법을 보여줍니다.

```python
<!--IMPORTS:[{"imported": "ZepCloudChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.zep_cloud.ZepCloudChatMessageHistory.html", "title": "ZepCloudChatMessageHistory"}, {"imported": "ZepCloudMemory", "source": "langchain_community.memory.zep_cloud_memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain_community.memory.zep_cloud_memory.ZepCloudMemory.html", "title": "ZepCloudChatMessageHistory"}, {"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "ZepCloudChatMessageHistory"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ZepCloudChatMessageHistory"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "ZepCloudChatMessageHistory"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ZepCloudChatMessageHistory"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "ZepCloudChatMessageHistory"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "ZepCloudChatMessageHistory"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "ZepCloudChatMessageHistory"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "ZepCloudChatMessageHistory"}]-->
from uuid import uuid4

from langchain_community.chat_message_histories import ZepCloudChatMessageHistory
from langchain_community.memory.zep_cloud_memory import ZepCloudMemory
from langchain_core.messages import AIMessage, HumanMessage
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables import (
    RunnableParallel,
)
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_openai import ChatOpenAI

session_id = str(uuid4())  # This is a unique identifier for the session
```


OpenAI 키를 제공하세요.

```python
import getpass

openai_key = getpass.getpass()
```


Zep API 키를 제공하세요. https://help.getzep.com/projects#api-keys를 참조하세요.

```python
zep_api_key = getpass.getpass()
```


메모리에 일부 메시지를 미리 로드합니다. 기본 메시지 창은 4개의 메시지입니다. 자동 요약을 시연하기 위해 이보다 더 많은 메시지를 추가하고자 합니다.

```python
test_history = [
    {"role": "human", "content": "Who was Octavia Butler?"},
    {
        "role": "ai",
        "content": (
            "Octavia Estelle Butler (June 22, 1947 – February 24, 2006) was an American"
            " science fiction author."
        ),
    },
    {"role": "human", "content": "Which books of hers were made into movies?"},
    {
        "role": "ai",
        "content": (
            "The most well-known adaptation of Octavia Butler's work is the FX series"
            " Kindred, based on her novel of the same name."
        ),
    },
    {"role": "human", "content": "Who were her contemporaries?"},
    {
        "role": "ai",
        "content": (
            "Octavia Butler's contemporaries included Ursula K. Le Guin, Samuel R."
            " Delany, and Joanna Russ."
        ),
    },
    {"role": "human", "content": "What awards did she win?"},
    {
        "role": "ai",
        "content": (
            "Octavia Butler won the Hugo Award, the Nebula Award, and the MacArthur"
            " Fellowship."
        ),
    },
    {
        "role": "human",
        "content": "Which other women sci-fi writers might I want to read?",
    },
    {
        "role": "ai",
        "content": "You might want to read Ursula K. Le Guin or Joanna Russ.",
    },
    {
        "role": "human",
        "content": (
            "Write a short synopsis of Butler's book, Parable of the Sower. What is it"
            " about?"
        ),
    },
    {
        "role": "ai",
        "content": (
            "Parable of the Sower is a science fiction novel by Octavia Butler,"
            " published in 1993. It follows the story of Lauren Olamina, a young woman"
            " living in a dystopian future where society has collapsed due to"
            " environmental disasters, poverty, and violence."
        ),
        "metadata": {"foo": "bar"},
    },
]

zep_memory = ZepCloudMemory(
    session_id=session_id,
    api_key=zep_api_key,
)

for msg in test_history:
    zep_memory.chat_memory.add_message(
        HumanMessage(content=msg["content"])
        if msg["role"] == "human"
        else AIMessage(content=msg["content"])
    )

import time

time.sleep(
    10
)  # Wait for the messages to be embedded and summarized, this happens asynchronously.
```


**MessagesPlaceholder** - 여기서 변수 이름 chat_history를 사용하고 있습니다. 이는 프롬프트에 대화 기록을 통합합니다.
이 변수 이름이 RunnableWithMessageHistory 체인의 history_messages_key와 일치하는 것이 중요합니다.

**question**은 `RunnableWithMessageHistory` 체인의 input_messages_key와 일치해야 합니다.

```python
template = """Be helpful and answer the question below using the provided context:
    """
answer_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", template),
        MessagesPlaceholder(variable_name="chat_history"),
        ("user", "{question}"),
    ]
)
```


RunnableWithMessageHistory를 사용하여 Zep의 대화 기록을 체인에 통합합니다. 이 클래스는 체인을 활성화할 때 session_id를 매개변수로 요구합니다.

```python
inputs = RunnableParallel(
    {
        "question": lambda x: x["question"],
        "chat_history": lambda x: x["chat_history"],
    },
)
chain = RunnableWithMessageHistory(
    inputs | answer_prompt | ChatOpenAI(openai_api_key=openai_key) | StrOutputParser(),
    lambda s_id: ZepCloudChatMessageHistory(
        session_id=s_id,  # This uniquely identifies the conversation, note that we are getting session id as chain configurable field
        api_key=zep_api_key,
        memory_type="perpetual",
    ),
    input_messages_key="question",
    history_messages_key="chat_history",
)
```


```python
chain.invoke(
    {
        "question": "What is the book's relevance to the challenges facing contemporary society?"
    },
    config={"configurable": {"session_id": session_id}},
)
```

```output
Parent run 622c6f75-3e4a-413d-ba20-558c1fea0d50 not found for run af12a4b1-e882-432d-834f-e9147465faf6. Treating as a root run.
```


```output
'"Parable of the Sower" is relevant to the challenges facing contemporary society as it explores themes of environmental degradation, economic inequality, social unrest, and the search for hope and community in the face of chaos. The novel\'s depiction of a dystopian future where society has collapsed due to environmental and economic crises serves as a cautionary tale about the potential consequences of our current societal and environmental challenges. By addressing issues such as climate change, social injustice, and the impact of technology on humanity, Octavia Butler\'s work prompts readers to reflect on the pressing issues of our time and the importance of resilience, empathy, and collective action in building a better future.'
```