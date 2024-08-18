---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/conversation_retrieval_chain.ipynb
description: 이 문서는 ConversationalRetrievalChain의 장점과 LCEL 구현에 대한 설명을 제공하며, 사용자 정의
  프롬프트를 통한 예제를 포함합니다.
title: Migrating from ConversationalRetrievalChain
---

[`ConversationalRetrievalChain`](https://api.python.langchain.com/en/latest/chains/langchain.chains.conversational_retrieval.base.ConversationalRetrievalChain.html)는 검색 증강 생성과 채팅 기록을 결합한 올인원 방식으로, 문서와 "채팅"할 수 있게 해줍니다.

LCEL 구현으로 전환하는 장점은 위의 `RetrievalQA` 섹션과 유사합니다:

- 더 명확한 내부 구조. `ConversationalRetrievalChain` 체인은 초기 쿼리를 채팅 기록에 대해 역참조하는 전체 질문 재구성 단계를 숨깁니다.
  - 이는 클래스가 두 세트의 구성 가능한 프롬프트, LLM 등을 포함하고 있음을 의미합니다.
- 소스 문서를 더 쉽게 반환할 수 있습니다.
- 스트리밍 및 비동기 작업과 같은 실행 가능한 메서드를 지원합니다.

여기 사용자 정의 프롬프트와 함께 나란히 구현된 예가 있습니다. 이전 섹션에서 로드된 문서와 벡터 저장소를 재사용할 것입니다:

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

이제 일부 레거시 체인의 기존 사용을 LCEL로 마이그레이션하는 방법을 보았습니다.

다음으로, 더 많은 배경 정보를 위해 [LCEL 개념 문서](/docs/concepts/#langchain-expression-language-lcel)를 확인하세요.