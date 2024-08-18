---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/callbacks_runtime.ipynb
description: 콜백을 실행 시점에 전달하는 방법에 대한 가이드로, 핸들러를 효율적으로 사용하여 중첩 객체에서 콜백을 관리하는 방법을 설명합니다.
---

# 런타임에서 콜백 전달하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 친숙함을 가정합니다:

- [콜백](/docs/concepts/#callbacks)
- [커스텀 콜백 핸들러](/docs/how_to/custom_callbacks)

:::

많은 경우, 객체를 실행할 때 대신 핸들러를 전달하는 것이 유리합니다. 실행할 때 `callbacks` 키워드 인수를 사용하여 [`CallbackHandlers`](https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html#langchain-core-callbacks-base-basecallbackhandler)를 통과시키면, 해당 콜백은 실행에 관련된 모든 중첩 객체에 의해 발행됩니다. 예를 들어, 핸들러가 에이전트에 전달되면, 이는 에이전트와 에이전트 실행에 관련된 모든 객체, 즉 도구와 LLM과 관련된 모든 콜백에 사용됩니다.

이렇게 하면 각 개별 중첩 객체에 핸들러를 수동으로 연결할 필요가 없습니다. 다음은 예시입니다:

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to pass callbacks in at runtime"}, {"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "How to pass callbacks in at runtime"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to pass callbacks in at runtime"}, {"imported": "LLMResult", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.llm_result.LLMResult.html", "title": "How to pass callbacks in at runtime"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to pass callbacks in at runtime"}]-->
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

chain.invoke({"number": "2"}, config={"callbacks": callbacks})
```

```output
Chain RunnableSequence started
Chain ChatPromptTemplate started
Chain ended, outputs: messages=[HumanMessage(content='What is 1 + 2?')]
Chat model started
Chat model ended, response: generations=[[ChatGeneration(text='1 + 2 = 3', message=AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01D8Tt5FdtBk5gLTfBPm2tac', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-bb0dddd8-85f3-4e6b-8553-eaa79f859ef8-0'))]] llm_output={'id': 'msg_01D8Tt5FdtBk5gLTfBPm2tac', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}} run=None
Chain ended, outputs: content='1 + 2 = 3' response_metadata={'id': 'msg_01D8Tt5FdtBk5gLTfBPm2tac', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}} id='run-bb0dddd8-85f3-4e6b-8553-eaa79f859ef8-0'
```


```output
AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01D8Tt5FdtBk5gLTfBPm2tac', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-bb0dddd8-85f3-4e6b-8553-eaa79f859ef8-0')
```


모듈과 관련된 기존 콜백이 이미 있는 경우, 이는 런타임에 전달된 콜백과 함께 실행됩니다.

## 다음 단계

이제 런타임에서 콜백을 전달하는 방법을 배웠습니다.

다음으로, 이 섹션의 다른 방법 가이드를 확인해 보세요. 예를 들어, [모듈 생성자에 콜백 전달하기](/docs/how_to/custom_callbacks)와 같은 내용을 참고하세요.