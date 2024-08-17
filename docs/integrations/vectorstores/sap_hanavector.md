---
canonical: https://python.langchain.com/v0.2/docs/integrations/vectorstores/sap_hanavector/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/sap_hanavector.ipynb
---

# SAP HANA Cloud Vector Engine

>[SAP HANA Cloud Vector Engine](https://www.sap.com/events/teched/news-guide/ai.html#article8) is a vector store fully integrated into the `SAP HANA Cloud` database.

You'll need to install `langchain-community` with `pip install -qU langchain-community` to use this integration

## Setting up

Installation of the HANA database driver.


```python
# Pip install necessary package
%pip install --upgrade --quiet  hdbcli
```

For `OpenAIEmbeddings` we use the OpenAI API key from the environment.


```python
import os
# Use OPENAI_API_KEY env variable
# os.environ["OPENAI_API_KEY"] = "Your OpenAI API key"
```

Create a database connection to a HANA Cloud instance.


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

## Example

Load the sample document "state_of_the_union.txt" and create chunks from it.


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

Create a LangChain VectorStore interface for the HANA database and specify the table (collection) to use for accessing the vector embeddings


```python
db = HanaDB(
    embedding=embeddings, connection=connection, table_name="STATE_OF_THE_UNION"
)
```

Add the loaded document chunks to the table. For this example, we delete any previous content from the table which might exist from previous runs.


```python
# Delete already existing documents from the table
db.delete(filter={})

# add the loaded document chunks
db.add_documents(text_chunks)
```

Perform a query to get the two best-matching document chunks from the ones that were added in the previous step.
By default "Cosine Similarity" is used for the search.


```python
query = "What did the president say about Ketanji Brown Jackson"
docs = db.similarity_search(query, k=2)

for doc in docs:
    print("-" * 80)
    print(doc.page_content)
```

Query the same content with "Euclidian Distance". The results shoud be the same as with "Cosine Similarity".


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

## Maximal Marginal Relevance Search (MMR)

`Maximal marginal relevance` optimizes for similarity to query AND diversity among selected documents. The first 20 (fetch_k) items will be retrieved from the DB. The MMR algorithm will then find the best 2 (k) matches.


```python
docs = db.max_marginal_relevance_search(query, k=2, fetch_k=20)
for doc in docs:
    print("-" * 80)
    print(doc.page_content)
```

## Basic Vectorstore Operations


```python
db = HanaDB(
    connection=connection, embedding=embeddings, table_name="LANGCHAIN_DEMO_BASIC"
)

# Delete already existing documents from the table
db.delete(filter={})
```

We can add simple text documents to the existing table.


```python
docs = [Document(page_content="Some text"), Document(page_content="Other docs")]
db.add_documents(docs)
```

Add documents with metadata.


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

Query documents with specific metadata.


```python
docs = db.similarity_search("foobar", k=2, filter={"quality": "bad"})
# With filtering on "quality"=="bad", only one document should be returned
for doc in docs:
    print("-" * 80)
    print(doc.page_content)
    print(doc.metadata)
```

Delete documents with specific metadata.


```python
db.delete(filter={"quality": "bad"})

# Now the similarity search with the same filter will return no results
docs = db.similarity_search("foobar", k=2, filter={"quality": "bad"})
print(len(docs))
```

## Advanced filtering
In addition to the basic value-based filtering capabilities, it is possible to use more advanced filtering.
The table below shows the available filter operators.

| Operator | Semantic                 |
|----------|-------------------------|
| `$eq`    | Equality (==)           |
| `$ne`    | Inequality (!=)         |
| `$lt`    | Less than (<)           |
| `$lte`   | Less than or equal (<=) |
| `$gt`    | Greater than (>)        |
| `$gte`   | Greater than or equal (>=) |
| `$in`    | Contained in a set of given values  (in)    |
| `$nin`   | Not contained in a set of given values  (not in)  |
| `$between` | Between the range of two boundary values |
| `$like`  | Text equality based on the "LIKE" semantics in SQL (using "%" as wildcard)  |
| `$and`   | Logical "and", supporting 2 or more operands |
| `$or`    | Logical "or", supporting 2 or more operands |


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

Filtering with `$ne`, `$gt`, `$gte`, `$lt`, `$lte`


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

Filtering with `$between`, `$in`, `$nin`


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

Text filtering with `$like`


```python
advanced_filter = {"name": {"$like": "a%"}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))

advanced_filter = {"name": {"$like": "%a%"}}
print(f"Filter: {advanced_filter}")
print_filter_result(db.similarity_search("just testing", k=5, filter=advanced_filter))
```

Combined filtering with `$and`, `$or`


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

## Using a VectorStore as a retriever in chains for retrieval augmented generation (RAG)


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

Define the prompt.


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

Create the ConversationalRetrievalChain, which handles the chat history and the retrieval of similar document chunks to be added to the prompt.


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

Ask the first question (and verify how many text chunks have been used).


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

Examine the used chunks of the chain in detail. Check if the best ranked chunk contains info about "Mexico and Guatemala" as mentioned in the question.


```python
for doc in source_docs:
    print("-" * 80)
    print(doc.page_content)
    print(doc.metadata)
```

Ask another question on the same conversational chain. The answer should relate to the previous answer given.


```python
question = "What about other countries?"

result = qa_chain.invoke({"question": question})
print("Answer from LLM:")
print("================")
print(result["answer"])
```

## Standard tables vs. "custom" tables with vector data

As default behaviour, the table for the embeddings is created with 3 columns:

- A column `VEC_TEXT`, which contains the text of the Document
- A column `VEC_META`, which contains the metadata of the Document
- A column `VEC_VECTOR`, which contains the embeddings-vector of the Document's text


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

Show the columns in table "LANGCHAIN_DEMO_NEW_TABLE"


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

Show the value of the inserted document in the three columns 


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

Custom tables must have at least three columns that match the semantics of a standard table

- A column with type `NCLOB` or `NVARCHAR` for the text/context of the embeddings
- A column with type `NCLOB` or `NVARCHAR` for the metadata 
- A column with type `REAL_VECTOR` for the embedding vector

The table can contain additional columns. When new Documents are inserted into the table, these additional columns must allow NULL values.


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

Add another document and perform a similarity search on the custom table.


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

### Filter Performance Optimization with Custom Columns

To allow flexible metadata values, all metadata is stored as JSON in the metadata column by default. If some of the used metadata keys and value types are known, they can be stored in additional columns instead by creating the target table with the key names as column names and passing them to the HanaDB constructor via the specific_metadata_columns list. Metadata keys that match those values are copied into the special column during insert. Filters use the special columns instead of the metadata JSON column for keys in the specific_metadata_columns list.


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

The special columns are completely transparent to the rest of the langchain interface. Everything works as it did before, just more performant.


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


## Related

- Vector store [conceptual guide](/docs/concepts/#vector-stores)
- Vector store [how-to guides](/docs/how_to/#vector-stores)