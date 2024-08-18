---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/sap_hanavector.ipynb
description: SAP HANA Cloud Vector Engine은 SAP HANA Cloud 데이터베이스에 완전히 통합된 벡터 저장소입니다.
  LangChain을 통해 쉽게 설정하고 사용할 수 있습니다.
---

# SAP HANA Cloud Vector Engine

> [SAP HANA Cloud Vector Engine](https://www.sap.com/events/teched/news-guide/ai.html#article8)는 `SAP HANA Cloud` 데이터베이스에 완전히 통합된 벡터 저장소입니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

## 설정하기

HANA 데이터베이스 드라이버 설치.

```python
# Pip install necessary package
%pip install --upgrade --quiet  hdbcli
```


`OpenAIEmbeddings`의 경우 환경에서 OpenAI API 키를 사용합니다.

```python
import os
# Use OPENAI_API_KEY env variable
# os.environ["OPENAI_API_KEY"] = "Your OpenAI API key"
```


HANA Cloud 인스턴스에 대한 데이터베이스 연결을 생성합니다.

```python
from hdbcli import dbapi

# Use connection settings from the environment
connection = dbapi.connect(
    address=os.environ.get("HANA_DB_ADDRESS"),
    port=os.environ.get("HANA_DB_PORT"),
    user=os.environ.get("HANA_DB_USER"),
    password=os.environ.get("HANA_DB_PASSWORD"),
    autocommit=True,
    sslValidateCertificate=False,
)
```


## 예제

샘플 문서 "state_of_the_union.txt"를 로드하고 그로부터 청크를 생성합니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "SAP HANA Cloud Vector Engine"}, {"imported": "HanaDB", "source": "langchain_community.vectorstores.hanavector", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.hanavector.HanaDB.html", "title": "SAP HANA Cloud Vector Engine"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "SAP HANA Cloud Vector Engine"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "SAP HANA Cloud Vector Engine"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "SAP HANA Cloud Vector Engine"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores.hanavector import HanaDB
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

text_documents = TextLoader("../../how_to/state_of_the_union.txt").load()
text_splitter = CharacterTextSplitter(chunk_size=500, chunk_overlap=0)
text_chunks = text_splitter.split_documents(text_documents)
print(f"Number of document chunks: {len(text_chunks)}")

embeddings = OpenAIEmbeddings()
```


HANA 데이터베이스에 대한 LangChain VectorStore 인터페이스를 생성하고 벡터 임베딩에 접근하기 위해 사용할 테이블(컬렉션)을 지정합니다.

```python
db = HanaDB(
    embedding=embeddings, connection=connection, table_name="STATE_OF_THE_UNION"
)
```


로드된 문서 청크를 테이블에 추가합니다. 이 예제에서는 이전 실행에서 존재할 수 있는 이전 콘텐츠를 테이블에서 삭제합니다.

```python
# Delete already existing documents from the table
db.delete(filter={})

# add the loaded document chunks
db.add_documents(text_chunks)
```


이전 단계에서 추가된 문서 청크 중에서 두 개의 가장 잘 일치하는 청크를 가져오기 위한 쿼리를 수행합니다. 기본적으로 "코사인 유사도"가 검색에 사용됩니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query, k=2)

for doc in docs:
    print("-" * 80)
    print(doc.page_content)
```


"유클리드 거리"로 동일한 콘텐츠를 쿼리합니다. 결과는 "코사인 유사도"와 동일해야 합니다.

```python
<!--IMPORTS:[{"imported": "DistanceStrategy", "source": "langchain_community.vectorstores.utils", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.utils.DistanceStrategy.html", "title": "SAP HANA Cloud Vector Engine"}]-->
from langchain_community.vectorstores.utils import DistanceStrategy

db = HanaDB(
    embedding=embeddings,
    connection=connection,
    distance_strategy=DistanceStrategy.EUCLIDEAN_DISTANCE,
    table_name="STATE_OF_THE_UNION",
)

query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query, k=2)
for doc in docs:
    print("-" * 80)
    print(doc.page_content)
```


## 최대 한계 관련성 검색 (MMR)

`최대 한계 관련성`은 쿼리에 대한 유사성과 선택된 문서 간의 다양성을 최적화합니다. DB에서 처음 20개(fetch_k) 항목이 검색됩니다. MMR 알고리즘은 그 후 가장 잘 일치하는 2개(k) 항목을 찾습니다.

```python
docs = db.max_marginal_relevance_search(query, k=2, fetch_k=20)
for doc in docs:
    print("-" * 80)
    print(doc.page_content)
```


## 기본 벡터 저장소 작업

```python
db = HanaDB(
    connection=connection, embedding=embeddings, table_name="LANGCHAIN_DEMO_BASIC"
)

# Delete already existing documents from the table
db.delete(filter={})
```


기존 테이블에 간단한 텍스트 문서를 추가할 수 있습니다.

```python
docs = [Document(page_content="Some text"), Document(page_content="Other docs")]
db.add_documents(docs)
```


메타데이터가 있는 문서를 추가합니다.

```python
docs = [
    Document(
        page_content="foo",
        metadata={"start": 100, "end": 150, "doc_name": "foo.txt", "quality": "bad"},
    ),
    Document(
        page_content="bar",
        metadata={"start": 200, "end": 250, "doc_name": "bar.txt", "quality": "good"},
    ),
]
db.add_documents(docs)
```


특정 메타데이터가 있는 문서를 쿼리합니다.

```python
docs = db.similarity_search("foobar", k=2, filter={"quality": "bad"})
# With filtering on "quality"=="bad", only one document should be returned
for doc in docs:
    print("-" * 80)
    print(doc.page_content)
    print(doc.metadata)
```


특정 메타데이터가 있는 문서를 삭제합니다.

```python
db.delete(filter={"quality": "bad"})

# Now the similarity search with the same filter will return no results
docs = db.similarity_search("foobar", k=2, filter={"quality": "bad"})
print(len(docs))
```


## 고급 필터링
기본 값 기반 필터링 기능 외에도 더 고급 필터링을 사용할 수 있습니다. 아래 표는 사용 가능한 필터 연산자를 보여줍니다.

| 연산자     | 의미                     |
|------------|-------------------------|
| `$eq`      | 동등성 (==)             |
| `$ne`      | 불일치 (!=)             |
| `$lt`      | 미만 (<)                |
| `$lte`     | 이하 (<=)               |
| `$gt`      | 초과 (>)                |
| `$gte`     | 이상 (>=)               |
| `$in`      | 주어진 값 집합에 포함됨 (in) |
| `$nin`     | 주어진 값 집합에 포함되지 않음 (not in) |
| `$between` | 두 경계 값의 범위 내에 있음 |
| `$like`    | SQL의 "LIKE" 의미에 기반한 텍스트 동등성 (와일드카드로 "%" 사용) |
| `$and`     | 논리적 "and", 2개 이상의 피연산자 지원 |
| `$or`      | 논리적 "or", 2개 이상의 피연산자 지원 |

```python
# Prepare some test documents
docs = [
    Document(
        page_content="First",
        metadata={"name": "adam", "is_active": True, "id": 1, "height": 10.0},
    ),
    Document(
        page_content="Second",
        metadata={"name": "bob", "is_active": False, "id": 2, "height": 5.7},
    ),
    Document(
        page_content="Third",
        metadata={"name": "jane", "is_active": True, "id": 3, "height": 2.4},
    ),
]

db = HanaDB(
    connection=connection,
    embedding=embeddings,
    table_name="LANGCHAIN_DEMO_ADVANCED_FILTER",
)

# Delete already existing documents from the table
db.delete(filter={})
db.add_documents(docs)


# Helper function for printing filter results
def print_filter_result(result):
    if len(result) == 0:
        print("<empty result>")
    for doc in result:
        print(doc.metadata)
```


`$ne`, `$gt`, `$gte`, `$lt`, `$lte`로 필터링

```python
advanced_filter = {"id": {"$ne": 1}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"id": {"$gt": 1}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"id": {"$gte": 1}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"id": {"$lt": 1}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"id": {"$lte": 1}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))
```


`$between`, `$in`, `$nin`으로 필터링

```python
advanced_filter = {"id": {"$between": (1, 2)}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"name": {"$in": ["adam", "bob"]}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"name": {"$nin": ["adam", "bob"]}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))
```


`$like`로 텍스트 필터링

```python
advanced_filter = {"name": {"$like": "a%"}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"name": {"$like": "%a%"}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))
```


`$and`, `$or`로 결합 필터링

```python
advanced_filter = {"$or": [{"id": 1}, {"name": "bob"}]}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"$and": [{"id": 1}, {"id": 2}]}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"$or": [{"id": 1}, {"id": 2}, {"id": 3}]}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))
```


## RAG(검색 증강 생성)를 위한 체인에서 검색기로서의 VectorStore 사용

```python
<!--IMPORTS:[{"imported": "ConversationBufferMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer.ConversationBufferMemory.html", "title": "SAP HANA Cloud Vector Engine"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "SAP HANA Cloud Vector Engine"}]-->
from langchain.memory import ConversationBufferMemory
from langchain_openai import ChatOpenAI

# Access the vector DB with a new table
db = HanaDB(
    connection=connection,
    embedding=embeddings,
    table_name="LANGCHAIN_DEMO_RETRIEVAL_CHAIN",
)

# Delete already existing entries from the table
db.delete(filter={})

# add the loaded document chunks from the "State Of The Union" file
db.add_documents(text_chunks)

# Create a retriever instance of the vector store
retriever = db.as_retriever()
```


프롬프트를 정의합니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "SAP HANA Cloud Vector Engine"}]-->
from langchain_core.prompts import PromptTemplate

