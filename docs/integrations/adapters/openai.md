---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/adapters/openai.ipynb
description: OpenAI 어댑터에 대한 문서로, LangChain을 통해 OpenAI API와의 통합 및 다양한 모델 탐색 방법을 설명합니다.
---

# OpenAI 어댑터

**OpenAI 라이브러리의 버전이 1.0.0 이상인지 확인하세요. 그렇지 않으면 이전 문서 [OpenAI 어댑터(구식)](/docs/integrations/adapters/openai-old/)를 참조하세요.**

많은 사람들이 OpenAI를 시작하지만 다른 모델을 탐색하고 싶어합니다. LangChain은 여러 모델 제공업체와의 통합을 통해 이를 쉽게 할 수 있도록 합니다. LangChain은 자체 메시지 및 모델 API를 가지고 있지만, LangChain 모델을 OpenAI API에 맞게 조정하는 어댑터를 제공하여 다른 모델을 탐색하는 것을 최대한 쉽게 만들었습니다.

현재 이 기능은 출력만 처리하며 다른 정보(토큰 수, 중지 사유 등)는 반환하지 않습니다.

```python
<!--IMPORTS:[{"imported": "openai", "source": "langchain_community.adapters", "docs": "https://api.python.langchain.com/en/latest/adapters/langchain_community.adapters.openai.openai.html", "title": "OpenAI Adapter"}]-->
import openai
from langchain_community.adapters import openai as lc_openai
```


## chat.completions.create

```python
messages = [{"role": "user", "content": "hi"}]
```


원래 OpenAI 호출

```python
result = openai.chat.completions.create(
    messages=messages, model="gpt-3.5-turbo", temperature=0
)
result.choices[0].message.model_dump()
```


```output
{'content': 'Hello! How can I assist you today?',
 'role': 'assistant',
 'function_call': None,
 'tool_calls': None}
```


LangChain OpenAI 래퍼 호출

```python
lc_result = lc_openai.chat.completions.create(
    messages=messages, model="gpt-3.5-turbo", temperature=0
)

lc_result.choices[0].message  # Attribute access
```


```output
{'role': 'assistant', 'content': 'Hello! How can I help you today?'}
```


```python
lc_result["choices"][0]["message"]  # Also compatible with index access
```


```output
{'role': 'assistant', 'content': 'Hello! How can I help you today?'}
```


모델 제공업체 변경

```python
lc_result = lc_openai.chat.completions.create(
    messages=messages, model="claude-2", temperature=0, provider="ChatAnthropic"
)
lc_result.choices[0].message
```


```output
{'role': 'assistant', 'content': 'Hello! How can I assist you today?'}
```


## chat.completions.stream

원래 OpenAI 호출

```python
for c in openai.chat.completions.create(
    messages=messages, model="gpt-3.5-turbo", temperature=0, stream=True
):
    print(c.choices[0].delta.model_dump())
```

```output
{'content': '', 'function_call': None, 'role': 'assistant', 'tool_calls': None}
{'content': 'Hello', 'function_call': None, 'role': None, 'tool_calls': None}
{'content': '!', 'function_call': None, 'role': None, 'tool_calls': None}
{'content': ' How', 'function_call': None, 'role': None, 'tool_calls': None}
{'content': ' can', 'function_call': None, 'role': None, 'tool_calls': None}
{'content': ' I', 'function_call': None, 'role': None, 'tool_calls': None}
{'content': ' assist', 'function_call': None, 'role': None, 'tool_calls': None}
{'content': ' you', 'function_call': None, 'role': None, 'tool_calls': None}
{'content': ' today', 'function_call': None, 'role': None, 'tool_calls': None}
{'content': '?', 'function_call': None, 'role': None, 'tool_calls': None}
{'content': None, 'function_call': None, 'role': None, 'tool_calls': None}
```

LangChain OpenAI 래퍼 호출

```python
for c in lc_openai.chat.completions.create(
    messages=messages, model="gpt-3.5-turbo", temperature=0, stream=True
):
    print(c.choices[0].delta)
```

```output
{'role': 'assistant', 'content': ''}
{'content': 'Hello'}
{'content': '!'}
{'content': ' How'}
{'content': ' can'}
{'content': ' I'}
{'content': ' assist'}
{'content': ' you'}
{'content': ' today'}
{'content': '?'}
{}
```

모델 제공업체 변경

```python
for c in lc_openai.chat.completions.create(
    messages=messages,
    model="claude-2",
    temperature=0,
    stream=True,
    provider="ChatAnthropic",
):
    print(c["choices"][0]["delta"])
```

```output
{'role': 'assistant', 'content': ''}
{'content': 'Hello'}
{'content': '!'}
{'content': ' How'}
{'content': ' can'}
{'content': ' I'}
{'content': ' assist'}
{'content': ' you'}
{'content': ' today'}
{'content': '?'}
{}
```