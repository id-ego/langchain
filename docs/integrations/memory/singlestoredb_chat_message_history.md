---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/singlestoredb_chat_message_history.ipynb
description: 이 문서는 SingleStoreDB를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다.
---

# SingleStoreDB

이 노트북은 SingleStoreDB를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다.

```python
<!--IMPORTS:[{"imported": "SingleStoreDBChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.singlestoredb.SingleStoreDBChatMessageHistory.html", "title": "SingleStoreDB"}]-->
from langchain_community.chat_message_histories import (
    SingleStoreDBChatMessageHistory,
)

history = SingleStoreDBChatMessageHistory(
    session_id="foo", host="root:pass@localhost:3306/db"
)

history.add_user_message("hi!")

history.add_ai_message("whats up?")
```


```python
history.messages
```