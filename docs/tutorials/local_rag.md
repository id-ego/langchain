---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/local_rag.ipynb
description: 로컬에서 LLM을 실행하고, 로컬 임베딩 및 LLM을 사용하여 RAG 애플리케이션을 구축하는 방법을 안내합니다.
---

# 로컬 RAG 애플리케이션 구축하기

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [채팅 모델](/docs/concepts/#chat-models)
- [체인 가능한 실행 가능 항목](/docs/how_to/sequence/)
- [임베딩](/docs/concepts/#embedding-models)
- [벡터 저장소](/docs/concepts/#vector-stores)
- [검색 보강 생성](/docs/tutorials/rag/)

:::

[llama.cpp](https://github.com/ggerganov/llama.cpp), [Ollama](https://github.com/ollama/ollama), [llamafile](https://github.com/Mozilla-Ocho/llamafile)와 같은 프로젝트의 인기는 LLM을 로컬에서 실행하는 것의 중요성을 강조합니다.

LangChain은 로컬에서 실행할 수 있는 [많은 오픈 소스 LLM 제공업체](/docs/how_to/local_llms)와 통합되어 있습니다.

이 가이드는 로컬 임베딩과 로컬 LLM을 사용하여 한 제공업체인 [Ollama](/docs/integrations/providers/ollama/)를 통해 `LLaMA 3.1`을 로컬에서 실행하는 방법을 보여줍니다 (예: 노트북에서). 그러나 원하신다면 [LlamaCPP](/docs/integrations/chat/llamacpp/)와 같은 다른 로컬 제공업체를 설정하고 교체할 수 있습니다.

**참고:** 이 가이드는 사용 중인 특정 로컬 모델에 맞게 입력 프롬프트 형식을 처리하는 [채팅 모델](/docs/concepts/#chat-models) 래퍼를 사용합니다. 그러나 [텍스트 입력/텍스트 출력 LLM](/docs/concepts/#llms) 래퍼로 로컬 모델에 직접 프롬프트를 제공하는 경우, 특정 모델에 맞는 프롬프트를 사용해야 할 수 있습니다. 이는 종종 [특수 토큰의 포함이 필요합니다](https://huggingface.co/blog/llama2#how-to-prompt-llama-2). [여기 LLaMA 2에 대한 예시가 있습니다](https://smith.langchain.com/hub/rlm/rag-prompt-llama).

## 설정

먼저 Ollama를 설정해야 합니다.

그들의 GitHub 리포지토리 [여기](https://github.com/ollama/ollama)에서 제공하는 지침을 요약하면 다음과 같습니다:

- [다운로드](https://ollama.com/download)하고 그들의 데스크탑 앱을 실행합니다.
- 명령줄에서 [이 옵션 목록](https://ollama.com/library)에서 모델을 가져옵니다. 이 가이드에서는 다음이 필요합니다:
  - `llama3.1:8b`와 같은 일반 목적 모델, 이는 `ollama pull llama3.1:8b`와 같은 명령으로 가져올 수 있습니다.
  - `nomic-embed-text`와 같은 [텍스트 임베딩 모델](https://ollama.com/search?c=embedding), 이는 `ollama pull nomic-embed-text`와 같은 명령으로 가져올 수 있습니다.
- 앱이 실행 중일 때 모든 모델은 자동으로 `localhost:11434`에서 제공됩니다.
- 모델 선택은 하드웨어 능력에 따라 달라질 수 있습니다.

다음으로, 로컬 임베딩, 벡터 저장소 및 추론에 필요한 패키지를 설치합니다.

```python
# Document loading, retrieval methods and text splitting
%pip install -qU langchain langchain_community

# Local vector store via Chroma
%pip install -qU langchain_chroma

# Local inference and embeddings via Ollama
%pip install -qU langchain_ollama
```


사용 가능한 임베딩 모델의 전체 목록은 [이 페이지](/docs/integrations/text_embedding/)를 참조하세요.

## 문서 로딩

이제 예제 문서를 로드하고 분할해 보겠습니다.

Lilian Weng의 [블로그 게시물](https://lilianweng.github.io/posts/2023-06-23-agent/)을 예제로 사용하겠습니다.

```python
<!--IMPORTS:[{"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "Build a Local RAG Application"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Build a Local RAG Application"}]-->
from langchain_community.document_loaders import WebBaseLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter

loader = WebBaseLoader("https://lilianweng.github.io/posts/2023-06-23-agent/")
data = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0)
all_splits = text_splitter.split_documents(data)
```


다음 단계에서는 벡터 저장소를 초기화합니다. 우리는 [`nomic-embed-text`](https://ollama.com/library/nomic-embed-text)를 사용하지만 다른 제공업체나 옵션도 탐색할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "Build a Local RAG Application"}, {"imported": "OllamaEmbeddings", "source": "langchain_ollama", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_ollama.embeddings.OllamaEmbeddings.html", "title": "Build a Local RAG Application"}]-->
from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings

local_embeddings = OllamaEmbeddings(model="nomic-embed-text")

vectorstore = Chroma.from_documents(documents=all_splits, embedding=local_embeddings)
```


이제 작동하는 벡터 저장소가 생겼습니다! 유사성 검색이 작동하는지 테스트해 보세요:

```python
question = "What are the approaches to Task Decomposition?"
docs = vectorstore.similarity_search(question)
len(docs)
```


```output
4
```


```python
docs[0]
```


```output
Document(metadata={'description': 'Building agents with LLM (large language model) as its core controller is a cool concept. Several proof-of-concepts demos, such as AutoGPT, GPT-Engineer and BabyAGI, serve as inspiring examples. The potentiality of LLM extends beyond generating well-written copies, stories, essays and programs; it can be framed as a powerful general problem solver.\nAgent System Overview In a LLM-powered autonomous agent system, LLM functions as the agent’s brain, complemented by several key components:', 'language': 'en', 'source': 'https://lilianweng.github.io/posts/2023-06-23-agent/', 'title': "LLM Powered Autonomous Agents | Lil'Log"}, page_content='Task decomposition can be done (1) by LLM with simple prompting like "Steps for XYZ.\\n1.", "What are the subgoals for achieving XYZ?", (2) by using task-specific instructions; e.g. "Write a story outline." for writing a novel, or (3) with human inputs.')
```


다음으로 모델을 설정합니다. 여기서는 `llama3.1:8b`와 함께 Ollama를 사용하지만, [다른 제공업체](/docs/how_to/local_llms/)나 [하드웨어 설정에 따른 모델 옵션](https://ollama.com/library)을 탐색할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "ChatOllama", "source": "langchain_ollama", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_ollama.chat_models.ChatOllama.html", "title": "Build a Local RAG Application"}]-->
from langchain_ollama import ChatOllama

model = ChatOllama(
    model="llama3.1:8b",
)
```


모든 것이 제대로 설정되었는지 테스트합니다:

```python
response_message = model.invoke(
    "Simulate a rap battle between Stephen Colbert and John Oliver"
)

print(response_message.content)
```

```output
**The scene is set: a packed arena, the crowd on their feet. In the blue corner, we have Stephen Colbert, aka "The O'Reilly Factor" himself. In the red corner, the challenger, John Oliver. The judges are announced as Tina Fey, Larry Wilmore, and Patton Oswalt. The crowd roars as the two opponents face off.**

**Stephen Colbert (aka "The Truth with a Twist"):**
Yo, I'm the king of satire, the one they all fear
My show's on late, but my jokes are clear
I skewer the politicians, with precision and might
They tremble at my wit, day and night

**John Oliver:**
Hold up, Stevie boy, you may have had your time
But I'm the new kid on the block, with a different prime
Time to wake up from that 90s coma, son
My show's got bite, and my facts are never done

**Stephen Colbert:**
Oh, so you think you're the one, with the "Last Week" crown
But your jokes are stale, like the ones I wore down
I'm the master of absurdity, the lord of the spin
You're just a British import, trying to fit in

**John Oliver:**
Stevie, my friend, you may have been the first
But I've got the skill and the wit, that's never blurred
My show's not afraid, to take on the fray
I'm the one who'll make you think, come what may

**Stephen Colbert:**
Well, it's time for a showdown, like two old friends
Let's see whose satire reigns supreme, till the very end
But I've got a secret, that might just seal your fate
My humor's contagious, and it's already too late!

**John Oliver:**
Bring it on, Stevie! I'm ready for you
I'll take on your jokes, and show them what to do
My sarcasm's sharp, like a scalpel in the night
You're just a relic of the past, without a fight

**The judges deliberate, weighing the rhymes and the flow. Finally, they announce their decision:**

Tina Fey: I've got to go with John Oliver. His jokes were sharper, and his delivery was smoother.

Larry Wilmore: Agreed! But Stephen Colbert's still got that old-school charm.

Patton Oswalt: You know what? It's a tie. Both of them brought the heat!

**The crowd goes wild as both opponents take a bow. The rap battle may be over, but the satire war is just beginning...
```

## 체인에서 사용하기

검색된 문서와 간단한 프롬프트를 전달하여 두 모델 중 하나로 요약 체인을 생성할 수 있습니다.

입력 키 값으로 제공된 값을 사용하여 프롬프트 템플릿을 형식화하고 형식화된 문자열을 지정된 모델에 전달합니다:

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Build a Local RAG Application"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Build a Local RAG Application"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template(
    "Summarize the main themes in these retrieved docs: {docs}"
)


# Convert loaded documents into strings by concatenating their content
# and ignoring metadata
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


chain = {"docs": format_docs} | prompt | model | StrOutputParser()

question = "What are the approaches to Task Decomposition?"

docs = vectorstore.similarity_search(question)

chain.invoke(docs)
```


```output
'The main themes in these documents are:\n\n1. **Task Decomposition**: The process of breaking down complex tasks into smaller, manageable subgoals is crucial for efficient task handling.\n2. **Autonomous Agent System**: A system powered by Large Language Models (LLMs) that can perform planning, reflection, and refinement to improve the quality of final results.\n3. **Challenges in Planning and Decomposition**:\n\t* Long-term planning and task decomposition are challenging for LLMs.\n\t* Adjusting plans when faced with unexpected errors is difficult for LLMs.\n\t* Humans learn from trial and error, making them more robust than LLMs in certain situations.\n\nOverall, the documents highlight the importance of task decomposition and planning in autonomous agent systems powered by LLMs, as well as the challenges that still need to be addressed.'
```


## Q&A

로컬 모델과 벡터 저장소를 사용하여 질문-응답도 수행할 수 있습니다. 간단한 문자열 프롬프트를 사용한 예시는 다음과 같습니다:

```python
<!--IMPORTS:[{"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Build a Local RAG Application"}]-->
from langchain_core.runnables import RunnablePassthrough

RAG_TEMPLATE = """
You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.

<context>
{context}
</context>

Answer the following question:

{question}"""

rag_prompt = ChatPromptTemplate.from_template(RAG_TEMPLATE)

chain = (
    RunnablePassthrough.assign(context=lambda input: format_docs(input["context"]))
    | rag_prompt
    | model
    | StrOutputParser()
)

question = "What are the approaches to Task Decomposition?"

docs = vectorstore.similarity_search(question)

# Run
chain.invoke({"context": docs, "question": question})
```


```output
'Task decomposition can be done through (1) simple prompting using LLM, (2) task-specific instructions, or (3) human inputs. This approach helps break down large tasks into smaller, manageable subgoals for efficient handling of complex tasks. It enables agents to plan ahead and improve the quality of final results through reflection and refinement.'
```


## 검색을 통한 Q&A

마지막으로, 문서를 수동으로 전달하는 대신 사용자 질문에 따라 벡터 저장소에서 자동으로 검색할 수 있습니다:

```python
retriever = vectorstore.as_retriever()

qa_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | rag_prompt
    | model
    | StrOutputParser()
)
```


```python
question = "What are the approaches to Task Decomposition?"

qa_chain.invoke(question)
```


```output
'Task decomposition can be done through (1) simple prompting in Large Language Models (LLM), (2) using task-specific instructions, or (3) with human inputs. This process involves breaking down large tasks into smaller, manageable subgoals for efficient handling of complex tasks.'
```


## 다음 단계

이제 로컬 구성 요소를 사용하여 RAG 애플리케이션을 구축하는 방법을 보았습니다. RAG는 매우 깊은 주제이며, 추가 기술을 논의하고 시연하는 다음 가이드에 관심이 있을 수 있습니다:

- [비디오: LLaMA 3로 신뢰할 수 있는 완전 로컬 RAG 에이전트](https://www.youtube.com/watch?v=-ROS6gfYIts) - 로컬 모델을 사용한 에이전틱 접근 방식
- [비디오: 오픈 소스 로컬 LLM으로부터 올바른 RAG 구축하기](https://www.youtube.com/watch?v=E2shqsYwxck)
- [검색에 대한 개념적 가이드](/docs/concepts/#retrieval) - 성능 향상을 위해 적용할 수 있는 다양한 검색 기술 개요
- [RAG에 대한 가이드](/docs/how_to/#qa-with-rag) - RAG에 대한 다양한 세부 사항을 깊이 있게 다루기
- [모델을 로컬에서 실행하는 방법](/docs/how_to/local_llms/) - 다양한 제공업체 설정 방법에 대한 다양한 접근 방식