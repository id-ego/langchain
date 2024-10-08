---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/recursive_url/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/recursive_url.ipynb
---

# Recursive URL

The `RecursiveUrlLoader` lets you recursively scrape all child links from a root URL and parse them into Documents.

## Overview
### Integration details

| Class | Package | Local | Serializable | [JS support](https://js.langchain.com/v0.2/docs/integrations/document_loaders/web_loaders/recursive_url_loader/)|
| :--- | :--- | :---: | :---: |  :---: |
| [RecursiveUrlLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.recursive_url_loader.RecursiveUrlLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ✅ | 
### Loader features
| Source | Document Lazy Loading | Native Async Support
| :---: | :---: | :---: |
| RecursiveUrlLoader | ✅ | ❌ | 

## Setup

### Credentials

No credentials are required to use the `RecursiveUrlLoader`.

### Installation

The `RecursiveUrlLoader` lives in the `langchain-community` package. There's no other required packages, though you will get richer default Document metadata if you have ``beautifulsoup4` installed as well.

```python
%pip install -qU langchain-community beautifulsoup4
```

## Instantiation

Now we can instantiate our document loader object and load Documents:

```python
<!--IMPORTS:[{"imported": "RecursiveUrlLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.recursive_url_loader.RecursiveUrlLoader.html", "title": "Recursive URL"}]-->
from langchain_community.document_loaders import RecursiveUrlLoader

loader = RecursiveUrlLoader(
    "https://docs.python.org/3.9/",
    # max_depth=2,
    # use_async=False,
    # extractor=None,
    # metadata_extractor=None,
    # exclude_dirs=(),
    # timeout=10,
    # check_response_status=True,
    # continue_on_failure=True,
    # prevent_outside=True,
    # base_url=None,
    # ...
)
```

## Load

Use `.load()` to synchronously load into memory all Documents, with one
Document per visited URL. Starting from the initial URL, we recurse through
all linked URLs up to the specified max_depth.

Let's run through a basic example of how to use the `RecursiveUrlLoader` on the [Python 3.9 Documentation](https://docs.python.org/3.9/).

```python
docs = loader.load()
docs[0].metadata
```
```output
/Users/bagatur/.pyenv/versions/3.9.1/lib/python3.9/html/parser.py:170: XMLParsedAsHTMLWarning: It looks like you're parsing an XML document using an HTML parser. If this really is an HTML document (maybe it's XHTML?), you can ignore or filter this warning. If it's XML, you should know that using an XML parser will be more reliable. To parse this document as XML, make sure you have the lxml package installed, and pass the keyword argument `features="xml"` into the BeautifulSoup constructor.
  k = self.parse_starttag(i)
```

```output
{'source': 'https://docs.python.org/3.9/',
 'content_type': 'text/html',
 'title': '3.9.19 Documentation',
 'language': None}
```

Great! The first document looks like the root page we started from. Let's look at the metadata of the next document

```python
docs[1].metadata
```

```output
{'source': 'https://docs.python.org/3.9/using/index.html',
 'content_type': 'text/html',
 'title': 'Python Setup and Usage — Python 3.9.19 documentation',
 'language': None}
```

That url looks like a child of our root page, which is great! Let's move on from metadata to examine the content of one of our documents

```python
print(docs[0].page_content[:300])
```
```output

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta charset="utf-8" /><title>3.9.19 Documentation</title><meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link rel="stylesheet" href="_static/pydoctheme.css" type="text/css" />
    <link rel=
```
That certainly looks like HTML that comes from the url https://docs.python.org/3.9/, which is what we expected. Let's now look at some variations we can make to our basic example that can be helpful in different situations. 

## Lazy loading

If we're loading a  large number of Documents and our downstream operations can be done over subsets of all loaded Documents, we can lazily load our Documents one at a time to minimize our memory footprint:

```python
pages = []
for doc in loader.lazy_load():
    pages.append(doc)
    if len(pages) >= 10:
        # do some paged operation, e.g.
        # index.upsert(page)

        pages = []
```
```output
/var/folders/4j/2rz3865x6qg07tx43146py8h0000gn/T/ipykernel_73962/2110507528.py:6: XMLParsedAsHTMLWarning: It looks like you're parsing an XML document using an HTML parser. If this really is an HTML document (maybe it's XHTML?), you can ignore or filter this warning. If it's XML, you should know that using an XML parser will be more reliable. To parse this document as XML, make sure you have the lxml package installed, and pass the keyword argument `features="xml"` into the BeautifulSoup constructor.
  soup = BeautifulSoup(html, "lxml")
```
In this example we never have more than 10 Documents loaded into memory at a time.

## Adding an Extractor

By default the loader sets the raw HTML from each link as the Document page content. To parse this HTML into a more human/LLM-friendly format you can pass in a custom `extractor` method:

```python
import re

from bs4 import BeautifulSoup


def bs4_extractor(html: str) -> str:
    soup = BeautifulSoup(html, "lxml")
    return re.sub(r"\n\n+", "\n\n", soup.text).strip()


loader = RecursiveUrlLoader("https://docs.python.org/3.9/", extractor=bs4_extractor)
docs = loader.load()
print(docs[0].page_content[:200])
```
```output
/var/folders/td/vzm913rx77x21csd90g63_7c0000gn/T/ipykernel_10935/1083427287.py:6: XMLParsedAsHTMLWarning: It looks like you're parsing an XML document using an HTML parser. If this really is an HTML document (maybe it's XHTML?), you can ignore or filter this warning. If it's XML, you should know that using an XML parser will be more reliable. To parse this document as XML, make sure you have the lxml package installed, and pass the keyword argument `features="xml"` into the BeautifulSoup constructor.
  soup = BeautifulSoup(html, "lxml")
/Users/isaachershenson/.pyenv/versions/3.11.9/lib/python3.11/html/parser.py:170: XMLParsedAsHTMLWarning: It looks like you're parsing an XML document using an HTML parser. If this really is an HTML document (maybe it's XHTML?), you can ignore or filter this warning. If it's XML, you should know that using an XML parser will be more reliable. To parse this document as XML, make sure you have the lxml package installed, and pass the keyword argument `features="xml"` into the BeautifulSoup constructor.
  k = self.parse_starttag(i)
``````output
3.9.19 Documentation

Download
Download these documents
Docs by version

Python 3.13 (in development)
Python 3.12 (stable)
Python 3.11 (security-fixes)
Python 3.10 (security-fixes)
Python 3.9 (securit
```
This looks much nicer!

You can similarly pass in a `metadata_extractor` to customize how Document metadata is extracted from the HTTP response. See the [API reference](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.recursive_url_loader.RecursiveUrlLoader.html) for more on this.

## API reference

These examples show just a few of the ways in which you can modify the default `RecursiveUrlLoader`, but there are many more modifications that can be made to best fit your use case. Using the parameters `link_regex` and `exclude_dirs` can help you filter out unwanted URLs, `aload()` and `alazy_load()` can be used for aynchronous loading, and more.

For detailed information on configuring and calling the `RecursiveUrlLoader`, please see the API reference: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.recursive_url_loader.RecursiveUrlLoader.html.

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)