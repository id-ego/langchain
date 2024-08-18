---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/callbacks_constructor.ipynb
description: 콜백을 생성자에 전달하는 방법에 대한 가이드입니다. 이 문서는 콜백의 범위와 사용 예제를 설명합니다.
---

# 콜백 전파하는 방법 생성자

:::info 전제 조건

이 가이드는 다음 개념에 대한 친숙함을 가정합니다:

- [콜백](/docs/concepts/#callbacks)
- [사용자 정의 콜백 핸들러](/docs/how_to/custom_callbacks)

:::

대부분의 LangChain 모듈은 생성자(즉, 초기화자)에 `callbacks`를 직접 전달할 수 있습니다. 이 경우, 콜백은 해당 인스턴스(및 모든 중첩 실행)에 대해서만 호출됩니다.

:::warning
생성자 콜백은 정의된 객체에만 범위가 제한됩니다. 객체의 자식에게는 **상속되지** 않습니다. 이는 혼란스러운 동작을 초래할 수 있으며, 일반적으로 콜백을 런타임 인수로 전달하는 것이 더 좋습니다.
:::

예시입니다:

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to propagate callbacks  constructor"}, {"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "How to propagate callbacks  constructor"}, {"imported": "BaseMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.base.BaseMessage.html", "title": "How to propagate callbacks  constructor"}, {"imported": "LLMResult", "source": "langchain_core.outputs", "docs": "https://api.python.langchain.com/en/latest/outputs/langchain_core.outputs.llm_result.LLMResult.html", "title": "How to propagate callbacks  constructor"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to propagate callbacks  constructor"}]-->
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
llm = ChatAnthropic(model="claude-3-sonnet-20240229", callbacks=callbacks)
prompt = ChatPromptTemplate.from_template("What is 1 + {number}?")

chain = prompt | llm

chain.invoke({"number": "2"})
```

```output
Chat model started
Chat model ended, response: generations=[[ChatGeneration(text='1 + 2 = 3', message=AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01CdKsRmeS9WRb8BWnHDEHm7', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-2d7fdf2a-7405-4e17-97c0-67e6b2a65305-0'))]] llm_output={'id': 'msg_01CdKsRmeS9WRb8BWnHDEHm7', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}} run=None
```


```output
AIMessage(content='1 + 2 = 3', response_metadata={'id': 'msg_01CdKsRmeS9WRb8BWnHDEHm7', 'model': 'claude-3-sonnet-20240229', 'stop_reason': 'end_turn', 'stop_sequence': None, 'usage': {'input_tokens': 16, 'output_tokens': 13}}, id='run-2d7fdf2a-7405-4e17-97c0-67e6b2a65305-0')
```


채팅 모델 실행에서만 이벤트가 표시되는 것을 볼 수 있습니다 - 프롬프트나 더 넓은 체인에서의 체인 이벤트는 없습니다.

## 다음 단계

이제 생성자에 콜백을 전달하는 방법을 배웠습니다.

다음으로, [런타임에 콜백 전달하기](/docs/how_to/callbacks_runtime)와 같은 이 섹션의 다른 사용 방법 가이드를 확인하세요.