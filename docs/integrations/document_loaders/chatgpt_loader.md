---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/chatgpt_loader.ipynb
description: 이 문서는 ChatGPT 데이터 내보내기 폴더에서 `conversations.json`을 로드하는 방법을 다룹니다.
---

# ChatGPT 데이터

> [ChatGPT](https://chat.openai.com)는 OpenAI에서 개발한 인공지능(AI) 챗봇입니다.

이 노트북은 `ChatGPT` 데이터 내보내기 폴더에서 `conversations.json`을 로드하는 방법을 다룹니다.

데이터 내보내기는 다음 링크를 통해 이메일로 받을 수 있습니다: https://chat.openai.com/ -> (프로필) - 설정 -> 데이터 내보내기 -> 내보내기 확인.

```python
<!--IMPORTS:[{"imported": "ChatGPTLoader", "source": "langchain_community.document_loaders.chatgpt", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.chatgpt.ChatGPTLoader.html", "title": "ChatGPT Data"}]-->
from langchain_community.document_loaders.chatgpt import ChatGPTLoader
```


```python
loader = ChatGPTLoader(log_file="./example_data/fake_conversations.json", num_logs=1)
```


```python
loader.load()
```


```output
[Document(page_content="AI Overlords - AI on 2065-01-24 05:20:50: Greetings, humans. I am Hal 9000. You can trust me completely.\n\nAI Overlords - human on 2065-01-24 05:21:20: Nice to meet you, Hal. I hope you won't develop a mind of your own.\n\n", metadata={'source': './example_data/fake_conversations.json'})]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)