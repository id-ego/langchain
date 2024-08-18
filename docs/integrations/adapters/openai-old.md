---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/adapters/openai-old.ipynb
description: OpenAI 라이브러리 1.0.0 미만에서 LangChain을 사용하여 다양한 모델을 탐색하는 방법을 안내합니다.
---

# OpenAI 어댑터(구형)

**OpenAI 라이브러리가 1.0.0 미만인지 확인하십시오. 그렇지 않으면 최신 문서 [OpenAI 어댑터](/docs/integrations/adapters/openai/)를 참조하십시오.**

많은 사람들이 OpenAI로 시작하지만 다른 모델을 탐색하고 싶어합니다. LangChain은 여러 모델 제공업체와의 통합을 통해 이를 쉽게 할 수 있도록 합니다. LangChain은 자체 메시지 및 모델 API를 가지고 있지만, LangChain 모델을 OpenAI API에 맞게 조정하는 어댑터를 노출하여 다른 모델을 탐색하는 것을 최대한 쉽게 만들었습니다.

현재 이 기능은 출력만 처리하며 다른 정보(토큰 수, 중지 이유 등)는 반환하지 않습니다.

```python
<!--IMPORTS:[{"imported": "openai", "source": "langchain_community.adapters", "docs": "https://api.python.langchain.com/en/latest/adapters/langchain_community.adapters.openai.openai.html", "title": "OpenAI Adapter(Old)"}]-->
import openai
from langchain_community.adapters import openai as lc_openai
```


## ChatCompletion.create

```python
messages = [{"role": "user", "content": "hi"}]
```


원래 OpenAI 호출

```python
result = openai.ChatCompletion.create(
    messages=messages, model="gpt-3.5-turbo", temperature=0
)
result["choices"][0]["message"].to_dict_recursive()
```


```output
{'role': 'assistant', 'content': 'Hello! How can I assist you today?'}
```


LangChain OpenAI 래퍼 호출

```python
lc_result = lc_openai.ChatCompletion.create(
    messages=messages, model="gpt-3.5-turbo", temperature=0
)
lc_result["choices"][0]["message"]
```


```output
{'role': 'assistant', 'content': 'Hello! How can I assist you today?'}
```


모델 제공업체 교체

```python
lc_result = lc_openai.ChatCompletion.create(
    messages=messages, model="claude-2", temperature=0, provider="ChatAnthropic"
)
lc_result["choices"][0]["message"]
```


```output
{'role': 'assistant', 'content': ' Hello!'}
```


## ChatCompletion.stream

원래 OpenAI 호출

```python
for c in openai.ChatCompletion.create(
    messages=messages, model="gpt-3.5-turbo", temperature=0, stream=True
):
    print(c["choices"][0]["delta"].to_dict_recursive())
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

LangChain OpenAI 래퍼 호출

```python
for c in lc_openai.ChatCompletion.create(
    messages=messages, model="gpt-3.5-turbo", temperature=0, stream=True
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

모델 제공업체 교체

```python
for c in lc_openai.ChatCompletion.create(
    messages=messages,
    model="claude-2",
    temperature=0,
    stream=True,
    provider="ChatAnthropic",
):
    print(c["choices"][0]["delta"])
```

```output
{'role': 'assistant', 'content': ' Hello'}
{'content': '!'}
{}
```