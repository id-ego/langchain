---
canonical: https://python.langchain.com/v0.2/docs/versions/migrating_chains/retrieval_qa/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/retrieval_qa.ipynb
title: Migrating from RetrievalQA
---

The [`RetrievalQA`](https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html) chain performed natural-language question answering over a data source using retrieval-augmented generation.

Some advantages of switching to the LCEL implementation are:

- Easier customizability. Details such as the prompt and how documents are formatted are only configurable via specific parameters in the `RetrievalQA` chain.
- More easily return source documents.
- Support for runnable methods like streaming and async operations.

Now let's look at them side-by-side. We'll use the same ingestion code to load a [blog post by Lilian Weng](https://lilianweng.github.io/posts/2023-06-23-agent/) on autonomous agents into a local vector store:

```python
%pip install --upgrade --quiet langchain-community langchain langchain-openai faiss-cpu
```

```python
import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```

```python
<!--IMPORTS:[{"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Load docs"}, {"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "Load docs"}, {"imported": "ChatOpenAI", "source": "langchain_openai.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Load docs"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Load docs"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Load docs"}]-->
# Load docs
from langchain_community.document_loaders import WebBaseLoader
from langchain_community.vectorstores import FAISS
from langchain_openai.chat_models import ChatOpenAI
from langchain_openai.embeddings import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

loader = WebBaseLoader("https://lilianweng.github.io/posts/2023-06-23-agent/")
data = loader.load()

# Split
text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0)
all_splits = text_splitter.split_documents(data)

# Store splits
vectorstore = FAISS.from_documents(documents=all_splits, embedding=OpenAIEmbeddings())

# LLM
llm = ChatOpenAI()
```

## Legacy

<details open>


```python
<!--IMPORTS:[{"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "Load docs"}]-->
from langchain import hub
from langchain.chains import RetrievalQA

# See full prompt at https://smith.langchain.com/hub/rlm/rag-prompt
prompt = hub.pull("rlm/rag-prompt")

qa_chain = RetrievalQA.from_llm(
    llm, retriever=vectorstore.as_retriever(), prompt=prompt
)

qa_chain("What are autonomous agents?")
```

```output
{'query': 'What are autonomous agents?',
 'result': 'Autonomous agents are LLM-empowered agents capable of handling autonomous design, planning, and performance of complex scientific experiments. These agents can browse the Internet, read documentation, execute code, call robotics experimentation APIs, and leverage other LLMs. They can generate reasoning steps, such as developing a novel anticancer drug, based on requested tasks.'}
```

</details>


## LCEL

<details open>


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Load docs"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Load docs"}]-->
from langchain import hub
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough

# See full prompt at https://smith.langchain.com/hub/rlm/rag-prompt
prompt = hub.pull("rlm/rag-prompt")


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


qa_chain = (
    {
        "context": vectorstore.as_retriever() | format_docs,
        "question": RunnablePassthrough(),
    }
    | prompt
    | llm
    | StrOutputParser()
)

qa_chain.invoke("What are autonomous agents?")
```

```output
'Autonomous agents are agents empowered by large language models (LLMs) that can handle autonomous design, planning, and performance of complex tasks such as scientific experiments. These agents can use tools to browse the Internet, read documentation, execute code, call robotics experimentation APIs, and leverage other LLMs for their tasks. The model can come up with reasoning steps when given a specific task, such as developing a novel anticancer drug.'
```

The LCEL implementation exposes the internals of what's happening around retrieving, formatting documents, and passing them through a prompt to the LLM, but it is more verbose. You can customize and wrap this composition logic in a helper function, or use the higher-level [`create_retrieval_chain`](https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html) and [`create_stuff_documents_chain`](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html) helper method:

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "Load docs"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "Load docs"}]-->
from langchain import hub
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

# See full prompt at https://smith.langchain.com/hub/langchain-ai/retrieval-qa-chat
retrieval_qa_chat_prompt = hub.pull("langchain-ai/retrieval-qa-chat")

combine_docs_chain = create_stuff_documents_chain(llm, retrieval_qa_chat_prompt)
rag_chain = create_retrieval_chain(vectorstore.as_retriever(), combine_docs_chain)

rag_chain.invoke({"input": "What are autonomous agents?"})
```

```output
{'input': 'What are autonomous agents?',
 'context': [Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'title': "LLM Powered Autonomous Agents | Lil'Log", 'description': 'Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.\nAgent System Overview In a LLM-powered autonomous agent system, LLM functions as the agent’s brain, complemented by several key components:', 'language': 'en'}, page_content='Boiko et al. (2023) also looked into LLM-empowered agents for scientific discovery, to handle autonomous design, planning, and performance of complex scientific experiments. This agent can use tools to browse the Internet, read documentation, execute code, call robotics experimentation APIs and leverage other LLMs.\nFor example, when requested to "develop a novel anticancer drug", the model came up with the following reasoning steps:'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'title': "LLM Powered Autonomous Agents | Lil'Log", 'description': 'Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.\nAgent System Overview In a LLM-powered autonomous agent system, LLM functions as the agent’s brain, complemented by several key components:', 'language': 'en'}, page_content='Weng, Lilian. (Jun 2023). “LLM-powered Autonomous Agents”. Lil’Log. https://lilianweng.github.io/posts/2023-06-23-agent/.'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'title': "LLM Powered Autonomous Agents | Lil'Log", 'description': 'Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.\nAgent System Overview In a LLM-powered autonomous agent system, LLM functions as the agent’s brain, complemented by several key components:', 'language': 'en'}, page_content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'title': "LLM Powered Autonomous Agents | Lil'Log", 'description': 'Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.\nAgent System Overview In a LLM-powered autonomous agent system, LLM functions as the agent’s brain, complemented by several key components:', 'language': 'en'}, page_content='Or\n@article{weng2023agent,\n  title   = "LLM-powered Autonomous Agents",\n  author  = "Weng, Lilian",\n  journal = "lilianweng.github.io",\n  year    = "2023",\n  month   = "Jun",\n  url     = "https://lilianweng.github.io/posts/2023-06-23-agent/"\n}\nReferences#\n[1] Wei et al. “Chain of thought prompting elicits reasoning in large language models.” NeurIPS 2022\n[2] Yao et al. “Tree of Thoughts: Dliberate Problem Solving with Large Language Models.” arXiv preprint arXiv:2305.10601 (2023).')],
 'answer': 'Autonomous agents are entities capable of operating independently to perform tasks or make decisions without direct human intervention. In the context provided, autonomous agents empowered by Large Language Models (LLMs) are used for scientific discovery, including tasks like autonomous design, planning, and executing complex scientific experiments.'}
```

</details>


## Next steps

Check out the [LCEL conceptual docs](/docs/concepts/#langchain-expression-language-lcel) for more background information.