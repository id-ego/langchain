---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/yellowbrick.ipynb
description: 이 문서는 Yellowbrick를 벡터 저장소로 활용한 ChatGpt 기반 챗봇 구축 튜토리얼을 제공합니다. 필요한 계정과
  API 키 안내 포함.
---

# 옐로우브릭

[옐로우브릭](https://yellowbrick.com/yellowbrick-data-warehouse/)은 클라우드와 온프레미스에서 실행되는 탄력적이고 대규모 병렬 처리(MPP) SQL 데이터베이스로, 확장성, 복원력 및 클라우드 이식성을 위해 쿠버네티스를 사용합니다. 옐로우브릭은 가장 크고 복잡한 비즈니스 크리티컬 데이터 웨어하우징 사용 사례를 해결하기 위해 설계되었습니다. 옐로우브릭이 제공하는 대규모 효율성은 SQL로 벡터를 저장하고 검색하는 고성능 및 확장 가능한 벡터 데이터베이스로 사용될 수 있게 합니다.

## ChatGpt를 위한 벡터 저장소로서의 옐로우브릭 사용

이 튜토리얼은 옐로우브릭을 벡터 저장소로 사용하여 검색 증강 생성(RAG)을 지원하는 ChatGpt 기반의 간단한 챗봇을 만드는 방법을 보여줍니다. 필요한 사항은 다음과 같습니다:

1. [옐로우브릭 샌드박스](https://cloudlabs.yellowbrick.com/) 계정
2. [OpenAI](https://platform.openai.com/)에서의 API 키

이 튜토리얼은 다섯 부분으로 나뉩니다. 첫째, 벡터 저장소 없이 ChatGpt와 상호작용하는 기본 챗봇을 만들기 위해 langchain을 사용할 것입니다. 둘째, 벡터 저장소를 나타내는 옐로우브릭의 임베딩 테이블을 생성할 것입니다. 셋째, 일련의 문서(옐로우브릭 매뉴얼의 관리 장)를 로드할 것입니다. 넷째, 이러한 문서의 벡터 표현을 생성하고 옐로우브릭 테이블에 저장할 것입니다. 마지막으로, 개선된 챗봇에 동일한 쿼리를 보내 결과를 확인할 것입니다.

```python
# Install all needed libraries
%pip install --upgrade --quiet  langchain
%pip install --upgrade --quiet  langchain-openai langchain-community
%pip install --upgrade --quiet  psycopg2-binary
%pip install --upgrade --quiet  tiktoken
```


## 설정: 옐로우브릭 및 OpenAI API에 연결하는 데 사용되는 정보 입력

우리의 챗봇은 langchain 라이브러리를 통해 ChatGpt와 통합되므로, 먼저 OpenAI에서 API 키를 받아야 합니다:

OpenAI의 API 키를 얻으려면:
1. https://platform.openai.com/에 등록합니다.
2. 결제 방법을 추가합니다 - 무료 할당량을 초과할 가능성은 낮습니다.
3. API 키를 생성합니다.

옐로우브릭 샌드박스 계정에 가입할 때 환영 이메일에서 사용자 이름, 비밀번호 및 데이터베이스 이름도 필요합니다.

다음은 귀하의 옐로우브릭 데이터베이스 및 OpenAPI 키 정보를 포함하도록 수정해야 합니다.

```python
# Modify these values to match your Yellowbrick Sandbox and OpenAI API Key
YBUSER = "[SANDBOX USER]"
YBPASSWORD = "[SANDBOX PASSWORD]"
YBDATABASE = "[SANDBOX_DATABASE]"
YBHOST = "trialsandbox.sandbox.aws.yellowbrickcloud.com"

OPENAI_API_KEY = "[OPENAI API KEY]"
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Yellowbrick"}, {"imported": "RetrievalQAWithSourcesChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.qa_with_sources.retrieval.RetrievalQAWithSourcesChain.html", "title": "Yellowbrick"}, {"imported": "Yellowbrick", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.yellowbrick.Yellowbrick.html", "title": "Yellowbrick"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Yellowbrick"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Yellowbrick"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Yellowbrick"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Yellowbrick"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Yellowbrick"}, {"imported": "HumanMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.HumanMessagePromptTemplate.html", "title": "Yellowbrick"}, {"imported": "SystemMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.SystemMessagePromptTemplate.html", "title": "Yellowbrick"}]-->
# Import libraries and setup keys / login info
import os
import pathlib
import re
import sys
import urllib.parse as urlparse
from getpass import getpass

import psycopg2
from IPython.display import Markdown, display
from langchain.chains import LLMChain, RetrievalQAWithSourcesChain
from langchain_community.vectorstores import Yellowbrick
from langchain_core.documents import Document
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Establish connection parameters to Yellowbrick.  If you've signed up for Sandbox, fill in the information from your welcome mail here:
yellowbrick_connection_string = (
    f"postgres://{urlparse.quote(YBUSER)}:{YBPASSWORD}@{YBHOST}:5432/{YBDATABASE}"
)

YB_DOC_DATABASE = "sample_data"
YB_DOC_TABLE = "yellowbrick_documentation"
embedding_table = "my_embeddings"

# API Key for OpenAI.  Signup at https://platform.openai.com
os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY

from langchain_core.prompts.chat import (
    ChatPromptTemplate,
    HumanMessagePromptTemplate,
    SystemMessagePromptTemplate,
)
```


## 1부: 벡터 저장소 없이 ChatGpt에 의해 지원되는 기본 챗봇 생성

우리는 langchain을 사용하여 ChatGPT에 쿼리를 보낼 것입니다. 벡터 저장소가 없기 때문에 ChatGPT는 질문에 답할 수 있는 맥락이 없습니다.

```python
# Set up the chat model and specific prompt
system_template = """If you don't know the answer, Make up your best guess."""
messages = [
    SystemMessagePromptTemplate.from_template(system_template),
    HumanMessagePromptTemplate.from_template("{question}"),
]
prompt = ChatPromptTemplate.from_messages(messages)

chain_type_kwargs = {"prompt": prompt}
llm = ChatOpenAI(
    model_name="gpt-3.5-turbo",  # Modify model_name if you have access to GPT-4
    temperature=0,
    max_tokens=256,
)

chain = LLMChain(
    llm=llm,
    prompt=prompt,
    verbose=False,
)


def print_result_simple(query):
    result = chain(query)
    output_text = f"""### Question:
  {query}
  ### Answer: 
  {result['text']}
    """
    display(Markdown(output_text))


# Use the chain to query
print_result_simple("How many databases can be in a Yellowbrick Instance?")

print_result_simple("What's an easy way to add users in bulk to Yellowbrick?")
```


## 2부: 옐로우브릭에 연결하고 임베딩 테이블 생성

문서 임베딩을 옐로우브릭에 로드하려면 저장할 테이블을 생성해야 합니다. 테이블이 포함된 옐로우브릭 데이터베이스는 UTF-8로 인코딩되어야 합니다.

다음 스키마를 사용하여 UTF-8 데이터베이스에 테이블을 생성하고 원하는 테이블 이름을 제공하십시오:

```python
# Establish a connection to the Yellowbrick database
try:
    conn = psycopg2.connect(yellowbrick_connection_string)
except psycopg2.Error as e:
    print(f"Error connecting to the database: {e}")
    exit(1)

# Create a cursor object using the connection
cursor = conn.cursor()

# Define the SQL statement to create a table
create_table_query = f"""
CREATE TABLE IF NOT EXISTS {embedding_table} (
    doc_id uuid NOT NULL,
    embedding_id smallint NOT NULL,
    embedding double precision NOT NULL
)
DISTRIBUTE ON (doc_id);
truncate table {embedding_table};
"""

# Execute the SQL query to create a table
try:
    cursor.execute(create_table_query)
    print(f"Table '{embedding_table}' created successfully!")
except psycopg2.Error as e:
    print(f"Error creating table: {e}")
    conn.rollback()

# Commit changes and close the cursor and connection
conn.commit()
cursor.close()
conn.close()
```


## 3부: 옐로우브릭의 기존 테이블에서 인덱싱할 문서 추출
기존 옐로우브릭 테이블에서 문서 경로 및 내용을 추출합니다. 우리는 다음 단계에서 이 문서를 사용하여 임베딩을 생성할 것입니다.

```python
yellowbrick_doc_connection_string = (
    f"postgres://{urlparse.quote(YBUSER)}:{YBPASSWORD}@{YBHOST}:5432/{YB_DOC_DATABASE}"
)

print(yellowbrick_doc_connection_string)

# Establish a connection to the Yellowbrick database
conn = psycopg2.connect(yellowbrick_doc_connection_string)

# Create a cursor object
cursor = conn.cursor()

# Query to select all documents from the table
query = f"SELECT path, document FROM {YB_DOC_TABLE}"

# Execute the query
cursor.execute(query)

# Fetch all documents
yellowbrick_documents = cursor.fetchall()

print(f"Extracted {len(yellowbrick_documents)} documents successfully!")

# Close the cursor and connection
cursor.close()
conn.close()
```


## 4부: 문서로 옐로우브릭 벡터 저장소 로드
문서를 검토하고, 소화 가능한 청크로 나누고, 임베딩을 생성하여 옐로우브릭 테이블에 삽입합니다. 이 작업은 약 5분이 소요됩니다.

```python
# Split documents into chunks for conversion to embeddings
DOCUMENT_BASE_URL = "https://docs.yellowbrick.com/6.7.1/"  # Actual URL


separator = "\n## "  # This separator assumes Markdown docs from the repo uses ### as logical main header most of the time
chunk_size_limit = 2000
max_chunk_overlap = 200

documents = [
    Document(
        page_content=document[1],
        metadata={"source": DOCUMENT_BASE_URL + document[0].replace(".md", ".html")},
    )
    for document in yellowbrick_documents
]

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=chunk_size_limit,
    chunk_overlap=max_chunk_overlap,
    separators=[separator, "\nn", "\n", ",", " ", ""],
)
split_docs = text_splitter.split_documents(documents)

docs_text = [doc.page_content for doc in split_docs]

embeddings = OpenAIEmbeddings()
vector_store = Yellowbrick.from_documents(
    documents=split_docs,
    embedding=embeddings,
    connection_string=yellowbrick_connection_string,
    table=embedding_table,
)

print(f"Created vector store with {len(documents)} documents")
```


## 5부: 옐로우브릭을 벡터 저장소로 사용하는 챗봇 생성

다음으로, 옐로우브릭을 벡터 저장소로 추가합니다. 벡터 저장소는 옐로우브릭 제품 문서의 관리 장을 나타내는 임베딩으로 채워졌습니다.

우리는 위와 동일한 쿼리를 보내 개선된 응답을 확인할 것입니다.

```python
system_template = """Use the following pieces of context to answer the users question.
Take note of the sources and include them in the answer in the format: "SOURCES: source1 source2", use "SOURCES" in capital letters regardless of the number of sources.
If you don't know the answer, just say that "I don't know", don't try to make up an answer.
----------------
{summaries}"""
messages = [
    SystemMessagePromptTemplate.from_template(system_template),
    HumanMessagePromptTemplate.from_template("{question}"),
]
prompt = ChatPromptTemplate.from_messages(messages)

vector_store = Yellowbrick(
    OpenAIEmbeddings(),
    yellowbrick_connection_string,
    embedding_table,  # Change the table name to reflect your embeddings
)

chain_type_kwargs = {"prompt": prompt}
llm = ChatOpenAI(
    model_name="gpt-3.5-turbo",  # Modify model_name if you have access to GPT-4
    temperature=0,
    max_tokens=256,
)
chain = RetrievalQAWithSourcesChain.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vector_store.as_retriever(search_kwargs={"k": 5}),
    return_source_documents=True,
    chain_type_kwargs=chain_type_kwargs,
)


def print_result_sources(query):
    result = chain(query)
    output_text = f"""### Question: 
  {query}
  ### Answer: 
  {result['answer']}
  ### Sources: 
  {result['sources']}
  ### All relevant sources:
  {', '.join(list(set([doc.metadata['source'] for doc in result['source_documents']])))}
    """
    display(Markdown(output_text))


# Use the chain to query

print_result_sources("How many databases can be in a Yellowbrick Instance?")

print_result_sources("Whats an easy way to add users in bulk to Yellowbrick?")
```


## 6부: 성능 향상을 위한 인덱스 도입

옐로우브릭은 지역 민감 해싱(Locality-Sensitive Hashing) 접근 방식을 사용한 인덱싱도 지원합니다. 이는 근사 최근접 이웃 검색 기술로, 정확성을 희생하면서 유사성 검색 시간을 거래할 수 있게 합니다. 인덱스는 두 개의 새로운 조정 가능한 매개변수를 도입합니다:

- 하이퍼플레인의 수는 `create_lsh_index(num_hyperplanes)`에 인수로 제공됩니다. 문서가 많을수록 더 많은 하이퍼플레인이 필요합니다. LSH는 차원 축소의 한 형태입니다. 원래 임베딩은 구성 요소 수가 하이퍼플레인 수와 동일한 저차원 벡터로 변환됩니다.
- 해밍 거리(Hamming distance)는 검색의 폭을 나타내는 정수입니다. 해밍 거리가 작을수록 더 빠른 검색이 가능하지만 정확도는 낮아집니다.

옐로우브릭에 로드한 임베딩에 인덱스를 생성하는 방법은 다음과 같습니다. 이전 챗 세션을 다시 실행하겠지만, 이번에는 검색이 인덱스를 사용할 것입니다. 이렇게 적은 수의 문서에 대해서는 성능 측면에서 인덱싱의 이점을 보지 못할 것입니다.

```python
system_template = """Use the following pieces of context to answer the users question.
Take note of the sources and include them in the answer in the format: "SOURCES: source1 source2", use "SOURCES" in capital letters regardless of the number of sources.
If you don't know the answer, just say that "I don't know", don't try to make up an answer.
----------------
{summaries}"""
messages = [
    SystemMessagePromptTemplate.from_template(system_template),
    HumanMessagePromptTemplate.from_template("{question}"),
]
prompt = ChatPromptTemplate.from_messages(messages)

vector_store = Yellowbrick(
    OpenAIEmbeddings(),
    yellowbrick_connection_string,
    embedding_table,  # Change the table name to reflect your embeddings
)

lsh_params = Yellowbrick.IndexParams(
    Yellowbrick.IndexType.LSH, {"num_hyperplanes": 8, "hamming_distance": 2}
)
vector_store.create_index(lsh_params)

chain_type_kwargs = {"prompt": prompt}
llm = ChatOpenAI(
    model_name="gpt-3.5-turbo",  # Modify model_name if you have access to GPT-4
    temperature=0,
    max_tokens=256,
)
chain = RetrievalQAWithSourcesChain.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vector_store.as_retriever(
        k=5, search_kwargs={"index_params": lsh_params}
    ),
    return_source_documents=True,
    chain_type_kwargs=chain_type_kwargs,
)


def print_result_sources(query):
    result = chain(query)
    output_text = f"""### Question: 
  {query}
  ### Answer: 
  {result['answer']}
  ### Sources: 
  {result['sources']}
  ### All relevant sources:
  {', '.join(list(set([doc.metadata['source'] for doc in result['source_documents']])))}
    """
    display(Markdown(output_text))


# Use the chain to query

print_result_sources("How many databases can be in a Yellowbrick Instance?")

print_result_sources("Whats an easy way to add users in bulk to Yellowbrick?")
```


## 다음 단계:

이 코드는 다른 질문을 하도록 수정할 수 있습니다. 또한 벡터 저장소에 자신의 문서를 로드할 수 있습니다. langchain 모듈은 매우 유연하며 다양한 파일(HTML, PDF 등)을 구문 분석할 수 있습니다.

Huggingface 임베딩 모델 및 Meta의 Llama 2 LLM을 사용하여 완전히 개인적인 챗봇 경험을 제공하도록 수정할 수도 있습니다.

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)