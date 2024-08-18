---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/upstash_ratelimit.ipynb
description: Upstash Ratelimit Callback을 사용하여 요청 수 또는 토큰 수에 기반한 속도 제한을 추가하는 방법을 안내합니다.
---

# Upstash Ratelimit Callback

이 가이드에서는 `UpstashRatelimitHandler`를 사용하여 요청 수 또는 토큰 수에 따라 속도 제한을 추가하는 방법에 대해 설명합니다. 이 핸들러는 [Upstash의 ratelimit 라이브러리](https://github.com/upstash/ratelimit-py/)를 사용하며, [Upstash Redis](https://upstash.com/docs/redis/overall/getstarted)를 활용합니다.

Upstash Ratelimit는 `limit` 메서드가 호출될 때마다 Upstash Redis에 HTTP 요청을 보내는 방식으로 작동합니다. 사용자의 남은 토큰/요청 수가 확인되고 업데이트됩니다. 남은 토큰에 따라 LLM을 호출하거나 벡터 저장소를 쿼리하는 것과 같은 비용이 많이 드는 작업의 실행을 중단할 수 있습니다:

```py
response = ratelimit.limit()
if response.allowed:
    execute_costly_operation()
```


`UpstashRatelimitHandler`를 사용하면 몇 분 안에 체인에 속도 제한 로직을 통합할 수 있습니다.

먼저, [Upstash 콘솔](https://console.upstash.com/login)로 이동하여 Redis 데이터베이스를 생성해야 합니다 ([문서 참조](https://upstash.com/docs/redis/overall/getstarted)). 데이터베이스를 생성한 후 환경 변수를 설정해야 합니다:

```
UPSTASH_REDIS_REST_URL="****"
UPSTASH_REDIS_REST_TOKEN="****"
```


다음으로, 다음 명령어로 Upstash Ratelimit 및 Redis 라이브러리를 설치해야 합니다:

```
pip install upstash-ratelimit upstash-redis
```


이제 체인에 속도 제한을 추가할 준비가 되었습니다!

## 요청당 속도 제한

사용자가 분당 10번 체인을 호출할 수 있도록 허용한다고 가정해 보겠습니다. 이를 달성하는 것은 간단합니다:

```python
<!--IMPORTS:[{"imported": "UpstashRatelimitError", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.upstash_ratelimit_callback.UpstashRatelimitError.html", "title": "Upstash Ratelimit Callback"}, {"imported": "UpstashRatelimitHandler", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.upstash_ratelimit_callback.UpstashRatelimitHandler.html", "title": "Upstash Ratelimit Callback"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "Upstash Ratelimit Callback"}]-->
# set env variables
import os

os.environ["UPSTASH_REDIS_REST_URL"] = "****"
os.environ["UPSTASH_REDIS_REST_TOKEN"] = "****"

from langchain_community.callbacks import UpstashRatelimitError, UpstashRatelimitHandler
from langchain_core.runnables import RunnableLambda
from upstash_ratelimit import FixedWindow, Ratelimit
from upstash_redis import Redis

# create ratelimit
ratelimit = Ratelimit(
    redis=Redis.from_env(),
    # 10 requests per window, where window size is 60 seconds:
    limiter=FixedWindow(max_requests=10, window=60),
)

# create handler
user_id = "user_id"  # should be a method which gets the user id
handler = UpstashRatelimitHandler(identifier=user_id, request_ratelimit=ratelimit)

# create mock chain
chain = RunnableLambda(str)

# invoke chain with handler:
try:
    result = chain.invoke("Hello world!", config={"callbacks": [handler]})
except UpstashRatelimitError:
    print("Handling ratelimit.", UpstashRatelimitError)
```

```output
Error in UpstashRatelimitHandler.on_chain_start callback: UpstashRatelimitError('Request limit reached!')
``````output
Handling ratelimit. <class 'langchain_community.callbacks.upstash_ratelimit_callback.UpstashRatelimitError'>
```

체인을 정의할 때 핸들러를 전달하는 대신 `invoke` 메서드에 핸들러를 전달한다는 점에 유의하세요.

`FixedWindow` 외의 속도 제한 알고리즘에 대한 내용은 [upstash-ratelimit 문서](https://github.com/upstash/ratelimit-py?tab=readme-ov-file#ratelimiting-algorithms)를 참조하세요.

파이프라인의 어떤 단계를 실행하기 전에, 속도 제한은 사용자가 요청 한도를 초과했는지 확인합니다. 그렇다면 `UpstashRatelimitError`가 발생합니다.

## 토큰당 속도 제한

또 다른 옵션은 다음을 기반으로 체인 호출에 속도 제한을 설정하는 것입니다:
1. 프롬프트의 토큰 수
2. 프롬프트와 LLM 완료의 토큰 수

이것은 체인에 LLM이 있는 경우에만 작동합니다. 또 다른 요구 사항은 사용 중인 LLM이 `LLMOutput`에서 토큰 사용량을 반환해야 한다는 것입니다.

### 작동 방식

핸들러는 LLM을 호출하기 전에 남은 토큰을 가져옵니다. 남은 토큰이 0보다 크면 LLM이 호출됩니다. 그렇지 않으면 `UpstashRatelimitError`가 발생합니다.

LLM이 호출된 후, 토큰 사용 정보는 사용자의 남은 토큰에서 차감됩니다. 이 단계에서는 오류가 발생하지 않습니다.

### 구성

첫 번째 구성의 경우, 핸들러를 다음과 같이 초기화합니다:

```python
ratelimit = Ratelimit(
    redis=Redis.from_env(),
    # 1000 tokens per window, where window size is 60 seconds:
    limiter=FixedWindow(max_requests=1000, window=60),
)

handler = UpstashRatelimitHandler(identifier=user_id, token_ratelimit=ratelimit)
```


두 번째 구성의 경우, 핸들러를 초기화하는 방법은 다음과 같습니다:

```python
ratelimit = Ratelimit(
    redis=Redis.from_env(),
    # 1000 tokens per window, where window size is 60 seconds:
    limiter=FixedWindow(max_requests=1000, window=60),
)

handler = UpstashRatelimitHandler(
    identifier=user_id,
    token_ratelimit=ratelimit,
    include_output_tokens=True,  # set to True
)
```


요청 및 토큰을 기반으로 동시에 속도 제한을 적용할 수도 있으며, `request_ratelimit` 및 `token_ratelimit` 매개변수를 모두 전달하면 됩니다.

다음은 LLM을 활용하는 체인의 예입니다:

```python
<!--IMPORTS:[{"imported": "UpstashRatelimitError", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.upstash_ratelimit_callback.UpstashRatelimitError.html", "title": "Upstash Ratelimit Callback"}, {"imported": "UpstashRatelimitHandler", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.upstash_ratelimit_callback.UpstashRatelimitHandler.html", "title": "Upstash Ratelimit Callback"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "Upstash Ratelimit Callback"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Upstash Ratelimit Callback"}]-->
# set env variables
import os

os.environ["UPSTASH_REDIS_REST_URL"] = "****"
os.environ["UPSTASH_REDIS_REST_TOKEN"] = "****"
os.environ["OPENAI_API_KEY"] = "****"

from langchain_community.callbacks import UpstashRatelimitError, UpstashRatelimitHandler
from langchain_core.runnables import RunnableLambda
from langchain_openai import ChatOpenAI
from upstash_ratelimit import FixedWindow, Ratelimit
from upstash_redis import Redis

# create ratelimit
ratelimit = Ratelimit(
    redis=Redis.from_env(),
    # 500 tokens per window, where window size is 60 seconds:
    limiter=FixedWindow(max_requests=500, window=60),
)

# create handler
user_id = "user_id"  # should be a method which gets the user id
handler = UpstashRatelimitHandler(identifier=user_id, token_ratelimit=ratelimit)

# create mock chain
as_str = RunnableLambda(str)
model = ChatOpenAI()

chain = as_str | model

# invoke chain with handler:
try:
    result = chain.invoke("Hello world!", config={"callbacks": [handler]})
except UpstashRatelimitError:
    print("Handling ratelimit.", UpstashRatelimitError)
```

```output
Error in UpstashRatelimitHandler.on_llm_start callback: UpstashRatelimitError('Token limit reached!')
``````output
Handling ratelimit. <class 'langchain_community.callbacks.upstash_ratelimit_callback.UpstashRatelimitError'>
```