---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/airtable/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/airtable.ipynb
---

# Airtable

```python
%pip install --upgrade --quiet  pyairtable
```

```python
<!--IMPORTS:[{"imported": "AirtableLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.airtable.AirtableLoader.html", "title": "Airtable"}]-->
from langchain_community.document_loaders import AirtableLoader
```

* Get your API key [here](https://support.airtable.com/docs/creating-and-using-api-keys-and-access-tokens).
* Get ID of your base [here](https://airtable.com/developers/web/api/introduction).
* Get your table ID from the table url as shown [here](https://www.highviewapps.com/kb/where-can-i-find-the-airtable-base-id-and-table-id/#:~:text=Both%20the%20Airtable%20Base%20ID,URL%20that%20begins%20with%20tbl).

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

Returns each table row as `dict`.

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

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)