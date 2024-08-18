---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/qa_streaming.ipynb
description: RAG 애플리케이션에서 결과를 스트리밍하는 방법을 설명하며, 최종 출력 및 중간 단계에서의 토큰 스트리밍을 다룹니다.
---

# RAG 애플리케이션에서 결과 스트리밍하는 방법

이 가이드는 RAG 애플리케이션에서 결과를 스트리밍하는 방법을 설명합니다. 최종 출력에서의 토큰 스트리밍과 체인의 중간 단계(예: 쿼리 재작성)에서의 스트리밍을 다룹니다.

우리는 Lilian Weng의 [RAG 튜토리얼](/docs/tutorials/rag) 블로그 게시물에서 구축한 소스를 가진 Q&A 앱을 기반으로 작업할 것입니다.

## 설정

### 의존성

이 walkthrough에서는 OpenAI 임베딩과 Chroma 벡터 저장소를 사용할 것이지만, 여기에서 보여지는 모든 것은 어떤 [임베딩](/docs/concepts#embedding-models), [벡터 저장소](/docs/concepts#vectorstores) 또는 [리트리버](/docs/concepts#retrievers)와도 작동합니다.

다음 패키지를 사용할 것입니다:

```python
%pip install --upgrade --quiet  langchain langchain-community langchainhub langchain-openai langchain-chroma bs4
```


우리는 환경 변수 `OPENAI_API_KEY`를 설정해야 하며, 이는 직접 설정하거나 다음과 같이 `.env` 파일에서 로드할 수 있습니다:

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()

# import dotenv

# dotenv.load_dotenv()
```


### LangSmith

LangChain으로 구축하는 많은 애플리케이션은 여러 단계와 여러 LLM 호출을 포함합니다. 이러한 애플리케이션이 점점 더 복잡해짐에 따라 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지를 검사할 수 있는 것이 중요해집니다. 이를 가장 잘 수행하는 방법은 [LangSmith](https://smith.langchain.com)를 사용하는 것입니다.

LangSmith는 필요하지 않지만 유용합니다. LangSmith를 사용하고 싶다면, 위 링크에서 가입한 후 환경 변수를 설정하여 추적 로그를 시작해야 합니다:

```python
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## RAG 체인

먼저 LLM을 선택해 봅시다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

여기 Lilian Weng의 [RAG 튜토리얼](/docs/tutorials/rag) 블로그 게시물에서 구축한 소스를 가진 Q&A 앱이 있습니다:

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "How to stream results from your RAG application"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "How to stream results from your RAG application"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to stream results from your RAG application"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "How to stream results from your RAG application"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to stream results from your RAG application"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to stream results from your RAG application"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to stream results from your RAG application"}]-->
import bs4
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


## 최종 출력 스트리밍

`create_retrieval_chain`로 구성된 체인은 `"input"`, `"context"`, `"answer"` 키를 가진 딕셔너리를 반환합니다. 기본적으로 `.stream` 메서드는 각 키를 순차적으로 스트리밍합니다.

여기서 `"answer"` 키만 토큰 단위로 스트리밍되며, 다른 구성 요소인 리트리벌은 토큰 수준 스트리밍을 지원하지 않습니다.

```python
for chunk in rag_chain.stream({"input": "What is Task Decomposition?"}):
    print(chunk)
```

