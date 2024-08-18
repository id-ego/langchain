---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/airtable.ipynb
description: Airtable API를 사용하여 데이터베이스와 상호작용하는 방법에 대한 가이드입니다. API 키 및 ID를 얻는 방법도 포함되어
  있습니다.
---

# Airtable

```python
%pip install --upgrade --quiet  pyairtable
```


```python
<!--IMPORTS:[{"imported": "AirtableLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.airtable.AirtableLoader.html", "title": "Airtable"}]-->
from langchain_community.document_loaders import AirtableLoader
```


* API 키를 [여기](https://support.airtable.com/docs/creating-and-using-api-keys-and-access-tokens)에서 가져오세요.
* 베이스 ID를 [여기](https://airtable.com/developers/web/api/introduction)에서 확인하세요.
* 테이블 URL에서 테이블 ID를 [여기](https://www.highviewapps.com/kb/where-can-i-find-the-airtable-base-id-and-table-id/#:~:text=Both%20the%20Airtable%20Base%20ID,URL%20that%20begins%20with%20tbl)와 같이 가져오세요.

```python
api_key = "xxx"
base_id = "xxx"
table_id = "xxx"
view = "xxx"  # optional
```


```python
loader = AirtableLoader(api_key, table_id, base_id, view=view)
docs = loader.load()
```


각 테이블 행을 `dict`로 반환합니다.

```python
len(docs)
```


```output
3
```


```python
eval(docs[0].page_content)
```


```output
{'id': 'recF3GbGZCuh9sXIQ',
 'createdTime': '2023-06-09T04:47:21.000Z',
 'fields': {'Priority': 'High',
  'Status': 'In progress',
  'Name': 'Document Splitters'}}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)