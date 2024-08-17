---
canonical: https://python.langchain.com/v0.2/docs/integrations/retrievers/wikipedia/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/wikipedia.ipynb
sidebar_label: Wikipedia
---

# WikipediaRetriever

## Overview
> [Wikipedia](https://wikipedia.org/) is a multilingual free online encyclopedia written and maintained by a community of volunteers, known as Wikipedians, through open collaboration and using a wiki-based editing system called MediaWiki. `Wikipedia` is the largest and most-read reference work in history.

This notebook shows how to retrieve wiki pages from `wikipedia.org` into the [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) format that is used downstream.

### Integration details

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="external_retrievers" item="WikipediaRetriever" />


## Setup
If you want to get automated tracing from runs of individual tools, you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

### Installation

The integration lives in the `langchain-community` package. We also need to install the `wikipedia` python package itself.

```python
%pip install -qU langchain_community wikipedia
```

## Instantiation

Now we can instantiate our retriever:

`WikipediaRetriever` parameters include:
- optional `lang`: default="en". Use it to search in a specific language part of Wikipedia
- optional `load_max_docs`: default=100. Use it to limit number of downloaded documents. It takes time to download all 100 documents, so use a small number for experiments. There is a hard limit of 300 for now.
- optional `load_all_available_meta`: default=False. By default only the most important fields downloaded: `Published` (date when document was published/last updated), `title`, `Summary`. If True, other fields also downloaded.

`get_relevant_documents()` has one argument, `query`: free text which used to find documents in Wikipedia

```python
<!--IMPORTS:[{"imported": "WikipediaRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.wikipedia.WikipediaRetriever.html", "title": "WikipediaRetriever"}]-->
from langchain_community.retrievers import WikipediaRetriever

retriever = WikipediaRetriever()
```

## Usage

```python
docs = retriever.invoke("TOKYO GHOUL")
```

```python
print(docs[0].page_content[:400])
```
```output
Tokyo Ghoul (Japanese: 東京喰種（トーキョーグール）, Hepburn: Tōkyō Gūru) is a Japanese dark fantasy manga series written and illustrated by Sui Ishida. It was serialized in Shueisha's seinen manga magazine Weekly Young Jump from September 2011 to September 2014, with its chapters collected in 14 tankōbon volumes. The story is set in an alternate version of Tokyo where humans coexist with ghouls, beings who loo
```
## Use within a chain
Like other retrievers, `WikipediaRetriever` can be incorporated into LLM applications via [chains](/docs/how_to/sequence/).

We will need a LLM or chat model:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "WikipediaRetriever"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "WikipediaRetriever"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "WikipediaRetriever"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

prompt = ChatPromptTemplate.from_template(
    """
    Answer the question based only on the context provided.
    Context: {context}
    Question: {question}
    """
)


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```

```python
chain.invoke(
    "Who is the main character in `Tokyo Ghoul` and does he transform into a ghoul?"
)
```

```output
'The main character in Tokyo Ghoul is Ken Kaneki, who transforms into a ghoul after receiving an organ transplant from a ghoul named Rize.'
```

## API reference

For detailed documentation of all `WikipediaRetriever` features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.wikipedia.WikipediaRetriever.html#langchain-community-retrievers-wikipedia-wikipediaretriever).

## Related

- Retriever [conceptual guide](/docs/concepts/#retrievers)
- Retriever [how-to guides](/docs/how_to/#retrievers)