---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/browserless.ipynb
description: Browserless는 클라우드에서 헤드리스 Chrome 인스턴스를 실행할 수 있는 서비스로, 자동화를 손쉽게 관리할 수 있게
  해줍니다.
---

# 브라우저리스

브라우저리스는 클라우드에서 헤드리스 크롬 인스턴스를 실행할 수 있는 서비스입니다. 이는 자체 인프라를 관리할 필요 없이 대규모로 브라우저 기반 자동화를 실행하는 훌륭한 방법입니다.

브라우저리스를 문서 로더로 사용하려면, 이 노트북에 표시된 대로 `BrowserlessLoader` 인스턴스를 초기화하세요. 기본적으로 `BrowserlessLoader`는 페이지의 `body` 요소의 `innerText`를 반환합니다. 이를 비활성화하고 원시 HTML을 얻으려면 `text_content`를 `False`로 설정하세요.

```python
<!--IMPORTS:[{"imported": "BrowserlessLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.browserless.BrowserlessLoader.html", "title": "Browserless"}]-->
from langchain_community.document_loaders import BrowserlessLoader
```


```python
BROWSERLESS_API_TOKEN = "YOUR_BROWSERLESS_API_TOKEN"
```


```python
loader = BrowserlessLoader(
    api_token=BROWSERLESS_API_TOKEN,
    urls=[
        "https://en.wikipedia.org/wiki/Document_classification",
    ],
    text_content=True,
)

documents = loader.load()

print(documents[0].page_content[:1000])
```

```output
Jump to content
Main menu
Search
Create account
Log in
Personal tools
Toggle the table of contents
Document classification
17 languages
Article
Talk
Read
Edit
View history
Tools
From Wikipedia, the free encyclopedia

Document classification or document categorization is a problem in library science, information science and computer science. The task is to assign a document to one or more classes or categories. This may be done "manually" (or "intellectually") or algorithmically. The intellectual classification of documents has mostly been the province of library science, while the algorithmic classification of documents is mainly in information science and computer science. The problems are overlapping, however, and there is therefore interdisciplinary research on document classification.

The documents to be classified may be texts, images, music, etc. Each kind of document possesses its special classification problems. When not otherwise specified, text classification is implied.

Do
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)