---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/lakefs/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/lakefs.ipynb
---

# lakeFS

>[lakeFS](https://docs.lakefs.io/) provides scalable version control over the data lake, and uses Git-like semantics to create and access those versions.

This notebooks covers how to load document objects from a `lakeFS` path (whether it's an object or a prefix).


## Initializing the lakeFS loader

Replace `ENDPOINT`, `LAKEFS_ACCESS_KEY`, and `LAKEFS_SECRET_KEY` values with your own.


```python
<!--IMPORTS:[{"imported": "LakeFSLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.lakefs.LakeFSLoader.html", "title": "lakeFS"}]-->
from langchain_community.document_loaders import LakeFSLoader
```


```python
ENDPOINT = ""
LAKEFS_ACCESS_KEY = ""
LAKEFS_SECRET_KEY = ""

lakefs_loader = LakeFSLoader(
    lakefs_access_key=LAKEFS_ACCESS_KEY,
    lakefs_secret_key=LAKEFS_SECRET_KEY,
    lakefs_endpoint=ENDPOINT,
)
```

## Specifying a path
You can specify a prefix or a complete object path to control which files to load.

Specify the repository, reference (branch, commit id, or tag), and path in the corresponding `REPO`, `REF`, and `PATH` to load the documents from:


```python
REPO = ""
REF = ""
PATH = ""

lakefs_loader.set_repo(REPO)
lakefs_loader.set_ref(REF)
lakefs_loader.set_path(PATH)

docs = lakefs_loader.load()
docs
```


## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)