prompt_template = """
You are an expert in state of the union topics. You are provided multiple context items that are related to the prompt you have to answer.
Use the following pieces of context to answer the question at the end.

'''
{context}
'''

Question: {question}
"""

PROMPT = PromptTemplate(
    template=prompt_template, input_variables=["context", "question"]
)
chain_type_kwargs = {"prompt": PROMPT}
```


채팅 기록과 프롬프트에 추가할 유사 문서 청크의 검색을 처리하는 ConversationalRetrievalChain을 생성합니다.

```python
<!--IMPORTS:[{"imported": "ConversationalRetrievalChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.conversational_retrieval.base.ConversationalRetrievalChain.html", "title": "SAP HANA Cloud Vector Engine"}]-->
from langchain.chains import ConversationalRetrievalChain

llm = ChatOpenAI(model="gpt-3.5-turbo")
memory = ConversationBufferMemory(
    memory_key="chat_history", output_key="answer", return_messages=True
)
qa_chain = ConversationalRetrievalChain.from_llm(
    llm,
    db.as_retriever(search_kwargs={"k": 5}),
    return_source_documents=True,
    memory=memory,
    verbose=False,
    combine_docs_chain_kwargs={"prompt": PROMPT},
)
```


첫 번째 질문을 합니다(사용된 텍스트 청크 수를 확인합니다).

```python
question = "What about Mexico and Guatemala?"

