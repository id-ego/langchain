---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/jaguar.ipynb
description: 재규어 벡터 데이터베이스는 분산형으로, 다중 모드 지원 및 즉각적인 수평 확장을 제공하며, 다양한 거리 측정 기능을 갖추고
  있습니다.
---

# 재규어 벡터 데이터베이스

1. 분산 벡터 데이터베이스입니다.
2. 재규어DB의 "ZeroMove" 기능은 즉각적인 수평 확장을 가능하게 합니다.
3. 다중 모드: 임베딩, 텍스트, 이미지, 비디오, PDF, 오디오, 시계열 및 지리적 데이터
4. 올-마스터: 병렬 읽기 및 쓰기를 모두 허용합니다.
5. 이상 탐지 기능
6. RAG 지원: LLM과 독점적이며 실시간 데이터를 결합합니다.
7. 공유 메타데이터: 여러 벡터 인덱스 간의 메타데이터 공유
8. 거리 측정: 유클리드, 코사인, 내적, 맨해튼, 체비셰프, 해밍, 제카르드, 민코프스키

## 전제 조건

이 파일의 예제를 실행하기 위한 두 가지 요구 사항이 있습니다.
1. 재규어DB 서버와 HTTP 게이트웨이 서버를 설치하고 설정해야 합니다.
다음의 지침을 참조하십시오:
[www.jaguardb.com](http://www.jaguardb.com)
도커 환경에서 빠른 설정을 위해:
docker pull jaguardb/jaguardb_with_http  
docker run -d -p 8888:8888 -p 8080:8080 --name jaguardb_with_http  jaguardb/jaguardb_with_http  
2. 재규어DB용 HTTP 클라이언트 패키지를 설치해야 합니다:  
   ```
       pip install -U jaguardb-http-client
   ```
  
3. 이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

## Langchain과 함께하는 RAG

이 섹션에서는 langchain 소프트웨어 스택에서 재규어와 함께 LLM과 대화하는 방법을 보여줍니다.

```python
<!--IMPORTS:[{"imported": "RetrievalQAWithSourcesChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.qa_with_sources.retrieval.RetrievalQAWithSourcesChain.html", "title": "Jaguar Vector Database"}, {"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Jaguar Vector Database"}, {"imported": "Jaguar", "source": "langchain_community.vectorstores.jaguar", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.jaguar.Jaguar.html", "title": "Jaguar Vector Database"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Jaguar Vector Database"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Jaguar Vector Database"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Jaguar Vector Database"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Jaguar Vector Database"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Jaguar Vector Database"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Jaguar Vector Database"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Jaguar Vector Database"}]-->
from langchain.chains import RetrievalQAWithSourcesChain
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores.jaguar import Jaguar
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI, OpenAI, OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

""" 
Load a text file into a set of documents 
"""
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=300)
docs = text_splitter.split_documents(documents)

"""
Instantiate a Jaguar vector store
"""
### Jaguar HTTP endpoint
url = "http://192.168.5.88:8080/fwww/"

### Use OpenAI embedding model
embeddings = OpenAIEmbeddings()

### Pod is a database for vectors
pod = "vdb"

### Vector store name
store = "langchain_rag_store"

### Vector index name
vector_index = "v"

### Type of the vector index
# cosine: distance metric
# fraction: embedding vectors are decimal numbers
# float: values stored with floating-point numbers
vector_type = "cosine_fraction_float"

### Dimension of each embedding vector
vector_dimension = 1536

### Instantiate a Jaguar store object
vectorstore = Jaguar(
    pod, store, vector_index, vector_type, vector_dimension, url, embeddings
)

"""
Login must be performed to authorize the client.
The environment variable JAGUAR_API_KEY or file $HOME/.jagrc
should contain the API key for accessing JaguarDB servers.
"""
vectorstore.login()


"""
Create vector store on the JaguarDB database server.
This should be done only once.
"""
# Extra metadata fields for the vector store
metadata = "category char(16)"

# Number of characters for the text field of the store
text_size = 4096

#  Create a vector store on the server
vectorstore.create(metadata, text_size)

"""
Add the texts from the text splitter to our vectorstore
"""
vectorstore.add_documents(docs)
# or tag the documents:
# vectorstore.add_documents(more_docs, text_tag="tags to these documents")

""" Get the retriever object """
retriever = vectorstore.as_retriever()
# retriever = vectorstore.as_retriever(search_kwargs={"where": "m1='123' and m2='abc'"})

template = """You are an assistant for question-answering tasks. Use the following pieces of retrieved context to answer the question. If you don't know the answer, just say that you don't know. Use three sentences maximum and keep the answer concise.
Question: {question}
Context: {context}
Answer:
"""
prompt = ChatPromptTemplate.from_template(template)

""" Obtain a Large Language Model """
LLM = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)

""" Create a chain for the RAG flow """
rag_chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | LLM
    | StrOutputParser()
)

resp = rag_chain.invoke("What did the president say about Justice Breyer?")
print(resp)
```


## 재규어 벡터 저장소와의 상호작용

사용자는 유사성 검색 및 이상 탐지를 위해 재규어 벡터 저장소와 직접 상호작용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Jaguar", "source": "langchain_community.vectorstores.jaguar", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.jaguar.Jaguar.html", "title": "Jaguar Vector Database"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Jaguar Vector Database"}]-->
from langchain_community.vectorstores.jaguar import Jaguar
from langchain_openai import OpenAIEmbeddings

# Instantiate a Jaguar vector store object
url = "http://192.168.3.88:8080/fwww/"
pod = "vdb"
store = "langchain_test_store"
vector_index = "v"
vector_type = "cosine_fraction_float"
vector_dimension = 10
embeddings = OpenAIEmbeddings()
vectorstore = Jaguar(
    pod, store, vector_index, vector_type, vector_dimension, url, embeddings
)

# Login for authorization
vectorstore.login()

# Create the vector store with two metadata fields
# This needs to be run only once.
metadata_str = "author char(32), category char(16)"
vectorstore.create(metadata_str, 1024)

# Add a list of texts
texts = ["foo", "bar", "baz"]
metadatas = [
    {"author": "Adam", "category": "Music"},
    {"author": "Eve", "category": "Music"},
    {"author": "John", "category": "History"},
]
ids = vectorstore.add_texts(texts=texts, metadatas=metadatas)

#  Search similar text
output = vectorstore.similarity_search(
    query="foo",
    k=1,
    metadatas=["author", "category"],
)
assert output[0].page_content == "foo"
assert output[0].metadata["author"] == "Adam"
assert output[0].metadata["category"] == "Music"
assert len(output) == 1

# Search with filtering (where)
where = "author='Eve'"
output = vectorstore.similarity_search(
    query="foo",
    k=3,
    fetch_k=9,
    where=where,
    metadatas=["author", "category"],
)
assert output[0].page_content == "bar"
assert output[0].metadata["author"] == "Eve"
assert output[0].metadata["category"] == "Music"
assert len(output) == 1

# Anomaly detection
result = vectorstore.is_anomalous(
    query="dogs can jump high",
)
assert result is False

# Remove all data in the store
vectorstore.clear()
assert vectorstore.count() == 0

# Remove the store completely
vectorstore.drop()

# Logout
vectorstore.logout()
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)