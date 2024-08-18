---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/anthropic_functions.ipynb
description: 이 문서는 Anthropic의 도구 호출 및 구조화된 출력 기능을 제공하는 실험적 래퍼 사용법을 설명합니다.
sidebar_class_name: hidden
---

# [사용 중단] 실험적 앤트로픽 도구 래퍼

::: {.callout-warning}

앤트로픽 API는 공식적으로 도구 호출을 지원하므로 이 우회 방법은 더 이상 필요하지 않습니다. `langchain-anthropic>=0.1.5`와 함께 [ChatAnthropic](/docs/integrations/chat/anthropic)를 사용하세요.

:::

이 노트북은 도구 호출 및 구조화된 출력 기능을 제공하는 앤트로픽 주위의 실험적 래퍼를 사용하는 방법을 보여줍니다. 앤트로픽의 가이드를 따릅니다 [여기](https://docs.anthropic.com/claude/docs/functions-external-tools)

래퍼는 `langchain-anthropic` 패키지에서 사용할 수 있으며, llm의 XML 출력을 파싱하기 위해 선택적 종속성 `defusedxml`도 필요합니다.

참고: 이는 베타 기능으로, 앤트로픽의 공식 도구 호출 구현으로 대체될 예정이지만, 그동안 테스트 및 실험에 유용합니다.

```python
<!--IMPORTS:[{"imported": "ChatAnthropicTools", "source": "langchain_anthropic.experimental", "docs": "https://api.python.langchain.com/en/latest/experimental/langchain_anthropic.experimental.ChatAnthropicTools.html", "title": "[Deprecated] Experimental Anthropic Tools Wrapper"}]-->
%pip install -qU langchain-anthropic defusedxml
from langchain_anthropic.experimental import ChatAnthropicTools
```


## 도구 바인딩

`ChatAnthropicTools`는 Pydantic 모델 또는 BaseTools를 llm에 전달할 수 있는 `bind_tools` 메서드를 노출합니다.

```python
from langchain_core.pydantic_v1 import BaseModel


class Person(BaseModel):
    name: str
    age: int


model = ChatAnthropicTools(model="claude-3-opus-20240229").bind_tools(tools=[Person])
model.invoke("I am a 27 year old named Erick")
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'function': {'name': 'Person', 'arguments': '{"name": "Erick", "age": "27"}'}, 'type': 'function'}]})
```


## 구조화된 출력

`ChatAnthropicTools`는 값 추출을 위한 [`with_structured_output` 사양](/docs/how_to/structured_output)을 구현합니다. 참고: 이는 도구 호출을 명시적으로 제공하는 모델만큼 안정적이지 않을 수 있습니다.

```python
chain = ChatAnthropicTools(model="claude-3-opus-20240229").with_structured_output(
    Person
)
chain.invoke("I am a 27 year old named Erick")
```


```output
Person(name='Erick', age=27)
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)