result = qa_chain.invoke({"question": question})
print("Answer from LLM:")
print("================")
print(result["answer"])

source_docs = result["source_documents"]
print("================")
print(f"Number of used source document chunks: {len(source_docs)}")
```


체인에서 사용된 청크를 자세히 검토합니다. 가장 높은 순위의 청크가 질문에서 언급된 "멕시코와 과테말라"에 대한 정보를 포함하는지 확인합니다.

```python
for doc in source_docs:
    print("-" * 80)
    print(doc.page_content)
    print(doc.metadata)
```


동일한 대화 체인에서 또 다른 질문을 합니다. 답변은 이전에 제공된 답변과 관련이 있어야 합니다.

```python
question = "What about other countries?"

result = qa_chain.invoke({"question": question})
print("Answer from LLM:")
print("================")
print(result["answer"])
```


## 표준 테이블 vs. 벡터 데이터가 있는 "사용자 정의" 테이블

기본 동작으로, 임베딩을 위한 테이블은 3개의 열로 생성됩니다:

- 문서의 텍스트를 포함하는 `VEC_TEXT` 열
- 문서의 메타데이터를 포함하는 `VEC_META` 열
- 문서 텍스트의 임베딩 벡터를 포함하는 `VEC_VECTOR` 열

```python
# Access the vector DB with a new table
db = HanaDB(
    connection=connection, embedding=embeddings, table_name="LANGCHAIN_DEMO_NEW_TABLE"
)

