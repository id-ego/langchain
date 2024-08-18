---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/chat_model_caching.ipynb
description: 챗 모델 응답을 캐시하는 방법에 대한 가이드입니다. API 호출을 줄여 비용을 절감하고 애플리케이션 속도를 높이는 방법을 설명합니다.
---

# 채팅 모델 응답 캐싱 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 친숙함을 가정합니다:
- [채팅 모델](/docs/concepts/#chat-models)
- [LLMs](/docs/concepts/#llms)

:::

LangChain은 채팅 모델을 위한 선택적 캐싱 레이어를 제공합니다. 이는 두 가지 주요 이유로 유용합니다:

- 동일한 완성을 여러 번 요청하는 경우 LLM 제공자에 대한 API 호출 수를 줄여 비용을 절감할 수 있습니다. 이는 앱 개발 중 특히 유용합니다.
- LLM 제공자에 대한 API 호출 수를 줄여 애플리케이션 속도를 높일 수 있습니다.

이 가이드는 앱에서 이를 활성화하는 방법을 안내합니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />


```python
<!--IMPORTS:[{"imported": "set_llm_cache", "source": "langchain_core.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain_core.globals.set_llm_cache.html", "title": "How to cache chat model responses"}]-->
# <!-- ruff: noqa: F821 -->
from langchain_core.globals import set_llm_cache
```


## 메모리 캐시

이것은 모델 호출을 메모리에 저장하는 일시적인 캐시입니다. 환경이 재시작될 때 삭제되며, 프로세스 간에 공유되지 않습니다.

```python
<!--IMPORTS:[{"imported": "InMemoryCache", "source": "langchain_core.caches", "docs": "https://api.python.langchain.com/en/latest/caches/langchain_core.caches.InMemoryCache.html", "title": "How to cache chat model responses"}]-->
%%time
from langchain_core.caches import InMemoryCache

set_llm_cache(InMemoryCache())

# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```

```output
CPU times: user 645 ms, sys: 214 ms, total: 859 ms
Wall time: 829 ms
```


```output
AIMessage(content="Why don't scientists trust atoms?\n\nBecause they make up everything!", response_metadata={'token_usage': {'completion_tokens': 13, 'prompt_tokens': 11, 'total_tokens': 24}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-b6836bdd-8c30-436b-828f-0ac5fc9ab50e-0')
```


```python
%%time
# The second time it is, so it goes faster
llm.invoke("Tell me a joke")
```

```output
CPU times: user 822 µs, sys: 288 µs, total: 1.11 ms
Wall time: 1.06 ms
```


```output
AIMessage(content="Why don't scientists trust atoms?\n\nBecause they make up everything!", response_metadata={'token_usage': {'completion_tokens': 13, 'prompt_tokens': 11, 'total_tokens': 24}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-b6836bdd-8c30-436b-828f-0ac5fc9ab50e-0')
```


## SQLite 캐시

이 캐시 구현은 응답을 저장하기 위해 `SQLite` 데이터베이스를 사용하며, 프로세스 재시작 간에도 지속됩니다.

```python
!rm .langchain.db
```


```python
<!--IMPORTS:[{"imported": "SQLiteCache", "source": "langchain_community.cache", "docs": "https://api.python.langchain.com/en/latest/cache/langchain_community.cache.SQLiteCache.html", "title": "How to cache chat model responses"}]-->
# We can do the same thing with a SQLite cache
from langchain_community.cache import SQLiteCache

set_llm_cache(SQLiteCache(database_path=".langchain.db"))
```


```python
%%time
# The first time, it is not yet in cache, so it should take longer
llm.invoke("Tell me a joke")
```

```output
CPU times: user 9.91 ms, sys: 7.68 ms, total: 17.6 ms
Wall time: 657 ms
```


```output
AIMessage(content='Why did the scarecrow win an award? Because he was outstanding in his field!', response_metadata={'token_usage': {'completion_tokens': 17, 'prompt_tokens': 11, 'total_tokens': 28}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_c2295e73ad', 'finish_reason': 'stop', 'logprobs': None}, id='run-39d9e1e8-7766-4970-b1d8-f50213fd94c5-0')
```


```python
%%time
# The second time it is, so it goes faster
llm.invoke("Tell me a joke")
```

```output
CPU times: user 52.2 ms, sys: 60.5 ms, total: 113 ms
Wall time: 127 ms
```


```output
AIMessage(content='Why did the scarecrow win an award? Because he was outstanding in his field!', id='run-39d9e1e8-7766-4970-b1d8-f50213fd94c5-0')
```


## 다음 단계

이제 모델 응답을 캐싱하여 시간과 비용을 절약하는 방법을 배웠습니다.

다음으로, 이 섹션의 다른 채팅 모델 관련 가이드인 [모델이 구조화된 출력을 반환하도록 하는 방법](/docs/how_to/structured_output) 또는 [자신만의 맞춤형 채팅 모델을 만드는 방법](/docs/how_to/custom_chat_model)을 확인해 보세요.