---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/chatbots_memory.ipynb
description: 챗봇에 메모리를 추가하는 방법을 다루며, 대화 이력을 관리하는 다양한 기법을 소개합니다.
sidebar_position: 1
---

# 챗봇에 메모리 추가하는 방법

챗봇의 주요 기능 중 하나는 이전 대화의 내용을 맥락으로 사용할 수 있는 능력입니다. 이 상태 관리는 여러 형태를 취할 수 있으며, 여기에는 다음이 포함됩니다:

- 이전 메시지를 단순히 챗 모델 프롬프트에 넣는 것.
- 위의 방법에서 오래된 메시지를 잘라내어 모델이 처리해야 할 방해 정보를 줄이는 것.
- 장기 대화를 위한 요약을 합성하는 것과 같은 더 복잡한 수정.

아래에서 몇 가지 기술에 대해 더 자세히 설명하겠습니다!

## 설정

몇 가지 패키지를 설치하고, OpenAI API 키를 `OPENAI_API_KEY`라는 환경 변수로 설정해야 합니다:

```python
%pip install --upgrade --quiet langchain langchain-openai

# Set env var OPENAI_API_KEY or load from a .env file:
import dotenv

dotenv.load_dotenv()
```

```output
[33mWARNING: You are using pip version 22.0.4; however, version 23.3.2 is available.
You should consider upgrading via the '/Users/jacoblee/.pyenv/versions/3.10.5/bin/python -m pip install --upgrade pip' command.[0m[33m
[0mNote: you may need to restart the kernel to use updated packages.
```


```output
True
```


아래 예제에 사용할 챗 모델도 설정해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add memory to chatbots"}]-->
from langchain_openai import ChatOpenAI

chat = ChatOpenAI(model="gpt-3.5-turbo-0125")
```


## 메시지 전달

메모리의 가장 간단한 형태는 챗 기록 메시지를 체인에 전달하는 것입니다. 다음은 예입니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add memory to chatbots"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant. Answer all questions to the best of your ability.",
        ),
        ("placeholder", "{messages}"),
    ]
)

chain = prompt | chat

ai_msg = chain.invoke(
    {
        "messages": [
            (
                "human",
                "Translate this sentence from English to French: I love programming.",
            ),
            ("ai", "J'adore la programmation."),
            ("human", "What did you just say?"),
        ],
    }
)
print(ai_msg.content)
```

```output
I said "J'adore la programmation," which means "I love programming" in French.
```

이전 대화를 체인에 전달함으로써 질문에 대한 답변을 맥락으로 사용할 수 있음을 알 수 있습니다. 이것이 챗봇 메모리의 기본 개념이며, 가이드의 나머지 부분에서는 메시지를 전달하거나 재구성하는 편리한 기술을 보여줄 것입니다.

## 챗 기록

