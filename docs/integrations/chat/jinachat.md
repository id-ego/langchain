---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/jinachat.ipynb
description: JinaChat 모델을 시작하는 방법을 다루며, 메시지 프롬프트 템플릿과 채팅 프롬프트 템플릿 사용법을 설명합니다.
---

# JinaChat

이 노트북은 JinaChat 채팅 모델을 시작하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "JinaChat", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.jinachat.JinaChat.html", "title": "JinaChat"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "JinaChat"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "JinaChat"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "JinaChat"}, {"imported": "HumanMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.HumanMessagePromptTemplate.html", "title": "JinaChat"}, {"imported": "SystemMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.SystemMessagePromptTemplate.html", "title": "JinaChat"}]-->
from langchain_community.chat_models import JinaChat
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_core.prompts.chat import (
    ChatPromptTemplate,
    HumanMessagePromptTemplate,
    SystemMessagePromptTemplate,
)
```


```python
chat = JinaChat(temperature=0)
```


```python
messages = [
    SystemMessage(
        content="You are a helpful assistant that translates English to French."
    ),
    HumanMessage(
        content="Translate this sentence from English to French. I love programming."
    ),
]
chat(messages)
```


```output
AIMessage(content="J'aime programmer.", additional_kwargs={}, example=False)
```


`MessagePromptTemplate`를 사용하여 템플릿을 활용할 수 있습니다. 하나 이상의 `MessagePromptTemplates`에서 `ChatPromptTemplate`을 구축할 수 있습니다. `ChatPromptTemplate`의 `format_prompt`를 사용할 수 있으며, 이는 `PromptValue`를 반환합니다. 이 값을 문자열 또는 메시지 객체로 변환할 수 있으며, 이는 포맷된 값을 llm 또는 채팅 모델의 입력으로 사용하고자 할 때에 따라 다릅니다.

편의를 위해 템플릿에서 노출된 `from_template` 메서드가 있습니다. 이 템플릿을 사용한다면, 다음과 같이 보일 것입니다:

```python
template = (
    "You are a helpful assistant that translates {input_language} to {output_language}."
)
system_message_prompt = SystemMessagePromptTemplate.from_template(template)
human_template = "{text}"
human_message_prompt = HumanMessagePromptTemplate.from_template(human_template)
```


```python
chat_prompt = ChatPromptTemplate.from_messages(
    [system_message_prompt, human_message_prompt]
)

# get a chat completion from the formatted messages
chat(
    chat_prompt.format_prompt(
        input_language="English", output_language="French", text="I love programming."
    ).to_messages()
)
```


```output
AIMessage(content="J'aime programmer.", additional_kwargs={}, example=False)
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)