# Delete already existing entries from the table
db.delete(filter={})

# Add a simple document with some metadata
docs = [
    Document(
        page_content="A simple document",
        metadata={"start": 100, "end": 150, "doc_name": "simple.txt"},
    )
]
db.add_documents(docs)
```


"LANGCHAIN_DEMO_NEW_TABLE" 테이블의 열을 보여줍니다.

```python
cur = connection.cursor()
cur.execute(
    "SELECT COLUMN_NAME, DATA_TYPE_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME = CURRENT_SCHEMA AND TABLE_NAME = 'LANGCHAIN_DEMO_NEW_TABLE'"
)
rows = cur.fetchall()
for row in rows:
    print(row)
cur.close()
```


세 개의 열에 삽입된 문서의 값을 보여줍니다.

```python
cur = connection.cursor()
cur.execute(
    "SELECT VEC_TEXT, VEC_META, TO_NVARCHAR(VEC_VECTOR) FROM LANGCHAIN_DEMO_NEW_TABLE LIMIT 1"
)
rows = cur.fetchall()
print(rows[0][0])  # The text
print(rows[0][1])  # The metadata
print(rows[0][2])  # The vector
cur.close()
```


사용자 정의 테이블은 표준 테이블의 의미와 일치하는 최소 세 개의 열을 가져야 합니다.

- 임베딩의 텍스트/컨텍스트를 위한 `NCLOB` 또는 `NVARCHAR` 유형의 열
- 메타데이터를 위한 `NCLOB` 또는 `NVARCHAR` 유형의 열
- 임베딩 벡터를 위한 `REAL_VECTOR` 유형의 열

테이블은 추가 열을 포함할 수 있습니다. 새 문서가 테이블에 삽입될 때, 이러한 추가 열은 NULL 값을 허용해야 합니다.

```python
# Create a new table "MY_OWN_TABLE" with three "standard" columns and one additional column
my_own_table_name = "MY_OWN_TABLE"
cur = connection.cursor()
cur.execute(
    (
        f"CREATE TABLE {my_own_table_name} ("
        "SOME_OTHER_COLUMN NVARCHAR(42), "
        "MY_TEXT NVARCHAR(2048), "
        "MY_METADATA NVARCHAR(1024), "
        "MY_VECTOR REAL_VECTOR )"
    )
)

# Create a HanaDB instance with the own table
db = HanaDB(
    connection=connection,
    embedding=embeddings,
    table_name=my_own_table_name,
    content_column="MY_TEXT",
    metadata_column="MY_METADATA",
    vector_column="MY_VECTOR",
)

# Add a simple document with some metadata
docs = [
    Document(
        page_content="Some other text",
        metadata={"start": 400, "end": 450, "doc_name": "other.txt"},
    )
]
db.add_documents(docs)

