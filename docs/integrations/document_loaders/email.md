---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/email.ipynb
description: 이 문서는 이메일(.eml) 및 Microsoft Outlook(.msg) 파일을 로드하는 방법과 Unstructured 사용법을
  설명합니다.
---

# 이메일

이 노트북은 이메일(`.eml`) 또는 `Microsoft Outlook`(`.msg`) 파일을 로드하는 방법을 보여줍니다.

Unstructured를 로컬로 설정하는 방법에 대한 추가 지침은 [이 가이드](/docs/integrations/providers/unstructured/)를 참조하십시오. 여기에는 필요한 시스템 종속성 설정이 포함됩니다.

## Unstructured 사용하기

```python
%pip install --upgrade --quiet unstructured
```


```python
<!--IMPORTS:[{"imported": "UnstructuredEmailLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.email.UnstructuredEmailLoader.html", "title": "Email"}]-->
from langchain_community.document_loaders import UnstructuredEmailLoader

loader = UnstructuredEmailLoader("./example_data/fake-email.eml")

data = loader.load()

data
```


```output
[Document(page_content='This is a test email to use for unit tests.\n\nImportant points:\n\nRoses are red\n\nViolets are blue', metadata={'source': './example_data/fake-email.eml'})]
```


### 요소 유지

언더 후드에서 Unstructured는 서로 다른 텍스트 조각에 대해 서로 다른 "요소"를 생성합니다. 기본적으로 우리는 그것들을 결합하지만, `mode="elements"`를 지정하여 쉽게 그 분리를 유지할 수 있습니다.

```python
loader = UnstructuredEmailLoader("example_data/fake-email.eml", mode="elements")

data = loader.load()

data[0]
```


```output
Document(page_content='This is a test email to use for unit tests.', metadata={'source': 'example_data/fake-email.eml', 'file_directory': 'example_data', 'filename': 'fake-email.eml', 'last_modified': '2022-12-16T17:04:16-05:00', 'sent_from': ['Matthew Robinson <mrobinson@unstructured.io>'], 'sent_to': ['Matthew Robinson <mrobinson@unstructured.io>'], 'subject': 'Test Email', 'languages': ['eng'], 'filetype': 'message/rfc822', 'category': 'NarrativeText'})
```


### 첨부 파일 처리

생성자에서 `process_attachments=True`를 설정하여 `UnstructuredEmailLoader`로 첨부 파일을 처리할 수 있습니다. 기본적으로 첨부 파일은 `unstructured`의 `partition` 함수를 사용하여 분할됩니다. 다른 분할 함수를 사용하려면 함수를 `attachment_partitioner` kwarg로 전달하면 됩니다.

```python
loader = UnstructuredEmailLoader(
    "example_data/fake-email.eml",
    mode="elements",
    process_attachments=True,
)

data = loader.load()

data[0]
```


```output
Document(page_content='This is a test email to use for unit tests.', metadata={'source': 'example_data/fake-email.eml', 'file_directory': 'example_data', 'filename': 'fake-email.eml', 'last_modified': '2022-12-16T17:04:16-05:00', 'sent_from': ['Matthew Robinson <mrobinson@unstructured.io>'], 'sent_to': ['Matthew Robinson <mrobinson@unstructured.io>'], 'subject': 'Test Email', 'languages': ['eng'], 'filetype': 'message/rfc822', 'category': 'NarrativeText'})
```


## OutlookMessageLoader 사용하기

```python
%pip install --upgrade --quiet extract_msg
```


```python
<!--IMPORTS:[{"imported": "OutlookMessageLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.email.OutlookMessageLoader.html", "title": "Email"}]-->
from langchain_community.document_loaders import OutlookMessageLoader

loader = OutlookMessageLoader("example_data/fake-email.msg")

data = loader.load()

data[0]
```


```output
Document(page_content='This is a test email to experiment with the MS Outlook MSG Extractor\r\n\r\n\r\n-- \r\n\r\n\r\nKind regards\r\n\r\n\r\n\r\n\r\nBrian Zhou\r\n\r\n', metadata={'source': 'example_data/fake-email.msg', 'subject': 'Test for TIF files', 'sender': 'Brian Zhou <brizhou@gmail.com>', 'date': datetime.datetime(2013, 11, 18, 0, 26, 24, tzinfo=zoneinfo.ZoneInfo(key='America/Los_Angeles'))})
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)