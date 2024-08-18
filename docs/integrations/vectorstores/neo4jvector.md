---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/neo4jvector.ipynb
description: Neo4j 벡터 인덱스 사용법을 소개하며, 유사도 검색 및 기존 벡터 저장소와의 작업 방법을 설명합니다.
---

# Neo4j 벡터 인덱스

> [Neo4j](https://neo4j.com/)는 벡터 유사성 검색을 통합 지원하는 오픈 소스 그래프 데이터베이스입니다.

다음과 같은 기능을 지원합니다:

- 근사 최근접 이웃 검색
- 유클리드 유사성 및 코사인 유사성
- 벡터 검색과 키워드 검색을 결합한 하이브리드 검색

이 노트북에서는 Neo4j 벡터 인덱스(`Neo4jVector`)를 사용하는 방법을 보여줍니다.

[설치 지침](https://neo4j.com/docs/operations-manual/current/installation/)을 참조하세요.

```python
# Pip install necessary package
%pip install --upgrade --quiet  neo4j
%pip install --upgrade --quiet  langchain-openai langchain-community
%pip install --upgrade --quiet  tiktoken
```


`OpenAIEmbeddings`를 사용하려면 OpenAI API 키를 받아야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```

```output
OpenAI API Key: ········
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Neo4j Vector Index"}, {"imported": "Neo4jVector", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.neo4j_vector.Neo4jVector.html", "title": "Neo4j Vector Index"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Neo4j Vector Index"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Neo4j Vector Index"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Neo4j Vector Index"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import Neo4jVector
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
loader = TextLoader("../../how_to/state_of_the_union.txt")

documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


```python
# Neo4jVector requires the Neo4j database credentials

url = "bolt://localhost:7687"
username = "neo4j"
password = "password"

# You can also use environment variables instead of directly passing named parameters
# os.environ["NEO4J_URI"] = "bolt://localhost:7687"
# os.environ["NEO4J_USERNAME"] = "neo4j"
# os.environ["NEO4J_PASSWORD"] = "pleaseletmein"
```


## 코사인 거리로 유사성 검색 (기본값)

```python
# The Neo4jVector Module will connect to Neo4j and create a vector index if needed.

db = Neo4jVector.from_documents(
    docs, OpenAIEmbeddings(), url=url, username=username, password=password
)
```


```python
query = "What did the president say about Ketanji Brown Jackson"
docs_with_score = db.similarity_search_with_score(query, k=2)
```


```python
for doc, score in docs_with_score:
    print("-" * 80)
    print("Score: ", score)
    print(doc.page_content)
    print("-" * 80)
```

```output
--------------------------------------------------------------------------------
Score:  0.9076391458511353
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Score:  0.8912242650985718
A former top litigator in private practice. A former federal public defender. And from a family of public school educators and police officers. A consensus builder. Since she’s been nominated, she’s received a broad range of support—from the Fraternal Order of Police to former judges appointed by Democrats and Republicans. 

And if we are to advance liberty and justice, we need to secure the Border and fix the immigration system. 

We can do both. At our border, we’ve installed new technology like cutting-edge scanners to better detect drug smuggling.  

We’ve set up joint patrols with Mexico and Guatemala to catch more human traffickers.  

We’re putting in place dedicated immigration judges so families fleeing persecution and violence can have their cases heard faster. 

We’re securing commitments and supporting partners in South and Central America to host more refugees and secure their own borders.
--------------------------------------------------------------------------------
```


## 벡터 저장소 작업하기

위에서는 처음부터 벡터 저장소를 생성했습니다. 그러나 종종 기존 벡터 저장소로 작업하고 싶습니다. 이를 위해 직접 초기화할 수 있습니다.

```python
index_name = "vector"  # default index name

store = Neo4jVector.from_existing_index(
    OpenAIEmbeddings(),
    url=url,
    username=username,
    password=password,
    index_name=index_name,
)
```


기존 그래프에서 `from_existing_graph` 메서드를 사용하여 벡터 저장소를 초기화할 수도 있습니다. 이 메서드는 데이터베이스에서 관련 텍스트 정보를 가져오고, 텍스트 임베딩을 계산하여 데이터베이스에 다시 저장합니다.

```python
# First we create sample data in graph
store.query(
    "CREATE (p:Person {name: 'Tomaz', location:'Slovenia', hobby:'Bicycle', age: 33})"
)
```


```output
[]
```


```python
# Now we initialize from existing graph
existing_graph = Neo4jVector.from_existing_graph(
    embedding=OpenAIEmbeddings(),
    url=url,
    username=username,
    password=password,
    index_name="person_index",
    node_label="Person",
    text_node_properties=["name", "location"],
    embedding_node_property="embedding",
)
result = existing_graph.similarity_search("Slovenia", k=1)
```


```python
result[0]
```


```output
Document(page_content='\nname: Tomaz\nlocation: Slovenia', metadata={'age': 33, 'hobby': 'Bicycle'})
```


Neo4j는 또한 관계 벡터 인덱스를 지원하며, 여기서 임베딩은 관계 속성으로 저장되고 인덱싱됩니다. 관계 벡터 인덱스는 LangChain을 통해 채울 수 없지만, 기존 관계 벡터 인덱스에 연결할 수 있습니다.

```python
# First we create sample data and index in graph
store.query(
    "MERGE (p:Person {name: 'Tomaz'}) "
    "MERGE (p1:Person {name:'Leann'}) "
    "MERGE (p1)-[:FRIEND {text:'example text', embedding:$embedding}]->(p2)",
    params={"embedding": OpenAIEmbeddings().embed_query("example text")},
)
# Create a vector index
relationship_index = "relationship_vector"
store.query(
    """
CREATE VECTOR INDEX $relationship_index
IF NOT EXISTS
FOR ()-[r:FRIEND]-() ON (r.embedding)
OPTIONS {indexConfig: {
 `vector.dimensions`: 1536,
 `vector.similarity_function`: 'cosine'
}}
""",
    params={"relationship_index": relationship_index},
)
```


```output
[]
```


```python
relationship_vector = Neo4jVector.from_existing_relationship_index(
    OpenAIEmbeddings(),
    url=url,
    username=username,
    password=password,
    index_name=relationship_index,
    text_node_property="text",
)
relationship_vector.similarity_search("Example")
```


```output
[Document(page_content='example text')]
```


### 메타데이터 필터링

Neo4j 벡터 저장소는 병렬 런타임과 정확한 최근접 이웃 검색을 결합하여 메타데이터 필터링을 지원합니다.
*Neo4j 5.18 이상 버전 필요.*

동등성 필터링은 다음과 같은 구문을 가집니다.

```python
existing_graph.similarity_search(
    "Slovenia",
    filter={"hobby": "Bicycle", "name": "Tomaz"},
)
```


```output
[Document(page_content='\nname: Tomaz\nlocation: Slovenia', metadata={'age': 33, 'hobby': 'Bicycle'})]
```


메타데이터 필터링은 다음 연산자도 지원합니다:

* `$eq: 같음`
* `$ne: 같지 않음`
* `$lt: 미만`
* `$lte: 이하`
* `$gt: 초과`
* `$gte: 이상`
* `$in: 값 목록에 포함`
* `$nin: 값 목록에 포함되지 않음`
* `$between: 두 값 사이`
* `$like: 텍스트에 값 포함`
* `$ilike: 소문자 텍스트에 값 포함`

```python
existing_graph.similarity_search(
    "Slovenia",
    filter={"hobby": {"$eq": "Bicycle"}, "age": {"$gt": 15}},
)
```


```output
[Document(page_content='\nname: Tomaz\nlocation: Slovenia', metadata={'age': 33, 'hobby': 'Bicycle'})]
```


필터 간에 `OR` 연산자를 사용할 수도 있습니다.

```python
existing_graph.similarity_search(
    "Slovenia",
    filter={"$or": [{"hobby": {"$eq": "Bicycle"}}, {"age": {"$gt": 15}}]},
)
```


```output
[Document(page_content='\nname: Tomaz\nlocation: Slovenia', metadata={'age': 33, 'hobby': 'Bicycle'})]
```


### 문서 추가
기존 벡터 저장소에 문서를 추가할 수 있습니다.

```python
store.add_documents([Document(page_content="foo")])
```


```output
['acbd18db4cc2f85cedef654fccc4a4d8']
```


```python
docs_with_score = store.similarity_search_with_score("foo")
```


```python
docs_with_score[0]
```


```output
(Document(page_content='foo'), 0.9999997615814209)
```


## 검색 쿼리로 응답 사용자 정의

사용자 정의 Cypher 스니펫을 사용하여 그래프에서 다른 정보를 가져옴으로써 응답을 사용자 정의할 수 있습니다.
내부적으로 최종 Cypher 문은 다음과 같이 구성됩니다:

```
read_query = (
  "CALL db.index.vector.queryNodes($index, $k, $embedding) "
  "YIELD node, score "
) + retrieval_query
```


검색 쿼리는 다음 세 가지 열을 반환해야 합니다:

* `text`: Union[str, Dict] = 문서의 `page_content`를 채우는 데 사용되는 값
* `score`: Float = 유사성 점수
* `metadata`: Dict = 문서의 추가 메타데이터

자세한 내용은 이 [블로그 게시물](https://medium.com/neo4j/implementing-rag-how-to-write-a-graph-retrieval-query-in-langchain-74abf13044f2)에서 확인하세요.

```python
retrieval_query = """
RETURN "Name:" + node.name AS text, score, {foo:"bar"} AS metadata
"""
retrieval_example = Neo4jVector.from_existing_index(
    OpenAIEmbeddings(),
    url=url,
    username=username,
    password=password,
    index_name="person_index",
    retrieval_query=retrieval_query,
)
retrieval_example.similarity_search("Foo", k=1)
```


```output
[Document(page_content='Name:Tomaz', metadata={'foo': 'bar'})]
```


다음은 `embedding`을 제외한 모든 노드 속성을 사전으로 `text` 열에 전달하는 예입니다.

```python
retrieval_query = """
RETURN node {.name, .age, .hobby} AS text, score, {foo:"bar"} AS metadata
"""
retrieval_example = Neo4jVector.from_existing_index(
    OpenAIEmbeddings(),
    url=url,
    username=username,
    password=password,
    index_name="person_index",
    retrieval_query=retrieval_query,
)
retrieval_example.similarity_search("Foo", k=1)
```


```output
[Document(page_content='name: Tomaz\nage: 33\nhobby: Bicycle\n', metadata={'foo': 'bar'})]
```


검색 쿼리에 Cypher 매개변수를 전달할 수도 있습니다.
매개변수는 추가 필터링, 탐색 등에 사용할 수 있습니다...

```python
retrieval_query = """
RETURN node {.*, embedding:Null, extra: $extra} AS text, score, {foo:"bar"} AS metadata
"""
retrieval_example = Neo4jVector.from_existing_index(
    OpenAIEmbeddings(),
    url=url,
    username=username,
    password=password,
    index_name="person_index",
    retrieval_query=retrieval_query,
)
retrieval_example.similarity_search("Foo", k=1, params={"extra": "ParamInfo"})
```


```output
[Document(page_content='location: Slovenia\nextra: ParamInfo\nname: Tomaz\nage: 33\nhobby: Bicycle\nembedding: None\n', metadata={'foo': 'bar'})]
```


## 하이브리드 검색 (벡터 + 키워드)

Neo4j는 벡터 인덱스와 키워드 인덱스를 통합하여 하이브리드 검색 접근 방식을 사용할 수 있습니다.

```python
# The Neo4jVector Module will connect to Neo4j and create a vector and keyword indices if needed.
hybrid_db = Neo4jVector.from_documents(
    docs,
    OpenAIEmbeddings(),
    url=url,
    username=username,
    password=password,
    search_type="hybrid",
)
```


기존 인덱스에서 하이브리드 검색을 로드하려면 벡터 인덱스와 키워드 인덱스를 모두 제공해야 합니다.

```python
index_name = "vector"  # default index name
keyword_index_name = "keyword"  # default keyword index name

store = Neo4jVector.from_existing_index(
    OpenAIEmbeddings(),
    url=url,
    username=username,
    password=password,
    index_name=index_name,
    keyword_index_name=keyword_index_name,
    search_type="hybrid",
)
```


## 검색기 옵션

이 섹션에서는 `Neo4jVector`를 검색기로 사용하는 방법을 보여줍니다.

```python
retriever = store.as_retriever()
retriever.invoke(query)[0]
```


```output
Document(page_content='Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. \n\nTonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. \n\nOne of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. \n\nAnd I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.', metadata={'source': '../../how_to/state_of_the_union.txt'})
```


## 출처가 있는 질문 답변

이 섹션에서는 인덱스에 대한 출처가 있는 질문-답변을 수행하는 방법을 설명합니다. 이는 인덱스에서 문서를 조회하는 `RetrievalQAWithSourcesChain`을 사용하여 수행됩니다.

```python
<!--IMPORTS:[{"imported": "RetrievalQAWithSourcesChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.qa_with_sources.retrieval.RetrievalQAWithSourcesChain.html", "title": "Neo4j Vector Index"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Neo4j Vector Index"}]-->
from langchain.chains import RetrievalQAWithSourcesChain
from langchain_openai import ChatOpenAI
```


```python
chain = RetrievalQAWithSourcesChain.from_chain_type(
    ChatOpenAI(temperature=0), chain_type="stuff", retriever=retriever
)
```


```python
chain.invoke(
    {"question": "What did the president say about Justice Breyer"},
    return_only_outputs=True,
)
```


```output
{'answer': 'The president honored Justice Stephen Breyer for his service to the country and mentioned his retirement from the United States Supreme Court.\n',
 'sources': '../../how_to/state_of_the_union.txt'}
```


## 관련 자료

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)