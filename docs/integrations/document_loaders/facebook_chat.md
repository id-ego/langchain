---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/facebook_chat.ipynb
description: 이 문서는 Facebook 채팅 데이터를 LangChain에 적합한 형식으로 로드하는 방법을 다룹니다.
---

# 페이스북 채팅

> [메신저](https://en.wikipedia.org/wiki/Messenger_(software))는 `Meta Platforms`에서 개발한 미국의 독점 인스턴트 메시징 앱 및 플랫폼입니다. 원래 2008년에 `Facebook Chat`으로 개발되었으며, 2010년에 회사는 메시징 서비스를 개편했습니다.

이 노트북은 [페이스북 채팅](https://www.facebook.com/business/help/1646890868956360)에서 데이터를 로드하여 LangChain에 삽입할 수 있는 형식으로 변환하는 방법을 다룹니다.

```python
# pip install pandas
```


```python
<!--IMPORTS:[{"imported": "FacebookChatLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.facebook_chat.FacebookChatLoader.html", "title": "Facebook Chat"}]-->
from langchain_community.document_loaders import FacebookChatLoader
```


```python
loader = FacebookChatLoader("example_data/facebook_chat.json")
```


```python
loader.load()
```


```output
[Document(page_content='User 2 on 2023-02-05 03:46:11: Bye!\n\nUser 1 on 2023-02-05 03:43:55: Oh no worries! Bye\n\nUser 2 on 2023-02-05 03:24:37: No Im sorry it was my mistake, the blue one is not for sale\n\nUser 1 on 2023-02-05 03:05:40: I thought you were selling the blue one!\n\nUser 1 on 2023-02-05 03:05:09: Im not interested in this bag. Im interested in the blue one!\n\nUser 2 on 2023-02-05 03:04:28: Here is $129\n\nUser 2 on 2023-02-05 03:04:05: Online is at least $100\n\nUser 1 on 2023-02-05 02:59:59: How much do you want?\n\nUser 2 on 2023-02-04 22:17:56: Goodmorning! $50 is too low.\n\nUser 1 on 2023-02-04 14:17:02: Hi! Im interested in your bag. Im offering $50. Let me know if you are interested. Thanks!\n\n', metadata={'source': 'example_data/facebook_chat.json'})]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)