---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/lcel_cheatsheet.ipynb
description: 이 문서는 LangChain 표현 언어(LCEL)의 주요 원칙을 간략하게 정리한 참고 자료입니다. 고급 사용법은 추가 가이드를
  참조하세요.
---

# LangChain 표현 언어 요약

이 문서는 가장 중요한 LCEL 원시 요소에 대한 빠른 참조입니다. 더 고급 사용법은 [LCEL 사용 안내서](/docs/how_to/#langchain-expression-language-lcel)와 [전체 API 참조](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html)를 참조하세요.

### 실행 가능 객체 호출
#### [Runnable.invoke()](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.invoke) / [Runnable.ainvoke()](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.ainvoke)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda

runnable = RunnableLambda(lambda x: str(x))
runnable.invoke(5)

# Async variant:
# await runnable.ainvoke(5)
```


```output
'5'
```


### 실행 가능 객체 배치
#### [Runnable.batch()](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.batch) / [Runnable.abatch()](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.abatch)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda

runnable = RunnableLambda(lambda x: str(x))
runnable.batch([7, 8, 9])

# Async variant:
# await runnable.abatch([7, 8, 9])
```


```output
['7', '8', '9']
```


### 실행 가능 객체 스트리밍
#### [Runnable.stream()](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.stream) / [Runnable.astream()](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.astream)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda


def func(x):
    for y in x:
        yield str(y)


runnable = RunnableLambda(func)

for chunk in runnable.stream(range(5)):
    print(chunk)

# Async variant:
# async for chunk in await runnable.astream(range(5)):
#     print(chunk)
```

```output
0
1
2
3
4
```


### 실행 가능 객체 조합
#### 파이프 연산자 `|`

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda

runnable1 = RunnableLambda(lambda x: {"foo": x})
runnable2 = RunnableLambda(lambda x: [x] * 2)

chain = runnable1 | runnable2

chain.invoke(2)
```


```output
[{'foo': 2}, {'foo': 2}]
```


### 실행 가능 객체를 병렬로 호출
#### [RunnableParallel](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda, RunnableParallel

runnable1 = RunnableLambda(lambda x: {"foo": x})
runnable2 = RunnableLambda(lambda x: [x] * 2)

chain = RunnableParallel(first=runnable1, second=runnable2)

chain.invoke(2)
```


```output
{'first': {'foo': 2}, 'second': [2, 2]}
```


### 모든 함수를 실행 가능 객체로 변환
#### [RunnableLambda](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda


def func(x):
    return x + 5


runnable = RunnableLambda(func)
runnable.invoke(2)
```


```output
7
```


### 입력 및 출력 딕셔너리 병합
#### [RunnablePassthrough.assign](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda, RunnablePassthrough

runnable1 = RunnableLambda(lambda x: x["foo"] + 7)

chain = RunnablePassthrough.assign(bar=runnable1)

chain.invoke({"foo": 10})
```


```output
{'foo': 10, 'bar': 17}
```


### 출력 딕셔너리에 입력 딕셔너리 포함
#### [RunnablePassthrough](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import (
    RunnableLambda,
    RunnableParallel,
    RunnablePassthrough,
)

runnable1 = RunnableLambda(lambda x: x["foo"] + 7)

chain = RunnableParallel(bar=runnable1, baz=RunnablePassthrough())

chain.invoke({"foo": 10})
```


```output
{'bar': 17, 'baz': {'foo': 10}}
```


### 기본 호출 인수 추가
#### [Runnable.bind](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.bind)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from typing import Optional

from langchain_core.runnables import RunnableLambda


def func(main_arg: dict, other_arg: Optional[str] = None) -> dict:
    if other_arg:
        return {**main_arg, **{"foo": other_arg}}
    return main_arg


runnable1 = RunnableLambda(func)
bound_runnable1 = runnable1.bind(other_arg="bye")

bound_runnable1.invoke({"bar": "hello"})
```


```output
{'bar': 'hello', 'foo': 'bye'}
```


### 폴백 추가
#### [Runnable.with_fallbacks](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.with_fallbacks)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda

runnable1 = RunnableLambda(lambda x: x + "foo")
runnable2 = RunnableLambda(lambda x: str(x) + "foo")

chain = runnable1.with_fallbacks([runnable2])

chain.invoke(5)
```


```output
'5foo'
```


### 재시도 추가
#### [Runnable.with_retry](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.with_retry)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda

counter = -1


def func(x):
    global counter
    counter += 1
    print(f"attempt with {counter=}")
    return x / counter


chain = RunnableLambda(func).with_retry(stop_after_attempt=2)

chain.invoke(2)
```

```output
attempt with counter=0
attempt with counter=1
```


```output
2.0
```


### 실행 가능 객체 실행 구성
#### [RunnableConfig](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda, RunnableParallel

runnable1 = RunnableLambda(lambda x: {"foo": x})
runnable2 = RunnableLambda(lambda x: [x] * 2)
runnable3 = RunnableLambda(lambda x: str(x))

chain = RunnableParallel(first=runnable1, second=runnable2, third=runnable3)

chain.invoke(7, config={"max_concurrency": 2})
```


```output
{'first': {'foo': 7}, 'second': [7, 7], 'third': '7'}
```


### 실행 가능 객체에 기본 구성 추가
#### [Runnable.with_config](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.with_config)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda, RunnableParallel

runnable1 = RunnableLambda(lambda x: {"foo": x})
runnable2 = RunnableLambda(lambda x: [x] * 2)
runnable3 = RunnableLambda(lambda x: str(x))

chain = RunnableParallel(first=runnable1, second=runnable2, third=runnable3)
configured_chain = chain.with_config(max_concurrency=2)

chain.invoke(7)
```


```output
{'first': {'foo': 7}, 'second': [7, 7], 'third': '7'}
```


### 실행 가능 객체 속성을 구성 가능하게 만들기
#### [Runnable.with_configurable_fields](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableSerializable.html#langchain_core.runnables.base.RunnableSerializable.configurable_fields)

```python
<!--IMPORTS:[{"imported": "ConfigurableField", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.utils.ConfigurableField.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableSerializable", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableSerializable.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from typing import Any, Optional

from langchain_core.runnables import (
    ConfigurableField,
    RunnableConfig,
    RunnableSerializable,
)


class FooRunnable(RunnableSerializable[dict, dict]):
    output_key: str

    def invoke(
        self, input: Any, config: Optional[RunnableConfig] = None, **kwargs: Any
    ) -> list:
        return self._call_with_config(self.subtract_seven, input, config, **kwargs)

    def subtract_seven(self, input: dict) -> dict:
        return {self.output_key: input["foo"] - 7}


runnable1 = FooRunnable(output_key="bar")
configurable_runnable1 = runnable1.configurable_fields(
    output_key=ConfigurableField(id="output_key")
)

configurable_runnable1.invoke(
    {"foo": 10}, config={"configurable": {"output_key": "not bar"}}
)
```


```output
{'not bar': 3}
```


```python
configurable_runnable1.invoke({"foo": 10})
```


```output
{'bar': 3}
```


### 체인 구성 요소를 구성 가능하게 만들기
#### [Runnable.with_configurable_alternatives](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableSerializable.html#langchain_core.runnables.base.RunnableSerializable.configurable_alternatives)

```python
<!--IMPORTS:[{"imported": "RunnableConfig", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.config.RunnableConfig.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from typing import Any, Optional

from langchain_core.runnables import RunnableConfig, RunnableLambda, RunnableParallel


class ListRunnable(RunnableSerializable[Any, list]):
    def invoke(
        self, input: Any, config: Optional[RunnableConfig] = None, **kwargs: Any
    ) -> list:
        return self._call_with_config(self.listify, input, config, **kwargs)

    def listify(self, input: Any) -> list:
        return [input]


class StrRunnable(RunnableSerializable[Any, str]):
    def invoke(
        self, input: Any, config: Optional[RunnableConfig] = None, **kwargs: Any
    ) -> list:
        return self._call_with_config(self.strify, input, config, **kwargs)

    def strify(self, input: Any) -> str:
        return str(input)


runnable1 = RunnableLambda(lambda x: {"foo": x})

configurable_runnable = ListRunnable().configurable_alternatives(
    ConfigurableField(id="second_step"), default_key="list", string=StrRunnable()
)
chain = runnable1 | configurable_runnable

chain.invoke(7, config={"configurable": {"second_step": "string"}})
```


```output
"{'foo': 7}"
```


```python
chain.invoke(7)
```


```output
[{'foo': 7}]
```


### 입력에 따라 동적으로 체인 구축

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda, RunnableParallel

runnable1 = RunnableLambda(lambda x: {"foo": x})
runnable2 = RunnableLambda(lambda x: [x] * 2)

chain = RunnableLambda(lambda x: runnable1 if x > 6 else runnable2)

chain.invoke(7)
```


```output
{'foo': 7}
```


```python
chain.invoke(5)
```


```output
[5, 5]
```


### 이벤트 스트림 생성
#### [Runnable.astream_events](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.astream_events)

```python
# | echo: false

import nest_asyncio

nest_asyncio.apply()
```


```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda, RunnableParallel

runnable1 = RunnableLambda(lambda x: {"foo": x}, name="first")


async def func(x):
    for _ in range(5):
        yield x


runnable2 = RunnableLambda(func, name="second")

chain = runnable1 | runnable2

async for event in chain.astream_events("bar", version="v2"):
    print(f"event={event['event']} | name={event['name']} | data={event['data']}")
```

```output
event=on_chain_start | name=RunnableSequence | data={'input': 'bar'}
event=on_chain_start | name=first | data={}
event=on_chain_stream | name=first | data={'chunk': {'foo': 'bar'}}
event=on_chain_start | name=second | data={}
event=on_chain_end | name=first | data={'output': {'foo': 'bar'}, 'input': 'bar'}
event=on_chain_stream | name=second | data={'chunk': {'foo': 'bar'}}
event=on_chain_stream | name=RunnableSequence | data={'chunk': {'foo': 'bar'}}
event=on_chain_stream | name=second | data={'chunk': {'foo': 'bar'}}
event=on_chain_stream | name=RunnableSequence | data={'chunk': {'foo': 'bar'}}
event=on_chain_stream | name=second | data={'chunk': {'foo': 'bar'}}
event=on_chain_stream | name=RunnableSequence | data={'chunk': {'foo': 'bar'}}
event=on_chain_stream | name=second | data={'chunk': {'foo': 'bar'}}
event=on_chain_stream | name=RunnableSequence | data={'chunk': {'foo': 'bar'}}
event=on_chain_stream | name=second | data={'chunk': {'foo': 'bar'}}
event=on_chain_stream | name=RunnableSequence | data={'chunk': {'foo': 'bar'}}
event=on_chain_end | name=second | data={'output': {'foo': 'bar'}, 'input': {'foo': 'bar'}}
event=on_chain_end | name=RunnableSequence | data={'output': {'foo': 'bar'}}
```


### 완료되는 대로 배치된 출력 반환
#### [Runnable.batch_as_completed](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.batch_as_completed) / [Runnable.abatch_as_completed](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.abatch_as_completed)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "LangChain Expression Language Cheatsheet"}]-->
import time

from langchain_core.runnables import RunnableLambda, RunnableParallel

runnable1 = RunnableLambda(lambda x: time.sleep(x) or print(f"slept {x}"))

for idx, result in runnable1.batch_as_completed([5, 1]):
    print(idx, result)

# Async variant:
# async for idx, result in runnable1.abatch_as_completed([5, 1]):
#     print(idx, result)
```


```output
slept 1
1 None
slept 5
0 None
```


### 출력 딕셔너리의 하위 집합 반환
#### [Runnable.pick](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.pick)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda, RunnablePassthrough

runnable1 = RunnableLambda(lambda x: x["baz"] + 5)
chain = RunnablePassthrough.assign(foo=runnable1).pick(["foo", "bar"])

chain.invoke({"bar": "hi", "baz": 2})
```


```output
{'foo': 7, 'bar': 'hi'}
```


### 실행 가능 객체의 배치 버전을 선언적으로 만들기
#### [Runnable.map](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.map)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda

runnable1 = RunnableLambda(lambda x: list(range(x)))
runnable2 = RunnableLambda(lambda x: x + 5)

chain = runnable1 | runnable2.map()

chain.invoke(3)
```


```output
[5, 6, 7]
```


### 실행 가능 객체의 그래프 표현 가져오기
#### [Runnable.get_graph](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.get_graph)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.runnables import RunnableLambda, RunnableParallel

runnable1 = RunnableLambda(lambda x: {"foo": x})
runnable2 = RunnableLambda(lambda x: [x] * 2)
runnable3 = RunnableLambda(lambda x: str(x))

chain = runnable1 | RunnableParallel(second=runnable2, third=runnable3)

chain.get_graph().print_ascii()
```


```output
                             +-------------+                              
                             | LambdaInput |                              
                             +-------------+                              
                                    *                                     
                                    *                                     
                                    *                                     
                    +------------------------------+                      
                    | Lambda(lambda x: {'foo': x}) |                      
                    +------------------------------+                      
                                    *                                     
                                    *                                     
                                    *                                     
                     +-----------------------------+                      
                     | Parallel<second,third>Input |                      
                     +-----------------------------+                      
                        ****                  ***                         
                    ****                         ****                     
                  **                                 **                   
+---------------------------+               +--------------------------+  
| Lambda(lambda x: [x] * 2) |               | Lambda(lambda x: str(x)) |  
+---------------------------+               +--------------------------+  
                        ****                  ***                         
                            ****          ****                            
                                **      **                                
                    +------------------------------+                      
                    | Parallel<second,third>Output |                      
                    +------------------------------+
```


### 체인의 모든 프롬프트 가져오기
#### [Runnable.get_prompts](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.get_prompts)

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableLambda

prompt1 = ChatPromptTemplate.from_messages(
    [("system", "good ai"), ("human", "{input}")]
)
prompt2 = ChatPromptTemplate.from_messages(
    [
        ("system", "really good ai"),
        ("human", "{input}"),
        ("ai", "{ai_output}"),
        ("human", "{input2}"),
    ]
)
fake_llm = RunnableLambda(lambda prompt: "i am good ai")
chain = prompt1.assign(ai_output=fake_llm) | prompt2 | fake_llm

for i, prompt in enumerate(chain.get_prompts()):
    print(f"**prompt {i=}**\n")
    print(prompt.pretty_repr())
    print("\n" * 3)
```


```output
**prompt i=0**

================================ System Message ================================

good ai

================================ Human Message =================================

{input}




**prompt i=1**

================================ System Message ================================

really good ai

================================ Human Message =================================

{input}

================================== AI Message ==================================

{ai_output}

================================ Human Message =================================

{input2}
```


### 생명 주기 리스너 추가
#### [Runnable.with_listeners](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.with_listeners)

```python
<!--IMPORTS:[{"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "LangChain Expression Language Cheatsheet"}, {"imported": "Run", "source": "langchain_core.tracers.schemas", "docs": "https://api.python.langchain.com/en/latest/tracers/langchain_core.tracers.schemas.Run.html", "title": "LangChain Expression Language Cheatsheet"}]-->
import time

from langchain_core.runnables import RunnableLambda
from langchain_core.tracers.schemas import Run


def on_start(run_obj: Run):
    print("start_time:", run_obj.start_time)


def on_end(run_obj: Run):
    print("end_time:", run_obj.end_time)


runnable1 = RunnableLambda(lambda x: time.sleep(x))
chain = runnable1.with_listeners(on_start=on_start, on_end=on_end)
chain.invoke(2)
```


```output
start_time: 2024-05-17 23:04:00.951065+00:00
end_time: 2024-05-17 23:04:02.958765+00:00
```