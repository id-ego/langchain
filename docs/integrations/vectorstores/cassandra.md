---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/cassandra.ipynb
description: 이 문서는 Apache Cassandra를 벡터 저장소로 사용하는 방법에 대한 빠른 시작 가이드를 제공합니다.
---

# 아파치 카산드라

이 페이지는 [Apache Cassandra®](https://cassandra.apache.org/)를 벡터 저장소로 사용하는 빠른 시작 가이드를 제공합니다.

> [Cassandra](https://cassandra.apache.org/)는 NoSQL, 행 지향, 고도로 확장 가능하고 고가용성 데이터베이스입니다. 5.0 버전부터 데이터베이스는 [벡터 검색 기능](https://cassandra.apache.org/doc/trunk/cassandra/vector-search/overview.html)을 제공합니다.

*참고: 데이터베이스에 접근하는 것 외에도 전체 예제를 실행하려면 OpenAI API 키가 필요합니다.*

### 설정 및 일반 종속성

통합을 사용하려면 다음 Python 패키지가 필요합니다.

```python
%pip install --upgrade --quiet langchain-community "cassio>=0.1.4"
```


*참고: LangChain 설정에 따라 이 데모에 필요한 다른 종속성을 설치/업그레이드해야 할 수도 있습니다.*
*(특히, `datasets`, `openai`, `pypdf` 및 `tiktoken`의 최근 버전과 `langchain-community`가 필요합니다.)*

```python
<!--IMPORTS:[{"imported": "PyPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html", "title": "Apache Cassandra"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Apache Cassandra"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Apache Cassandra"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Apache Cassandra"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "Apache Cassandra"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Apache Cassandra"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Apache Cassandra"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "Apache Cassandra"}]-->
import os
from getpass import getpass

from datasets import (
    load_dataset,
)
from langchain_community.document_loaders import PyPDFLoader
from langchain_core.documents import Document
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
```


```python
os.environ["OPENAI_API_KEY"] = getpass("OPENAI_API_KEY = ")
```


```python
embe = OpenAIEmbeddings()
```


## 벡터 저장소 가져오기

```python
<!--IMPORTS:[{"imported": "Cassandra", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.cassandra.Cassandra.html", "title": "Apache Cassandra"}]-->
from langchain_community.vectorstores import Cassandra
```


## 연결 매개변수

이 페이지에 표시된 벡터 저장소 통합은 카산드라뿐만 아니라 CQL(카산드라 쿼리 언어) 프로토콜을 사용하는 다른 파생 데이터베이스(예: Astra DB)와 함께 사용할 수 있습니다.

> DataStax [Astra DB](https://docs.datastax.com/en/astra-serverless/docs/vector-search/quickstart.html)는 카산드라를 기반으로 구축된 관리형 서버리스 데이터베이스로, 동일한 인터페이스와 강점을 제공합니다.

Cassandra 클러스터에 연결하는지 또는 CQL을 통해 Astra DB에 연결하는지에 따라 벡터 저장소 객체를 생성할 때 제공하는 매개변수가 다릅니다.

### 카산드라 클러스터에 연결하기

먼저 [Cassandra 드라이버 문서](https://docs.datastax.com/en/developer/python-driver/latest/api/cassandra/cluster/#module-cassandra.cluster)에 설명된 대로 `cassandra.cluster.Session` 객체를 생성해야 합니다. 세부 사항은 네트워크 설정 및 인증 등으로 다를 수 있지만, 다음과 같은 형식일 수 있습니다:

```python
from cassandra.cluster import Cluster

cluster = Cluster(["127.0.0.1"])
session = cluster.connect()
```


이제 세션과 원하는 키스페이스 이름을 전역 CassIO 매개변수로 설정할 수 있습니다:

```python
import cassio

CASSANDRA_KEYSPACE = input("CASSANDRA_KEYSPACE = ")

cassio.init(session=session, keyspace=CASSANDRA_KEYSPACE)
```


이제 벡터 저장소를 생성할 수 있습니다:

```python
vstore = Cassandra(
    embedding=embe,
    table_name="cassandra_vector_demo",
    # session=None, keyspace=None  # Uncomment on older versions of LangChain
)
```


*참고: 벡터 저장소를 생성할 때 세션과 키스페이스를 매개변수로 직접 전달할 수도 있습니다. 그러나 전역 `cassio.init` 설정을 사용하면 여러 방식으로 카산드라를 사용하는 애플리케이션(예: 벡터 저장소, 채팅 메모리 및 LLM 응답 캐싱)에서 자격 증명 및 DB 연결 관리를 중앙 집중화할 수 있어 유용합니다.*

### CQL을 통한 Astra DB에 연결하기

이 경우 다음 연결 매개변수로 CassIO를 초기화합니다:

- 데이터베이스 ID, 예: `01234567-89ab-cdef-0123-456789abcdef`
- 토큰, 예: `AstraCS:6gBhNmsk135....` (이것은 "데이터베이스 관리자" 토큰이어야 합니다)
- 선택적으로 키스페이스 이름 (생략하면 데이터베이스의 기본 키스페이스가 사용됩니다)

```python
ASTRA_DB_ID = input("ASTRA_DB_ID = ")
ASTRA_DB_APPLICATION_TOKEN = getpass("ASTRA_DB_APPLICATION_TOKEN = ")

desired_keyspace = input("ASTRA_DB_KEYSPACE (optional, can be left empty) = ")
if desired_keyspace:
    ASTRA_DB_KEYSPACE = desired_keyspace
else:
    ASTRA_DB_KEYSPACE = None
```


```python
import cassio

cassio.init(
    database_id=ASTRA_DB_ID,
    token=ASTRA_DB_APPLICATION_TOKEN,
    keyspace=ASTRA_DB_KEYSPACE,
)
```


이제 벡터 저장소를 생성할 수 있습니다:

```python
vstore = Cassandra(
    embedding=embe,
    table_name="cassandra_vector_demo",
    # session=None, keyspace=None  # Uncomment on older versions of LangChain
)
```


## 데이터셋 로드하기

소스 데이터셋의 각 항목을 `Document`로 변환한 다음 벡터 저장소에 작성합니다:

```python
philo_dataset = load_dataset("datastax/philosopher-quotes")["train"]

docs = []
for entry in philo_dataset:
    metadata = {"author": entry["author"]}
    doc = Document(page_content=entry["quote"], metadata=metadata)
    docs.append(doc)

inserted_ids = vstore.add_documents(docs)
print(f"\nInserted {len(inserted_ids)} documents.")
```


위에서 `metadata` 사전은 소스 데이터에서 생성되며 `Document`의 일부입니다.

이번에는 `add_texts`로 더 많은 항목을 추가합니다:

```python
texts = ["I think, therefore I am.", "To the things themselves!"]
metadatas = [{"author": "descartes"}, {"author": "husserl"}]
ids = ["desc_01", "huss_xy"]

inserted_ids_2 = vstore.add_texts(texts=texts, metadatas=metadatas, ids=ids)
print(f"\nInserted {len(inserted_ids_2)} documents.")
```


*참고: `add_texts` 및 `add_documents`의 실행 속도를 높이려면 이러한 대량 작업의 동시성 수준을 높이는 것이 좋습니다 - 메서드의 `batch_size` 매개변수를 확인하여 자세한 내용을 확인하세요. 네트워크 및 클라이언트 머신 사양에 따라 최적의 매개변수 선택이 달라질 수 있습니다.*

## 검색 실행하기

이 섹션에서는 메타데이터 필터링 및 유사도 점수를 가져오는 방법을 보여줍니다:

```python
results = vstore.similarity_search("Our life is what we make of it", k=3)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```


```python
results_filtered = vstore.similarity_search(
    "Our life is what we make of it",
    k=3,
    filter={"author": "plato"},
)
for res in results_filtered:
    print(f"* {res.page_content} [{res.metadata}]")
```


```python
results = vstore.similarity_search_with_score("Our life is what we make of it", k=3)
for res, score in results:
    print(f"* [SIM={score:3f}] {res.page_content} [{res.metadata}]")
```


### MMR (최대-마진-관련성) 검색

```python
results = vstore.max_marginal_relevance_search(
    "Our life is what we make of it",
    k=3,
    filter={"author": "aristotle"},
)
for res in results:
    print(f"* {res.page_content} [{res.metadata}]")
```


## 저장된 문서 삭제하기

```python
delete_1 = vstore.delete(inserted_ids[:3])
print(f"all_succeed={delete_1}")  # True, all documents deleted
```


```python
delete_2 = vstore.delete(inserted_ids[2:5])
print(f"some_succeeds={delete_2}")  # True, though some IDs were gone already
```


## 최소 RAG 체인

다음 셀에서는 간단한 RAG 파이프라인을 구현합니다:
- 샘플 PDF 파일을 다운로드하고 저장소에 로드합니다;
- 벡터 저장소를 중심으로 LCEL(랭크체인 표현 언어)로 RAG 체인을 생성합니다;
- 질문-응답 체인을 실행합니다.

```python
!curl -L \
    "https://github.com/awesome-astra/datasets/blob/main/demo-resources/what-is-philosophy/what-is-philosophy.pdf?raw=true" \
    -o "what-is-philosophy.pdf"
```


```python
pdf_loader = PyPDFLoader("what-is-philosophy.pdf")
splitter = RecursiveCharacterTextSplitter(chunk_size=512, chunk_overlap=64)
docs_from_pdf = pdf_loader.load_and_split(text_splitter=splitter)

print(f"Documents from PDF: {len(docs_from_pdf)}.")
inserted_ids_from_pdf = vstore.add_documents(docs_from_pdf)
print(f"Inserted {len(inserted_ids_from_pdf)} documents.")
```


```python
retriever = vstore.as_retriever(search_kwargs={"k": 3})

philo_template = """
You are a philosopher that draws inspiration from great thinkers of the past
to craft well-thought answers to user questions. Use the provided context as the basis
for your answers and do not make up new reasoning paths - just mix-and-match what you are given.
Your answers must be concise and to the point, and refrain from answering about other topics than philosophy.

CONTEXT:
{context}

QUESTION: {question}

YOUR ANSWER:"""

philo_prompt = ChatPromptTemplate.from_template(philo_template)

llm = ChatOpenAI()

chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | philo_prompt
    | llm
    | StrOutputParser()
)
```


```python
chain.invoke("How does Russel elaborate on Peirce's idea of the security blanket?")
```


자세한 내용은 CQL을 통해 Astra DB를 사용하는 완전한 RAG 템플릿을 [여기](https://github.com/langchain-ai/langchain/tree/master/templates/cassandra-entomology-rag)에서 확인하세요.

## 정리

다음은 본질적으로 CassIO에서 `Session` 객체를 검색하고 CQL `DROP TABLE` 문을 실행합니다:

*(저장한 데이터가 손실됩니다.)*

```python
cassio.config.resolve_session().execute(
    f"DROP TABLE {cassio.config.resolve_keyspace()}.cassandra_vector_demo;"
)
```


### 더 알아보기

자세한 정보, 확장된 빠른 시작 및 추가 사용 예는 [CassIO 문서](https://cassio.org/frameworks/langchain/about/)를 방문하여 LangChain `Cassandra` 벡터 저장소 사용에 대한 자세한 내용을 확인하세요.

#### 저작권 명시

> Apache Cassandra, Cassandra 및 Apache는 [Apache Software Foundation](http://www.apache.org/)의 등록 상표 또는 상표입니다. 미국 및/또는 기타 국가에서 사용됩니다.

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)