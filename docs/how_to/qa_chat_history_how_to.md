---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/qa_chat_history_how_to.ipynb
description: 사용자가 과거 질문과 답변을 기억할 수 있도록 Q&A 애플리케이션에 대화 이력을 추가하는 방법을 안내합니다.
---

# 채팅 기록 추가하는 방법

많은 Q&A 애플리케이션에서는 사용자가 상호작용할 수 있는 대화를 허용하고자 하며, 이는 애플리케이션이 과거 질문과 답변에 대한 "기억"과 이를 현재 사고에 통합하는 논리를 필요로 함을 의미합니다.

이 가이드에서는 **역사적 메시지를 통합하는 논리 추가**에 중점을 둡니다.

이는 [대화형 RAG 튜토리얼](/docs/tutorials/qa_chat_history)의 요약 버전입니다.

두 가지 접근 방식을 다룰 것입니다:
1. [체인](/docs/how_to/qa_chat_history_how_to#chains), 항상 검색 단계를 실행하는 경우;
2. [에이전트](/docs/how_to/qa_chat_history_how_to#agents), 검색 단계를 실행할지 여부와 방법에 대한 재량을 LLM에 부여하는 경우.

외부 지식 소스로는 Lilian Weng의 [LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/) 블로그 게시물을 사용할 것입니다.

## 설정

### 의존성

이 walkthrough에서는 OpenAI 임베딩과 Chroma 벡터 저장소를 사용할 것이지만, 여기서 보여지는 모든 것은 어떤 [임베딩](/docs/concepts#embedding-models) 및 [벡터 저장소](/docs/concepts#vectorstores) 또는 [검색기](/docs/concepts#retrievers)와도 작동합니다.

다음 패키지를 사용할 것입니다:

```python
%%capture --no-stderr
%pip install --upgrade --quiet  langchain langchain-community langchain-chroma bs4
```


환경 변수 `OPENAI_API_KEY`를 설정해야 하며, 이는 직접 설정하거나 다음과 같이 `.env` 파일에서 로드할 수 있습니다:

```python
import getpass
import os

if not os.environ.get("OPENAI_API_KEY"):
    os.environ["OPENAI_API_KEY"] = getpass.getpass()

# import dotenv

# dotenv.load_dotenv()
```


### LangSmith

LangChain으로 구축하는 많은 애플리케이션은 여러 단계와 여러 LLM 호출을 포함합니다. 이러한 애플리케이션이 점점 더 복잡해짐에 따라 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지를 검사할 수 있는 것이 중요해집니다. 이를 가장 잘 수행하는 방법은 [LangSmith](https://smith.langchain.com)입니다.

LangSmith는 필요하지 않지만 유용합니다. LangSmith를 사용하고 싶다면, 위 링크에서 가입한 후 환경 변수를 설정하여 추적 로그를 시작해야 합니다:

```python
os.environ["LANGCHAIN_TRACING_V2"] = "true"
if not os.environ.get("LANGCHAIN_API_KEY"):
    os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 체인 {#chains}

대화형 RAG 애플리케이션에서 검색기에 발행된 쿼리는 대화의 맥락에 의해 정보가 제공되어야 합니다. LangChain은 이를 단순화하기 위해 [create_history_aware_retriever](https://api.python.langchain.com/en/latest/chains/langchain.chains.history_aware_retriever.create_history_aware_retriever.html) 생성자를 제공합니다. 이는 `input` 및 `chat_history` 키를 입력으로 받아들이고 검색기와 동일한 출력 스키마를 갖는 체인을 구성합니다. `create_history_aware_retriever`는 다음을 입력으로 요구합니다:

1. LLM;
2. 검색기;
3. 프롬프트.

먼저 이러한 객체를 얻습니다:

### LLM

지원되는 채팅 모델을 사용할 수 있습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

### 검색기

검색기에는 [WebBaseLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html)를 사용하여 웹 페이지의 내용을 로드합니다. 여기에서 `Chroma` 벡터 저장소를 인스턴스화한 다음, [.as_retriever](https://api.python.langchain.com/en/latest/vectorstores/langchain_core.vectorstores.VectorStore.html#langchain_core.vectorstores.VectorStore.as_retriever) 메서드를 사용하여 [LCEL](/docs/concepts/#langchain-expression-language) 체인에 통합할 수 있는 검색기를 구축합니다.

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "How to add chat history"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "How to add chat history"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to add chat history"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "How to add chat history"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to add chat history"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add chat history"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to add chat history"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to add chat history"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to add chat history"}]-->
import bs4
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_chroma import Chroma
from langchain_community.document_loaders import WebBaseLoader
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

loader = WebBaseLoader(
    web_paths=("https://lilianweng.github.io/posts/2023-06-23-agent/",),
    bs_kwargs=dict(
        parse_only=bs4.SoupStrainer(
            class_=("post-content", "post-title", "post-header")
        )
    ),
)
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(docs)
vectorstore = Chroma.from_documents(documents=splits, embedding=OpenAIEmbeddings())
retriever = vectorstore.as_retriever()
```


### 프롬프트

`MessagesPlaceholder` 변수를 "chat_history"라는 이름으로 포함하는 프롬프트를 사용할 것입니다. 이를 통해 "chat_history" 입력 키를 사용하여 메시지 목록을 프롬프트에 전달할 수 있으며, 이러한 메시지는 시스템 메시지 뒤와 최신 질문을 포함하는 인간 메시지 앞에 삽입됩니다.

```python
<!--IMPORTS:[{"imported": "create_history_aware_retriever", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.history_aware_retriever.create_history_aware_retriever.html", "title": "How to add chat history"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to add chat history"}]-->
from langchain.chains import create_history_aware_retriever
from langchain_core.prompts import MessagesPlaceholder

contextualize_q_system_prompt = (
    "Given a chat history and the latest user question "
    "which might reference context in the chat history, "
    "formulate a standalone question which can be understood "
    "without the chat history. Do NOT answer the question, "
    "just reformulate it if needed and otherwise return it as is."
)

contextualize_q_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", contextualize_q_system_prompt),
        MessagesPlaceholder("chat_history"),
        ("human", "{input}"),
    ]
)
```


### 체인 조립

그런 다음 역사 인식 검색기를 인스턴스화할 수 있습니다:

```python
history_aware_retriever = create_history_aware_retriever(
    llm, retriever, contextualize_q_prompt
)
```


이 체인은 입력 쿼리의 재구성을 검색기 앞에 추가하여 검색이 대화의 맥락을 통합하도록 합니다.

이제 전체 QA 체인을 구축할 수 있습니다.

[RAG 튜토리얼](/docs/tutorials/rag)와 마찬가지로, [create_stuff_documents_chain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html)을 사용하여 `question_answer_chain`을 생성합니다. 입력 키는 `context`, `chat_history`, `input`이며, 검색된 컨텍스트와 대화 기록 및 쿼리를 함께 수용하여 답변을 생성합니다.

최종 `rag_chain`을 [create_retrieval_chain](https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html)으로 구축합니다. 이 체인은 `history_aware_retriever`와 `question_answer_chain`을 순차적으로 적용하여 편의를 위해 검색된 컨텍스트와 같은 중간 출력을 유지합니다. 입력 키는 `input` 및 `chat_history`이며, 출력에는 `input`, `chat_history`, `context`, `answer`가 포함됩니다.

```python
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
        MessagesPlaceholder("chat_history"),
        ("human", "{input}"),
    ]
)
question_answer_chain = create_stuff_documents_chain(llm, qa_prompt)

rag_chain = create_retrieval_chain(history_aware_retriever, question_answer_chain)
```


### 채팅 기록 추가

채팅 기록을 관리하기 위해 다음이 필요합니다:

1. 채팅 기록을 저장할 객체;
2. 체인을 래핑하고 채팅 기록 업데이트를 관리하는 객체.

이를 위해 [BaseChatMessageHistory](https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.BaseChatMessageHistory.html)와 [RunnableWithMessageHistory](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html)를 사용할 것입니다. 후자는 LCEL 체인과 `BaseChatMessageHistory`를 래핑하여 입력에 채팅 기록을 주입하고 각 호출 후 이를 업데이트하는 역할을 합니다.

이러한 클래스를 함께 사용하여 상태 유지 대화형 체인을 만드는 방법에 대한 자세한 설명은 [메시지 기록 추가하는 방법 (메모리)](/docs/how_to/message_history/) LCEL 가이드를 참조하십시오.

아래는 채팅 기록이 간단한 dict에 저장되는 두 번째 옵션의 간단한 예를 구현합니다. LangChain은 [Redis](/docs/integrations/memory/redis_chat_message_history/) 및 기타 기술과 함께 메모리 통합을 관리하여 더 강력한 지속성을 제공합니다.

`RunnableWithMessageHistory`의 인스턴스는 채팅 기록을 관리합니다. 이들은 입력에 추가할 대화 기록을 가져오고 같은 대화 기록에 출력을 추가하는 키(`"session_id"` 기본값)를 포함하는 구성을 수용합니다. 아래는 예시입니다:

```python
<!--IMPORTS:[{"imported": "ChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.ChatMessageHistory.html", "title": "How to add chat history"}, {"imported": "BaseChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.BaseChatMessageHistory.html", "title": "How to add chat history"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "How to add chat history"}]-->
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_core.chat_history import BaseChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory

store = {}


def get_session_history(session_id: str) -> BaseChatMessageHistory:
    if session_id not in store:
        store[session_id] = ChatMessageHistory()
    return store[session_id]


conversational_rag_chain = RunnableWithMessageHistory(
    rag_chain,
    get_session_history,
    input_messages_key="input",
    history_messages_key="chat_history",
    output_messages_key="answer",
)
```


```python
conversational_rag_chain.invoke(
    {"input": "What is Task Decomposition?"},
    config={
        "configurable": {"session_id": "abc123"}
    },  # constructs a key "abc123" in `store`.
)["answer"]
```


```output
'Task decomposition involves breaking down a complex task into smaller and simpler steps to make it more manageable and easier to accomplish. This process can be done using techniques like Chain of Thought (CoT) or Tree of Thoughts to guide the model in breaking down tasks effectively. Task decomposition can be facilitated by providing simple prompts to a language model, task-specific instructions, or human inputs.'
```


```python
conversational_rag_chain.invoke(
    {"input": "What are common ways of doing it?"},
    config={"configurable": {"session_id": "abc123"}},
)["answer"]
```


```output
'Task decomposition can be achieved through various methods, including using techniques like Chain of Thought (CoT) or Tree of Thoughts to guide the model in breaking down tasks effectively. Common ways of task decomposition include providing simple prompts to a language model, task-specific instructions, or human inputs to break down complex tasks into smaller and more manageable steps. Additionally, task decomposition can involve utilizing resources like internet access for information gathering, long-term memory management, and GPT-3.5 powered agents for delegation of simple tasks.'
```


대화 기록은 `store` dict에서 검사할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to add chat history"}]-->
from langchain_core.messages import AIMessage

for message in store["abc123"].messages:
    if isinstance(message, AIMessage):
        prefix = "AI"
    else:
        prefix = "User"

    print(f"{prefix}: {message.content}\n")
```

```output
User: What is Task Decomposition?

AI: Task decomposition involves breaking down a complex task into smaller and simpler steps to make it more manageable and easier to accomplish. This process can be done using techniques like Chain of Thought (CoT) or Tree of Thoughts to guide the model in breaking down tasks effectively. Task decomposition can be facilitated by providing simple prompts to a language model, task-specific instructions, or human inputs.

User: What are common ways of doing it?

AI: Task decomposition can be achieved through various methods, including using techniques like Chain of Thought (CoT) or Tree of Thoughts to guide the model in breaking down tasks effectively. Common ways of task decomposition include providing simple prompts to a language model, task-specific instructions, or human inputs to break down complex tasks into smaller and more manageable steps. Additionally, task decomposition can involve utilizing resources like internet access for information gathering, long-term memory management, and GPT-3.5 powered agents for delegation of simple tasks.
```

### 모든 것을 연결하기

![](../../static/img/conversational_retrieval_chain.png)

편의를 위해 모든 필요한 단계를 단일 코드 셀에 연결합니다:

```python
<!--IMPORTS:[{"imported": "create_history_aware_retriever", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.history_aware_retriever.create_history_aware_retriever.html", "title": "How to add chat history"}, {"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "How to add chat history"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "How to add chat history"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to add chat history"}, {"imported": "ChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.ChatMessageHistory.html", "title": "How to add chat history"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "How to add chat history"}, {"imported": "BaseChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.BaseChatMessageHistory.html", "title": "How to add chat history"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add chat history"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to add chat history"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "How to add chat history"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add chat history"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to add chat history"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to add chat history"}]-->
import bs4
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_chroma import Chroma
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_community.document_loaders import WebBaseLoader
from langchain_core.chat_history import BaseChatMessageHistory
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)


### Construct retriever ###
loader = WebBaseLoader(
    web_paths=("https://lilianweng.github.io/posts/2023-06-23-agent/",),
    bs_kwargs=dict(
        parse_only=bs4.SoupStrainer(
            class_=("post-content", "post-title", "post-header")
        )
    ),
)
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(docs)
vectorstore = Chroma.from_documents(documents=splits, embedding=OpenAIEmbeddings())
retriever = vectorstore.as_retriever()


### Contextualize question ###
contextualize_q_system_prompt = (
    "Given a chat history and the latest user question "
    "which might reference context in the chat history, "
    "formulate a standalone question which can be understood "
    "without the chat history. Do NOT answer the question, "
    "just reformulate it if needed and otherwise return it as is."
)
contextualize_q_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", contextualize_q_system_prompt),
        MessagesPlaceholder("chat_history"),
        ("human", "{input}"),
    ]
)
history_aware_retriever = create_history_aware_retriever(
    llm, retriever, contextualize_q_prompt
)


### Answer question ###
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
        MessagesPlaceholder("chat_history"),
        ("human", "{input}"),
    ]
)
question_answer_chain = create_stuff_documents_chain(llm, qa_prompt)

