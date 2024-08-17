---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/joplin/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/joplin.ipynb
---

# Joplin

>[Joplin](https://joplinapp.org/) is an open-source note-taking app. Capture your thoughts and securely access them from any device.

This notebook covers how to load documents from a `Joplin` database.

`Joplin` has a [REST API](https://joplinapp.org/api/references/rest_api/) for accessing its local database. This loader uses the API to retrieve all notes in the database and their metadata. This requires an access token that can be obtained from the app by following these steps:

1. Open the `Joplin` app. The app must stay open while the documents are being loaded.
2. Go to settings / options and select "Web Clipper".
3. Make sure that the Web Clipper service is enabled.
4. Under "Advanced Options", copy the authorization token.

You may either initialize the loader directly with the access token, or store it in the environment variable JOPLIN_ACCESS_TOKEN.

An alternative to this approach is to export the `Joplin`'s note database to Markdown files (optionally, with Front Matter metadata) and use a Markdown loader, such as ObsidianLoader, to load them.


```python
<!--IMPORTS:[{"imported": "JoplinLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.joplin.JoplinLoader.html", "title": "Joplin"}]-->
from langchain_community.document_loaders import JoplinLoader
```


```python
loader = JoplinLoader(access_token="<access-token>")
```


```python
docs = loader.load()
```


## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)