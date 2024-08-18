---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/telegram.ipynb
description: 텔레그램에서 데이터를 로드하여 LangChain에 적합한 형식으로 변환하는 방법을 다룬 문서입니다.
---

# 텔레그램

> [텔레그램 메신저](https://web.telegram.org/a/)는 전 세계에서 접근 가능한 프리미엄, 크로스 플랫폼, 암호화된, 클라우드 기반 및 중앙 집중식 인스턴트 메시징 서비스입니다. 이 애플리케이션은 선택적으로 종단 간 암호화된 채팅 및 영상 통화, VoIP, 파일 공유 및 여러 가지 다른 기능도 제공합니다.

이 노트북은 `텔레그램`에서 데이터를 로드하여 LangChain에 삽입할 수 있는 형식으로 변환하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "TelegramChatApiLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.telegram.TelegramChatApiLoader.html", "title": "Telegram"}, {"imported": "TelegramChatFileLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.telegram.TelegramChatFileLoader.html", "title": "Telegram"}]-->
from langchain_community.document_loaders import (
    TelegramChatApiLoader,
    TelegramChatFileLoader,
)
```


```python
loader = TelegramChatFileLoader("example_data/telegram.json")
```


```python
loader.load()
```


```output
[Document(page_content="Henry on 2020-01-01T00:00:02: It's 2020...\n\nHenry on 2020-01-01T00:00:04: Fireworks!\n\nGrace ðŸ§¤ ðŸ\x8d’ on 2020-01-01T00:00:05: You're a minute late!\n\n", metadata={'source': 'example_data/telegram.json'})]
```


`TelegramChatApiLoader`는 텔레그램의 지정된 채팅에서 데이터를 직접 로드합니다. 데이터를 내보내려면 텔레그램 계정을 인증해야 합니다.

API_HASH 및 API_ID는 https://my.telegram.org/auth?to=apps 에서 얻을 수 있습니다.

chat_entity – 채널의 [엔티티](https://docs.telethon.dev/en/stable/concepts/entities.html?highlight=Entity#what-is-an-entity)로 추천됩니다.

```python
loader = TelegramChatApiLoader(
    chat_entity="<CHAT_URL>",  # recommended to use Entity here
    api_hash="<API HASH >",
    api_id="<API_ID>",
    username="",  # needed only for caching the session.
)
```


```python
loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)