---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/neo4j_chat_message_history.ipynb
description: 이 문서는 Neo4j를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다. 그래프 데이터베이스의 효율성을 강조합니다.
---

# Neo4j

[Neo4j](https://en.wikipedia.org/wiki/Neo4j)는 고도로 연결된 데이터를 효율적으로 관리하는 것으로 유명한 오픈 소스 그래프 데이터베이스 관리 시스템입니다. 데이터를 테이블에 저장하는 전통적인 데이터베이스와 달리, Neo4j는 노드, 엣지 및 속성을 사용하여 데이터를 표현하고 저장하는 그래프 구조를 사용합니다. 이 설계는 복잡한 데이터 관계에 대한 고성능 쿼리를 가능하게 합니다.

이 노트북은 `Neo4j`를 사용하여 채팅 메시지 기록을 저장하는 방법에 대해 설명합니다.

```python
<!--IMPORTS:[{"imported": "Neo4jChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.neo4j.Neo4jChatMessageHistory.html", "title": "Neo4j"}]-->
from langchain_community.chat_message_histories import Neo4jChatMessageHistory

history = Neo4jChatMessageHistory(
    url="bolt://localhost:7687",
    username="neo4j",
    password="password",
    session_id="session_id_1",
)

history.add_user_message("hi!")

history.add_ai_message("whats up?")
```


```python
history.messages
```