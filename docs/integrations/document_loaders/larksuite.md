---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/larksuite/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/larksuite.ipynb
---

# LarkSuite (FeiShu)

> [LarkSuite](https://www.larksuite.com/) is an enterprise collaboration platform developed by ByteDance.

This notebook covers how to load data from the `LarkSuite` REST API into a format that can be ingested into LangChain, along with example usage for text summarization.

The LarkSuite API requires an access token (tenant_access_token or user_access_token), checkout [LarkSuite open platform document](https://open.larksuite.com/document) for API details.

```python
<!--IMPORTS:[{"imported": "LarkSuiteDocLoader", "source": "langchain_community.document_loaders.larksuite", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.larksuite.LarkSuiteDocLoader.html", "title": "LarkSuite (FeiShu)"}, {"imported": "LarkSuiteWikiLoader", "source": "langchain_community.document_loaders.larksuite", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.larksuite.LarkSuiteWikiLoader.html", "title": "LarkSuite (FeiShu)"}]-->
from getpass import getpass

from langchain_community.document_loaders.larksuite import (
    LarkSuiteDocLoader,
    LarkSuiteWikiLoader,
)

DOMAIN = input("larksuite domain")
ACCESS_TOKEN = getpass("larksuite tenant_access_token or user_access_token")
DOCUMENT_ID = input("larksuite document id")
```

## Load From Document

```python
from pprint import pprint

larksuite_loader = LarkSuiteDocLoader(DOMAIN, ACCESS_TOKEN, DOCUMENT_ID)
docs = larksuite_loader.load()

pprint(docs)
```
```output
[Document(page_content='Test Doc\nThis is a Test Doc\n\n1\n2\n3\n\n', metadata={'document_id': 'V76kdbd2HoBbYJxdiNNccajunPf', 'revision_id': 11, 'title': 'Test Doc'})]
```
## Load From Wiki

```python
from pprint import pprint

DOCUMENT_ID = input("larksuite wiki id")
larksuite_loader = LarkSuiteWikiLoader(DOMAIN, ACCESS_TOKEN, DOCUMENT_ID)
docs = larksuite_loader.load()

pprint(docs)
```
```output
[Document(page_content='Test doc\nThis is a test wiki doc.\n', metadata={'document_id': 'TxOKdtMWaoSTDLxYS4ZcdEI7nwc', 'revision_id': 15, 'title': 'Test doc'})]
```

```python
<!--IMPORTS:[{"imported": "load_summarize_chain", "source": "langchain.chains.summarize", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.summarize.chain.load_summarize_chain.html", "title": "LarkSuite (FeiShu)"}, {"imported": "FakeListLLM", "source": "langchain_community.llms.fake", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.fake.FakeListLLM.html", "title": "LarkSuite (FeiShu)"}]-->
# see https://python.langchain.com/docs/use_cases/summarization for more details
from langchain.chains.summarize import load_summarize_chain
from langchain_community.llms.fake import FakeListLLM

llm = FakeListLLM()
chain = load_summarize_chain(llm, chain_type="map_reduce")
chain.run(docs)
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)