---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/jupyter_notebook/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/jupyter_notebook.ipynb
---

# Jupyter Notebook

> [Jupyter Notebook](https://en.wikipedia.org/wiki/Project_Jupyter#Applications) (formerly `IPython Notebook`) is a web-based interactive computational environment for creating notebook documents.

This notebook covers how to load data from a `Jupyter notebook (.ipynb)` into a format suitable by LangChain.

```python
<!--IMPORTS:[{"imported": "NotebookLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.notebook.NotebookLoader.html", "title": "Jupyter Notebook"}]-->
from langchain_community.document_loaders import NotebookLoader
```

```python
loader = NotebookLoader(
    "example_data/notebook.ipynb",
    include_outputs=True,
    max_output_length=20,
    remove_newline=True,
)
```

`NotebookLoader.load()` loads the `.ipynb` notebook file into a `Document` object.

**Parameters**:

* `include_outputs` (bool): whether to include cell outputs in the resulting document (default is False).
* `max_output_length` (int): the maximum number of characters to include from each cell output (default is 10).
* `remove_newline` (bool): whether to remove newline characters from the cell sources and outputs (default is False).
* `traceback` (bool): whether to include full traceback (default is False).

```python
loader.load()
```

```output
[Document(page_content='\'markdown\' cell: \'[\'# Notebook\', \'\', \'This notebook covers how to load data from an .html notebook into a format suitable by LangChain.\']\'\n\n \'code\' cell: \'[\'from langchain_community.document_loaders import NotebookLoader\']\'\n\n \'code\' cell: \'[\'loader = NotebookLoader("example_data/notebook.html")\']\'\n\n \'markdown\' cell: \'[\'`NotebookLoader.load()` loads the `.html` notebook file into a `Document` object.\', \'\', \'**Parameters**:\', \'\', \'* `include_outputs` (bool): whether to include cell outputs in the resulting document (default is False).\', \'* `max_output_length` (int): the maximum number of characters to include from each cell output (default is 10).\', \'* `remove_newline` (bool): whether to remove newline characters from the cell sources and outputs (default is False).\', \'* `traceback` (bool): whether to include full traceback (default is False).\']\'\n\n \'code\' cell: \'[\'loader.load(include_outputs=True, max_output_length=20, remove_newline=True)\']\'\n\n', metadata={'source': 'example_data/notebook.html'})]
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)