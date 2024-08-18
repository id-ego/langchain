---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/upstash_redis_chat_message_history.ipynb
description: 이 문서는 Upstash Redis를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다.
---

# Upstash Redis

> [Upstash](https://upstash.com/docs/introduction)은 서버리스 `Redis`, `Kafka`, 및 `QStash` API의 제공업체입니다.

이 노트북은 `Upstash Redis`를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다.

```python
<!--IMPORTS:[{"imported": "UpstashRedisChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.upstash_redis.UpstashRedisChatMessageHistory.html", "title": "Upstash Redis"}]-->
from langchain_community.chat_message_histories import (
    UpstashRedisChatMessageHistory,
)

URL = "<UPSTASH_REDIS_REST_URL>"
TOKEN = "<UPSTASH_REDIS_REST_TOKEN>"

history = UpstashRedisChatMessageHistory(
    url=URL, token=TOKEN, ttl=10, session_id="my-test-session"
)

history.add_user_message("hello llm!")
history.add_ai_message("hello user!")
```


```python
history.messages
```