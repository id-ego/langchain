---
canonical: https://python.langchain.com/v0.2/docs/integrations/memory/upstash_redis_chat_message_history/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/upstash_redis_chat_message_history.ipynb
---

# Upstash Redis

>[Upstash](https://upstash.com/docs/introduction) is a provider of the serverless `Redis`, `Kafka`, and `QStash` APIs.

This notebook goes over how to use `Upstash Redis` to store chat message history.


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