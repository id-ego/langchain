---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/functions.ipynb
description: 사용자 정의 함수를 Runnables로 실행하는 방법을 안내하며, Lambda 함수를 활용한 입력 처리에 대한 정보를 제공합니다.
keywords:
- RunnableLambda
- LCEL
sidebar_position: 3
---

# 사용자 정의 함수 실행 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [LangChain 표현 언어 (LCEL)](/docs/concepts/#langchain-expression-language)
- [Runnable 연결하기](/docs/how_to/sequence/)

:::

임의의 함수를 [Runnables](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable)로 사용할 수 있습니다. 이는 형식을 지정하거나 다른 LangChain 구성 요소에서 제공되지 않는 기능이 필요할 때 유용하며, Runnables로 사용되는 사용자 정의 함수는 [`RunnableLambdas`](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html)라고 합니다.

이 함수에 대한 모든 입력은 단일 인수여야 합니다. 여러 인수를 허용하는 함수가 있는 경우, 단일 dict 입력을 허용하고 이를 여러 인수로 풀어내는 래퍼를 작성해야 합니다.

이 가이드는 다음 내용을 다룹니다:

- `RunnableLambda` 생성자와 편리한 `@chain` 데코레이터를 사용하여 사용자 정의 함수에서 명시적으로 runnable을 생성하는 방법
- 체인에서 사용될 때 사용자 정의 함수를 runnable로 강제 변환하는 방법
- 사용자 정의 함수에서 실행 메타데이터를 수용하고 사용하는 방법
- 사용자 정의 함수가 생성기를 반환하도록 하여 스트리밍하는 방법

## 생성자 사용하기

아래에서 우리는 `RunnableLambda` 생성자를 사용하여 우리의 사용자 정의 논리를 명시적으로 래핑합니다:

```python
%pip install -qU langchain langchain_openai

import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to run custom functions"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "How to run custom functions"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to run custom functions"}]-->
from operator import itemgetter

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableLambda
from langchain_openai import ChatOpenAI


def length_function(text):
    return len(text)


def _multiple_length_function(text1, text2):
    return len(text1) * len(text2)


def multiple_length_function(_dict):
    return _multiple_length_function(_dict["text1"], _dict["text2"])


model = ChatOpenAI()

prompt = ChatPromptTemplate.from_template("what is {a} + {b}")

chain1 = prompt | model

chain = (
    {
        "a": itemgetter("foo") | RunnableLambda(length_function),
        "b": {"text1": itemgetter("foo"), "text2": itemgetter("bar")}
        | RunnableLambda(multiple_length_function),
    }
    | prompt
    | model
)

chain.invoke({"foo": "bar", "bar": "gah"})
```


```output
AIMessage(content='3 + 9 equals 12.', response_metadata={'token_usage': {'completion_tokens': 8, 'prompt_tokens': 14, 'total_tokens': 22}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-73728de3-e483-49e3-ad54-51bd9570e71a-0')
```


## 편리한 `@chain` 데코레이터

임의의 함수를 체인으로 변환하려면 `@chain` 데코레이터를 추가할 수 있습니다. 이는 위에서 보여준 것처럼 함수를 `RunnableLambda` 생성자로 래핑하는 것과 기능적으로 동일합니다. 예를 들어:

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to run custom functions"}, {"imported": "chain", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.chain.html", "title": "How to run custom functions"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import chain

prompt1 = ChatPromptTemplate.from_template("Tell me a joke about {topic}")
prompt2 = ChatPromptTemplate.from_template("What is the subject of this joke: {joke}")


@chain
def custom_chain(text):
    prompt_val1 = prompt1.invoke({"topic": text})
    output1 = ChatOpenAI().invoke(prompt_val1)
    parsed_output1 = StrOutputParser().invoke(output1)
    chain2 = prompt2 | ChatOpenAI() | StrOutputParser()
    return chain2.invoke({"joke": parsed_output1})


