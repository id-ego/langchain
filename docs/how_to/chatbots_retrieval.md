---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/chatbots_retrieval.ipynb
description: 챗봇에 데이터 검색 기능을 추가하는 방법을 다루며, 설정 및 검색기 생성 과정을 설명합니다.
sidebar_position: 2
---

# 챗봇에 검색 기능 추가하는 방법

검색은 챗봇이 훈련 데이터 외부의 데이터를 사용하여 응답을 보강하는 데 사용하는 일반적인 기술입니다. 이 섹션에서는 챗봇의 맥락에서 검색을 구현하는 방법을 다룰 것이지만, 검색은 매우 미묘하고 깊은 주제라는 점에 유의해야 합니다. 더 깊이 있는 내용을 원하시면 [문서의 다른 부분](/docs/how_to#qa-with-rag)을 탐색해 보시기 바랍니다!

## 설정

몇 가지 패키지를 설치하고, OpenAI API 키를 `OPENAI_API_KEY`라는 환경 변수로 설정해야 합니다:

```python
%pip install -qU langchain langchain-openai langchain-chroma beautifulsoup4

# Set env var OPENAI_API_KEY or load from a .env file:
import dotenv

dotenv.load_dotenv()
```

```output
[33mWARNING: You are using pip version 22.0.4; however, version 23.3.2 is available.
You should consider upgrading via the '/Users/jacoblee/.pyenv/versions/3.10.5/bin/python -m pip install --upgrade pip' command.[0m[33m
[0mNote: you may need to restart the kernel to use updated packages.
```


```output
True
```


아래 예제에서 사용할 챗 모델도 설정해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add retrieval to chatbots"}]-->
from langchain_openai import ChatOpenAI

chat = ChatOpenAI(model="gpt-3.5-turbo-1106", temperature=0.2)
```


## 검색기 생성

우리는 [LangSmith 문서](https://docs.smith.langchain.com/overview)를 소스 자료로 사용하고, 내용을 나중에 검색할 수 있도록 벡터 저장소에 저장할 것입니다. 이 예제는 데이터 소스를 파싱하고 저장하는 것에 대한 세부 사항을 간단히 다룰 것이므로, [검색 시스템 생성에 대한 더 심층적인 문서](/docs/how_to#qa-with-rag)를 참조하시기 바랍니다.

문서 로더를 사용하여 문서에서 텍스트를 가져오겠습니다:

```python
<!--IMPORTS:[{"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "How to add retrieval to chatbots"}]-->
from langchain_community.document_loaders import WebBaseLoader

loader = WebBaseLoader("https://docs.smith.langchain.com/overview")
data = loader.load()
```


다음으로, LLM의 컨텍스트 창이 처리할 수 있는 더 작은 청크로 나누고 이를 벡터 데이터베이스에 저장합니다:

```python
<!--IMPORTS:[{"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to add retrieval to chatbots"}]-->
from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0)
all_splits = text_splitter.split_documents(data)
```


그런 다음, 이러한 청크를 임베드하고 벡터 데이터베이스에 저장합니다:

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to add retrieval to chatbots"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to add retrieval to chatbots"}]-->
from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings

vectorstore = Chroma.from_documents(documents=all_splits, embedding=OpenAIEmbeddings())
```


마지막으로, 초기화된 벡터 저장소에서 검색기를 생성해 보겠습니다:

```python
# k is the number of chunks to retrieve
retriever = vectorstore.as_retriever(k=4)

docs = retriever.invoke("Can LangSmith help test my LLM applications?")

docs
```


```output
[Document(page_content='Skip to main content🦜️🛠️ LangSmith DocsPython DocsJS/TS DocsSearchGo to AppLangSmithOverviewTracingTesting & EvaluationOrganizationsHubLangSmith CookbookOverviewOn this pageLangSmith Overview and User GuideBuilding reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.Over the past two months, we at LangChain', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
 Document(page_content='LangSmith Overview and User Guide | 🦜️🛠️ LangSmith', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
 Document(page_content='You can also quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs.Monitoring\u200bAfter all this, your app might finally ready to go in production. LangSmith can also be used to monitor your application in much the same way that you used for debugging. You can log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise. Each run can also be', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
 Document(page_content="does that affect the output?\u200bSo you notice a bad output, and you go into LangSmith to see what's going on. You find the faulty LLM call and are now looking at the exact input. You want to try changing a word or a phrase to see what happens -- what do you do?We constantly ran into this issue. Initially, we copied the prompt to a playground of sorts. But this got annoying, so we built a playground of our own! When examining an LLM call, you can click the Open in Playground button to access this", metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'})]
```


위의 검색기를 호출하면 우리 챗봇이 질문에 답할 때 사용할 수 있는 테스트에 대한 정보를 포함한 LangSmith 문서의 일부를 얻을 수 있습니다. 이제 LangSmith 문서에서 관련 데이터를 반환할 수 있는 검색기를 갖추게 되었습니다!

## 문서 체인

이제 LangChain 문서를 반환할 수 있는 검색기를 갖추었으므로, 이를 사용하여 질문에 답할 수 있는 체인을 생성해 보겠습니다. 우리는 `create_stuff_documents_chain` 도우미 함수를 사용하여 모든 입력 문서를 프롬프트에 "채워 넣을" 것입니다. 이 함수는 문서를 문자열로 포맷하는 것도 처리합니다.

챗 모델 외에도, 이 함수는 `context` 변수를 포함하는 프롬프트와 `messages`라는 이름의 채팅 기록 메시지에 대한 자리 표시자를 기대합니다. 적절한 프롬프트를 생성하고 아래와 같이 전달하겠습니다:

```python
<!--IMPORTS:[{"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "How to add retrieval to chatbots"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add retrieval to chatbots"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to add retrieval to chatbots"}]-->
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

SYSTEM_TEMPLATE = """
Answer the user's questions based on the below context. 
If the context doesn't contain any relevant information to the question, don't make something up and just say "I don't know":

<context>
{context}
</context>
"""

question_answering_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            SYSTEM_TEMPLATE,
        ),
        MessagesPlaceholder(variable_name="messages"),
    ]
)

document_chain = create_stuff_documents_chain(chat, question_answering_prompt)
```


우리는 이 `document_chain`을 단독으로 호출하여 질문에 답할 수 있습니다. 위에서 검색한 문서와 동일한 질문인 `langsmith가 테스트에 어떻게 도움이 될 수 있나요?`를 사용해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to add retrieval to chatbots"}]-->
from langchain_core.messages import HumanMessage

document_chain.invoke(
    {
        "context": docs,
        "messages": [
            HumanMessage(content="Can LangSmith help test my LLM applications?")
        ],
    }
)
```


```output
'Yes, LangSmith can help test and evaluate your LLM applications. It simplifies the initial setup, and you can use it to monitor your application, log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise.'
```


좋습니다! 비교를 위해, 컨텍스트 문서 없이 시도해 보고 결과를 비교해 보겠습니다:

```python
document_chain.invoke(
    {
        "context": [],
        "messages": [
            HumanMessage(content="Can LangSmith help test my LLM applications?")
        ],
    }
)
```


```output
"I don't know about LangSmith's specific capabilities for testing LLM applications. It's best to reach out to LangSmith directly to inquire about their services and how they can assist with testing your LLM applications."
```


LLM이 결과를 반환하지 않는 것을 볼 수 있습니다.

## 검색 체인

이 문서 체인을 검색기와 결합해 보겠습니다. 다음은 이 조합의 한 가지 예입니다:

```python
<!--IMPORTS:[{"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to add retrieval to chatbots"}]-->
from typing import Dict

from langchain_core.runnables import RunnablePassthrough


def parse_retriever_input(params: Dict):
    return params["messages"][-1].content


retrieval_chain = RunnablePassthrough.assign(
    context=parse_retriever_input | retriever,
).assign(
    answer=document_chain,
)
```


입력 메시지 목록이 주어지면, 목록에서 마지막 메시지의 내용을 추출하고 이를 검색기에 전달하여 문서를 가져옵니다. 그런 다음, 이러한 문서를 컨텍스트로 문서 체인에 전달하여 최종 응답을 생성합니다.

이 체인을 호출하면 위에서 설명한 두 단계를 결합합니다:

```python
retrieval_chain.invoke(
    {
        "messages": [
            HumanMessage(content="Can LangSmith help test my LLM applications?")
        ],
    }
)
```


```output
{'messages': [HumanMessage(content='Can LangSmith help test my LLM applications?')],
 'context': [Document(page_content='Skip to main content🦜️🛠️ LangSmith DocsPython DocsJS/TS DocsSearchGo to AppLangSmithOverviewTracingTesting & EvaluationOrganizationsHubLangSmith CookbookOverviewOn this pageLangSmith Overview and User GuideBuilding reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.Over the past two months, we at LangChain', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
  Document(page_content='LangSmith Overview and User Guide | 🦜️🛠️ LangSmith', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
  Document(page_content='You can also quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs.Monitoring\u200bAfter all this, your app might finally ready to go in production. LangSmith can also be used to monitor your application in much the same way that you used for debugging. You can log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise. Each run can also be', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
  Document(page_content="does that affect the output?\u200bSo you notice a bad output, and you go into LangSmith to see what's going on. You find the faulty LLM call and are now looking at the exact input. You want to try changing a word or a phrase to see what happens -- what do you do?We constantly ran into this issue. Initially, we copied the prompt to a playground of sorts. But this got annoying, so we built a playground of our own! When examining an LLM call, you can click the Open in Playground button to access this", metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'})],
 'answer': 'Yes, LangSmith can help test and evaluate your LLM applications. It simplifies the initial setup, and you can use it to monitor your application, log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise.'}
```


좋습니다!

## 쿼리 변환

우리의 검색 체인은 LangSmith에 대한 질문에 답할 수 있지만, 문제가 있습니다 - 챗봇은 사용자와 대화식으로 상호작용하며, 따라서 후속 질문을 처리해야 합니다.

현재 형태의 체인은 이 문제를 처리하는 데 어려움을 겪을 것입니다. 원래 질문에 대한 후속 질문인 `더 말해 주세요!`를 고려해 보십시오. 그 쿼리로 검색기를 직접 호출하면 LLM 애플리케이션 테스트와 관련 없는 문서를 얻게 됩니다:

```python
retriever.invoke("Tell me more!")
```


```output
[Document(page_content='You can also quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs.Monitoring\u200bAfter all this, your app might finally ready to go in production. LangSmith can also be used to monitor your application in much the same way that you used for debugging. You can log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise. Each run can also be', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
 Document(page_content='playground. Here, you can modify the prompt and re-run it to observe the resulting changes to the output - as many times as needed!Currently, this feature supports only OpenAI and Anthropic models and works for LLM and Chat Model calls. We plan to extend its functionality to more LLM types, chains, agents, and retrievers in the future.What is the exact sequence of events?\u200bIn complicated chains and agents, it can often be hard to understand what is going on under the hood. What calls are being', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
 Document(page_content='however, there is still no complete substitute for human review to get the utmost quality and reliability from your application.', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
 Document(page_content='Skip to main content🦜️🛠️ LangSmith DocsPython DocsJS/TS DocsSearchGo to AppLangSmithOverviewTracingTesting & EvaluationOrganizationsHubLangSmith CookbookOverviewOn this pageLangSmith Overview and User GuideBuilding reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.Over the past two months, we at LangChain', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'})]
```


이는 검색기가 상태에 대한 고유한 개념이 없으며, 주어진 쿼리와 가장 유사한 문서만 가져오기 때문입니다. 이를 해결하기 위해 쿼리를 LLM과 외부 참조가 없는 독립적인 쿼리로 변환할 수 있습니다.

예를 들어:

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to add retrieval to chatbots"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to add retrieval to chatbots"}]-->
from langchain_core.messages import AIMessage, HumanMessage

query_transform_prompt = ChatPromptTemplate.from_messages(
    [
        MessagesPlaceholder(variable_name="messages"),
        (
            "user",
            "Given the above conversation, generate a search query to look up in order to get information relevant to the conversation. Only respond with the query, nothing else.",
        ),
    ]
)

query_transformation_chain = query_transform_prompt | chat

query_transformation_chain.invoke(
    {
        "messages": [
            HumanMessage(content="Can LangSmith help test my LLM applications?"),
            AIMessage(
                content="Yes, LangSmith can help test and evaluate your LLM applications. It allows you to quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs. Additionally, LangSmith can be used to monitor your application, log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise."
            ),
            HumanMessage(content="Tell me more!"),
        ],
    }
)
```


```output
AIMessage(content='"LangSmith LLM application testing and evaluation"')
```


멋집니다! 변환된 쿼리는 LLM 애플리케이션 테스트와 관련된 컨텍스트 문서를 가져올 것입니다.

이것을 검색 체인에 추가해 보겠습니다. 검색기를 다음과 같이 래핑할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to add retrieval to chatbots"}, {"imported": "RunnableBranch", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.branch.RunnableBranch.html", "title": "How to add retrieval to chatbots"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnableBranch

query_transforming_retriever_chain = RunnableBranch(
    (
        lambda x: len(x.get("messages", [])) == 1,
        # If only one message, then we just pass that message's content to retriever
        (lambda x: x["messages"][-1].content) | retriever,
    ),
    # If messages, then we pass inputs to LLM chain to transform the query, then pass to retriever
    query_transform_prompt | chat | StrOutputParser() | retriever,
).with_config(run_name="chat_retriever_chain")
```


그런 다음, 이 쿼리 변환 체인을 사용하여 검색 체인이 이러한 후속 질문을 더 잘 처리할 수 있도록 만들 수 있습니다:

```python
SYSTEM_TEMPLATE = """
Answer the user's questions based on the below context. 
If the context doesn't contain any relevant information to the question, don't make something up and just say "I don't know":

<context>
{context}
</context>
"""

question_answering_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            SYSTEM_TEMPLATE,
        ),
        MessagesPlaceholder(variable_name="messages"),
    ]
)

document_chain = create_stuff_documents_chain(chat, question_answering_prompt)

conversational_retrieval_chain = RunnablePassthrough.assign(
    context=query_transforming_retriever_chain,
).assign(
    answer=document_chain,
)
```


멋집니다! 이전과 동일한 입력으로 이 새로운 체인을 호출해 보겠습니다:

```python
conversational_retrieval_chain.invoke(
    {
        "messages": [
            HumanMessage(content="Can LangSmith help test my LLM applications?"),
        ]
    }
)
```


```output
{'messages': [HumanMessage(content='Can LangSmith help test my LLM applications?')],
 'context': [Document(page_content='Skip to main content🦜️🛠️ LangSmith DocsPython DocsJS/TS DocsSearchGo to AppLangSmithOverviewTracingTesting & EvaluationOrganizationsHubLangSmith CookbookOverviewOn this pageLangSmith Overview and User GuideBuilding reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.Over the past two months, we at LangChain', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
  Document(page_content='LangSmith Overview and User Guide | 🦜️🛠️ LangSmith', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
  Document(page_content='You can also quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs.Monitoring\u200bAfter all this, your app might finally ready to go in production. LangSmith can also be used to monitor your application in much the same way that you used for debugging. You can log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise. Each run can also be', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
  Document(page_content="does that affect the output?\u200bSo you notice a bad output, and you go into LangSmith to see what's going on. You find the faulty LLM call and are now looking at the exact input. You want to try changing a word or a phrase to see what happens -- what do you do?We constantly ran into this issue. Initially, we copied the prompt to a playground of sorts. But this got annoying, so we built a playground of our own! When examining an LLM call, you can click the Open in Playground button to access this", metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'})],
 'answer': 'Yes, LangSmith can help test and evaluate LLM (Language Model) applications. It simplifies the initial setup, and you can use it to monitor your application, log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise.'}
```


```python
conversational_retrieval_chain.invoke(
    {
        "messages": [
            HumanMessage(content="Can LangSmith help test my LLM applications?"),
            AIMessage(
                content="Yes, LangSmith can help test and evaluate your LLM applications. It allows you to quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs. Additionally, LangSmith can be used to monitor your application, log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise."
            ),
            HumanMessage(content="Tell me more!"),
        ],
    }
)
```


```output
{'messages': [HumanMessage(content='Can LangSmith help test my LLM applications?'),
  AIMessage(content='Yes, LangSmith can help test and evaluate your LLM applications. It allows you to quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs. Additionally, LangSmith can be used to monitor your application, log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise.'),
  HumanMessage(content='Tell me more!')],
 'context': [Document(page_content='LangSmith Overview and User Guide | 🦜️🛠️ LangSmith', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
  Document(page_content='You can also quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs.Monitoring\u200bAfter all this, your app might finally ready to go in production. LangSmith can also be used to monitor your application in much the same way that you used for debugging. You can log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise. Each run can also be', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
  Document(page_content='Skip to main content🦜️🛠️ LangSmith DocsPython DocsJS/TS DocsSearchGo to AppLangSmithOverviewTracingTesting & EvaluationOrganizationsHubLangSmith CookbookOverviewOn this pageLangSmith Overview and User GuideBuilding reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.Over the past two months, we at LangChain', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}),
  Document(page_content='LangSmith makes it easy to manually review and annotate runs through annotation queues.These queues allow you to select any runs based on criteria like model type or automatic evaluation scores, and queue them up for human review. As a reviewer, you can then quickly step through the runs, viewing the input, output, and any existing tags before adding your own feedback.We often use this for a couple of reasons:To assess subjective qualities that automatic evaluators struggle with, like', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'})],
 'answer': 'LangSmith simplifies the initial setup for building reliable LLM applications, but it acknowledges that there is still work needed to bring the performance of prompts, chains, and agents up to the level where they are reliable enough to be used in production. It also provides the capability to manually review and annotate runs through annotation queues, allowing you to select runs based on criteria like model type or automatic evaluation scores for human review. This feature is particularly useful for assessing subjective qualities that automatic evaluators struggle with.'}
```


[이 LangSmith 추적](https://smith.langchain.com/public/bb329a3b-e92a-4063-ad78-43f720fbb5a2/r)를 확인하여 내부 쿼리 변환 단계를 직접 확인할 수 있습니다.

## 스트리밍

이 체인은 LCEL로 구성되어 있으므로, `.stream()`와 같은 친숙한 메서드를 사용할 수 있습니다:

```python
stream = conversational_retrieval_chain.stream(
    {
        "messages": [
            HumanMessage(content="Can LangSmith help test my LLM applications?"),
            AIMessage(
                content="Yes, LangSmith can help test and evaluate your LLM applications. It allows you to quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs. Additionally, LangSmith can be used to monitor your application, log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise."
            ),
            HumanMessage(content="Tell me more!"),
        ],
    }
)

for chunk in stream:
    print(chunk)
```

```output
{'messages': [HumanMessage(content='Can LangSmith help test my LLM applications?'), AIMessage(content='Yes, LangSmith can help test and evaluate your LLM applications. It allows you to quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs. Additionally, LangSmith can be used to monitor your application, log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise.'), HumanMessage(content='Tell me more!')]}
{'context': [Document(page_content='LangSmith Overview and User Guide | 🦜️🛠️ LangSmith', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}), Document(page_content='You can also quickly edit examples and add them to datasets to expand the surface area of your evaluation sets or to fine-tune a model for improved quality or reduced costs.Monitoring\u200bAfter all this, your app might finally ready to go in production. LangSmith can also be used to monitor your application in much the same way that you used for debugging. You can log all traces, visualize latency and token usage statistics, and troubleshoot specific issues as they arise. Each run can also be', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}), Document(page_content='Skip to main content🦜️🛠️ LangSmith DocsPython DocsJS/TS DocsSearchGo to AppLangSmithOverviewTracingTesting & EvaluationOrganizationsHubLangSmith CookbookOverviewOn this pageLangSmith Overview and User GuideBuilding reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.Over the past two months, we at LangChain', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'}), Document(page_content='LangSmith makes it easy to manually review and annotate runs through annotation queues.These queues allow you to select any runs based on criteria like model type or automatic evaluation scores, and queue them up for human review. As a reviewer, you can then quickly step through the runs, viewing the input, output, and any existing tags before adding your own feedback.We often use this for a couple of reasons:To assess subjective qualities that automatic evaluators struggle with, like', metadata={'description': 'Building reliable LLM applications can be challenging. LangChain simplifies the initial setup, but there is still work needed to bring the performance of prompts, chains and agents up the level where they are reliable enough to be used in production.', 'language': 'en', 'source': 'https://docs.smith.langchain.com/overview', 'title': 'LangSmith Overview and User Guide | 🦜️🛠️ LangSmith'})]}
{'answer': ''}
{'answer': 'Lang'}
{'answer': 'Smith'}
{'answer': ' simpl'}
{'answer': 'ifies'}
{'answer': ' the'}
{'answer': ' initial'}
{'answer': ' setup'}
{'answer': ' for'}
{'answer': ' building'}
{'answer': ' reliable'}
{'answer': ' L'}
{'answer': 'LM'}
{'answer': ' applications'}
{'answer': '.'}
{'answer': ' It'}
{'answer': ' provides'}
{'answer': ' features'}
{'answer': ' for'}
{'answer': ' manually'}
{'answer': ' reviewing'}
{'answer': ' and'}
{'answer': ' annot'}
{'answer': 'ating'}
{'answer': ' runs'}
{'answer': ' through'}
{'answer': ' annotation'}
{'answer': ' queues'}
{'answer': ','}
{'answer': ' allowing'}
{'answer': ' you'}
{'answer': ' to'}
{'answer': ' select'}
{'answer': ' runs'}
{'answer': ' based'}
{'answer': ' on'}
{'answer': ' criteria'}
{'answer': ' like'}
{'answer': ' model'}
{'answer': ' type'}
{'answer': ' or'}
{'answer': ' automatic'}
{'answer': ' evaluation'}
{'answer': ' scores'}
{'answer': ','}
{'answer': ' and'}
{'answer': ' queue'}
{'answer': ' them'}
{'answer': ' up'}
{'answer': ' for'}
{'answer': ' human'}
{'answer': ' review'}
{'answer': '.'}
{'answer': ' As'}
{'answer': ' a'}
{'answer': ' reviewer'}
{'answer': ','}
{'answer': ' you'}
{'answer': ' can'}
{'answer': ' quickly'}
{'answer': ' step'}
{'answer': ' through'}
{'answer': ' the'}
{'answer': ' runs'}
{'answer': ','}
{'answer': ' view'}
{'answer': ' the'}
{'answer': ' input'}
{'answer': ','}
{'answer': ' output'}
{'answer': ','}
{'answer': ' and'}
{'answer': ' any'}
{'answer': ' existing'}
{'answer': ' tags'}
{'answer': ' before'}
{'answer': ' adding'}
{'answer': ' your'}
{'answer': ' own'}
{'answer': ' feedback'}
{'answer': '.'}
{'answer': ' This'}
{'answer': ' can'}
{'answer': ' be'}
{'answer': ' particularly'}
{'answer': ' useful'}
{'answer': ' for'}
{'answer': ' assessing'}
{'answer': ' subjective'}
{'answer': ' qualities'}
{'answer': ' that'}
{'answer': ' automatic'}
{'answer': ' evalu'}
{'answer': 'ators'}
{'answer': ' struggle'}
{'answer': ' with'}
{'answer': '.'}
{'answer': ''}
```

## 추가 읽기

이 가이드는 검색 기술의 표면만 긁어냅니다. 가장 관련성 높은 데이터를 수집, 준비 및 검색하는 다양한 방법에 대한 자세한 내용은 관련된 방법 가이드를 [여기](/docs/how_to#document-loaders)에서 확인해 보시기 바랍니다.