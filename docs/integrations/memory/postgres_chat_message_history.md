---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/postgres_chat_message_history.ipynb
description: PostgreSQL을 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명하는 문서입니다.
---

# Postgres

> [PostgreSQL](https://en.wikipedia.org/wiki/PostgreSQL)는 `Postgres`로도 알려져 있으며, 확장성과 SQL 준수를 강조하는 무료 오픈 소스 관계형 데이터베이스 관리 시스템(RDBMS)입니다.

이 노트북에서는 Postgres를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다.

```python
<!--IMPORTS:[{"imported": "PostgresChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.postgres.PostgresChatMessageHistory.html", "title": "Postgres"}]-->
from langchain_community.chat_message_histories import (
    PostgresChatMessageHistory,
)

history = PostgresChatMessageHistory(
    connection_string="postgresql://postgres:mypassword@localhost/chat_history",
    session_id="foo",
)

history.add_user_message("hi!")

history.add_ai_message("whats up?")
```


```python
history.messages
```