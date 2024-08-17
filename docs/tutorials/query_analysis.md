---
canonical: https://python.langchain.com/v0.2/docs/tutorials/query_analysis/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/query_analysis.ipynb
sidebar_position: 0
---

# Build a Query Analysis System

:::info Prerequisites

This guide assumes familiarity with the following concepts:

- [Document loaders](/docs/concepts/#document-loaders)
- [Chat models](/docs/concepts/#chat-models)
- [Embeddings](/docs/concepts/#embedding-models)
- [Vector stores](/docs/concepts/#vector-stores)
- [Retrieval](/docs/concepts/#retrieval)

:::

This page will show how to use query analysis in a basic end-to-end example. This will cover creating a simple search engine, showing a failure mode that occurs when passing a raw user question to that search, and then an example of how query analysis can help address that issue. There are MANY different query analysis techniques and this end-to-end example will not show all of them.

For the purpose of this example, we will do retrieval over the LangChain YouTube videos.

## Setup
#### Install dependencies


```python
# %pip install -qU langchain langchain-community langchain-openai youtube-transcript-api pytube langchain-chroma
```

#### Set environment variables

We'll use OpenAI in this example:


```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()

# Optional, uncomment to trace runs with LangSmith. Sign up here: https://smith.langchain.com.
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```

### Load documents

We can use the `YouTubeLoader` to load transcripts of a few LangChain videos:


```python
<!--IMPORTS:[{"imported": "YoutubeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.youtube.YoutubeLoader.html", "title": "Build a Query Analysis System"}]-->
from langchain_community.document_loaders import YoutubeLoader

urls = [
    "https://www.youtube.com/watch?v=HAn9vnJy6S4",
    "https://www.youtube.com/watch?v=dA1cHGACXCo",
    "https://www.youtube.com/watch?v=ZcEMLz27sL4",
    "https://www.youtube.com/watch?v=hvAPnpSfSGo",
    "https://www.youtube.com/watch?v=EhlPDL4QrWY",
    "https://www.youtube.com/watch?v=mmBo8nlu2j0",
    "https://www.youtube.com/watch?v=rQdibOsL1ps",
    "https://www.youtube.com/watch?v=28lC4fqukoc",
    "https://www.youtube.com/watch?v=es-9MgxB-uc",
    "https://www.youtube.com/watch?v=wLRHwKuKvOE",
    "https://www.youtube.com/watch?v=ObIltMaRJvY",
    "https://www.youtube.com/watch?v=DjuXACWYkkU",
    "https://www.youtube.com/watch?v=o7C9ld6Ln-M",
]
docs = []
for url in urls:
    docs.extend(YoutubeLoader.from_youtube_url(url, add_video_info=True).load())
```


```python
import datetime

# Add some additional metadata: what year the video was published
for doc in docs:
    doc.metadata["publish_year"] = int(
        datetime.datetime.strptime(
            doc.metadata["publish_date"], "%Y-%m-%d %H:%M:%S"
        ).strftime("%Y")
    )
```

Here are the titles of the videos we've loaded:


```python
[doc.metadata["title"] for doc in docs]
```



```output
['OpenGPTs',
 'Building a web RAG chatbot: using LangChain, Exa (prev. Metaphor), LangSmith, and Hosted Langserve',
 'Streaming Events: Introducing a new `stream_events` method',
 'LangGraph: Multi-Agent Workflows',
 'Build and Deploy a RAG app with Pinecone Serverless',
 'Auto-Prompt Builder (with Hosted LangServe)',
 'Build a Full Stack RAG App With TypeScript',
 'Getting Started with Multi-Modal LLMs',
 'SQL Research Assistant',
 'Skeleton-of-Thought: Building a New Template from Scratch',
 'Benchmarking RAG over LangChain Docs',
 'Building a Research Assistant from Scratch',
 'LangServe and LangChain Templates Webinar']
```


Here's the metadata associated with each video. We can see that each document also has a title, view count, publication date, and length:


```python
docs[0].metadata
```



```output
{'source': 'HAn9vnJy6S4',
 'title': 'OpenGPTs',
 'description': 'Unknown',
 'view_count': 7210,
 'thumbnail_url': 'https://i.ytimg.com/vi/HAn9vnJy6S4/hq720.jpg',
 'publish_date': '2024-01-31 00:00:00',
 'length': 1530,
 'author': 'LangChain',
 'publish_year': 2024}
```


And here's a sample from a document's contents:


```python
docs[0].page_content[:500]
```



```output
"hello today I want to talk about open gpts open gpts is a project that we built here at linkchain uh that replicates the GPT store in a few ways so it creates uh end user-facing friendly interface to create different Bots and these Bots can have access to different tools and they can uh be given files to retrieve things over and basically it's a way to create a variety of bots and expose the configuration of these Bots to end users it's all open source um it can be used with open AI it can be us"
```


### Indexing documents

Whenever we perform retrieval we need to create an index of documents that we can query. We'll use a vector store to index our documents, and we'll chunk them first to make our retrievals more concise and precise:


```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Build a Query Analysis System"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Build a Query Analysis System"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Build a Query Analysis System"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter(chunk_size=2000)
chunked_docs = text_splitter.split_documents(docs)
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectorstore = Chroma.from_documents(
    chunked_docs,
    embeddings,
)
```

## Retrieval without query analysis

We can perform similarity search on a user question directly to find chunks relevant to the question:


```python
search_results = vectorstore.similarity_search("how do I build a RAG agent")
print(search_results[0].metadata["title"])
print(search_results[0].page_content[:500])
```
```output
Build and Deploy a RAG app with Pinecone Serverless
hi this is Lance from the Lang chain team and today we're going to be building and deploying a rag app using pine con serval list from scratch so we're going to kind of walk through all the code required to do this and I'll use these slides as kind of a guide to kind of lay the the ground work um so first what is rag so under capoy has this pretty nice visualization that shows LMS as a kernel of a new kind of operating system and of course one of the core components of our operating system is th
```
This works pretty well! Our first result is quite relevant to the question.


What if we wanted to search for results from a specific time period?


```python
search_results = vectorstore.similarity_search("videos on RAG published in 2023")
print(search_results[0].metadata["title"])
print(search_results[0].metadata["publish_date"])
print(search_results[0].page_content[:500])
```
```output
OpenGPTs
2024-01-31
hardcoded that it will always do a retrieval step here the assistant decides whether to do a retrieval step or not sometimes this is good sometimes this is bad sometimes it you don't need to do a retrieval step when I said hi it didn't need to call it tool um but other times you know the the llm might mess up and not realize that it needs to do a retrieval step and so the rag bot will always do a retrieval step so it's more focused there because this is also a simpler architecture so it's always
```
Our first result is from 2024 (despite us asking for videos from 2023), and not very relevant to the input. Since we're just searching against document contents, there's no way for the results to be filtered on any document attributes.

This is just one failure mode that can arise. Let's now take a look at how a basic form of query analysis can fix it!

## Query analysis

We can use query analysis to improve the results of retrieval. This will involve defining a **query schema** that contains some date filters and use a function-calling model to convert a user question into a structured queries. 

### Query schema
In this case we'll have explicit min and max attributes for publication date so that it can be filtered on.


```python
from typing import Optional

from langchain_core.pydantic_v1 import BaseModel, Field


class Search(BaseModel):
    """Search over a database of tutorial videos about a software library."""

    query: str = Field(
        ...,
        description="Similarity search query applied to video transcripts.",
    )
    publish_year: Optional[int] = Field(None, description="Year video was published")
```

### Query generation

To convert user questions to structured queries we'll make use of OpenAI's tool-calling API. Specifically we'll use the new [ChatModel.with_structured_output()](/docs/how_to/structured_output) constructor to handle passing the schema to the model and parsing the output.


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Build a Query Analysis System"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Build a Query Analysis System"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Build a Query Analysis System"}]-->
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI

system = """You are an expert at converting user questions into database queries. \
You have access to a database of tutorial videos about a software library for building LLM-powered applications. \
Given a question, return a list of database queries optimized to retrieve the most relevant results.

If there are acronyms or words you are not familiar with, do not try to rephrase them."""
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system),
        ("human", "{question}"),
    ]
)
llm = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0)
structured_llm = llm.with_structured_output(Search)
query_analyzer = {"question": RunnablePassthrough()} | prompt | structured_llm
```
```output
/Users/bagatur/langchain/libs/core/langchain_core/_api/beta_decorator.py:86: LangChainBetaWarning: The function `with_structured_output` is in beta. It is actively being worked on, so the API may change.
  warn_beta(
```
Let's see what queries our analyzer generates for the questions we searched earlier:


```python
query_analyzer.invoke("how do I build a RAG agent")
```



```output
Search(query='build RAG agent', publish_year=None)
```



```python
query_analyzer.invoke("videos on RAG published in 2023")
```



```output
Search(query='RAG', publish_year=2023)
```


## Retrieval with query analysis

Our query analysis looks pretty good; now let's try using our generated queries to actually perform retrieval. 

**Note:** in our example, we specified `tool_choice="Search"`. This will force the LLM to call one - and only one - tool, meaning that we will always have one optimized query to look up. Note that this is not always the case - see other guides for how to deal with situations when no - or multiple - optmized queries are returned.


```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Build a Query Analysis System"}]-->
from typing import List

from langchain_core.documents import Document
```


```python
def retrieval(search: Search) -> List[Document]:
    if search.publish_year is not None:
        # This is syntax specific to Chroma,
        # the vector database we are using.
        _filter = {"publish_year": {"$eq": search.publish_year}}
    else:
        _filter = None
    return vectorstore.similarity_search(search.query, filter=_filter)
```


```python
retrieval_chain = query_analyzer | retrieval
```

We can now run this chain on the problematic input from before, and see that it yields only results from that year!


```python
results = retrieval_chain.invoke("RAG tutorial published in 2023")
```


```python
[(doc.metadata["title"], doc.metadata["publish_date"]) for doc in results]
```



```output
[('Getting Started with Multi-Modal LLMs', '2023-12-20 00:00:00'),
 ('LangServe and LangChain Templates Webinar', '2023-11-02 00:00:00'),
 ('Getting Started with Multi-Modal LLMs', '2023-12-20 00:00:00'),
 ('Building a Research Assistant from Scratch', '2023-11-16 00:00:00')]
```