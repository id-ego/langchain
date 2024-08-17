---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/roam/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/roam.ipynb
---

# Roam

>[ROAM](https://roamresearch.com/) is a note-taking tool for networked thought, designed to create a personal knowledge base.

This notebook covers how to load documents from a Roam database. This takes a lot of inspiration from the example repo [here](https://github.com/JimmyLv/roam-qa).

## 🧑 Instructions for ingesting your own dataset

Export your dataset from Roam Research. You can do this by clicking on the three dots in the upper right hand corner and then clicking `Export`.

When exporting, make sure to select the `Markdown & CSV` format option.

This will produce a `.zip` file in your Downloads folder. Move the `.zip` file into this repository.

Run the following command to unzip the zip file (replace the `Export...` with your own file name as needed).

```shell
unzip Roam-Export-1675782732639.zip -d Roam_DB
```



```python
<!--IMPORTS:[{"imported": "RoamLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.roam.RoamLoader.html", "title": "Roam"}]-->
from langchain_community.document_loaders import RoamLoader
```


```python
loader = RoamLoader("Roam_DB")
```


```python
docs = loader.load()
```


## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)