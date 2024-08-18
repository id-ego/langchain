---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/whatsapp_chat.ipynb
description: 이 문서는 WhatsApp 채팅 데이터를 LangChain에 적합한 형식으로 로드하는 방법을 다룹니다.
---

# WhatsApp 채팅

> [WhatsApp](https://www.whatsapp.com/) (또는 `WhatsApp Messenger`)는 무료 소프트웨어, 크로스 플랫폼, 중앙 집중식 인스턴트 메시징(IM) 및 음성 통화(VoIP) 서비스입니다. 사용자는 텍스트 및 음성 메시지를 보내고, 음성 및 영상 통화를 하며, 이미지, 문서, 사용자 위치 및 기타 콘텐츠를 공유할 수 있습니다.

이 노트북은 `WhatsApp Chats`에서 LangChain에 수집할 수 있는 형식으로 데이터를 로드하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "WhatsAppChatLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.whatsapp_chat.WhatsAppChatLoader.html", "title": "WhatsApp Chat"}]-->
from langchain_community.document_loaders import WhatsAppChatLoader
```


```python
loader = WhatsAppChatLoader("example_data/whatsapp_chat.txt")
```


```python
loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)