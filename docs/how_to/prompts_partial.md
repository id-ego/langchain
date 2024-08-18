---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/prompts_partial.ipynb
description: 프롬프트 템플릿을 부분적으로 포맷하는 방법을 소개하며, 문자열 및 함수 사용 사례를 설명합니다. LangChain에서의 활용법을
  다룹니다.
sidebar_position: 4
---

# 프롬프트 템플릿 부분 형식 지정 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 친숙함을 가정합니다:
- [프롬프트 템플릿](/docs/concepts/#prompt-templates)

:::

함수에 인수를 부분적으로 바인딩하는 것처럼, 프롬프트 템플릿을 "부분적으로" 만드는 것이 의미가 있을 수 있습니다. 예를 들어, 필요한 값의 하위 집합을 전달하여 나머지 값의 하위 집합만 기대하는 새로운 프롬프트 템플릿을 생성하는 것입니다.

LangChain은 이를 두 가지 방법으로 지원합니다:

1. 문자열 값을 사용한 부분 형식 지정.
2. 문자열 값을 반환하는 함수를 사용한 부분 형식 지정.

아래 예제에서는 두 가지 사용 사례에 대한 동기와 LangChain에서 이를 수행하는 방법을 설명합니다.

## 문자열로 부분 형식 지정

프롬프트 템플릿을 부분적으로 만들고자 하는 일반적인 사용 사례 중 하나는 다른 변수보다 먼저 프롬프트에서 일부 변수를 사용할 수 있는 경우입니다. 예를 들어, `foo`와 `baz`라는 두 변수가 필요한 프롬프트 템플릿이 있다고 가정해 보겠습니다. 체인에서 `foo` 값을 일찍 얻었지만 `baz` 값은 나중에 얻는 경우, 두 변수를 체인 전체에 걸쳐 전달하는 것은 불편할 수 있습니다. 대신, `foo` 값으로 프롬프트 템플릿을 부분적으로 만들고, 부분화된 프롬프트 템플릿을 전달하여 그것만 사용할 수 있습니다. 아래는 이를 수행하는 예입니다:

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to partially format prompt templates"}]-->
from langchain_core.prompts import PromptTemplate

prompt = PromptTemplate.from_template("{foo}{bar}")
partial_prompt = prompt.partial(foo="foo")
print(partial_prompt.format(bar="baz"))
```

```output
foobaz
```

부분화된 변수로 프롬프트를 초기화할 수도 있습니다.

```python
prompt = PromptTemplate(
    template="{foo}{bar}", input_variables=["bar"], partial_variables={"foo": "foo"}
)
print(prompt.format(bar="baz"))
```

```output
foobaz
```

## 함수로 부분 형식 지정

다른 일반적인 사용 사례는 함수를 사용하여 부분적으로 만드는 것입니다. 이 경우는 항상 공통적인 방식으로 가져오고 싶은 변수가 있을 때입니다. 이의 대표적인 예는 날짜나 시간입니다. 항상 현재 날짜를 가져오고 싶은 프롬프트가 있다고 상상해 보십시오. 프롬프트에 하드 코딩할 수 없고, 다른 입력 변수와 함께 전달하는 것은 불편합니다. 이 경우, 항상 현재 날짜를 반환하는 함수로 프롬프트를 부분적으로 만드는 것이 유용합니다.

```python
from datetime import datetime


def _get_datetime():
    now = datetime.now()
    return now.strftime("%m/%d/%Y, %H:%M:%S")


prompt = PromptTemplate(
    template="Tell me a {adjective} joke about the day {date}",
    input_variables=["adjective", "date"],
)
partial_prompt = prompt.partial(date=_get_datetime)
print(partial_prompt.format(adjective="funny"))
```

```output
Tell me a funny joke about the day 04/21/2024, 19:43:57
```

부분화된 변수로 프롬프트를 초기화할 수도 있으며, 이는 이 워크플로우에서 더 의미가 있을 때가 많습니다.

```python
prompt = PromptTemplate(
    template="Tell me a {adjective} joke about the day {date}",
    input_variables=["adjective"],
    partial_variables={"date": _get_datetime},
)
print(prompt.format(adjective="funny"))
```

```output
Tell me a funny joke about the day 04/21/2024, 19:43:57
```

## 다음 단계

이제 프롬프트 템플릿에 변수를 부분적으로 적용하는 방법을 배웠습니다.

다음으로, 이 섹션의 프롬프트 템플릿에 대한 다른 사용 방법 가이드를 확인해 보세요. 예를 들어, [프롬프트 템플릿에 몇 가지 샷 예제 추가하기](/docs/how_to/few_shot_examples_chat)와 같은 가이드입니다.