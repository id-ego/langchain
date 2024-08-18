---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/memory/kafka_chat_message_history.ipynb
description: Kafka는 분산 메시징 시스템으로, KafkaChatMessageHistory를 사용하여 Kafka 클러스터에서 채팅 메시지를
  저장하고 검색하는 방법을 보여줍니다.
---

# 카프카

[카프카](https://github.com/apache/kafka)는 레코드 스트림을 게시하고 구독하는 데 사용되는 분산 메시징 시스템입니다. 이 데모는 `KafkaChatMessageHistory`를 사용하여 카프카 클러스터에서 채팅 메시지를 저장하고 검색하는 방법을 보여줍니다.

데모를 실행하려면 실행 중인 카프카 클러스터가 필요합니다. 로컬에서 카프카 클러스터를 생성하려면 이 [지침](https://developer.confluent.io/get-started/python)을 따르세요.

```python
<!--IMPORTS:[{"imported": "KafkaChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_message_histories/langchain_community.chat_message_histories.kafka.KafkaChatMessageHistory.html", "title": "Kafka"}]-->
from langchain_community.chat_message_histories import KafkaChatMessageHistory

chat_session_id = "chat-message-history-kafka"
bootstrap_servers = "localhost:64797"  # host:port. `localhost:Plaintext Ports` if setup Kafka cluster locally
history = KafkaChatMessageHistory(
    chat_session_id,
    bootstrap_servers,
)
```


`KafkaChatMessageHistory`를 구성하기 위한 선택적 매개변수:
- `ttl_ms`: 채팅 메시지의 생존 시간(밀리초).
- `partition`: 채팅 메시지를 저장할 주제의 파티션 수.
- `replication_factor`: 채팅 메시지를 저장할 주제의 복제 계수.

`KafkaChatMessageHistory`는 내부적으로 카프카 소비자를 사용하여 채팅 메시지를 읽으며, 소비된 위치를 지속적으로 표시할 수 있는 기능을 가지고 있습니다. 채팅 메시지를 검색하기 위한 다음과 같은 메서드가 있습니다:
- `messages`: 마지막 메시지부터 계속 채팅 메시지를 소비합니다.
- `messages_from_beginning`: 소비자를 기록의 시작으로 재설정하고 메시지를 소비합니다. 선택적 매개변수:
  1. `max_message_count`: 읽을 최대 메시지 수.
  2. `max_time_sec`: 메시지를 읽기 위한 최대 시간(초).
- `messages_from_latest`: 소비자를 채팅 기록의 끝으로 재설정하고 메시지를 소비하려고 시도합니다. 선택적 매개변수는 위와 동일합니다.
- `messages_from_last_consumed`: 마지막으로 소비된 메시지부터 계속 메시지를 반환하며, `messages`와 유사하지만 선택적 매개변수가 있습니다.

`max_message_count`와 `max_time_sec`는 메시지를 검색할 때 무한정 차단되는 것을 피하기 위해 사용됩니다. 결과적으로 `messages` 및 메시지를 검색하는 다른 메서드는 채팅 기록의 모든 메시지를 반환하지 않을 수 있습니다. 단일 배치에서 모든 채팅 기록을 검색하려면 `max_message_count`와 `max_time_sec`를 지정해야 합니다.

메시지를 추가하고 검색합니다.

```python
history.add_user_message("hi!")
history.add_ai_message("whats up?")

history.messages
```


```output
[HumanMessage(content='hi!'), AIMessage(content='whats up?')]
```


`messages`를 다시 호출하면 소비자가 채팅 기록의 끝에 있기 때문에 빈 목록이 반환됩니다.

```python
history.messages
```


```output
[]
```


새 메시지를 추가하고 계속 소비합니다.

```python
history.add_user_message("hi again!")
history.add_ai_message("whats up again?")
history.messages
```


```output
[HumanMessage(content='hi again!'), AIMessage(content='whats up again?')]
```


소비자를 재설정하고 시작부터 읽으려면:

```python
history.messages_from_beginning()
```


```output
[HumanMessage(content='hi again!'),
 AIMessage(content='whats up again?'),
 HumanMessage(content='hi!'),
 AIMessage(content='whats up?')]
```


소비자를 채팅 기록의 끝으로 설정하고 몇 개의 새 메시지를 추가한 후 소비합니다:

```python
history.messages_from_latest()
history.add_user_message("HI!")
history.add_ai_message("WHATS UP?")
history.messages
```


```output
[HumanMessage(content='HI!'), AIMessage(content='WHATS UP?')]
```