custom_chain.invoke("bears")
```


```output
'The subject of the joke is the bear and his girlfriend.'
```


위에서 `@chain` 데코레이터는 `custom_chain`을 runnable로 변환하는 데 사용되며, 우리는 `.invoke()` 메서드로 이를 호출합니다.

[LangSmith](https://docs.smith.langchain.com/)와 함께 추적을 사용하는 경우, 그 안에 `custom_chain` 추적이 표시되며, OpenAI에 대한 호출이 그 아래에 중첩되어 있어야 합니다.

## 체인에서의 자동 강제 변환

파이프 연산자(`|`)로 체인에서 사용자 정의 함수를 사용할 때, `RunnableLambda` 또는 `@chain` 생성자를 생략하고 강제 변환에 의존할 수 있습니다. 다음은 모델의 출력을 받아서 그 첫 다섯 글자를 반환하는 함수의 간단한 예입니다:

```python
prompt = ChatPromptTemplate.from_template("tell me a story about {topic}")

model = ChatOpenAI()

chain_with_coerced_function = prompt | model | (lambda x: x.content[:5])

chain_with_coerced_function.invoke({"topic": "bears"})
```


```output
'Once '
```


파이프 연산자의 왼쪽에 있는 `model`이 이미 Runnable이기 때문에 우리는 사용자 정의 함수 `(lambda x: x.content[:5])`를 `RunnableLambda` 생성자로 래핑할 필요가 없었습니다. 사용자 정의 함수는 **강제 변환**되어 runnable이 됩니다. 자세한 내용은 [이 섹션](/docs/how_to/sequence/#coercion)을 참조하세요.

## 실행 메타데이터 전달하기

Runnable lambdas는 선택적으로 [RunnableConfig](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html#langchain_core.runnables.config.RunnableConfig) 매개변수를 수용할 수 있으며, 이를 사용하여 콜백, 태그 및 기타 구성 정보를 중첩된 실행에 전달할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "How to run custom functions"}]-->
import json

from langchain_core.runnables import RunnableConfig


def parse_or_fix(text: str, config: RunnableConfig):
    fixing_chain = (
        ChatPromptTemplate.from_template(
            "Fix the following text:\n\n```text\n{input}\n```\nError: {error}"
            " Don't narrate, just respond with the fixed data."
        )
        | model
        | StrOutputParser()
    )
    for _ in range(3):
        try:
            return json.loads(text)
        except Exception as e:
            text = fixing_chain.invoke({"input": text, "error": e}, config)
    return "Failed to parse"


from langchain_community.callbacks import get_openai_callback

with get_openai_callback() as cb:
    output = RunnableLambda(parse_or_fix).invoke(
        "{foo: bar}", {"tags": ["my-tag"], "callbacks": [cb]}
    )
    print(output)
    print(cb)
```

```output
{'foo': 'bar'}
Tokens Used: 62
	Prompt Tokens: 56
	Completion Tokens: 6
Successful Requests: 1
Total Cost (USD): $9.6e-05
```


```python
<!--IMPORTS:[{"imported": "get_openai_callback", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.manager.get_openai_callback.html", "title": "How to run custom functions"}]-->
from langchain_community.callbacks import get_openai_callback

with get_openai_callback() as cb:
    output = RunnableLambda(parse_or_fix).invoke(
        "{foo: bar}", {"tags": ["my-tag"], "callbacks": [cb]}
    )
    print(output)
    print(cb)
```

```output
{'foo': 'bar'}
Tokens Used: 62
	Prompt Tokens: 56
	Completion Tokens: 6
Successful Requests: 1
Total Cost (USD): $9.6e-05
```


## 스트리밍

:::note
[RunnableLambda](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html)는 스트리밍을 지원할 필요가 없는 코드에 가장 적합합니다. 스트리밍을 지원해야 하는 경우(즉, 입력의 청크를 처리하고 출력의 청크를 생성할 수 있어야 함) 아래의 예와 같이 [RunnableGenerator](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableGenerator.html)를 사용하세요.
:::

