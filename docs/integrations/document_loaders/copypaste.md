---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/copypaste.ipynb
description: 이 문서에서는 복사하여 붙여넣기를 통해 문서 객체를 로드하는 방법과 메타데이터 추가 방법을 설명합니다.
---

# 복사 붙여넣기

이 노트북은 복사하고 붙여넣고 싶은 것에서 문서 객체를 로드하는 방법을 다룹니다. 이 경우, DocumentLoader를 사용할 필요 없이 문서를 직접 구성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Copy Paste"}]-->
from langchain_core.documents import Document
```


```python
text = "..... put the text you copy pasted here......"
```


```python
doc = Document(page_content=text)
```


## 메타데이터
이 텍스트 조각을 어디서 가져왔는지에 대한 메타데이터를 추가하고 싶다면, 메타데이터 키를 사용하여 쉽게 추가할 수 있습니다.

```python
metadata = {"source": "internet", "date": "Friday"}
```


```python
doc = Document(page_content=text, metadata=metadata)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)