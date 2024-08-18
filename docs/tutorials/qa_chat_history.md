---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/qa_chat_history.ipynb
description: 이 문서는 대화형 RAG를 위한 가이드를 제공하며, 과거 메시지를 통합하는 방법에 대해 설명합니다.
sidebar_position: 2
---

# 대화형 RAG

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [채팅 기록](/docs/concepts/#chat-history)
- [채팅 모델](/docs/concepts/#chat-models)
- [임베딩](/docs/concepts/#embedding-models)
- [벡터 저장소](/docs/concepts/#vector-stores)
- [검색 증강 생성](/docs/tutorials/rag/)
- [도구](/docs/concepts/#tools)
- [에이전트](/docs/concepts/#agents)

:::

많은 Q&A 애플리케이션에서는 사용자가 상호작용할 수 있는 대화를 허용하고자 합니다. 즉, 애플리케이션은 과거 질문과 답변에 대한 일종의 "기억"과 이를 현재 사고에 통합하는 논리가 필요합니다.

이 가이드에서는 **역사적 메시지를 통합하는 논리 추가**에 중점을 둡니다. 채팅 기록 관리에 대한 자세한 내용은 [여기에서 다룹니다](/docs/how_to/message_history).

두 가지 접근 방식을 다룰 것입니다:

1. 항상 검색 단계를 실행하는 체인;
2. LLM이 검색 단계를 실행할지 여부와 방법에 대한 재량을 가지는 에이전트.

외부 지식 출처로는 [RAG 튜토리얼](/docs/tutorials/rag)에서 Lilian Weng의 [LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/) 블로그 게시물을 사용할 것입니다.

## 설정

### 의존성

이 안내서에서는 OpenAI 임베딩과 Chroma 벡터 저장소를 사용할 예정이지만, 여기에서 보여지는 모든 내용은 모든 [임베딩](/docs/concepts#embedding-models) 및 [벡터 저장소](/docs/concepts#vectorstores) 또는 [검색기](/docs/concepts#retrievers)와 함께 작동합니다.

다음 패키지를 사용할 것입니다:

```python
%%capture --no-stderr
%pip install --upgrade --quiet  langchain langchain-community langchainhub langchain-chroma bs4
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

LangSmith는 필요하지 않지만 유용합니다. LangSmith를 사용하고 싶다면 위 링크에서 가입한 후, 추적을 기록하기 위해 환경 변수를 설정해야 합니다:

```python
os.environ["LANGCHAIN_TRACING_V2"] = "true"
if not os.environ.get("LANGCHAIN_API_KEY"):
    os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## 체인 {#chains}

먼저 Lilian Weng의 [LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/) 블로그 게시물에서 구축한 Q&A 앱을 다시 살펴보겠습니다.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "Conversational RAG"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "Conversational RAG"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Conversational RAG"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Conversational RAG"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Conversational RAG"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Conversational RAG"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Conversational RAG"}]-->
import bs4
from langchain import hub
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_chroma import Chroma
from langchain_community.document_loaders import WebBaseLoader
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

# 1. Load, chunk and index the contents of the blog to create a retriever.
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


# 2. Incorporate the retriever into a question-answering chain.
system_prompt = (
    "You are an assistant for question-answering tasks. "
    "Use the following pieces of retrieved context to answer "
    "the question. If you don't know the answer, say that you "
    "don't know. Use three sentences maximum and keep the "
    "answer concise."
    "\n\n"
    "{context}"
)

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        ("human", "{input}"),
    ]
)

question_answer_chain = create_stuff_documents_chain(llm, prompt)
rag_chain = create_retrieval_chain(retriever, question_answer_chain)
```


```python
response = rag_chain.invoke({"input": "What is Task Decomposition?"})
response["answer"]
```


```output
"Task decomposition involves breaking down complex tasks into smaller and simpler steps to make them more manageable for an agent or model. This process helps in guiding the agent through the various subgoals required to achieve the overall task efficiently. Different techniques like Chain of Thought and Tree of Thoughts can be used to decompose tasks into step-by-step processes, enhancing performance and understanding of the model's thinking process."
```


기본 솔루션의 기본 요소는 다음과 같습니다:

1. 검색기;
2. 프롬프트;
3. LLM.

이것은 채팅 기록을 통합하는 과정을 단순화합니다.

### 채팅 기록 추가

우리가 구축한 체인은 입력 쿼리를 직접 사용하여 관련 컨텍스트를 검색합니다. 그러나 대화 설정에서는 사용자 쿼리가 이해되기 위해 대화 컨텍스트가 필요할 수 있습니다. 예를 들어, 다음과 같은 대화를 고려해 보십시오:

> 인간: "작업 분해란 무엇인가요?"
> 
> AI: "작업 분해는 복잡한 작업을 더 작고 단순한 단계로 나누어 에이전트나 모델이 더 쉽게 관리할 수 있도록 하는 것입니다."
> 
> 인간: "그것을 하는 일반적인 방법은 무엇인가요?"

두 번째 질문에 답하기 위해 시스템은 "그것"이 "작업 분해"를 가리킨다는 것을 이해해야 합니다.

기존 앱에 대해 두 가지를 업데이트해야 합니다:

1. **프롬프트**: 역사적 메시지를 입력으로 지원하도록 프롬프트를 업데이트합니다.
2. **질문 맥락화**: 최신 사용자 질문을 가져와 채팅 기록의 맥락에서 재구성하는 하위 체인을 추가합니다. 이는 단순히 새로운 "역사 인식" 검색기를 구축하는 것으로 생각할 수 있습니다. 이전에는:
   - `query` -> `retriever`\
이제 우리는 다음과 같이 됩니다:
   - `(query, conversation history)` -> `LLM` -> `rephrased query` -> `retriever`

#### 질문 맥락화

먼저 역사적 메시지와 최신 사용자 질문을 받아들이고, 역사적 정보에 대한 참조가 있을 경우 질문을 재구성하는 하위 체인을 정의해야 합니다.

우리는 `MessagesPlaceholder` 변수를 "chat_history"라는 이름으로 포함하는 프롬프트를 사용할 것입니다. 이를 통해 "chat_history" 입력 키를 사용하여 메시지 목록을 프롬프트에 전달할 수 있으며, 이러한 메시지는 시스템 메시지 다음과 최신 질문을 포함하는 인간 메시지 이전에 삽입됩니다.

우리는 이 단계에서 `chat_history`가 비어 있는 경우를 관리하고, 그렇지 않으면 `prompt | llm | StrOutputParser() | retriever`를 순차적으로 적용하는 도우미 함수 [create_history_aware_retriever](https://api.python.langchain.com/en/latest/chains/langchain.chains.history_aware_retriever.create_history_aware_retriever.html)를 활용합니다.

`create_history_aware_retriever`는 `input` 및 `chat_history` 키를 입력으로 받아들이고, 검색기와 동일한 출력 스키마를 가집니다.

```python
<!--IMPORTS:[{"imported": "create_history_aware_retriever", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.history_aware_retriever.create_history_aware_retriever.html", "title": "Conversational RAG"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Conversational RAG"}]-->
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
history_aware_retriever = create_history_aware_retriever(
    llm, retriever, contextualize_q_prompt
)
```


이 체인은 입력 쿼리의 재구성을 검색기에 추가하여 검색이 대화의 맥락을 통합하도록 합니다.

이제 전체 QA 체인을 구축할 수 있습니다. 이는 검색기를 새로운 `history_aware_retriever`로 업데이트하는 것만큼 간단합니다.

다시 말해, 우리는 [create_stuff_documents_chain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html)를 사용하여 `question_answer_chain`을 생성할 것입니다. 입력 키는 `context`, `chat_history`, `input`이며, 검색된 컨텍스트와 함께 대화 기록 및 쿼리를 수용하여 답변을 생성합니다. 더 자세한 설명은 [여기에서](/docs/tutorials/rag/#built-in-chains) 확인할 수 있습니다.

최종 `rag_chain`은 [create_retrieval_chain](https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html)을 사용하여 구축합니다. 이 체인은 `history_aware_retriever`와 `question_answer_chain`을 순차적으로 적용하며, 편의를 위해 검색된 컨텍스트와 같은 중간 출력을 유지합니다. 입력 키는 `input` 및 `chat_history`이며, 출력에는 `input`, `chat_history`, `context`, `answer`가 포함됩니다.

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "Conversational RAG"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "Conversational RAG"}]-->
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain

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


이제 시도해 보겠습니다. 아래에서는 질문과 맥락화가 필요한 후속 질문을 합니다. 우리의 체인에는 `"chat_history"` 입력이 포함되어 있으므로 호출자는 채팅 기록을 관리해야 합니다. 이는 입력 및 출력 메시지를 목록에 추가하여 달성할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "Conversational RAG"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Conversational RAG"}]-->
from langchain_core.messages import AIMessage, HumanMessage

chat_history = []

question = "What is Task Decomposition?"
ai_msg_1 = rag_chain.invoke({"input": question, "chat_history": chat_history})
chat_history.extend(
    [
        HumanMessage(content=question),
        AIMessage(content=ai_msg_1["answer"]),
    ]
)

second_question = "What are common ways of doing it?"
ai_msg_2 = rag_chain.invoke({"input": second_question, "chat_history": chat_history})

print(ai_msg_2["answer"])
```

```output
Task decomposition can be achieved through various methods such as using techniques like Chain of Thought (CoT) or Tree of Thoughts to break down complex tasks into smaller steps. Common ways include prompting the model with simple instructions like "Steps for XYZ" or task-specific instructions like "Write a story outline." Human inputs can also be used to guide the task decomposition process effectively.
```

:::tip

[LangSmith 추적](https://smith.langchain.com/public/243301e4-4cc5-4e52-a6e7-8cfe9208398d/r)를 확인해 보세요.

:::

#### 채팅 기록의 상태 관리

여기에서는 역사적 출력을 통합하기 위한 애플리케이션 논리를 추가하는 방법을 살펴보았지만, 여전히 채팅 기록을 수동으로 업데이트하고 각 입력에 삽입하고 있습니다. 실제 Q&A 애플리케이션에서는 채팅 기록을 지속시키고 이를 자동으로 삽입 및 업데이트하는 방법이 필요합니다.

이를 위해 다음을 사용할 수 있습니다:

- [BaseChatMessageHistory](https://api.python.langchain.com/en/latest/langchain_api_reference.html#module-langchain.memory): 채팅 기록 저장.
- [RunnableWithMessageHistory](/docs/how_to/message_history): LCEL 체인과 `BaseChatMessageHistory`의 래퍼로, 입력에 채팅 기록을 주입하고 각 호출 후 업데이트하는 기능을 처리합니다.

이러한 클래스를 함께 사용하여 상태가 있는 대화형 체인을 만드는 방법에 대한 자세한 설명은 [메시지 기록 추가 방법 (메모리)](/docs/how_to/message_history) LCEL 페이지를 참조하세요.

아래에서는 채팅 기록이 간단한 dict에 저장되는 두 번째 옵션의 간단한 예제를 구현합니다. LangChain은 [Redis](/docs/integrations/memory/redis_chat_message_history/) 및 기타 기술과의 메모리 통합을 관리하여 더 강력한 지속성을 제공합니다.

`RunnableWithMessageHistory`의 인스턴스는 채팅 기록을 관리합니다. 이들은 입력에 추가할 대화 기록을 가져오기 위해 키(`"session_id"`가 기본값)로 구성된 구성을 수용하고, 출력은 동일한 대화 기록에 추가합니다. 아래는 예제입니다:

```python
<!--IMPORTS:[{"imported": "ChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.ChatMessageHistory.html", "title": "Conversational RAG"}, {"imported": "BaseChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.BaseChatMessageHistory.html", "title": "Conversational RAG"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Conversational RAG"}]-->
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
'Task decomposition involves breaking down complex tasks into smaller and simpler steps to make them more manageable. Techniques like Chain of Thought (CoT) and Tree of Thoughts help models decompose hard tasks into multiple manageable subtasks. This process allows agents to plan ahead and tackle intricate tasks effectively.'
```


```python
conversational_rag_chain.invoke(
    {"input": "What are common ways of doing it?"},
    config={"configurable": {"session_id": "abc123"}},
)["answer"]
```


```output
'Task decomposition can be achieved through various methods such as using Language Model (LLM) with simple prompting, task-specific instructions tailored to the specific task at hand, or incorporating human inputs to break down the task into smaller components. These approaches help in guiding agents to think step by step and decompose complex tasks into more manageable subgoals.'
```


대화 기록은 `store` dict에서 확인할 수 있습니다:

```python
for message in store["abc123"].messages:
    if isinstance(message, AIMessage):
        prefix = "AI"
    else:
        prefix = "User"

    print(f"{prefix}: {message.content}\n")
```

```output
User: What is Task Decomposition?

AI: Task decomposition involves breaking down complex tasks into smaller and simpler steps to make them more manageable. Techniques like Chain of Thought (CoT) and Tree of Thoughts help models decompose hard tasks into multiple manageable subtasks. This process allows agents to plan ahead and tackle intricate tasks effectively.

User: What are common ways of doing it?

AI: Task decomposition can be achieved through various methods such as using Language Model (LLM) with simple prompting, task-specific instructions tailored to the specific task at hand, or incorporating human inputs to break down the task into smaller components. These approaches help in guiding agents to think step by step and decompose complex tasks into more manageable subgoals.
```

### 통합하기

![](../../static/img/conversational_retrieval_chain.png)

편의를 위해 모든 필수 단계를 단일 코드 셀에 묶습니다:

```python
<!--IMPORTS:[{"imported": "create_history_aware_retriever", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.history_aware_retriever.create_history_aware_retriever.html", "title": "Conversational RAG"}, {"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "Conversational RAG"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "Conversational RAG"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Conversational RAG"}, {"imported": "ChatMessageHistory", "source": "langchain_community.chat_message_histories", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.ChatMessageHistory.html", "title": "Conversational RAG"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Conversational RAG"}, {"imported": "BaseChatMessageHistory", "source": "langchain_core.chat_history", "docs": "https://api.python.langchain.com/en/latest/chat_history/langchain_core.chat_history.BaseChatMessageHistory.html", "title": "Conversational RAG"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Conversational RAG"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "Conversational RAG"}, {"imported": "RunnableWithMessageHistory", "source": "langchain_core.runnables.history", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.history.RunnableWithMessageHistory.html", "title": "Conversational RAG"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Conversational RAG"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Conversational RAG"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Conversational RAG"}]-->
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
'Task decomposition is a technique used to break down complex tasks into smaller and simpler steps. It involves transforming big tasks into multiple manageable tasks to facilitate problem-solving. Different methods like Chain of Thought and Tree of Thoughts can be employed to decompose tasks effectively.'
```


```python
conversational_rag_chain.invoke(
    {"input": "What are common ways of doing it?"},
    config={"configurable": {"session_id": "abc123"}},
)["answer"]
```


```output
'Task decomposition can be achieved through various methods such as using prompting techniques like "Steps for XYZ" or "What are the subgoals for achieving XYZ?", providing task-specific instructions like "Write a story outline," or incorporating human inputs to break down complex tasks into smaller components. These approaches help in organizing thoughts and planning ahead for successful task completion.'
```


## 에이전트 {#agents}

에이전트는 실행 중에 결정을 내리기 위해 LLM의 추론 능력을 활용합니다. 에이전트를 사용하면 검색 프로세스에 대한 일부 재량을 오프로드할 수 있습니다. 그들의 행동은 체인보다 덜 예측 가능하지만, 이 맥락에서 몇 가지 장점을 제공합니다:

- 에이전트는 검색기에 대한 입력을 직접 생성하며, 위에서 했던 것처럼 반드시 맥락화를 명시적으로 구축할 필요가 없습니다;
- 에이전트는 쿼리를 위해 여러 검색 단계를 실행하거나, 사용자로부터의 일반적인 인사에 대한 응답으로 검색 단계를 전혀 실행하지 않을 수 있습니다.

### 검색 도구

에이전트는 "도구"에 접근하고 실행을 관리할 수 있습니다. 이 경우, 우리는 검색기를 에이전트가 사용할 수 있는 LangChain 도구로 변환할 것입니다:

```python
<!--IMPORTS:[{"imported": "create_retriever_tool", "source": "langchain.tools.retriever", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.retriever.create_retriever_tool.html", "title": "Conversational RAG"}]-->
from langchain.tools.retriever import create_retriever_tool

tool = create_retriever_tool(
    retriever,
    "blog_post_retriever",
    "Searches and returns excerpts from the Autonomous Agents blog post.",
)
tools = [tool]
```


도구는 LangChain [Runnables](/docs/concepts#langchain-expression-language-lcel)이며, 일반적인 인터페이스를 구현합니다:

```python
tool.invoke("task decomposition")
```


```output
'Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.\n\nFig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nFig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.'
```


### 에이전트 생성자

이제 도구와 LLM을 정의했으므로 에이전트를 생성할 수 있습니다. 우리는 [LangGraph](/docs/concepts/#langgraph)를 사용하여 에이전트를 구성할 것입니다. 현재 우리는 에이전트를 구성하기 위해 고급 인터페이스를 사용하고 있지만, LangGraph의 장점은 이 고급 인터페이스가 에이전트 논리를 수정하고자 할 경우 저수준의 매우 제어 가능한 API에 의해 지원된다는 것입니다.

```python
from langgraph.prebuilt import create_react_agent

agent_executor = create_react_agent(llm, tools)
```


이제 시도해 볼 수 있습니다. 지금까지는 상태가 없으므로(여전히 메모리를 추가해야 함) 주의하세요.

```python
query = "What is Task Decomposition?"

for s in agent_executor.stream(
    {"messages": [HumanMessage(content=query)]},
):
    print(s)
    print("----")
```

```output
Error in LangChainTracer.on_tool_end callback: TracerException("Found chain run at ID 1a50f4da-34a7-44af-8cbb-c67c90c9619e, but expected {'tool'} run.")
``````output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_1ZkTWsLYIlKZ1uMyIQGUuyJx', 'function': {'arguments': '{"query":"Task Decomposition"}', 'name': 'blog_post_retriever'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 19, 'prompt_tokens': 68, 'total_tokens': 87}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-dddbe2d2-2355-4ca5-9961-1ceb39d78cf9-0', tool_calls=[{'name': 'blog_post_retriever', 'args': {'query': 'Task Decomposition'}, 'id': 'call_1ZkTWsLYIlKZ1uMyIQGUuyJx'}])]}}
----
{'tools': {'messages': [ToolMessage(content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nFig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.', name='blog_post_retriever', tool_call_id='call_1ZkTWsLYIlKZ1uMyIQGUuyJx')]}}
----
{'agent': {'messages': [AIMessage(content='Task decomposition is a technique used to break down complex tasks into smaller and simpler steps. This approach helps in managing and solving difficult tasks by dividing them into more manageable components. One common method of task decomposition is the Chain of Thought (CoT) technique, where models are instructed to think step by step to decompose hard tasks into smaller steps. Another extension of CoT is the Tree of Thoughts, which explores multiple reasoning possibilities at each step and generates multiple thoughts per step, creating a tree structure. Task decomposition can be facilitated by using simple prompts, task-specific instructions, or human inputs.', response_metadata={'token_usage': {'completion_tokens': 119, 'prompt_tokens': 636, 'total_tokens': 755}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-4a701854-97f2-4ec2-b6e1-73410911fa72-0')]}}
----
```

LangGraph는 내장된 지속성을 제공하므로 ChatMessageHistory를 사용할 필요가 없습니다! 대신, LangGraph 에이전트에 직접 체크포인터를 전달할 수 있습니다.

```python
from langgraph.checkpoint.memory import MemorySaver

memory = MemorySaver()

agent_executor = create_react_agent(llm, tools, checkpointer=memory)
```


대화형 RAG 에이전트를 구성하는 데 필요한 모든 것입니다.

그 행동을 관찰해 봅시다. 검색 단계를 필요로 하지 않는 쿼리를 입력하면 에이전트는 검색 단계를 실행하지 않습니다:

```python
config = {"configurable": {"thread_id": "abc123"}}

for s in agent_executor.stream(
    {"messages": [HumanMessage(content="Hi! I'm bob")]}, config=config
):
    print(s)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content='Hello Bob! How can I assist you today?', response_metadata={'token_usage': {'completion_tokens': 11, 'prompt_tokens': 67, 'total_tokens': 78}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-022806f0-eb26-4c87-9132-ed2fcc6c21ea-0')]}}
----
```

또한 검색 단계를 필요로 하는 쿼리를 입력하면 에이전트는 도구에 대한 입력을 생성합니다:

```python
query = "What is Task Decomposition?"

for s in agent_executor.stream(
    {"messages": [HumanMessage(content=query)]}, config=config
):
    print(s)
    print("----")
```

```output
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_DdAAJJgGIQOZQgKVE4duDyML', 'function': {'arguments': '{"query":"Task Decomposition"}', 'name': 'blog_post_retriever'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 19, 'prompt_tokens': 91, 'total_tokens': 110}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': None, 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-acc3c903-4f6f-48dd-8b36-f6f3b80d0856-0', tool_calls=[{'name': 'blog_post_retriever', 'args': {'query': 'Task Decomposition'}, 'id': 'call_DdAAJJgGIQOZQgKVE4duDyML'}])]}}
----
``````output
Error in LangChainTracer.on_tool_end callback: TracerException("Found chain run at ID 9a7ba580-ec91-412d-9649-1b5cbf5ae7bc, but expected {'tool'} run.")
``````output
{'tools': {'messages': [ToolMessage(content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nFig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.\n\nTree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.', name='blog_post_retriever', tool_call_id='call_DdAAJJgGIQOZQgKVE4duDyML')]}}
----
```

위에서 에이전트는 도구에 쿼리를 그대로 삽입하는 대신 "what"과 "is"와 같은 불필요한 단어를 제거했습니다.

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
{'agent': {'messages': [AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_KvoiamnLfGEzMeEMlV3u0TJ7', 'function': {'arguments': '{"query":"common ways of task decomposition"}', 'name': 'blog_post_retriever'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 21, 'prompt_tokens': 930, 'total_tokens': 951}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_3b956da36b', 'finish_reason': 'tool_calls', 'logprobs': None}, id='run-dd842071-6dbd-4b68-8657-892eaca58638-0', tool_calls=[{'name': 'blog_post_retriever', 'args': {'query': 'common ways of task decomposition'}, 'id': 'call_KvoiamnLfGEzMeEMlV3u0TJ7'}])]}}
----
{'action': {'messages': [ToolMessage(content='Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.\n\nFig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.\n\nResources:\n1. Internet access for searches and information gathering.\n2. Long Term memory management.\n3. GPT-3.5 powered Agents for delegation of simple tasks.\n4. File output.\n\nPerformance Evaluation:\n1. Continuously review and analyze your actions to ensure you are performing to the best of your abilities.\n2. Constructively self-criticize your big-picture behavior constantly.\n3. Reflect on past decisions and strategies to refine your approach.\n4. Every command has a cost, so be smart and efficient. Aim to complete tasks in the least number of steps.\n\n(3) Task execution: Expert models execute on the specific tasks and log results.\nInstruction:\n\nWith the input and the inference results, the AI assistant needs to describe the process and results. The previous stages can be formed as - User Input: {{ User Input }}, Task Planning: {{ Tasks }}, Model Selection: {{ Model Assignment }}, Task Execution: {{ Predictions }}. You must first answer the user\'s request in a straightforward manner. Then describe the task process and show your analysis and model inference results to the user in the first person. If inference results contain a file path, must tell the user the complete file path.', name='blog_post_retriever', id='c749bb8e-c8e0-4fa3-bc11-3e2e0651880b', tool_call_id='call_KvoiamnLfGEzMeEMlV3u0TJ7')]}}
----
{'agent': {'messages': [AIMessage(content='According to the blog post, common ways of task decomposition include:\n\n1. Using language models with simple prompting like "Steps for XYZ" or "What are the subgoals for achieving XYZ?"\n2. Utilizing task-specific instructions, for example, using "Write a story outline" for writing a novel.\n3. Involving human inputs in the task decomposition process.\n\nThese methods help in breaking down complex tasks into smaller and more manageable steps, facilitating better planning and execution of the overall task.', response_metadata={'token_usage': {'completion_tokens': 100, 'prompt_tokens': 1475, 'total_tokens': 1575}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_3b956da36b', 'finish_reason': 'stop', 'logprobs': None}, id='run-98b765b3-f1a6-4c9a-ad0f-2db7950b900f-0')]}}
----
```

에이전트는 쿼리에서 "그것"이 "작업 분해"를 가리킨다는 것을 추론할 수 있었고, 그 결과로 합리적인 검색 쿼리인 "작업 분해의 일반적인 방법"을 생성했습니다.

### 통합하기

편의를 위해 모든 필수 단계를 단일 코드 셀에 묶습니다:

```python
<!--IMPORTS:[{"imported": "create_retriever_tool", "source": "langchain.tools.retriever", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.retriever.create_retriever_tool.html", "title": "Conversational RAG"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Conversational RAG"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Conversational RAG"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Conversational RAG"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Conversational RAG"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Conversational RAG"}]-->
import bs4
from langchain.tools.retriever import create_retriever_tool
from langchain_chroma import Chroma
from langchain_community.document_loaders import WebBaseLoader
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langgraph.checkpoint.memory import MemorySaver
from langgraph.prebuilt import create_react_agent

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

기본 대화형 Q&A 애플리케이션을 구축하는 단계를 다루었습니다:

- 우리는 체인을 사용하여 각 사용자 입력에 대한 검색 쿼리를 생성하는 예측 가능한 애플리케이션을 구축했습니다;
- 우리는 에이전트를 사용하여 검색 쿼리를 생성할 때와 방법을 "결정"하는 애플리케이션을 구축했습니다.

다양한 유형의 검색기와 검색 전략을 탐색하려면 [검색기](/docs/how_to/#retrievers) 섹션의 가이드에서 확인하세요.

LangChain의 대화 메모리 추상화에 대한 자세한 설명은 [메시지 기록 추가 방법 (메모리)](/docs/how_to/message_history) LCEL 페이지를 방문하세요.

에이전트에 대해 더 알아보려면 [에이전트 모듈](/docs/tutorials/agents)로 이동하세요.