체인에서 생성기 함수(즉, `yield` 키워드를 사용하고 반복자처럼 동작하는 함수)를 사용할 수 있습니다.

이 생성기의 서명은 `Iterator[Input] -> Iterator[Output]`이어야 합니다. 또는 비동기 생성기의 경우: `AsyncIterator[Input] -> AsyncIterator[Output]`.

이는 다음과 같은 경우에 유용합니다:
- 사용자 정의 출력 파서를 구현할 때
- 스트리밍 기능을 유지하면서 이전 단계의 출력을 수정할 때

다음은 쉼표로 구분된 목록에 대한 사용자 정의 출력 파서의 예입니다. 먼저, 우리는 그러한 목록을 텍스트로 생성하는 체인을 만듭니다:

```python
from typing import Iterator, List

prompt = ChatPromptTemplate.from_template(
    "Write a comma-separated list of 5 animals similar to: {animal}. Do not include numbers"
)

str_chain = prompt | model | StrOutputParser()

for chunk in str_chain.stream({"animal": "bear"}):
    print(chunk, end="", flush=True)
```

```output
lion, tiger, wolf, gorilla, panda
```


다음으로, 현재 스트리밍된 출력을 집계하고 모델이 목록에서 다음 쉼표를 생성할 때 이를 반환하는 사용자 정의 함수를 정의합니다:

```python
# This is a custom parser that splits an iterator of llm tokens
# into a list of strings separated by commas
def split_into_list(input: Iterator[str]) -> Iterator[List[str]]:
    # hold partial input until we get a comma
    buffer = ""
    for chunk in input:
        # add current chunk to buffer
        buffer += chunk
        # while there are commas in the buffer
        while "," in buffer:
            # split buffer on comma
            comma_index = buffer.index(",")
            # yield everything before the comma
            yield [buffer[:comma_index].strip()]
            # save the rest for the next iteration
            buffer = buffer[comma_index + 1 :]
    # yield the last chunk
    yield [buffer.strip()]


list_chain = str_chain | split_into_list

for chunk in list_chain.stream({"animal": "bear"}):
    print(chunk, flush=True)
```

```output
['lion']
['tiger']
['wolf']
['gorilla']
['raccoon']
```


이를 호출하면 값의 전체 배열이 생성됩니다:

```python
list_chain.invoke({"animal": "bear"})
```


```output
['lion', 'tiger', 'wolf', 'gorilla', 'raccoon']
```


## 비동기 버전

비동기 환경에서 작업하는 경우, 위 예제의 비동기 버전은 다음과 같습니다:

```python
from typing import AsyncIterator


async def asplit_into_list(
    input: AsyncIterator[str],
) -> AsyncIterator[List[str]]:  # async def
    buffer = ""
    async for (
        chunk
    ) in input:  # `input` is a `async_generator` object, so use `async for`
        buffer += chunk
        while "," in buffer:
            comma_index = buffer.index(",")
            yield [buffer[:comma_index].strip()]
            buffer = buffer[comma_index + 1 :]
    yield [buffer.strip()]


list_chain = str_chain | asplit_into_list

async for chunk in list_chain.astream({"animal": "bear"}):
    print(chunk, flush=True)
```

```output
['lion']
['tiger']
['wolf']
['gorilla']
['panda']
```


```python
await list_chain.ainvoke({"animal": "bear"})
```


```output
['lion', 'tiger', 'wolf', 'gorilla', 'panda']
```


## 다음 단계

이제 체인 내에서 사용자 정의 논리를 사용하는 몇 가지 방법과 스트리밍을 구현하는 방법을 배웠습니다.

더 알아보려면 이 섹션의 다른 runnable에 대한 가이드를 참조하세요.