메시지를 배열로 직접 저장하고 전달하는 것도 완전히 괜찮지만, LangChain의 내장된 [메시지 기록 클래스](https://api.python.langchain.com/en/latest/langchain_api_reference.html#module-langchain.memory)를 사용하여 메시지를 저장하고 로드할 수도 있습니다. 이 클래스의 인스턴스는 지속적인 저장소에서 챗 메시지를 저장하고 로드하는 역할을 합니다. LangChain은 많은 공급자와 통합되어 있으며, [통합 목록을 여기에서 확인할 수 있습니다](/docs/integrations/memory) - 하지만 이 데모에서는 일시적인 데모 클래스를 사용할 것입니다.

API의 예는 다음과 같습니다:

```python
<!--IMPORTS:[{"imported": "ChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.ChatMessageHistory.html", "title": "How to add memory to chatbots"}]-->
from langchain_community.chat_message_histories import ChatMessageHistory

demo_ephemeral_chat_history = ChatMessageHistory()

demo_ephemeral_chat_history.add_user_message(
    "Translate this sentence from English to French: I love programming."
)

demo_ephemeral_chat_history.add_ai_message("J'adore la programmation.")

demo_ephemeral_chat_history.messages
```


```output
[HumanMessage(content='Translate this sentence from English to French: I love programming.'),
 AIMessage(content="J'adore la programmation.")]
```


체인을 위해 대화 턴을 저장하는 데 직접 사용할 수 있습니다:

```python
demo_ephemeral_chat_history = ChatMessageHistory()

input1 = "Translate this sentence from English to French: I love programming."

demo_ephemeral_chat_history.add_user_message(input1)

response = chain.invoke(
    {
        "messages": demo_ephemeral_chat_history.messages,
    }
)

demo_ephemeral_chat_history.add_ai_message(response)

input2 = "What did I just ask you?"

demo_ephemeral_chat_history.add_user_message(input2)

chain.invoke(
    {
        "messages": demo_ephemeral_chat_history.messages,
    }
)
```


```output
AIMessage(content='You just asked me to translate the sentence "I love programming" from English to French.', response_metadata={'token_usage': {'completion_tokens': 18, 'prompt_tokens': 61, 'total_tokens': 79}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-5cbb21c2-9c30-4031-8ea8-bfc497989535-0', usage_metadata={'input_tokens': 61, 'output_tokens': 18, 'total_tokens': 79})
```


## 자동 기록 관리

이전 예제는 메시지를 체인에 명시적으로 전달합니다. 이것은 완전히 허용되는 접근 방식이지만, 새로운 메시지에 대한 외부 관리가 필요합니다. LangChain은 이 프로세스를 자동으로 처리할 수 있는 `RunnableWithMessageHistory`라는 LCEL 체인에 대한 래퍼도 포함하고 있습니다.

작동 방식을 보여주기 위해, 위의 프롬프트를 약간 수정하여 챗 기록 뒤에 `HumanMessage` 템플릿을 채우는 최종 `input` 변수를 받도록 하겠습니다. 이는 현재 메시지 이전의 모든 메시지를 포함하는 `chat_history` 매개변수를 기대하게 됩니다:

```python
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant. Answer all questions to the best of your ability.",
        ),
        ("placeholder", "{chat_history}"),
        ("human", "{input}"),
    ]
)

chain = prompt | chat
```


여기서 최신 입력을 대화에 전달하고 `RunnableWithMessageHistory` 클래스가 우리의 체인을 감싸고 그 `input` 변수를 챗 기록에 추가하는 작업을 수행하도록 하겠습니다.

다음으로, 감싼 체인을 선언해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "How to add memory to chatbots"}]-->
from langchain_core.runnables.history import RunnableWithMessageHistory

demo_ephemeral_chat_history_for_chain = ChatMessageHistory()