# Check if data has been inserted into our own table
cur.execute(f"SELECT * FROM {my_own_table_name} LIMIT 1")
rows = cur.fetchall()
print(rows[0][0])  # Value of column "SOME_OTHER_DATA". Should be NULL/None
print(rows[0][1])  # The text
print(rows[0][2])  # The metadata
print(rows[0][3])  # The vector

cur.close()
```


또 다른 문서를 추가하고 사용자 정의 테이블에서 유사성 검색을 수행합니다.

```python
docs = [
    Document(
        page_content="Some more text",
        metadata={"start": 800, "end": 950, "doc_name": "more.txt"},
    )
]
db.add_documents(docs)

query = "What's up?"
docs = db.similarity_search(query, k=2)
for doc in docs:
    print("-" * 80)
    print(doc.page_content)
```


### 사용자 정의 열로 필터 성능 최적화

유연한 메타데이터 값을 허용하기 위해 모든 메타데이터는 기본적으로 메타데이터 열에 JSON으로 저장됩니다. 사용된 메타데이터 키와 값 유형 중 일부가 알려진 경우, 대상 테이블을 키 이름을 열 이름으로 하여 생성하고 특정 메타데이터 열 목록을 통해 HanaDB 생성자에 전달하여 추가 열에 저장할 수 있습니다. 해당 값과 일치하는 메타데이터 키는 삽입 중에 특별 열로 복사됩니다. 필터는 특정 메타데이터 열 목록의 키에 대해 메타데이터 JSON 열 대신 특별 열을 사용합니다.

```python
# Create a new table "PERFORMANT_CUSTOMTEXT_FILTER" with three "standard" columns and one additional column
my_own_table_name = "PERFORMANT_CUSTOMTEXT_FILTER"
cur = connection.cursor()
cur.execute(
    (
        f"CREATE TABLE {my_own_table_name} ("
        "CUSTOMTEXT NVARCHAR(500), "
        "MY_TEXT NVARCHAR(2048), "
        "MY_METADATA NVARCHAR(1024), "
        "MY_VECTOR REAL_VECTOR )"
    )
)

# Create a HanaDB instance with the own table
db = HanaDB(
    connection=connection,
    embedding=embeddings,
    table_name=my_own_table_name,
    content_column="MY_TEXT",
    metadata_column="MY_METADATA",
    vector_column="MY_VECTOR",
    specific_metadata_columns=["CUSTOMTEXT"],
)

# Add a simple document with some metadata
docs = [
    Document(
        page_content="Some other text",
        metadata={
            "start": 400,
            "end": 450,
            "doc_name": "other.txt",
            "CUSTOMTEXT": "Filters on this value are very performant",
        },
    )
]
db.add_documents(docs)

# Check if data has been inserted into our own table
cur.execute(f"SELECT * FROM {my_own_table_name} LIMIT 1")
rows = cur.fetchall()
print(
    rows[0][0]
)  # Value of column "CUSTOMTEXT". Should be "Filters on this value are very performant"
print(rows[0][1])  # The text
print(
    rows[0][2]
)  # The metadata without the "CUSTOMTEXT" data, as this is extracted into a sperate column
print(rows[0][3])  # The vector

cur.close()
```


특별 열은 langchain 인터페이스의 나머지 부분에 대해 완전히 투명합니다. 모든 것이 이전과 같이 작동하며, 성능이 더 향상되었습니다.

```python
docs = [
    Document(
        page_content="Some more text",
        metadata={
            "start": 800,
            "end": 950,
            "doc_name": "more.txt",
            "CUSTOMTEXT": "Another customtext value",
        },
    )
]
db.add_documents(docs)

advanced_filter = {"CUSTOMTEXT": {"$like": "%value%"}}
query = "What's up?"
docs = db.similarity_search(query, k=2, filter=advanced_filter)
for doc in docs:
    print("-" * 80)
    print(doc.page_content)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)