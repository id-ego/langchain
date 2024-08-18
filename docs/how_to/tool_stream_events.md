---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/tool_stream_events.ipynb
description: 이 가이드는 LangChain 도구에서 이벤트를 스트리밍하고 내부 이벤트에 접근하는 방법을 설명합니다.
---

# 도구에서 이벤트 스트리밍하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [LangChain 도구](/docs/concepts/#tools)
- [사용자 정의 도구](/docs/how_to/custom_tools)
- [스트림 이벤트 사용하기](/docs/how_to/streaming/#using-stream-events)
- [사용자 정의 도구 내에서 RunnableConfig 접근하기](/docs/how_to/tool_configure/)

:::

채팅 모델, 검색기 또는 기타 실행 가능한 도구를 호출하는 도구가 있는 경우, 해당 실행 가능한 도구의 내부 이벤트에 접근하거나 추가 속성으로 구성하고 싶을 수 있습니다. 이 가이드는 `astream_events()` 메서드를 사용하여 매개변수를 올바르게 수동으로 전달하는 방법을 보여줍니다.

:::caution 호환성

LangChain은 `python<=3.10`에서 `async` 코드를 실행하는 경우, `astream_events()`에 필요한 콜백을 포함한 구성을 자식 실행 가능한 도구로 자동 전파할 수 없습니다. 이는 사용자 정의 실행 가능한 도구나 도구에서 이벤트가 발생하지 않는 일반적인 이유입니다.

`python<=3.10`을 실행하는 경우, 비동기 환경에서 자식 실행 가능한 도구로 `RunnableConfig` 객체를 수동으로 전파해야 합니다. 구성 전파 방법에 대한 예시는 아래의 `bar` RunnableLambda 구현을 참조하세요.

`python>=3.11`을 실행하는 경우, `RunnableConfig`는 비동기 환경에서 자식 실행 가능한 도구로 자동 전파됩니다. 그러나 코드가 이전 Python 버전에서 실행될 수 있는 경우 `RunnableConfig`를 수동으로 전파하는 것이 여전히 좋은 방법입니다.

이 가이드는 또한 `langchain-core>=0.2.16`이 필요합니다.
:::

사용자 정의 도구가 입력을 압축하여 채팅 모델에 10단어만 반환하도록 요청한 다음 출력을 반전시키는 체인을 호출한다고 가정해 보겠습니다. 먼저, 이를 단순한 방식으로 정의합니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="model" />


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to stream events from a tool"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to stream events from a tool"}, {"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "How to stream events from a tool"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.tools import tool


@tool
async def special_summarization_tool(long_text: str) -> str:
    """A tool that summarizes input text using advanced techniques."""
    prompt = ChatPromptTemplate.from_template(
        "You are an expert writer. Summarize the following text in 10 words or less:\n\n{long_text}"
    )

    def reverse(x: str):
        return x[::-1]

    chain = prompt | model | StrOutputParser() | reverse
    summary = await chain.ainvoke({"long_text": long_text})
    return summary
```


도구를 직접 호출하면 잘 작동합니다:

```python
LONG_TEXT = """
NARRATOR:
(Black screen with text; The sound of buzzing bees can be heard)
According to all known laws of aviation, there is no way a bee should be able to fly. Its wings are too small to get its fat little body off the ground. The bee, of course, flies anyway because bees don't care what humans think is impossible.
BARRY BENSON:
(Barry is picking out a shirt)
Yellow, black. Yellow, black. Yellow, black. Yellow, black. Ooh, black and yellow! Let's shake it up a little.
JANET BENSON:
Barry! Breakfast is ready!
BARRY:
Coming! Hang on a second.
"""

await special_summarization_tool.ainvoke({"long_text": LONG_TEXT})
```


```output
'.yad noitaudarg rof tiftuo sesoohc yrraB ;scisyhp seifed eeB'
```


하지만 전체 도구 대신 채팅 모델의 원시 출력을 접근하고 싶다면 [`astream_events()`](/docs/how_to/streaming/#using-stream-events) 메서드를 사용하고 `on_chat_model_end` 이벤트를 찾아보려고 할 수 있습니다. 다음과 같은 일이 발생합니다:

```python
stream = special_summarization_tool.astream_events(
    {"long_text": LONG_TEXT}, version="v2"
)

async for event in stream:
    if event["event"] == "on_chat_model_end":
        # Never triggers in python<=3.10!
        print(event)
```


이 가이드를 `python>=3.11`에서 실행하지 않는 한, 자식 실행에서 채팅 모델 이벤트가 발생하지 않는 것을 알 수 있습니다!

이는 위의 예제가 도구의 구성 객체를 내부 체인에 전달하지 않기 때문입니다. 이를 수정하려면 도구를 `RunnableConfig`로 타입이 지정된 특별한 매개변수를 받도록 재정의해야 합니다(자세한 내용은 [이 가이드](/docs/how_to/tool_configure)를 참조하세요). 또한 실행할 때 해당 매개변수를 내부 체인으로 전달해야 합니다:

```python
<!--IMPORTS:[{"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to stream events from a tool"}]-->
from langchain_core.runnables import RunnableConfig


@tool
async def special_summarization_tool_with_config(
    long_text: str, config: RunnableConfig
) -> str:
    """A tool that summarizes input text using advanced techniques."""
    prompt = ChatPromptTemplate.from_template(
        "You are an expert writer. Summarize the following text in 10 words or less:\n\n{long_text}"
    )

    def reverse(x: str):
        return x[::-1]

    chain = prompt | model | StrOutputParser() | reverse
    # Pass the "config" object as an argument to any executed runnables
    summary = await chain.ainvoke({"long_text": long_text}, config=config)
    return summary
```


이제 새로운 도구로 이전과 같은 `astream_events()` 호출을 시도해 보세요:

```python
stream = special_summarization_tool_with_config.astream_events(
    {"long_text": LONG_TEXT}, version="v2"
)

async for event in stream:
    if event["event"] == "on_chat_model_end":
        print(event)
```

```output
{'event': 'on_chat_model_end', 'data': {'output': AIMessage(content='Bee defies physics; Barry chooses outfit for graduation day.', response_metadata={'stop_reason': 'end_turn', 'stop_sequence': None}, id='run-d23abc80-0dce-4f74-9d7b-fb98ca4f2a9e', usage_metadata={'input_tokens': 182, 'output_tokens': 16, 'total_tokens': 198}), 'input': {'messages': [[HumanMessage(content="You are an expert writer. Summarize the following text in 10 words or less:\n\n\nNARRATOR:\n(Black screen with text; The sound of buzzing bees can be heard)\nAccording to all known laws of aviation, there is no way a bee should be able to fly. Its wings are too small to get its fat little body off the ground. The bee, of course, flies anyway because bees don't care what humans think is impossible.\nBARRY BENSON:\n(Barry is picking out a shirt)\nYellow, black. Yellow, black. Yellow, black. Yellow, black. Ooh, black and yellow! Let's shake it up a little.\nJANET BENSON:\nBarry! Breakfast is ready!\nBARRY:\nComing! Hang on a second.\n")]]}}, 'run_id': 'd23abc80-0dce-4f74-9d7b-fb98ca4f2a9e', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['f25c41fe-8972-4893-bc40-cecf3922c1fa']}
```

멋져요! 이번에는 이벤트가 발생했습니다.

스트리밍의 경우, `astream_events()`는 가능하다면 스트리밍이 활성화된 체인에서 내부 실행 가능한 도구를 자동으로 호출하므로, 채팅 모델에서 생성되는 토큰의 스트림을 원한다면 다른 변경 없이 `on_chat_model_stream` 이벤트를 찾도록 필터링할 수 있습니다:

```python
stream = special_summarization_tool_with_config.astream_events(
    {"long_text": LONG_TEXT}, version="v2"
)

async for event in stream:
    if event["event"] == "on_chat_model_stream":
        print(event)
```

```output
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42', usage_metadata={'input_tokens': 182, 'output_tokens': 0, 'total_tokens': 182})}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='Bee', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content=' def', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='ies physics', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content=';', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content=' Barry', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content=' cho', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='oses outfit', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content=' for', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content=' graduation', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content=' day', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='.', id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42')}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
{'event': 'on_chat_model_stream', 'data': {'chunk': AIMessageChunk(content='', response_metadata={'stop_reason': 'end_turn', 'stop_sequence': None}, id='run-f24ab147-0b82-4e63-810a-b12bd8d1fb42', usage_metadata={'input_tokens': 0, 'output_tokens': 16, 'total_tokens': 16})}, 'run_id': 'f24ab147-0b82-4e63-810a-b12bd8d1fb42', 'name': 'ChatAnthropic', 'tags': ['seq:step:2'], 'metadata': {'ls_provider': 'anthropic', 'ls_model_name': 'claude-3-5-sonnet-20240620', 'ls_model_type': 'chat', 'ls_temperature': 0.0, 'ls_max_tokens': 1024}, 'parent_ids': ['385f3612-417c-4a70-aae0-cce3a5ba6fb6']}
```

## 다음 단계

이제 도구 내에서 이벤트를 스트리밍하는 방법을 보았습니다. 다음으로 도구 사용에 대한 더 많은 정보를 얻으려면 다음 가이드를 확인하세요:

- [런타임 값을 도구에 전달하기](/docs/how_to/tool_runtime)
- [모델에 도구 결과 전달하기](/docs/how_to/tool_results_pass_to_model)
- [사용자 정의 콜백 이벤트 전송하기](/docs/how_to/callbacks_custom_events)

또한 도구 호출의 좀 더 구체적인 사용 사례를 확인할 수 있습니다:

- [도구를 사용하는 체인 및 에이전트 구축하기](/docs/how_to#tools)
- 모델에서 [구조화된 출력](/docs/how_to/structured_output/) 얻기