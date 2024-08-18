---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/qa_sources.ipynb
description: RAG 애플리케이션에서 답변에 사용된 출처를 반환하는 방법을 설명합니다. 두 가지 접근 방식을 다룹니다.
---

# RAG 애플리케이션에서 출처를 반환하는 방법

Q&A 애플리케이션에서는 사용자가 답변을 생성하는 데 사용된 출처를 보여주는 것이 중요합니다. 이를 가장 간단하게 수행하는 방법은 체인이 각 생성에서 검색된 문서를 반환하는 것입니다.

우리는 Lilian Weng의 [RAG 튜토리얼](/docs/tutorials/rag) 블로그 게시물에서 구축한 Q&A 앱을 기반으로 작업할 것입니다. 

두 가지 접근 방식을 다룰 것입니다:

1. 기본적으로 출처를 반환하는 내장 [create_retrieval_chain](https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html) 사용;
2. 운영 원리를 보여주기 위한 간단한 [LCEL](/docs/concepts#langchain-expression-language-lcel) 구현.

또한 모델 응답에 출처를 구조화하는 방법을 보여드릴 것이며, 이를 통해 모델이 답변을 생성하는 데 사용한 특정 출처를 보고할 수 있습니다.

## 설정

### 종속성

이 안내서에서는 OpenAI 임베딩과 Chroma 벡터 저장소를 사용할 것이지만, 여기에서 보여지는 모든 것은 어떤 [임베딩](/docs/concepts#embedding-models), [벡터 저장소](/docs/concepts#vectorstores) 또는 [검색기](/docs/concepts#retrievers)와도 작동합니다.

다음 패키지를 사용할 것입니다:

```python
%pip install --upgrade --quiet  langchain langchain-community langchainhub langchain-openai langchain-chroma bs4
```


환경 변수 `OPENAI_API_KEY`를 설정해야 하며, 이는 직접 설정하거나 다음과 같이 `.env` 파일에서 로드할 수 있습니다:

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()

# import dotenv

# dotenv.load_dotenv()
```


### LangSmith

LangChain으로 구축하는 많은 애플리케이션은 여러 단계와 여러 LLM 호출을 포함합니다. 이러한 애플리케이션이 점점 더 복잡해짐에 따라 체인이나 에이전트 내부에서 정확히 무슨 일이 일어나고 있는지를 검사할 수 있는 것이 중요해집니다. 이를 가장 잘 수행하는 방법은 [LangSmith](https://smith.langchain.com)입니다.

LangSmith는 필요하지 않지만 유용합니다. LangSmith를 사용하고 싶다면 위 링크에서 가입한 후 환경 변수를 설정하여 추적 로그를 시작하세요:

```python
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


## `create_retrieval_chain` 사용하기

먼저 LLM을 선택해 보겠습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

다음은 Lilian Weng의 [RAG 튜토리얼](/docs/tutorials/rag) 블로그 게시물에서 구축한 출처가 포함된 Q&A 앱입니다:

```python
<!--IMPORTS:[{"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "How to get your RAG application to return sources"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "How to get your RAG application to return sources"}, {"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to get your RAG application to return sources"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "How to get your RAG application to return sources"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to get your RAG application to return sources"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to get your RAG application to return sources"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to get your RAG application to return sources"}]-->
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


```python
result = rag_chain.invoke({"input": "What is Task Decomposition?"})
```


`result`는 `"input"`, `"context"`, `"answer"` 키를 가진 dict입니다:

```python
result
```


```output
{'input': 'What is Task Decomposition?',
 'context': [Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}, page_content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}, page_content='Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}, page_content='Resources:\n1. Internet access for searches and information gathering.\n2. Long Term memory management.\n3. GPT-3.5 powered Agents for delegation of simple tasks.\n4. File output.\n\nPerformance Evaluation:\n1. Continuously review and analyze your actions to ensure you are performing to the best of your abilities.\n2. Constructively self-criticize your big-picture behavior constantly.\n3. Reflect on past decisions and strategies to refine your approach.\n4. Every command has a cost, so be smart and efficient. Aim to complete tasks in the least number of steps.'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}, page_content="(3) Task execution: Expert models execute on the specific tasks and log results.\nInstruction:\n\nWith the input and the inference results, the AI assistant needs to describe the process and results. The previous stages can be formed as - User Input: {{ User Input }}, Task Planning: {{ Tasks }}, Model Selection: {{ Model Assignment }}, Task Execution: {{ Predictions }}. You must first answer the user's request in a straightforward manner. Then describe the task process and show your analysis and model inference results to the user in the first person. If inference results contain a file path, must tell the user the complete file path.")],
 'answer': 'Task decomposition involves breaking down a complex task into smaller and more manageable steps. This process helps agents or models tackle difficult tasks by dividing them into simpler subtasks or components. Task decomposition can be achieved through techniques like Chain of Thought or Tree of Thoughts, which guide the agent in breaking down tasks into sequential or branching steps.'}
```


여기서 `"context"`는 LLM이 `"answer"`에서 응답을 생성하는 데 사용한 출처를 포함합니다.

## 사용자 정의 LCEL 구현

아래에서는 `create_retrieval_chain`으로 구축된 것과 유사한 체인을 구성합니다. 이는 dict를 구축하여 작동합니다:

1. 입력 쿼리로 dict를 시작하고, `"context"` 키에 검색된 문서를 추가합니다;
2. 쿼리와 컨텍스트를 RAG 체인에 공급하고 결과를 dict에 추가합니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to get your RAG application to return sources"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to get your RAG application to return sources"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


# This Runnable takes a dict with keys 'input' and 'context',
# formats them into a prompt, and generates a response.
rag_chain_from_docs = (
    {
        "input": lambda x: x["input"],  # input query
        "context": lambda x: format_docs(x["context"]),  # context
    }
    | prompt  # format query and context into prompt
    | llm  # generate response
    | StrOutputParser()  # coerce to string
)

# Pass input query to retriever
retrieve_docs = (lambda x: x["input"]) | retriever

# Below, we chain `.assign` calls. This takes a dict and successively
# adds keys-- "context" and "answer"-- where the value for each key
# is determined by a Runnable. The Runnable operates on all existing
# keys in the dict.
chain = RunnablePassthrough.assign(context=retrieve_docs).assign(
    answer=rag_chain_from_docs
)

chain.invoke({"input": "What is Task Decomposition"})
```


```output
{'input': 'What is Task Decomposition',
 'context': [Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}, page_content='Fig. 1. Overview of a LLM-powered autonomous agent system.\nComponent One: Planning#\nA complicated task usually involves many steps. An agent needs to know what they are and plan ahead.\nTask Decomposition#\nChain of thought (CoT; Wei et al. 2022) has become a standard prompting technique for enhancing model performance on complex tasks. The model is instructed to “think step by step” to utilize more test-time computation to decompose hard tasks into smaller and simpler steps. CoT transforms big tasks into multiple manageable tasks and shed lights into an interpretation of the model’s thinking process.'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}, page_content='Tree of Thoughts (Yao et al. 2023) extends CoT by exploring multiple reasoning possibilities at each step. It first decomposes the problem into multiple thought steps and generates multiple thoughts per step, creating a tree structure. The search process can be BFS (breadth-first search) or DFS (depth-first search) with each state evaluated by a classifier (via a prompt) or majority vote.\nTask decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}, page_content='The AI assistant can parse user input to several tasks: [{"task": task, "id", task_id, "dep": dependency_task_ids, "args": {"text": text, "image": URL, "audio": URL, "video": URL}}]. The "dep" field denotes the id of the previous task which generates a new resource that the current task relies on. A special tag "-task_id" refers to the generated text image, audio and video in the dependency task with id as task_id. The task MUST be selected from the following options: {{ Available Task List }}. There is a logical relationship between tasks, please note their order. If the user input can\'t be parsed, you need to reply empty JSON. Here are several cases for your reference: {{ Demonstrations }}. The chat history is recorded as {{ Chat History }}. From this chat history, you can find the path of the user-mentioned resources for your task planning.'),
  Document(metadata={'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/'}, page_content='Fig. 11. Illustration of how HuggingGPT works. (Image source: Shen et al. 2023)\nThe system comprises of 4 stages:\n(1) Task planning: LLM works as the brain and parses the user requests into multiple tasks. There are four attributes associated with each task: task type, ID, dependencies, and arguments. They use few-shot examples to guide LLM to do task parsing and planning.\nInstruction:')],
 'answer': 'Task decomposition is a technique used in artificial intelligence to break down complex tasks into smaller and more manageable subtasks. This approach helps agents or models to tackle difficult problems by dividing them into simpler steps, improving performance and interpretability. Different methods like Chain of Thought and Tree of Thoughts have been developed to enhance task decomposition in AI systems.'}
```


:::tip

[LangSmith 추적](https://smith.langchain.com/public/1c055a3b-0236-4670-a3fb-023d418ba796/r)을 확인하세요.

:::

## 모델 응답에 출처 구조화하기

지금까지 우리는 검색 단계에서 반환된 문서를 최종 응답으로 단순히 전달했습니다. 하지만 이는 모델이 답변을 생성하는 데 의존한 정보의 하위 집합을 설명하지 않을 수 있습니다. 아래에서는 출처를 모델 응답에 구조화하는 방법을 보여주어, 모델이 답변을 위해 의존한 특정 컨텍스트를 보고할 수 있도록 합니다.

위의 LCEL 구현은 [Runnable](/docs/concepts/#runnable-interface) 원시 요소로 구성되어 있으므로 확장하기가 간단합니다. 아래에서는 간단한 변경을 합니다:

- 모델의 도구 호출 기능을 사용하여 답변과 출처 목록으로 구성된 [구조화된 출력](/docs/how_to/structured_output/)을 생성합니다. 응답의 스키마는 아래의 `AnswerWithSources` TypedDict로 표현됩니다.
- 이 시나리오에서는 `dict` 출력을 예상하므로 `StrOutputParser()`를 제거합니다.

```python
<!--IMPORTS:[{"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to get your RAG application to return sources"}]-->
from typing import List

from langchain_core.runnables import RunnablePassthrough
from typing_extensions import Annotated, TypedDict


# Desired schema for response
class AnswerWithSources(TypedDict):
    """An answer to the question, with sources."""

    answer: str
    sources: Annotated[
        List[str],
        ...,
        "List of sources (author + year) used to answer the question",
    ]


# Our rag_chain_from_docs has the following changes:
# - add `.with_structured_output` to the LLM;
# - remove the output parser
rag_chain_from_docs = (
    {
        "input": lambda x: x["input"],
        "context": lambda x: format_docs(x["context"]),
    }
    | prompt
    | llm.with_structured_output(AnswerWithSources)
)

retrieve_docs = (lambda x: x["input"]) | retriever

chain = RunnablePassthrough.assign(context=retrieve_docs).assign(
    answer=rag_chain_from_docs
)

response = chain.invoke({"input": "What is Chain of Thought?"})
```


```python
import json

print(json.dumps(response["answer"], indent=2))
```

```output
{
  "answer": "Chain of Thought (CoT) is a prompting technique that enhances model performance on complex tasks by instructing the model to \"think step by step\" to decompose hard tasks into smaller and simpler steps. It transforms big tasks into multiple manageable tasks and sheds light on the interpretation of the model's thinking process.",
  "sources": [
    "Wei et al. 2022"
  ]
}
```

:::tip

[LangSmith 추적](https://smith.langchain.com/public/0eeddf06-3a7b-4f27-974c-310ca8160f60/r)을 확인하세요.

:::