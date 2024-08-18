---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/aperturedb.ipynb
description: ApertureDB는 텍스트, 이미지, 비디오 등 다양한 데이터를 저장하고 관리하는 데이터베이스입니다. 이 문서는 임베딩 기능
  사용법을 설명합니다.
---

# ApertureDB

[ApertureDB](https://docs.aperturedata.io)는 텍스트, 이미지, 비디오, 바운딩 박스 및 임베딩과 같은 다중 모드 데이터를 저장, 인덱싱 및 관리하며, 관련 메타데이터와 함께 저장하는 데이터베이스입니다.

이 노트북에서는 ApertureDB의 임베딩 기능을 사용하는 방법을 설명합니다.

## ApertureDB Python SDK 설치

이것은 ApertureDB에 대한 클라이언트 코드를 작성하는 데 사용되는 [Python SDK](https://docs.aperturedata.io/category/aperturedb-python-sdk)를 설치합니다.

```python
%pip install --upgrade --quiet aperturedb
```

```output
Note: you may need to restart the kernel to use updated packages.
```

## ApertureDB 인스턴스 실행

계속하려면 [ApertureDB 인스턴스가 실행 중](https://docs.aperturedata.io/HowToGuides/start/Setup)이어야 하며, 이를 사용하도록 환경을 구성해야 합니다.\
이를 수행하는 방법은 여러 가지가 있습니다. 예를 들어:

```bash
docker run --publish 55555:55555 aperturedata/aperturedb-standalone
adb config create local --active --no-interactive
```


## 웹 문서 다운로드
우리는 여기에서 하나의 웹 페이지를 미니 크롤링할 것입니다.

```python
<!--IMPORTS:[{"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "ApertureDB"}]-->
# For loading documents from web
from langchain_community.document_loaders import WebBaseLoader

loader = WebBaseLoader("https://docs.aperturedata.io")
docs = loader.load()
```

```output
USER_AGENT environment variable not set, consider setting it to identify your requests.
```

## 임베딩 모델 선택

OllamaEmbeddings를 사용하고자 하므로 필요한 모듈을 가져와야 합니다.

Ollama는 [문서](https://hub.docker.com/r/ollama/ollama)에서 설명한 대로 도커 컨테이너로 설정할 수 있습니다. 예를 들어:
```bash
# Run server
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
# Tell server to load a specific model
docker exec ollama ollama run llama2
```


```python
<!--IMPORTS:[{"imported": "OllamaEmbeddings", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.ollama.OllamaEmbeddings.html", "title": "ApertureDB"}]-->
from langchain_community.embeddings import OllamaEmbeddings

embeddings = OllamaEmbeddings()
```


## 문서를 세그먼트로 분할

우리는 단일 문서를 여러 세그먼트로 변환하고자 합니다.

```python
<!--IMPORTS:[{"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "ApertureDB"}]-->
from langchain_text_splitters import RecursiveCharacterTextSplitter

text_splitter = RecursiveCharacterTextSplitter()
documents = text_splitter.split_documents(docs)
```


## 문서 및 임베딩으로부터 벡터 저장소 생성

이 코드는 ApertureDB 인스턴스에서 벡터 저장소를 생성합니다.
인스턴스 내에서 이 벡터 저장소는 "[descriptor set](https://docs.aperturedata.io/category/descriptorset-commands)"으로 표현됩니다.
기본적으로, descriptor set의 이름은 `langchain`입니다. 다음 코드는 각 문서에 대한 임베딩을 생성하고 이를 ApertureDB에 descriptor로 저장합니다. 임베딩이 생성되는 데 몇 초가 걸릴 것입니다.

```python
<!--IMPORTS:[{"imported": "ApertureDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.aperturedb.ApertureDB.html", "title": "ApertureDB"}]-->
from langchain_community.vectorstores import ApertureDB

vector_db = ApertureDB.from_documents(documents, embeddings)
```


## 대형 언어 모델 선택

다시 말해, 우리는 로컬 처리를 위해 설정한 Ollama 서버를 사용합니다.

```python
<!--IMPORTS:[{"imported": "Ollama", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.ollama.Ollama.html", "title": "ApertureDB"}]-->
from langchain_community.llms import Ollama

llm = Ollama(model="llama2")
```


## RAG 체인 구축

이제 RAG(검색 증강 생성) 체인을 생성하는 데 필요한 모든 구성 요소가 준비되었습니다. 이 체인은 다음과 같은 작업을 수행합니다:
1. 사용자 쿼리에 대한 임베딩 설명자를 생성합니다.
2. 벡터 저장소를 사용하여 사용자 쿼리와 유사한 텍스트 세그먼트를 찾습니다.
3. 프롬프트 템플릿을 사용하여 사용자 쿼리와 컨텍스트 문서를 LLM에 전달합니다.
4. LLM의 답변을 반환합니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ApertureDB"}, {"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "ApertureDB"}, {"imported": "create_retrieval_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval.create_retrieval_chain.html", "title": "ApertureDB"}]-->
# Create prompt
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template("""Answer the following question based only on the provided context:

<context>
{context}
</context>

Question: {input}""")


# Create a chain that passes documents to an LLM
from langchain.chains.combine_documents import create_stuff_documents_chain

document_chain = create_stuff_documents_chain(llm, prompt)


# Treat the vectorstore as a document retriever
retriever = vector_db.as_retriever()


# Create a RAG chain that connects the retriever to the LLM
from langchain.chains import create_retrieval_chain

retrieval_chain = create_retrieval_chain(retriever, document_chain)
```

```output
Based on the provided context, ApertureDB can store images. In fact, it is specifically designed to manage multimodal data such as images, videos, documents, embeddings, and associated metadata including annotations. So, ApertureDB has the capability to store and manage images.
```

## RAG 체인 실행

마지막으로 체인에 질문을 전달하고 답변을 받습니다. LLM이 쿼리와 컨텍스트 문서에서 답변을 생성하는 데 몇 초가 걸릴 것입니다.

```python
user_query = "How can ApertureDB store images?"
response = retrieval_chain.invoke({"input": user_query})
print(response["answer"])
```

```output
Based on the provided context, ApertureDB can store images in several ways:

1. Multimodal data management: ApertureDB offers a unified interface to manage multimodal data such as images, videos, documents, embeddings, and associated metadata including annotations. This means that images can be stored along with other types of data in a single database instance.
2. Image storage: ApertureDB provides image storage capabilities through its integration with the public cloud providers or on-premise installations. This allows customers to host their own ApertureDB instances and store images on their preferred cloud provider or on-premise infrastructure.
3. Vector database: ApertureDB also offers a vector database that enables efficient similarity search and classification of images based on their semantic meaning. This can be useful for applications where image search and classification are important, such as in computer vision or machine learning workflows.

Overall, ApertureDB provides flexible and scalable storage options for images, allowing customers to choose the deployment model that best suits their needs.
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)