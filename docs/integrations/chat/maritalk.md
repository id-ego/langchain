---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/maritalk.ipynb
description: MariTalk는 브라질의 Maritaca AI가 개발한 포르투갈어 이해에 특화된 언어 모델 기반의 어시스턴트입니다. LangChain과
  함께 사용법을 보여줍니다.
---

<a href="https://colab.research.google.com/github/langchain-ai/langchain/blob/master/docs/docs/integrations/chat/maritalk.ipynb" target="_parent"><img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/></a>

# Maritalk

## 소개

MariTalk는 브라질 회사 [Maritaca AI](https://www.maritaca.ai)에서 개발한 어시스턴트입니다.  
MariTalk는 포르투갈어를 잘 이해하도록 특별히 훈련된 언어 모델을 기반으로 합니다.

이 노트북은 두 가지 예제를 통해 LangChain과 함께 MariTalk를 사용하는 방법을 보여줍니다:

1. MariTalk를 사용하여 작업을 수행하는 간단한 예제.
2. LLM + RAG: 두 번째 예제는 MariTalk의 토큰 제한에 맞지 않는 긴 문서에서 답변을 찾는 질문에 답하는 방법을 보여줍니다. 이를 위해 간단한 검색기(BM25)를 사용하여 문서에서 가장 관련성이 높은 섹션을 먼저 검색한 후, 이를 MariTalk에 제공하여 답변을 받습니다.

## 설치
먼저, 다음 명령어를 사용하여 LangChain 라이브러리(및 모든 종속성)를 설치합니다:

```python
!pip install langchain langchain-core langchain-community httpx
```


## API 키
chat.maritaca.ai에서 API 키를 얻어야 합니다("Chaves da API" 섹션).

### 예제 1 - 애완동물 이름 제안

우리의 언어 모델인 ChatMaritalk를 정의하고 API 키로 구성해봅시다.

```python
<!--IMPORTS:[{"imported": "ChatMaritalk", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.maritalk.ChatMaritalk.html", "title": "Maritalk"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Maritalk"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Maritalk"}]-->
from langchain_community.chat_models import ChatMaritalk
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts.chat import ChatPromptTemplate

llm = ChatMaritalk(
    model="sabia-2-medium",  # Available models: sabia-2-small and sabia-2-medium
    api_key="",  # Insert your API key here
    temperature=0.7,
    max_tokens=100,
)

output_parser = StrOutputParser()

chat_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are an assistant specialized in suggesting pet names. Given the animal, you must suggest 4 names.",
        ),
        ("human", "I have a {animal}"),
    ]
)

chain = chat_prompt | llm | output_parser

response = chain.invoke({"animal": "dog"})
print(response)  # should answer something like "1. Max\n2. Bella\n3. Charlie\n4. Rocky"
```


### 스트림 생성

긴 텍스트 생성과 관련된 작업, 예를 들어 광범위한 기사를 작성하거나 대규모 문서를 번역하는 경우, 전체 텍스트를 기다리는 대신 텍스트가 생성되는 동안 응답을 부분적으로 받는 것이 유리할 수 있습니다. 이는 생성된 텍스트가 방대할 때 애플리케이션을 더 반응적이고 효율적으로 만듭니다. 이 요구를 충족하기 위해 두 가지 접근 방식을 제공합니다: 하나는 동기식이고 다른 하나는 비동기식입니다.

#### 동기식:

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Maritalk"}]-->
from langchain_core.messages import HumanMessage

messages = [HumanMessage(content="Suggest 3 names for my dog")]

for chunk in llm.stream(messages):
    print(chunk.content, end="", flush=True)
```


#### 비동기식:

```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Maritalk"}]-->
from langchain_core.messages import HumanMessage


async def async_invoke_chain(animal: str):
    messages = [HumanMessage(content=f"Suggest 3 names for my {animal}")]
    async for chunk in llm._astream(messages):
        print(chunk.message.content, end="", flush=True)


await async_invoke_chain("dog")
```


### 예제 2 - RAG + LLM: UNICAMP 2024 입학 시험 질문 응답 시스템
이 예제를 위해 몇 가지 추가 라이브러리를 설치해야 합니다:

```python
!pip install unstructured rank_bm25 pdf2image pdfminer-six pikepdf pypdf unstructured_inference fastapi kaleido uvicorn "pillow<10.1.0" pillow_heif -q
```


#### 데이터베이스 로딩

첫 번째 단계는 공지에서 정보를 포함하는 데이터베이스를 만드는 것입니다. 이를 위해 COMVEST 웹사이트에서 공지를 다운로드하고 추출된 텍스트를 500자 창으로 분할합니다.

```python
<!--IMPORTS:[{"imported": "OnlinePDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.OnlinePDFLoader.html", "title": "Maritalk"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Maritalk"}]-->
from langchain_community.document_loaders import OnlinePDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Loading the COMVEST 2024 notice
loader = OnlinePDFLoader(
    "https://www.comvest.unicamp.br/wp-content/uploads/2023/10/31-2023-Dispoe-sobre-o-Vestibular-Unicamp-2024_com-retificacao.pdf"
)
data = loader.load()

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=500, chunk_overlap=100, separators=["\n", " ", ""]
)
texts = text_splitter.split_documents(data)
```


#### 검색기 생성
이제 데이터베이스가 준비되었으므로 검색기가 필요합니다. 이 예제에서는 간단한 BM25를 검색 시스템으로 사용할 것이지만, 이는 다른 검색기(예: 임베딩을 통한 검색)로 대체될 수 있습니다.

```python
<!--IMPORTS:[{"imported": "BM25Retriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.bm25.BM25Retriever.html", "title": "Maritalk"}]-->
from langchain_community.retrievers import BM25Retriever

retriever = BM25Retriever.from_documents(texts)
```


#### 검색 시스템 + LLM 결합
이제 검색기가 준비되었으므로, 작업을 지정하는 프롬프트를 구현하고 체인을 호출하기만 하면 됩니다.

```python
<!--IMPORTS:[{"imported": "load_qa_chain", "source": "langchain.chains.question_answering", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.question_answering.chain.load_qa_chain.html", "title": "Maritalk"}]-->
from langchain.chains.question_answering import load_qa_chain

prompt = """Baseado nos seguintes documentos, responda a pergunta abaixo.

{context}

Pergunta: {query}
"""

qa_prompt = ChatPromptTemplate.from_messages([("human", prompt)])

chain = load_qa_chain(llm, chain_type="stuff", verbose=True, prompt=qa_prompt)

query = "Qual o tempo máximo para realização da prova?"

docs = retriever.invoke(query)

chain.invoke(
    {"input_documents": docs, "query": query}
)  # Should output something like: "O tempo máximo para realização da prova é de 5 horas."
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)