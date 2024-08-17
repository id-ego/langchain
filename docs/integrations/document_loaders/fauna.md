---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/fauna/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/fauna.ipynb
---

# Fauna

> [Fauna](https://fauna.com/) is a Document Database.

Query `Fauna` documents

```python
%pip install --upgrade --quiet  fauna
```

## Query data example

```python
<!--IMPORTS:[{"imported": "FaunaLoader", "source": "langchain_community.document_loaders.fauna", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.fauna.FaunaLoader.html", "title": "Fauna"}]-->
from langchain_community.document_loaders.fauna import FaunaLoader

secret = "<enter-valid-fauna-secret>"
query = "Item.all()"  # Fauna query. Assumes that the collection is called "Item"
field = "text"  # The field that contains the page content. Assumes that the field is called "text"

loader = FaunaLoader(query, field, secret)
docs = loader.lazy_load()

for value in docs:
    print(value)
```

### Query with Pagination
You get a `after` value if there are more data. You can get values after the curcor by passing in the `after` string in query. 

To learn more following [this link](https://fqlx-beta--fauna-docs.netlify.app/fqlx/beta/reference/schema_entities/set/static-paginate)

```python
query = """
Item.paginate("hs+DzoPOg ... aY1hOohozrV7A")
Item.all()
"""
loader = FaunaLoader(query, field, secret)
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)