chain_with_message_history = RunnableWithMessageHistory(
    chain,
    lambda session_id: demo_ephemeral_chat_history_for_chain,
    input_messages_key="input",
    history_messages_key="chat_history",
)
```


이 클래스는 우리가 감싸고자 하는 체인 외에 몇 가지 매개변수를 받습니다:

- 주어진 세션 ID에 대한 메시지 기록을 반환하는 팩토리 함수. 이를 통해 체인은 서로 다른 대화에 대해 서로 다른 메시지를 로드하여 여러 사용자를 동시에 처리할 수 있습니다.
- 입력의 어떤 부분을 추적하고 챗 기록에 저장할지 지정하는 `input_messages_key`. 이 예제에서는 `input`으로 전달된 문자열을 추적하고자 합니다.
- 이전 메시지가 프롬프트에 무엇으로 주입되어야 하는지를 지정하는 `history_messages_key`. 우리의 프롬프트에는 `chat_history`라는 `MessagesPlaceholder`가 있으므로, 이 속성을 일치하도록 지정합니다.
- (여러 출력을 가진 체인의 경우) 어떤 출출력을 기록으로 저장할지를 지정하는 `output_messages_key`. 이는 `input_messages_key`의 반대입니다.

이 새로운 체인을 일반적으로 호출할 수 있으며, 특정 `session_id`를 팩토리 함수에 전달하도록 지정하는 추가 `configurable` 필드가 있습니다. 이는 데모에서는 사용되지 않지만, 실제 체인에서는 전달된 세션에 해당하는 챗 기록을 반환하고자 할 것입니다:

```python
chain_with_message_history.invoke(
    {"input": "Translate this sentence from English to French: I love programming."},
    {"configurable": {"session_id": "unused"}},
)
```

```output
Parent run dc4e2f79-4bcd-4a36-9506-55ace9040588 not found for run 34b5773e-3ced-46a6-8daf-4d464c15c940. Treating as a root run.
```


```output
AIMessage(content='"J\'adore la programmation."', response_metadata={'token_usage': {'completion_tokens': 9, 'prompt_tokens': 39, 'total_tokens': 48}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-648b0822-b0bb-47a2-8e7d-7d34744be8f2-0', usage_metadata={'input_tokens': 39, 'output_tokens': 9, 'total_tokens': 48})
```


```python
chain_with_message_history.invoke(
    {"input": "What did I just ask you?"}, {"configurable": {"session_id": "unused"}}
)
```

```output
Parent run cc14b9d8-c59e-40db-a523-d6ab3fc2fa4f not found for run 5b75e25c-131e-46ee-9982-68569db04330. Treating as a root run.
```


```output
AIMessage(content='You asked me to translate the sentence "I love programming" from English to French.', response_metadata={'token_usage': {'completion_tokens': 17, 'prompt_tokens': 63, 'total_tokens': 80}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-5950435c-1dc2-43a6-836f-f989fd62c95e-0', usage_metadata={'input_tokens': 63, 'output_tokens': 17, 'total_tokens': 80})
```


## 챗 기록 수정

저장된 챗 메시지를 수정하면 챗봇이 다양한 상황을 처리하는 데 도움이 될 수 있습니다. 다음은 몇 가지 예입니다:

### 메시지 다듬기

LLM과 챗 모델은 제한된 맥락 창을 가지며, 직접적으로 한계를 초과하지 않더라도 모델이 처리해야 할 방해 요소의 양을 제한하고 싶을 수 있습니다. 한 가지 해결책은 모델에 전달하기 전에 역사적 메시지를 잘라내는 것입니다. 사전 로드된 메시지가 있는 예제 기록을 사용해 보겠습니다:

```python
demo_ephemeral_chat_history = ChatMessageHistory()

demo_ephemeral_chat_history.add_user_message("Hey there! I'm Nemo.")
demo_ephemeral_chat_history.add_ai_message("Hello!")
demo_ephemeral_chat_history.add_user_message("How are you today?")
demo_ephemeral_chat_history.add_ai_message("Fine thanks!")

demo_ephemeral_chat_history.messages
```


```output
[HumanMessage(content="Hey there! I'm Nemo."),
 AIMessage(content='Hello!'),
 HumanMessage(content='How are you today?'),
 AIMessage(content='Fine thanks!')]
```


위에서 선언한 `RunnableWithMessageHistory` 체인과 함께 이 메시지 기록을 사용해 보겠습니다:

```python
chain_with_message_history = RunnableWithMessageHistory(
    chain,
    lambda session_id: demo_ephemeral_chat_history,
    input_messages_key="input",
    history_messages_key="chat_history",
)

chain_with_message_history.invoke(
    {"input": "What's my name?"},
    {"configurable": {"session_id": "unused"}},
)
```

```output
Parent run 7ff2d8ec-65e2-4f67-8961-e498e2c4a591 not found for run 3881e990-6596-4326-84f6-2b76949e0657. Treating as a root run.
```


```output
AIMessage(content='Your name is Nemo.', response_metadata={'token_usage': {'completion_tokens': 6, 'prompt_tokens': 66, 'total_tokens': 72}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-f8aabef8-631a-4238-a39b-701e881fbe47-0', usage_metadata={'input_tokens': 66, 'output_tokens': 6, 'total_tokens': 72})
```


체인이 사전 로드된 이름을 기억하고 있음을 알 수 있습니다.

하지만 매우 작은 맥락 창이 있고, 체인에 전달되는 메시지 수를 가장 최근의 2개로 제한하고 싶다고 가정해 보겠습니다. 우리는 메시지가 프롬프트에 도달하기 전에 토큰 수를 기준으로 메시지를 잘라내기 위해 내장된 [trim_messages](/docs/how_to/trim_messages/) 유틸리티를 사용할 수 있습니다. 이 경우 각 메시지를 1 "토큰"으로 계산하고 마지막 두 메시지만 유지합니다:

```python
<!--IMPORTS:[{"imported": "trim_messages", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.utils.trim_messages.html", "title": "How to add memory to chatbots"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to add memory to chatbots"}]-->
from operator import itemgetter

from langchain_core.messages import trim_messages
from langchain_core.runnables import RunnablePassthrough

trimmer = trim_messages(strategy="last", max_tokens=2, token_counter=len)

chain_with_trimming = (
    RunnablePassthrough.assign(chat_history=itemgetter("chat_history") | trimmer)
    | prompt
    | chat
)

chain_with_trimmed_history = RunnableWithMessageHistory(
    chain_with_trimming,
    lambda session_id: demo_ephemeral_chat_history,
    input_messages_key="input",
    history_messages_key="chat_history",
)
```


이 새로운 체인을 호출하고 메시지를 확인해 보겠습니다:

```python
chain_with_trimmed_history.invoke(
    {"input": "Where does P. Sherman live?"},
    {"configurable": {"session_id": "unused"}},
)
```

```output
Parent run 775cde65-8d22-4c44-80bb-f0b9811c32ca not found for run 5cf71d0e-4663-41cd-8dbe-e9752689cfac. Treating as a root run.
```


```output
AIMessage(content='P. Sherman is a fictional character from the animated movie "Finding Nemo" who lives at 42 Wallaby Way, Sydney.', response_metadata={'token_usage': {'completion_tokens': 27, 'prompt_tokens': 53, 'total_tokens': 80}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-5642ef3a-fdbe-43cf-a575-d1785976a1b9-0', usage_metadata={'input_tokens': 53, 'output_tokens': 27, 'total_tokens': 80})
```


```python
demo_ephemeral_chat_history.messages
```


```output
[HumanMessage(content="Hey there! I'm Nemo."),
 AIMessage(content='Hello!'),
 HumanMessage(content='How are you today?'),
 AIMessage(content='Fine thanks!'),
 HumanMessage(content="What's my name?"),
 AIMessage(content='Your name is Nemo.', response_metadata={'token_usage': {'completion_tokens': 6, 'prompt_tokens': 66, 'total_tokens': 72}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-f8aabef8-631a-4238-a39b-701e881fbe47-0', usage_metadata={'input_tokens': 66, 'output_tokens': 6, 'total_tokens': 72}),
 HumanMessage(content='Where does P. Sherman live?'),
 AIMessage(content='P. Sherman is a fictional character from the animated movie "Finding Nemo" who lives at 42 Wallaby Way, Sydney.', response_metadata={'token_usage': {'completion_tokens': 27, 'prompt_tokens': 53, 'total_tokens': 80}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-5642ef3a-fdbe-43cf-a575-d1785976a1b9-0', usage_metadata={'input_tokens': 53, 'output_tokens': 27, 'total_tokens': 80})]
```


우리의 기록에서 가장 오래된 두 메시지가 제거되었고, 가장 최근의 대화가 끝에 추가된 것을 확인할 수 있습니다. 다음에 체인이 호출될 때, `trim_messages`가 다시 호출되고 가장 최근의 두 메시지만 모델에 전달됩니다. 이 경우, 이는 모델이 다음에 호출할 때 우리가 준 이름을 잊게 된다는 것을 의미합니다:

```python
chain_with_trimmed_history.invoke(
    {"input": "What is my name?"},
    {"configurable": {"session_id": "unused"}},
)
```

```output
Parent run fde7123f-6fd3-421a-a3fc-2fb37dead119 not found for run 061a4563-2394-470d-a3ed-9bf1388ca431. Treating as a root run.
```


```output
AIMessage(content="I'm sorry, but I don't have access to your personal information, so I don't know your name. How else may I assist you today?", response_metadata={'token_usage': {'completion_tokens': 31, 'prompt_tokens': 74, 'total_tokens': 105}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-0ab03495-1f7c-4151-9070-56d2d1c565ff-0', usage_metadata={'input_tokens': 74, 'output_tokens': 31, 'total_tokens': 105})
```


메시지 잘라내기에 대한 [가이드](/docs/how_to/trim_messages/)를 확인해 보세요.

### 요약 메모리

우리는 이 동일한 패턴을 다른 방식으로도 사용할 수 있습니다. 예를 들어, 체인을 호출하기 전에 대화의 요약을 생성하기 위해 추가 LLM 호출을 사용할 수 있습니다. 우리의 챗 기록과 챗봇 체인을 재구성해 보겠습니다:

```python
demo_ephemeral_chat_history = ChatMessageHistory()

demo_ephemeral_chat_history.add_user_message("Hey there! I'm Nemo.")
demo_ephemeral_chat_history.add_ai_message("Hello!")
demo_ephemeral_chat_history.add_user_message("How are you today?")
demo_ephemeral_chat_history.add_ai_message("Fine thanks!")

demo_ephemeral_chat_history.messages
```


```output
[HumanMessage(content="Hey there! I'm Nemo."),
 AIMessage(content='Hello!'),
 HumanMessage(content='How are you today?'),
 AIMessage(content='Fine thanks!')]
```


LLM이 챗 기록 대신 응축된 요약을 받을 것임을 인식하도록 프롬프트를 약간 수정하겠습니다:

```python
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant. Answer all questions to the best of your ability. The provided chat history includes facts about the user you are speaking with.",
        ),
        ("placeholder", "{chat_history}"),
        ("user", "{input}"),
    ]
)

chain = prompt | chat

chain_with_message_history = RunnableWithMessageHistory(
    chain,
    lambda session_id: demo_ephemeral_chat_history,
    input_messages_key="input",
    history_messages_key="chat_history",
)
```


이제 이전 상호작용을 요약으로 증류하는 함수를 만들어 보겠습니다. 이것을 체인의 앞부분에 추가할 수도 있습니다:

```python
def summarize_messages(chain_input):
    stored_messages = demo_ephemeral_chat_history.messages
    if len(stored_messages) == 0:
        return False
    summarization_prompt = ChatPromptTemplate.from_messages(
        [
            ("placeholder", "{chat_history}"),
            (
                "user",
                "Distill the above chat messages into a single summary message. Include as many specific details as you can.",
            ),
        ]
    )
    summarization_chain = summarization_prompt | chat

    summary_message = summarization_chain.invoke({"chat_history": stored_messages})

    demo_ephemeral_chat_history.clear()

    demo_ephemeral_chat_history.add_message(summary_message)

    return True


chain_with_summarization = (
    RunnablePassthrough.assign(messages_summarized=summarize_messages)
    | chain_with_message_history
)
```


우리가 준 이름을 기억하는지 확인해 보겠습니다:

```python
chain_with_summarization.invoke(
    {"input": "What did I say my name was?"},
    {"configurable": {"session_id": "unused"}},
)
```


```output
AIMessage(content='You introduced yourself as Nemo. How can I assist you today, Nemo?')
```


```python
demo_ephemeral_chat_history.messages
```


```output
[AIMessage(content='The conversation is between Nemo and an AI. Nemo introduces himself and the AI responds with a greeting. Nemo then asks the AI how it is doing, and the AI responds that it is fine.'),
 HumanMessage(content='What did I say my name was?'),
 AIMessage(content='You introduced yourself as Nemo. How can I assist you today, Nemo?')]
```


체인을 다시 호출하면 초기 요약과 새로운 메시지로부터 생성된 또 다른 요약이 생성된다는 점에 유의하세요. 특정 수의 메시지를 챗 기록에 유지하면서 다른 메시지를 요약하는 하이브리드 접근 방식을 설계할 수도 있습니다.