rag_chain = create_retrieval_chain(history_aware_retriever, question_answer_chain)


### Statefully manage chat history ###
store = {}


def get_session_history(session_id: str) -> BaseChatMessageHistory:
    if session_id not in store:
        store[session_id] = ChatMessageHistory()
    return store[session_id]


conversational_rag_chain = RunnableWithMessageHistory(
    rag_chain,
    get_session_history,
    input_messages_key="input",
    history_messages_key="chat_history",
    output_messages_key="answer",
)
```


```python
conversational_rag_chain.invoke(
    {"input": "What is Task Decomposition?"},
    config={
        "configurable": {"session_id": "abc123"}
    },  # constructs a key "abc123" in `store`.
)["answer"]
```


```output
'Task decomposition involves breaking down a complex task into smaller and simpler steps to make it more manageable. Techniques like Chain of Thought (CoT) and Tree of Thoughts help in decomposing hard tasks into multiple manageable tasks by instructing models to think step by step and explore multiple reasoning possibilities at each step. Task decomposition can be achieved through various methods such as using prompting techniques, task-specific instructions, or human inputs.'
```


```python
conversational_rag_chain.invoke(
    {"input": "What are common ways of doing it?"},
    config={"configurable": {"session_id": "abc123"}},
)["answer"]
```


```output
'Task decomposition can be done in common ways such as using prompting techniques like Chain of Thought (CoT) or Tree of Thoughts, which instruct models to think step by step and explore multiple reasoning possibilities at each step. Another way is to provide task-specific instructions, such as asking to "Write a story outline" for writing a novel, to guide the decomposition process. Additionally, task decomposition can also involve human inputs to break down complex tasks into smaller and simpler steps.'
```


## 에이전트 {#agents}

에이전트는 실행 중에 결정을 내리기 위해 LLM의 추론 능력을 활용합니다. 에이전트를 사용하면 검색 프로세스에 대한 일부 재량을 오프로드할 수 있습니다. 그들의 행동은 체인보다 덜 예측 가능하지만, 이 맥락에서 몇 가지 장점을 제공합니다:
- 에이전트는 검색기에 대한 입력을 직접 생성하므로 우리가 위에서 했던 것처럼 맥락화를 명시적으로 구축할 필요가 없습니다;
- 에이전트는 쿼리를 위해 여러 검색 단계를 실행하거나 검색 단계를 전혀 실행하지 않을 수 있습니다(예: 사용자의 일반적인 인사에 응답할 때).

### 검색 도구

에이전트는 "도구"에 접근하고 실행을 관리할 수 있습니다. 이 경우, 검색기를 LangChain 도구로 변환하여 에이전트가 사용할 수 있도록 합니다:

```python
<!--IMPORTS:[{"imported": "create_retriever_tool", "source": "langchain.tools.retriever", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.retriever.create_retriever_tool.html", "title": "How to add chat history"}]-->
from langchain.tools.retriever import create_retriever_tool

tool = create_retriever_tool(
    retriever,
    "blog_post_retriever",
    "Searches and returns excerpts from the Autonomous Agents blog post.",
)
tools = [tool]
```


### 에이전트 생성자

이제 도구와 LLM을 정의했으므로 에이전트를 생성할 수 있습니다. 에이전트를 구성하기 위해 [LangGraph](/docs/concepts/#langgraph)를 사용할 것입니다. 현재 우리는 에이전트를 구성하기 위해 높은 수준의 인터페이스를 사용하고 있지만, LangGraph의 좋은 점은 이 높은 수준의 인터페이스가 에이전트 논리를 수정하고자 할 때 사용할 수 있는 낮은 수준의 매우 제어 가능한 API에 의해 지원된다는 것입니다.

```python
from langgraph.prebuilt import create_react_agent

agent_executor = create_react_agent(llm, tools)
```


이제 시험해 볼 수 있습니다. 지금까지는 상태가 유지되지 않으며(여전히 메모리를 추가해야 함) 

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to add chat history"}]-->
from langchain_core.messages import HumanMessage

query = "What is Task Decomposition?"

for s in agent_executor.stream(
    {"messages": [HumanMessage(content=query)]},
):
    print(s)
    print("----")
```

```output
Error in LangChainTracer.on_tool_end callback: TracerException("Found chain run at ID 5cd28d13-88dd-4eac-a465-3770ac27eff6, but expected {'tool'} run.")
``````output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_TbhPPPN05GKi36HLeaN4QM90', 'function': {'arguments': '{"query":"Task Decomposition"}', 'name': 'blog_post_retriever'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 19, 'prompt_tokens': 68, 'total_tokens': 87}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-2e60d910-879a-4a2a-b1e9-6a6c5c7d7ebc-0', tool_calls=[{'name': 'blog_post_retriever', 'args': {'query': 'Task Decomposition'}, 'id': 'call_TbhPPPN05GKi36HLeaN4QM90'}])]}}
----
{'tools': {'messages': [ToolMessage(content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nFig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.', name='blog_post_retriever', tool_call_id='call_TbhPPPN05GKi36HLeaN4QM90')]}}
----
{'agent': {'messages': [AIMessage(content='Task decomposition is a technique used to break down complex tasks into smaller and simpler steps. This approach helps in transforming big tasks into multiple manageable tasks, making it easier for autonomous agents to handle and interpret the thinking process. One common method for task decomposition is the Chain of Thought (CoT) technique, where models are instructed to "think step by step" to decompose hard tasks. Another extension of CoT is the Tree of Thoughts, which explores multiple reasoning possibilities at each step by creating a tree structure of multiple thoughts per step. Task decomposition can be facilitated through various methods such as using simple prompts, task-specific instructions, or human inputs.', response_metadata={'token_usage': {'completion_tokens': 130, 'prompt_tokens': 636, 'total_tokens': 766}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-3ef17638-65df-4030-a7fe-795e6da91c69-0')]}}
----
```

LangGraph는 내장된 지속성을 제공하므로 ChatMessageHistory를 사용할 필요가 없습니다! 대신, LangGraph 에이전트에 직접 체크포인터를 전달할 수 있습니다.

구별된 대화는 구성 dict에서 대화 스레드에 대한 키를 지정하여 관리됩니다. 아래와 같이 보여집니다.

```python
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()

agent_executor = create_react_agent(llm, tools, checkpointer=memory)
```


이것이 대화형 RAG 에이전트를 구성하는 데 필요한 모든 것입니다.

그 행동을 관찰해 보겠습니다. 검색 단계가 필요하지 않은 쿼리를 입력하면 에이전트는 검색 단계를 실행하지 않습니다:

```python
config = {"configurable": {"thread_id": "abc123"}}

for s in agent_executor.stream(
    {"messages": [HumanMessage(content="Hi! I'm bob")]}, config=config
):
    print(s)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content='Hello Bob! How can I assist you today?', response_metadata={'token_usage': {'completion_tokens': 11, 'prompt_tokens': 67, 'total_tokens': 78}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-1cd17562-18aa-4839-b41b-403b17a0fc20-0')]}}
----
```

또한 검색 단계가 필요한 쿼리를 입력하면 에이전트는 도구에 대한 입력을 생성합니다:

```python
query = "What is Task Decomposition?"

for s in agent_executor.stream(
    {"messages": [HumanMessage(content=query)]}, config=config
):
    print(s)
    print("----")
```

```output
Error in LangChainTracer.on_tool_end callback: TracerException("Found chain run at ID c54381c0-c5d9-495a-91a0-aca4ae755663, but expected {'tool'} run.")
``````output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_rg7zKTE5e0ICxVSslJ1u9LMg', 'function': {'arguments': '{"query":"Task Decomposition"}', 'name': 'blog_post_retriever'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 19, 'prompt_tokens': 91, 'total_tokens': 110}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-122bf097-7ff1-49aa-b430-e362b51354ad-0', tool_calls=[{'name': 'blog_post_retriever', 'args': {'query': 'Task Decomposition'}, 'id': 'call_rg7zKTE5e0ICxVSslJ1u9LMg'}])]}}
----
{'tools': {'messages': [ToolMessage(content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nFig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.', name='blog_post_retriever', tool_call_id='call_rg7zKTE5e0ICxVSslJ1u9LMg')]}}
----
{'agent': {'messages': [AIMessage(content='Task decomposition is a technique used to break down complex tasks into smaller and simpler steps. This approach helps in managing and solving intricate problems by dividing them into more manageable components. By decomposing tasks, agents or models can better understand the steps involved and plan their actions accordingly. Techniques like Chain of Thought (CoT) and Tree of Thoughts are examples of methods that enhance model performance on complex tasks by breaking them down into smaller steps.', response_metadata={'token_usage': {'completion_tokens': 87, 'prompt_tokens': 659, 'total_tokens': 746}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-b9166386-83e5-4b82-9a4b-590e5fa76671-0')]}}
----
```

위에서 에이전트는 쿼리를 도구에 그대로 삽입하는 대신 "what"과 "is"와 같은 불필요한 단어를 제거했습니다.

이 동일한 원칙은 에이전트가 필요할 때 대화의 맥락을 사용할 수 있게 합니다:

```python
query = "What according to the blog post are common ways of doing it? redo the search"

for s in agent_executor.stream(
    {"messages": [HumanMessage(content=query)]}, config=config
):
    print(s)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_6kbxTU5CDWLmF9mrvR7bWSkI', 'function': {'arguments': '{"query":"Common ways of task decomposition"}', 'name': 'blog_post_retriever'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 21, 'prompt_tokens': 769, 'total_tokens': 790}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-2d2c8327-35cd-484a-b8fd-52436657c2d8-0', tool_calls=[{'name': 'blog_post_retriever', 'args': {'query': 'Common ways of task decomposition'}, 'id': 'call_6kbxTU5CDWLmF9mrvR7bWSkI'}])]}}
----
``````output
Error in LangChainTracer.on_tool_end callback: TracerException("Found chain run at ID 29553415-e0f4-41a9-8921-ba489e377f68, but expected {'tool'} run.")
``````output
{'tools': {'messages': [ToolMessage(content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nFig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.', name='blog_post_retriever', tool_call_id='call_6kbxTU5CDWLmF9mrvR7bWSkI')]}}
----
{'agent': {'messages': [AIMessage(content='Common ways of task decomposition include:\n1. Using LLM with simple prompting like "Steps for XYZ" or "What are the subgoals for achieving XYZ?"\n2. Using task-specific instructions, for example, "Write a story outline" for writing a novel.\n3. Involving human inputs in the task decomposition process.', response_metadata={'token_usage': {'completion_tokens': 67, 'prompt_tokens': 1339, 'total_tokens': 1406}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-9ad14cde-ca75-4238-a868-f865e0fc50dd-0')]}}
----
```

에이전트는 쿼리에서 "it"이 "task decomposition"을 참조한다는 것을 추론할 수 있었으며, 그 결과 합리적인 검색 쿼리를 생성했습니다. 이 경우 "common ways of task decomposition"입니다.

### 모든 것을 연결하기

편의를 위해 모든 필요한 단계를 단일 코드 셀에 연결합니다:

```python
<!--IMPORTS:[{"imported": "create_retriever_tool", "source": "langchain.tools.retriever", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.retriever.create_retriever_tool.html", "title": "How to add chat history"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to add chat history"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "How to add chat history"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add chat history"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to add chat history"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to add chat history"}]-->
import bs4
from langchain.tools.retriever import create_retriever_tool
from langchain_chroma import Chroma
from langchain_community.document_loaders import WebBaseLoader
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()
llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)


### Construct retriever ###
loader = WebBaseLoader(
    web_paths=("https://lilianweng.github.io/posts/2023-06-23-agent/",),
    bs_kwargs=dict(
        parse_only=bs4.SoupStrainer(
            class_=("post-content", "post-title", "post-header")
        )
    ),
)
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(docs)
vectorstore = Chroma.from_documents(documents=splits, embedding=OpenAIEmbeddings())
retriever = vectorstore.as_retriever()


### Build retriever tool ###
tool = create_retriever_tool(
    retriever,
    "blog_post_retriever",
    "Searches and returns excerpts from the Autonomous Agents blog post.",
)
tools = [tool]


agent_executor = create_react_agent(llm, tools, checkpointer=memory)
```


## 다음 단계

기본적인 대화형 Q&A 애플리케이션을 구축하는 단계를 다루었습니다:

- 우리는 체인을 사용하여 각 사용자 입력에 대한 검색 쿼리를 생성하는 예측 가능한 애플리케이션을 구축했습니다;
- 우리는 에이전트를 사용하여 검색 쿼리를 생성할 시기와 방법을 "결정하는" 애플리케이션을 구축했습니다.

다양한 유형의 검색기와 검색 전략을 탐색하려면 [검색기](/docs/how_to#retrievers) 섹션의 가이드를 방문하십시오.

LangChain의 대화 메모리 추상화에 대한 자세한 설명은 [메시지 기록 추가하는 방법 (메모리)](/docs/how_to/message_history) LCEL 페이지를 방문하십시오.

에이전트에 대해 더 알고 싶다면 [에이전트 모듈](/docs/tutorials/agents)로 이동하십시오.