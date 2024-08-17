---
canonical: https://python.langchain.com/v0.2/docs/versions/migrating_chains/conversation_retrieval_chain/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/conversation_retrieval_chain.ipynb
title: Migrating from ConversationalRetrievalChain
---

The [`ConversationalRetrievalChain`](https://api.python.langchain.com/en/latest/chains/langchain.chains.conversational_retrieval.base.ConversationalRetrievalChain.html) was an all-in one way that combined retrieval-augmented generation with chat history, allowing you to "chat with" your documents.

Advantages of switching to the LCEL implementation are similar to the `RetrievalQA` section above:

- Clearer internals. The `ConversationalRetrievalChain` chain hides an entire question rephrasing step which dereferences the initial query against the chat history.
  - This means the class contains two sets of configurable prompts, LLMs, etc.
- More easily return source documents.
- Support for runnable methods like streaming and async operations.

Here are side-by-side implementations with custom prompts. We'll reuse the loaded documents and vector store from the previous section:

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
<!--IMPORTS:[{"imported": "ConversationalRetrievalChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.conversational_retrieval.base.ConversationalRetrievalChain.html", "title": "Load docs"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Load docs"}]-->
from langchain.chains import ConversationalRetrievalChain
from langchain_core.prompts import ChatPromptTemplate

condense_question_template = """
Given the following conversation and a follow up question, rephrase the follow up question to be a standalone question.

Chat History:
{chat_history}
Follow Up Input: {question}
Standalone question:"""

condense_question_prompt = ChatPromptTemplate.from_template(condense_question_template)

qa_template = """
You are an assistant for question-answering tasks.
Use the following pieces of retrieved context to answer
the question. If you don't know the answer, say that you
don't know. Use three sentences maximum and keep the
answer concise.

Chat History:
{chat_history}

Other context:
{context}

Question: {question}
"""

qa_prompt = ChatPromptTemplate.from_template(qa_template)

convo_qa_chain = ConversationalRetrievalChain.from_llm(
    llm,
    vectorstore.as_retriever(),
    condense_question_prompt=condense_question_prompt,
    combine_docs_chain_kwargs={
        "prompt": qa_prompt,
    },
)

convo_qa_chain(
    {
        "question": "What are autonomous agents?",
        "chat_history": "",
    }
)
```

```output
{'question': 'What are autonomous agents?',
 'chat_history': '',
 'answer': 'Autonomous agents are entities empowered with capabilities like planning, task decomposition, and memory to perform complex tasks independently. These agents can leverage tools like browsing the internet, reading documentation, executing code, and calling APIs to achieve their objectives. They are designed to handle tasks like scientific discovery and experimentation autonomously.'}
```

</details>


## LCEL

<details open>


```python
<!--IMPORTS:[{"imported": "create_history_aware_retriever", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.history_aware_retriever.create_history_aware_retriever.html", "title": "Load docs"}, {"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "Load docs"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "Load docs"}]-->
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

condense_question_system_template = (
    "Given a chat history and the latest user question "
    "which might reference context in the chat history, "
    "formulate a standalone question which can be understood "
    "without the chat history. Do NOT answer the question, "
    "just reformulate it if needed and otherwise return it as is."
)

condense_question_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", condense_question_system_template),
        ("placeholder", "{chat_history}"),
        ("human", "{input}"),
    ]
)
history_aware_retriever = create_history_aware_retriever(
    llm, vectorstore.as_retriever(), condense_question_prompt
)

system_prompt = (
    "You are an assistant for question-answering tasks. "
    "Use the following pieces of retrieved context to answer "
    "the question. If you don't know the answer, say that you "
    "don't know. Use three sentences maximum and keep the "
    "answer concise."
    "\n\n"
    "{context}"
)

qa_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        ("placeholder", "{chat_history}"),
        ("human", "{input}"),
    ]
)
qa_chain = create_stuff_documents_chain(llm, qa_prompt)

convo_qa_chain = create_retrieval_chain(history_aware_retriever, qa_chain)

convo_qa_chain.invoke(
    {
        "input": "What are autonomous agents?",
        "chat_history": [],
    }
)
```

```output
{'input': 'What are autonomous agents?',
 'chat_history': [],
 'context': [Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'title': "LLM Powered Autonomous Agents | Lil'Log", 'description': 'Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.\nAgent System Overview In a LLM-powered autonomous agent system, LLM functions as the agent’s brain, complemented by several key components:', 'language': 'en'}, page_content='Boiko et al. (2023) also looked into LLM-empowered agents for scientific discovery, to handle autonomous design, planning, and performance of complex scientific experiments. This agent can use tools to browse the Internet, read documentation, execute code, call robotics experimentation APIs and leverage other LLMs.\nFor example, when requested to "develop a novel anticancer drug", the model came up with the following reasoning steps:'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'title': "LLM Powered Autonomous Agents | Lil'Log", 'description': 'Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.\nAgent System Overview In a LLM-powered autonomous agent system, LLM functions as the agent’s brain, complemented by several key components:', 'language': 'en'}, page_content='Weng, Lilian. (Jun 2023). “LLM-powered Autonomous Agents”. Lil’Log. https://lilianweng.github.io/posts/2023-06-23-agent/.'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'title': "LLM Powered Autonomous Agents | Lil'Log", 'description': 'Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.\nAgent System Overview In a LLM-powered autonomous agent system, LLM functions as the agent’s brain, complemented by several key components:', 'language': 'en'}, page_content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'title': "LLM Powered Autonomous Agents | Lil'Log", 'description': 'Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.\nAgent System Overview In a LLM-powered autonomous agent system, LLM functions as the agent’s brain, complemented by several key components:', 'language': 'en'}, page_content="LLM Powered Autonomous Agents | Lil'Log\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nLil'Log\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nPosts\n\n\n\n\nArchive\n\n\n\n\nSearch\n\n\n\n\nTags\n\n\n\n\nFAQ\n\n\n\n\nemojisearch.app\n\n\n\n\n\n\n\n\n\n      LLM Powered Autonomous Agents\n    \nDate: June 23, 2023  |  Estimated Reading Time: 31 min  |  Author: Lilian Weng\n\n\n \n\n\nTable of Contents\n\n\n\nAgent System Overview\n\nComponent One: Planning\n\nTask Decomposition\n\nSelf-Reflection\n\n\nComponent Two: Memory\n\nTypes of Memory\n\nMaximum Inner Product Search (MIPS)")],
 'answer': 'Autonomous agents are entities that can act independently to achieve specific goals or tasks without direct human intervention. These agents have the ability to perceive their environment, make decisions, and take actions based on their programming or learning. They can perform tasks such as planning, execution, and problem-solving autonomously.'}
```

</details>


## Next steps

You've now seen how to migrate existing usage of some legacy chains to LCEL.

Next, check out the [LCEL conceptual docs](/docs/concepts/#langchain-expression-language-lcel) for more background information.