```output
{'input': 'What is Task Decomposition?'}
{'context': [Document(page_content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.', metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}), Document(page_content='Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.', metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}), Document(page_content='Resources:\n1. Internet access for searches and information gathering.\n2. Long Term memory management.\n3. GPT-3.5 powered Agents for delegation of simple tasks.\n4. File output.\n\nPerformance Evaluation:\n1. Continuously review and analyze your actions to ensure you are performing to the best of your abilities.\n2. Constructively self-criticize your big-picture behavior constantly.\n3. Reflect on past decisions and strategies to refine your approach.\n4. Every command has a cost, so be smart and efficient. Aim to complete tasks in the least number of steps.', metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}), Document(page_content="(3) Task execution: Expert models execute on the specific tasks and log results.\nInstruction:\n\nWith the input and the inference results, the AI assistant needs to describe the process and results. The previous stages can be formed as - User Input: {{ User Input }}, Task Planning: {{ Tasks }}, Model Selection: {{ Model Assignment }}, Task Execution: {{ Predictions }}. You must first answer the user's request in a straightforward manner. Then describe the task process and show your analysis and model inference results to the user in the first person. If inference results contain a file path, must tell the user the complete file path.", metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'})]}
{'answer': ''}
{'answer': 'Task'}
{'answer': ' decomposition'}
{'answer': ' involves'}
{'answer': ' breaking'}
{'answer': ' down'}
{'answer': ' complex'}
{'answer': ' tasks'}
{'answer': ' into'}
{'answer': ' smaller'}
{'answer': ' and'}
{'answer': ' simpler'}
{'answer': ' steps'}
{'answer': ' to'}
{'answer': ' make'}
{'answer': ' them'}
{'answer': ' more'}
{'answer': ' manageable'}
{'answer': '.'}
{'answer': ' This'}
{'answer': ' process'}
{'answer': ' can'}
{'answer': ' be'}
{'answer': ' facilitated'}
{'answer': ' by'}
{'answer': ' techniques'}
{'answer': ' like'}
{'answer': ' Chain'}
{'answer': ' of'}
{'answer': ' Thought'}
{'answer': ' ('}
{'answer': 'Co'}
{'answer': 'T'}
{'answer': ')'}
{'answer': ' and'}
{'answer': ' Tree'}
{'answer': ' of'}
{'answer': ' Thoughts'}
{'answer': ','}
{'answer': ' which'}
{'answer': ' help'}
{'answer': ' agents'}
{'answer': ' plan'}
{'answer': ' and'}
{'answer': ' execute'}
{'answer': ' tasks'}
{'answer': ' effectively'}
{'answer': ' by'}
{'answer': ' dividing'}
{'answer': ' them'}
{'answer': ' into'}
{'answer': ' sub'}
{'answer': 'goals'}
{'answer': ' or'}
{'answer': ' multiple'}
{'answer': ' reasoning'}
{'answer': ' possibilities'}
{'answer': '.'}
{'answer': ' Task'}
{'answer': ' decomposition'}
{'answer': ' can'}
{'answer': ' be'}
{'answer': ' initiated'}
{'answer': ' through'}
{'answer': ' simple'}
{'answer': ' prompts'}
{'answer': ','}
{'answer': ' task'}
{'answer': '-specific'}
{'answer': ' instructions'}
{'answer': ','}
{'answer': ' or'}
{'answer': ' human'}
{'answer': ' inputs'}
{'answer': ' to'}
{'answer': ' guide'}
{'answer': ' the'}
{'answer': ' agent'}
{'answer': ' in'}
{'answer': ' achieving'}
{'answer': ' its'}
{'answer': ' goals'}
{'answer': ' efficiently'}
{'answer': '.'}
{'answer': ''}
```

우리는 스트리밍되는 청크를 자유롭게 처리할 수 있습니다. 예를 들어, 답변 토큰만 스트리밍하고 싶다면, 해당 키로 청크를 선택할 수 있습니다:

```python
for chunk in rag_chain.stream({"input": "What is Task Decomposition?"}):
    if answer_chunk := chunk.get("answer"):
        print(f"{answer_chunk}|", end="")
```

```output
Task| decomposition| is| a| technique| used| to| break| down| complex| tasks| into| smaller| and| more| manageable| steps|.| This| process| helps| agents| or| models| handle| intricate| tasks| by| dividing| them| into| simpler| sub|tasks|.| By| decom|posing| tasks|,| the| model| can| effectively| plan| and| execute| each| step| towards| achieving| the| overall| goal|.|
```

더 간단하게는, [.pick](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.pick) 메서드를 사용하여 원하는 키만 선택할 수 있습니다:

```python
chain = rag_chain.pick("answer")

for chunk in chain.stream({"input": "What is Task Decomposition?"}):
    print(f"{chunk}|", end="")
```

```output
|Task| decomposition| involves| breaking| down| complex| tasks| into| smaller| and| simpler| steps| to| make| them| more| manageable| for| an| agent| or| model| to| handle|.| This| process| helps| in| planning| and| executing| tasks| efficiently| by| dividing| them| into| a| series| of| sub|goals| or| actions|.| Task| decomposition| can| be| achieved| through| techniques| like| Chain| of| Thought| (|Co|T|)| or| Tree| of| Thoughts|,| which| enhance| model| performance| on| intricate| tasks| by| guiding| them| through| step|-by|-step| thinking| processes|.||
```

## 중간 단계 스트리밍

체인의 최종 출력뿐만 아니라 일부 중간 단계도 스트리밍하고 싶다고 가정해 봅시다. 예를 들어, 우리의 [대화형 RAG](/docs/tutorials/qa_chat_history) 체인을 살펴보겠습니다. 여기서 우리는 리트리버에 전달하기 전에 사용자 질문을 재구성합니다. 이 재구성된 질문은 최종 출력의 일부로 반환되지 않습니다. 우리는 체인을 수정하여 새로운 질문을 반환할 수 있지만, 시연 목적으로 그대로 두겠습니다.

```python
<!--IMPORTS:[{"imported": "create_history_aware_retriever", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.history_aware_retriever.create_history_aware_retriever.html", "title": "How to stream results from your RAG application"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to stream results from your RAG application"}]-->
from langchain.chains import create_history_aware_retriever
from langchain_core.prompts import MessagesPlaceholder

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
contextualize_q_llm = llm.with_config(tags=["contextualize_q_llm"])
history_aware_retriever = create_history_aware_retriever(
    contextualize_q_llm, retriever, contextualize_q_prompt
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
```


