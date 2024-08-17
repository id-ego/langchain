---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/telegram/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/telegram.ipynb
---

# Telegram

>[Telegram Messenger](https://web.telegram.org/a/) is a globally accessible freemium, cross-platform, encrypted, cloud-based and centralized instant messaging service. The application also provides optional end-to-end encrypted chats and video calling, VoIP, file sharing and several other features.

This notebook covers how to load data from `Telegram` into a format that can be ingested into LangChain.


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


`TelegramChatApiLoader` loads data directly from any specified chat from Telegram. In order to export the data, you will need to authenticate your Telegram account. 

You can get the API_HASH and API_ID from https://my.telegram.org/auth?to=apps

chat_entity – recommended to be the [entity](https://docs.telethon.dev/en/stable/concepts/entities.html?highlight=Entity#what-is-an-entity) of a channel.




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


## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)