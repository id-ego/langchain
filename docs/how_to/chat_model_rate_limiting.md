---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/chat_model_rate_limiting.ipynb
description: 모델 제공 API의 속도 제한을 처리하는 방법과 Langchain의 내장 속도 제한기를 사용하는 방법에 대한 가이드입니다.
---

# 속도 제한 처리 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [채팅 모델](/docs/concepts/#chat-models)
- [LLMs](/docs/concepts/#llms)
:::

모델 제공 API에서 너무 많은 요청을 보내고 있어 속도 제한을 받는 상황에 처할 수 있습니다.

예를 들어, 테스트 데이터셋에서 채팅 모델을 벤치마킹하기 위해 많은 병렬 쿼리를 실행하는 경우 이러한 일이 발생할 수 있습니다.

이런 상황에 직면한 경우, 요청을 보내는 속도를 API에서 허용하는 속도와 일치시키기 위해 속도 제한기를 사용할 수 있습니다.

:::info `langchain-core >= 0.2.24` 필요

이 기능은 `langchain-core == 0.2.24`에 추가되었습니다. 패키지가 최신인지 확인하세요.
:::

## 속도 제한기 초기화

Langchain은 내장 메모리 속도 제한기를 제공합니다. 이 속도 제한기는 스레드 안전하며 동일한 프로세스 내의 여러 스레드에서 공유할 수 있습니다.

제공된 속도 제한기는 단위 시간당 요청 수만 제한할 수 있습니다. 요청의 크기를 기준으로 제한해야 하는 경우에는 도움이 되지 않습니다.

```python
<!--IMPORTS:[{"imported": "InMemoryRateLimiter", "source": "langchain_core.rate_limiters", "docs": "https://api.python.langchain.com/en/latest/rate_limiters/langchain_core.rate_limiters.InMemoryRateLimiter.html", "title": "How to handle rate limits"}]-->
from langchain_core.rate_limiters import InMemoryRateLimiter

rate_limiter = InMemoryRateLimiter(
    requests_per_second=0.1,  # <-- Super slow! We can only make a request once every 10 seconds!!
    check_every_n_seconds=0.1,  # Wake up every 100 ms to check whether allowed to make a request,
    max_bucket_size=10,  # Controls the maximum burst size.
)
```


## 모델 선택

모델을 선택하고 `rate_limiter` 속성을 통해 속도 제한기를 전달합니다.

```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to handle rate limits"}]-->
import os
import time
from getpass import getpass

if "ANTHROPIC_API_KEY" not in os.environ:
    os.environ["ANTHROPIC_API_KEY"] = getpass()


from langchain_anthropic import ChatAnthropic

model = ChatAnthropic(model_name="claude-3-opus-20240229", rate_limiter=rate_limiter)
```


속도 제한기가 작동하는지 확인해 봅시다. 우리는 10초에 한 번만 모델을 호출할 수 있어야 합니다.

```python
for _ in range(5):
    tic = time.time()
    model.invoke("hello")
    toc = time.time()
    print(toc - tic)
```

```output
11.599073648452759
10.7502121925354
10.244257926940918
8.83088755607605
11.645203590393066
```