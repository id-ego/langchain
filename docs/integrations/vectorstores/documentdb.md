---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/documentdb.ipynb
description: Amazon DocumentDB는 MongoDB와 호환되는 데이터베이스를 클라우드에서 쉽게 설정하고 운영할 수 있게 해줍니다.
  벡터 검색 기능도 지원합니다.
---

# 아마존 문서 DB

> [아마존 DocumentDB (MongoDB 호환)](https://docs.aws.amazon.com/documentdb/)는 클라우드에서 MongoDB 호환 데이터베이스를 쉽게 설정하고 운영하며 확장할 수 있게 해줍니다.  
아마존 DocumentDB를 사용하면 MongoDB와 함께 사용하는 동일한 애플리케이션 코드와 드라이버 및 도구를 실행할 수 있습니다.  
아마존 DocumentDB의 벡터 검색은 JSON 기반 문서 데이터베이스의 유연성과 풍부한 쿼리 기능을 벡터 검색의 힘과 결합합니다.

이 노트북은 [아마존 Document DB 벡터 검색](https://docs.aws.amazon.com/documentdb/latest/developerguide/vector-search.html)을 사용하여 문서를 컬렉션에 저장하고, 인덱스를 생성하며, "코사인", "유클리드", "내적"과 같은 근사 최근접 이웃 알고리즘을 사용하여 벡터 검색 쿼리를 수행하는 방법을 보여줍니다. 기본적으로 DocumentDB는 계층적 탐색 가능한 작은 세계(HNSW) 인덱스를 생성합니다. 지원되는 다른 벡터 인덱스 유형에 대한 자세한 내용은 위의 문서를 참조하십시오.

DocumentDB를 사용하려면 먼저 클러스터를 배포해야 합니다. 자세한 내용은 [개발자 가이드](https://docs.aws.amazon.com/documentdb/latest/developerguide/what-is.html)를 참조하십시오.

[가입하기](https://aws.amazon.com/free/)하여 오늘 시작하세요.

```python
!pip install pymongo
```


```python
import getpass

# DocumentDB connection string
# i.e., "mongodb://{username}:{pass}@{cluster_endpoint}:{port}/?{params}"
CONNECTION_STRING = getpass.getpass("DocumentDB Cluster URI:")

INDEX_NAME = "izzy-test-index"
NAMESPACE = "izzy_test_db.izzy_test_collection"
DB_NAME, COLLECTION_NAME = NAMESPACE.split(".")
```


`OpenAIEmbeddings`를 사용하려고 하므로 OpenAI 환경 변수를 설정해야 합니다.

```python
import getpass
import os

# Set up the OpenAI Environment Variables
os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
os.environ["OPENAI_EMBEDDINGS_DEPLOYMENT"] = (
    "smart-agent-embedding-ada"  # the deployment name for the embedding model
)
os.environ["OPENAI_EMBEDDINGS_MODEL_NAME"] = "text-embedding-ada-002"  # the model name
```


이제 문서를 컬렉션에 로드하고, 인덱스를 생성한 다음, 인덱스에 대해 쿼리를 수행합니다.

특정 매개변수에 대한 질문이 있는 경우 [문서](https://docs.aws.amazon.com/documentdb/latest/developerguide/vector-search.html)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Amazon Document DB"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Amazon Document DB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Amazon Document DB"}]-->
from langchain.vectorstores.documentdb import (
    DocumentDBSimilarityType,
    DocumentDBVectorSearch,
)
from langchain_community.document_loaders import TextLoader
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

SOURCE_FILE_NAME = "../../how_to/state_of_the_union.txt"

loader = TextLoader(SOURCE_FILE_NAME)
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

# OpenAI Settings
model_deployment = os.getenv(
    "OPENAI_EMBEDDINGS_DEPLOYMENT", "smart-agent-embedding-ada"
)
model_name = os.getenv("OPENAI_EMBEDDINGS_MODEL_NAME", "text-embedding-ada-002")


openai_embeddings: OpenAIEmbeddings = OpenAIEmbeddings(
    deployment=model_deployment, model=model_name
)
```


```python
from pymongo import MongoClient

INDEX_NAME = "izzy-test-index-2"
NAMESPACE = "izzy_test_db.izzy_test_collection"
DB_NAME, COLLECTION_NAME = NAMESPACE.split(".")

client: MongoClient = MongoClient(CONNECTION_STRING)
collection = client[DB_NAME][COLLECTION_NAME]

model_deployment = os.getenv(
    "OPENAI_EMBEDDINGS_DEPLOYMENT", "smart-agent-embedding-ada"
)
model_name = os.getenv("OPENAI_EMBEDDINGS_MODEL_NAME", "text-embedding-ada-002")

vectorstore = DocumentDBVectorSearch.from_documents(
    documents=docs,
    embedding=openai_embeddings,
    collection=collection,
    index_name=INDEX_NAME,
)

# number of dimensions used by model above
dimensions = 1536

# specify similarity algorithm, valid options are:
#   cosine (COS), euclidean (EUC), dotProduct (DOT)
similarity_algorithm = DocumentDBSimilarityType.COS

vectorstore.create_index(dimensions, similarity_algorithm)
```


```output
{ 'createdCollectionAutomatically' : false,
   'numIndexesBefore' : 1,
   'numIndexesAfter' : 2,
   'ok' : 1,
   'operationTime' : Timestamp(1703656982, 1)}
```


```python
# perform a similarity search between the embedding of the query and the embeddings of the documents
query = "What did the President say about Ketanji Brown Jackson"
docs = vectorstore.similarity_search(query)
```


```python
print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```

문서가 로드되고 인덱스가 생성되면 이제 벡터 저장소를 직접 인스턴스화하고 인덱스에 대해 쿼리를 실행할 수 있습니다.

```python
vectorstore = DocumentDBVectorSearch.from_connection_string(
    connection_string=CONNECTION_STRING,
    namespace=NAMESPACE,
    embedding=openai_embeddings,
    index_name=INDEX_NAME,
)

# perform a similarity search between a query and the ingested documents
query = "What did the president say about Ketanji Brown Jackson"
docs = vectorstore.similarity_search(query)
```


```python
print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```


```python
# perform a similarity search between a query and the ingested documents
query = "Which stats did the President share about the U.S. economy"
docs = vectorstore.similarity_search(query)
```


```python
print(docs[0].page_content)
```

```output
And unlike the $2 Trillion tax cut passed in the previous administration that benefitted the top 1% of Americans, the American Rescue Plan helped working people—and left no one behind. 

And it worked. It created jobs. Lots of jobs. 

In fact—our economy created over 6.5 Million new jobs just last year, more jobs created in one year  
than ever before in the history of America. 

Our economy grew at a rate of 5.7% last year, the strongest growth in nearly 40 years, the first step in bringing fundamental change to an economy that hasn’t worked for the working people of this nation for too long.  

For the past 40 years we were told that if we gave tax breaks to those at the very top, the benefits would trickle down to everyone else. 

But that trickle-down theory led to weaker economic growth, lower wages, bigger deficits, and the widest gap between those at the top and everyone else in nearly a century.
```

## 질문 응답

```python
qa_retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 25},
)
```


```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Amazon Document DB"}]-->
from langchain_core.prompts import PromptTemplate

prompt_template = """Use the following pieces of context to answer the question at the end. If you don't know the answer, just say that you don't know, don't try to make up an answer.

{context}

Question: {question}
"""
PROMPT = PromptTemplate(
    template=prompt_template, input_variables=["context", "question"]
)
```


```python
<!--IMPORTS:[{"imported": "RetrievalQA", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.retrieval_qa.base.RetrievalQA.html", "title": "Amazon Document DB"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Amazon Document DB"}]-->
from langchain.chains import RetrievalQA
from langchain_openai import OpenAI

qa = RetrievalQA.from_chain_type(
    llm=OpenAI(),
    chain_type="stuff",
    retriever=qa_retriever,
    return_source_documents=True,
    chain_type_kwargs={"prompt": PROMPT},
)

docs = qa({"query": "gpt-4 compute requirements"})

print(docs["result"])
print(docs["source_documents"])
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)