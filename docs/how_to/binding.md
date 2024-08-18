---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/binding.ipynb
description: Runnable을 사용하여 고정 인수를 설정하는 방법을 배우고, RunnableSequence 내에서 이를 활용하는 방법을
  안내합니다.
keywords:
- RunnableBinding
- LCEL
sidebar_position: 2
---

# 기본 호출 인수를 Runnable에 추가하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language)
- [Runnable 연결하기](/docs/how_to/sequence/)
- [도구 호출하기](/docs/how_to/tool_calling)

:::

때때로 우리는 [`Runnable`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html)를 [RunnableSequence](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableSequence.html) 내에서 이전 Runnable의 출력이나 사용자 입력의 일부가 아닌 상수 인수로 호출하고 싶습니다. 이러한 인수를 미리 설정하기 위해 [`Runnable.bind()`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.bind) 메서드를 사용할 수 있습니다.

## 중지 시퀀스 바인딩

간단한 프롬프트 + 모델 체인이 있다고 가정해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to add default invocation args to a Runnable"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add default invocation args to a Runnable"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to add default invocation args to a Runnable"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add default invocation args to a Runnable"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "Write out the following equation using algebraic symbols then solve it. Use the format\n\nEQUATION:...\nSOLUTION:...\n\n",
        ),
        ("human", "{equation_statement}"),
    ]
)

model = ChatOpenAI(temperature=0)

runnable = (
    {"equation_statement": RunnablePassthrough()} | prompt | model | StrOutputParser()
)

print(runnable.invoke("x raised to the third plus seven equals 12"))
```

```output
EQUATION: x^3 + 7 = 12

SOLUTION: 
Subtract 7 from both sides:
x^3 = 5

Take the cube root of both sides:
x = ∛5
```

특정 `stop` 단어로 모델을 호출하여 특정 유형의 프롬프트 기법에서 유용하게 출력 길이를 줄이고 싶습니다. 일부 인수를 생성자에 전달할 수 있지만, 다른 런타임 인수는 다음과 같이 `.bind()` 메서드를 사용합니다:

```python
runnable = (
    {"equation_statement": RunnablePassthrough()}
    | prompt
    | model.bind(stop="SOLUTION")
    | StrOutputParser()
)

print(runnable.invoke("x raised to the third plus seven equals 12"))
```

```output
EQUATION: x^3 + 7 = 12
```

Runnable에 바인딩할 수 있는 것은 호출할 때 전달할 수 있는 추가 매개변수에 따라 달라집니다.

## OpenAI 도구 연결하기

또 다른 일반적인 사용 사례는 도구 호출입니다. 도구 호출 모델에는 일반적으로 [`.bind_tools()`](/docs/how_to/tool_calling) 메서드를 사용해야 하지만, 더 낮은 수준의 제어를 원할 경우 공급자 특정 인수를 직접 바인딩할 수도 있습니다:

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_current_weather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA",
                    },
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
                },
                "required": ["location"],
            },
        },
    }
]
```


```python
model = ChatOpenAI(model="gpt-3.5-turbo-1106").bind(tools=tools)
model.invoke("What's the weather in SF, NYC and LA?")
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_z0OU2CytqENVrRTI6T8DkI3u', 'function': {'arguments': '{"location": "San Francisco, CA", "unit": "celsius"}', 'name': 'get_current_weather'}, 'type': 'function'}, {'id': 'call_ft96IJBh0cMKkQWrZjNg4bsw', 'function': {'arguments': '{"location": "New York, NY", "unit": "celsius"}', 'name': 'get_current_weather'}, 'type': 'function'}, {'id': 'call_tfbtGgCLmuBuWgZLvpPwvUMH', 'function': {'arguments': '{"location": "Los Angeles, CA", "unit": "celsius"}', 'name': 'get_current_weather'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 84, 'prompt_tokens': 85, 'total_tokens': 169}, 'model_name': 'gpt-3.5-turbo-1106', 'system_fingerprint': 'fp_77a673219d', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-d57ad5fa-b52a-4822-bc3e-74f838697e18-0', tool_calls=[{'name': 'get_current_weather', 'args': {'location': 'San Francisco, CA', 'unit': 'celsius'}, 'id': 'call_z0OU2CytqENVrRTI6T8DkI3u'}, {'name': 'get_current_weather', 'args': {'location': 'New York, NY', 'unit': 'celsius'}, 'id': 'call_ft96IJBh0cMKkQWrZjNg4bsw'}, {'name': 'get_current_weather', 'args': {'location': 'Los Angeles, CA', 'unit': 'celsius'}, 'id': 'call_tfbtGgCLmuBuWgZLvpPwvUMH'}])
```


## 다음 단계

이제 Runnable에 런타임 인수를 바인딩하는 방법을 알게 되었습니다.

더 알아보려면 이 섹션의 다른 Runnable에 대한 가이드를 참조하세요. 여기에는 다음이 포함됩니다:

- [구성 가능한 필드 및 대안 사용하기](/docs/how_to/configure) 체인의 단계 매개변수를 변경하거나 런타임에 전체 단계를 교체하는 방법.