위에서 우리는 질문 재구성 단계에 사용되는 LLM에 태그를 할당하기 위해 `.with_config`를 사용합니다. 이는 필요하지 않지만 특정 단계에서 출력을 스트리밍하는 데 더 편리합니다.

시연을 위해 인위적인 메시지 기록을 전달하겠습니다:
```
Human: What is task decomposition?

AI: Task decomposition involves breaking up a complex task into smaller and simpler steps.
```

그런 다음 후속 질문을 합니다: "어떤 일반적인 방법이 있나요?" 리트리벌 단계로 이어지는 우리의 `history_aware_retriever`는 대화의 맥락을 사용하여 이 질문을 재구성하여 리트리벌이 의미 있게 되도록 합니다.

중간 출력을 스트리밍하기 위해 비동기 `.astream_events` 메서드의 사용을 권장합니다. 이 메서드는 체인의 모든 "이벤트"에서 출력을 스트리밍하며, 상당히 장황할 수 있습니다. 우리는 여기서와 같이 태그, 이벤트 유형 및 기타 기준을 사용하여 필터링할 수 있습니다.

아래는 체인 입력을 전달하고 원하는 결과를 방출하는 전형적인 `.astream_events` 루프를 보여줍니다. 더 자세한 내용은 [API 참조](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html#langchain_core.runnables.base.Runnable.astream_events) 및 [스트리밍 가이드](/docs/how_to/streaming)를 참조하십시오.

```python
first_question = "What is task decomposition?"
first_answer = (
    "Task decomposition involves breaking up "
    "a complex task into smaller and simpler "
    "steps."
)
follow_up_question = "What are some common ways of doing it?"

chat_history = [
    ("human", first_question),
    ("ai", first_answer),
]


async for event in rag_chain.astream_events(
    {
        "input": follow_up_question,
        "chat_history": chat_history,
    },
    version="v1",
):
    if (
        event["event"] == "on_chat_model_stream"
        and "contextualize_q_llm" in event["tags"]
    ):
        ai_message_chunk = event["data"]["chunk"]
        print(f"{ai_message_chunk.content}|", end="")
```

```output
|What| are| some| typical| methods| used| for| task| decomposition|?||
```

여기서 우리는 "어떤 일반적인 방법이 있나요?"라는 질문에 대해 리트리버에 전달된 쿼리를 토큰 단위로 복구합니다.

우리가 검색된 문서를 얻고 싶다면, 이름 "Retriever"로 필터링할 수 있습니다:

```python
async for event in rag_chain.astream_events(
    {
        "input": follow_up_question,
        "chat_history": chat_history,
    },
    version="v1",
):
    if event["name"] == "Retriever":
        print(event)
        print()
```

```output
{'event': 'on_retriever_start', 'name': 'Retriever', 'run_id': '6834097c-07fe-42f5-a566-a4780af4d1d0', 'tags': ['seq:step:4', 'Chroma', 'OpenAIEmbeddings'], 'metadata': {}, 'data': {'input': {'query': 'What are some typical methods used for task decomposition?'}}}

{'event': 'on_retriever_end', 'name': 'Retriever', 'run_id': '6834097c-07fe-42f5-a566-a4780af4d1d0', 'tags': ['seq:step:4', 'Chroma', 'OpenAIEmbeddings'], 'metadata': {}, 'data': {'input': {'query': 'What are some typical methods used for task decomposition?'}, 'output': {'documents': [Document(page_content='Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.', metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}), Document(page_content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.', metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}), Document(page_content='Resources:\n1. Internet access for searches and information gathering.\n2. Long Term memory management.\n3. GPT-3.5 powered Agents for delegation of simple tasks.\n4. File output.\n\nPerformance Evaluation:\n1. Continuously review and analyze your actions to ensure you are performing to the best of your abilities.\n2. Constructively self-criticize your big-picture behavior constantly.\n3. Reflect on past decisions and strategies to refine your approach.\n4. Every command has a cost, so be smart and efficient. Aim to complete tasks in the least number of steps.', metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}), Document(page_content='Fig. 9. Comparison of MIPS algorithms, measured in recall@10. (Image source: Google Blog, 2020)\nCheck more MIPS algorithms and performance comparison in ann-benchmarks.com.\nComponent Three: Tool Use#\nTool use is a remarkable and distinguishing characteristic of human beings. We create, modify and utilize external objects to do things that go beyond our physical and cognitive limits. Equipping LLMs with external tools can significantly extend the model capabilities.', metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'})]}}}
```

중간 단계를 스트리밍하는 방법에 대한 자세한 내용은 [스트리밍 가이드](/docs/how_to/streaming)를 확인하십시오.