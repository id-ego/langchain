---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/unstructured_markdown/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/unstructured_markdown.ipynb
---

# UnstructuredMarkdownLoader

This notebook provides a quick overview for getting started with UnstructuredMarkdown [document loader](https://python.langchain.com/v0.2/docs/concepts/#document-loaders). For detailed documentation of all __ModuleName__Loader features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html).

## Overview
### Integration details

| Class | Package | Local | Serializable | [JS support](https://js.langchain.com/v0.2/docs/integrations/document_loaders/file_loaders/unstructured/)|
| :--- | :--- | :---: | :---: |  :---: |
| [UnstructuredMarkdownLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ❌ | ❌ | ✅ | 
### Loader features
| Source | Document Lazy Loading | Native Async Support
| :---: | :---: | :---: |
| UnstructuredMarkdownLoader | ✅ | ❌ | 

## Setup

To access UnstructuredMarkdownLoader document loader you'll need to install the `langchain-community` integration package and the `unstructured` python package.

### Credentials

No credentials are needed to use this loader.

If you want to get automated best in-class tracing of your model calls you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

### Installation

Install **langchain_community** and **unstructured**

```python
%pip install -qU langchain_community unstructured
```

## Initialization

Now we can instantiate our model object and load documents. 

You can run the loader in one of two modes: "single" and "elements". If you use "single" mode, the document will be returned as a single `Document` object. If you use "elements" mode, the unstructured library will split the document into elements such as `Title` and `NarrativeText`. You can pass in additional `unstructured` kwargs after mode to apply different `unstructured` settings.

```python
<!--IMPORTS:[{"imported": "UnstructuredMarkdownLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html", "title": "UnstructuredMarkdownLoader"}]-->
from langchain_community.document_loaders import UnstructuredMarkdownLoader

loader = UnstructuredMarkdownLoader(
    "./example_data/example.md",
    mode="single",
    strategy="fast",
)
```

## Load

```python
docs = loader.load()
docs[0]
```

```output
Document(metadata={'source': './example_data/example.md'}, page_content='Sample Markdown Document\n\nIntroduction\n\nWelcome to this sample Markdown document. Markdown is a lightweight markup language used for formatting text. It\'s widely used for documentation, readme files, and more.\n\nFeatures\n\nHeaders\n\nMarkdown supports multiple levels of headers:\n\nHeader 1: # Header 1\n\nHeader 2: ## Header 2\n\nHeader 3: ### Header 3\n\nLists\n\nUnordered List\n\nItem 1\n\nItem 2\n\nSubitem 2.1\n\nSubitem 2.2\n\nOrdered List\n\nFirst item\n\nSecond item\n\nThird item\n\nLinks\n\nOpenAI is an AI research organization.\n\nImages\n\nHere\'s an example image:\n\nCode\n\nInline Code\n\nUse code for inline code snippets.\n\nCode Block\n\n```python def greet(name): return f"Hello, {name}!"\n\nprint(greet("World")) ```')
```

```python
print(docs[0].metadata)
```
```output
{'source': './example_data/example.md'}
```
## Lazy Load

```python
page = []
for doc in loader.lazy_load():
    page.append(doc)
    if len(page) >= 10:
        # do some paged operation, e.g.
        # index.upsert(page)

        page = []
page[0]
```

```output
Document(metadata={'source': './example_data/example.md', 'link_texts': ['OpenAI'], 'link_urls': ['https://www.openai.com'], 'last_modified': '2024-08-14T15:04:18', 'languages': ['eng'], 'parent_id': 'de1f74bf226224377ab4d8b54f215bb9', 'filetype': 'text/markdown', 'file_directory': './example_data', 'filename': 'example.md', 'category': 'NarrativeText', 'element_id': '898a542a261f7dc65e0072d1e847d535'}, page_content='OpenAI is an AI research organization.')
```

## Load Elements

In this example we will load in the `elements` mode, which will return a list of the different elements in the markdown document:

```python
<!--IMPORTS:[{"imported": "UnstructuredMarkdownLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html", "title": "UnstructuredMarkdownLoader"}]-->
from langchain_community.document_loaders import UnstructuredMarkdownLoader

loader = UnstructuredMarkdownLoader(
    "./example_data/example.md",
    mode="elements",
    strategy="fast",
)

docs = loader.load()
len(docs)
```

```output
29
```

As you see there are 29 elements that were pulled from the `example.md` file. The first element is the title of the document as expected:

```python
docs[0].page_content
```

```output
'Sample Markdown Document'
```

## API reference

For detailed documentation of all UnstructuredMarkdownLoader features and configurations head to the API reference: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)