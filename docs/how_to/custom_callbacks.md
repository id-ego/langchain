---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/custom_callbacks.ipynb
description: 사용자 정의 콜백 핸들러를 만드는 방법에 대한 가이드로, 이벤트 처리 및 핸들러 구현에 대한 설명을 포함합니다.
---

# 사용자 정의 콜백 핸들러 만들기

:::info 전제 조건

이 가이드는 다음 개념에 대한 친숙함을 가정합니다:

- [콜백](/docs/concepts/#callbacks)

:::

LangChain에는 몇 가지 내장 콜백 핸들러가 있지만, 종종 사용자 정의 로직으로 자신의 핸들러를 만들고 싶을 것입니다.

사용자 정의 콜백 핸들러를 만들기 위해서는 우리가 처리하고자 하는 [이벤트](https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html#langchain-core-callbacks-base-basecallbackhandler)와 이벤트가 발생했을 때 콜백 핸들러가 수행할 작업을 결정해야 합니다. 그런 다음 콜백 핸들러를 객체에 연결하기만 하면 됩니다. 예를 들어 [생성자를 통해](/docs/how_to/callbacks_constructor) 또는 [런타임에](/docs/how_to/callbacks_runtime) 연결할 수 있습니다.

아래 예제에서는 사용자 정의 핸들러를 사용하여 스트리밍을 구현합니다.

우리의 사용자 정의 콜백 핸들러 `MyCustomHandler`에서는 `on_llm_new_token` 핸들러를 구현하여 방금 수신한 토큰을 출력합니다. 그런 다음 생성자 콜백으로 모델 객체에 사용자 정의 핸들러를 연결합니다.

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to create custom callback handlers"}, {"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "How to create custom callback handlers"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to create custom callback handlers"}]-->
from langchain_anthropic import ChatAnthropic
from langchain_core.callbacks import BaseCallbackHandler
from langchain_core.prompts import ChatPromptTemplate


class MyCustomHandler(BaseCallbackHandler):
    def on_llm_new_token(self, token: str, **kwargs) -> None:
        print(f"My custom handler, token: {token}")


prompt = ChatPromptTemplate.from_messages(["Tell me a joke about {animal}"])

# To enable streaming, we pass in `streaming=True` to the ChatModel constructor
# Additionally, we pass in our custom handler as a list to the callbacks parameter
model = ChatAnthropic(
    model="claude-3-sonnet-20240229", streaming=True, callbacks=[MyCustomHandler()]
)

chain = prompt | model

response = chain.invoke({"animal": "bears"})
```

```output
My custom handler, token: Here
My custom handler, token: 's
My custom handler, token:  a
My custom handler, token:  bear
My custom handler, token:  joke
My custom handler, token:  for
My custom handler, token:  you
My custom handler, token: :
My custom handler, token: 

Why
My custom handler, token:  di
My custom handler, token: d the
My custom handler, token:  bear
My custom handler, token:  dissol
My custom handler, token: ve
My custom handler, token:  in
My custom handler, token:  water
My custom handler, token: ?
My custom handler, token: 
Because
My custom handler, token:  it
My custom handler, token:  was
My custom handler, token:  a
My custom handler, token:  polar
My custom handler, token:  bear
My custom handler, token: !
```

처리할 수 있는 이벤트 목록은 [이 참조 페이지](https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html#langchain-core-callbacks-base-basecallbackhandler)에서 확인할 수 있습니다. `handle_chain_*` 이벤트는 대부분의 LCEL 실행 가능 항목에 대해 실행됩니다.

## 다음 단계

이제 사용자 정의 콜백 핸들러를 만드는 방법을 배웠습니다.

다음으로, [실행 가능 항목에 콜백을 연결하는 방법](/docs/how_to/callbacks_attach)과 같은 이 섹션의 다른 가이드도 확인해 보세요.