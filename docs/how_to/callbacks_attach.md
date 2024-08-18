---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/callbacks_attach.ipynb
description: 이 문서는 여러 실행에서 콜백을 재사용하기 위해 Runnable에 콜백을 연결하는 방법을 설명합니다.
---

# 실행 가능한 항목에 콜백을 연결하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 친숙함을 가정합니다:

- [콜백](/docs/concepts/#callbacks)
- [사용자 정의 콜백 핸들러](/docs/how_to/custom_callbacks)
- [실행 가능한 항목 연결](/docs/how_to/sequence)
- [실행 가능한 항목에 런타임 인수 연결](/docs/how_to/binding)

:::

실행 가능한 항목의 체인을 구성하고 여러 실행에서 콜백을 재사용하려는 경우, [`.with_config()`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.with_config) 메서드를 사용하여 콜백을 연결할 수 있습니다. 이렇게 하면 체인을 호출할 때마다 콜백을 전달할 필요가 없습니다.

:::important

`with_config()`는 **런타임** 구성으로 해석될 구성을 바인딩합니다. 따라서 이러한 콜백은 모든 자식 구성 요소로 전파됩니다.
:::

예제는 다음과 같습니다:

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to attach callbacks to a runnable"}, {"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "How to attach callbacks to a runnable"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to attach callbacks to a runnable"}, {"imported": "LLMResult", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.llm_result.LLMResult.html", "title": "How to attach callbacks to a runnable"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to attach callbacks to a runnable"}]-->
from typing import Any, Dict, List

from langchain_anthropic import ChatAnthropic
from langchain_core.callbacks import BaseCallbackHandler
from langchain_core.messages import BaseMessage
from langchain_core.outputs import LLMResult
from langchain_core.prompts import ChatPromptTemplate


class LoggingHandler(BaseCallbackHandler):
    def on_chat_model_start(
        self, serialized: Dict[str, Any], messages: List[List[BaseMessage]], **kwargs
    ) -> None:
        print("Chat model started")

    def on_llm_end(self, response: LLMResult, **kwargs) -> None:
        print(f"Chat model ended, response: {response}")

    def on_chain_start(
        self, serialized: Dict[str, Any], inputs: Dict[str, Any], **kwargs
    ) -> None:
        print(f"Chain {serialized.get('name')} started")

    def on_chain_end(self, outputs: Dict[str, Any], **kwargs) -> None:
        print(f"Chain ended, outputs: {outputs}")


callbacks = [LoggingHandler()]
llm = ChatAnthropic(model="claude-3-sonnet-20240229")
prompt = ChatPromptTemplate.from_template("What is 1 + {number}?")

chain = prompt | llm

chain_with_callbacks = chain.with_config(callbacks=callbacks)

chain_with_callbacks.invoke({"number": "2"})
```

```output
Chain RunnableSequence started
Chain ChatPromptTemplate started
Chain ended, outputs: messages=[HumanMessage(content='What is 1 + 2?')]
Chat model started
Chat model ended, response: generations=[[ChatGeneration(text='1 + 2 = 3', message=AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01NTYMsH9YxkoWsiPYs4Lemn', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-d6bcfd72-9c94-466d-bac0-f39e456ad6e3-0'))]] llm_output={'id': 'msg_01NTYMsH9YxkoWsiPYs4Lemn', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}} run=None
Chain ended, outputs: content='1 + 2 = 3' response_metadata={'id': 'msg_01NTYMsH9YxkoWsiPYs4Lemn', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}} id='run-d6bcfd72-9c94-466d-bac0-f39e456ad6e3-0'
```


```output
AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01NTYMsH9YxkoWsiPYs4Lemn', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-d6bcfd72-9c94-466d-bac0-f39e456ad6e3-0')
```


바인딩된 콜백은 모든 중첩 모듈 실행에 대해 실행됩니다.

## 다음 단계

이제 체인에 콜백을 연결하는 방법을 배웠습니다.

다음으로, [런타임에 콜백 전달하기](/docs/how_to/callbacks_runtime)와 같은 이 섹션의 다른 사용 방법 가이드를 확인하세요.