---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/databricks_vector_search.ipynb
description: Databricks Vector Search는 데이터의 벡터 표현을 저장하고 유사성을 검색할 수 있는 서버리스 엔진입니다.
  LangChain과 함께 사용 방법을 소개합니다.
---

# Databricks 벡터 검색

Databricks 벡터 검색은 데이터의 벡터 표현과 메타데이터를 벡터 데이터베이스에 저장할 수 있는 서버리스 유사성 검색 엔진입니다. 벡터 검색을 사용하면 Unity Catalog에서 관리하는 Delta 테이블로부터 자동 업데이트되는 벡터 검색 인덱스를 생성하고, 간단한 API를 통해 가장 유사한 벡터를 반환하는 쿼리를 실행할 수 있습니다.

이 노트북은 Databricks 벡터 검색과 함께 LangChain을 사용하는 방법을 보여줍니다.

이 노트북에서 사용되는 `databricks-vectorsearch` 및 관련 Python 패키지를 설치합니다.

```python
%pip install --upgrade --quiet  langchain-core databricks-vectorsearch langchain-openai tiktoken
```


임베딩을 위해 `OpenAIEmbeddings`를 사용합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


문서를 분할하고 임베딩을 가져옵니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Databricks Vector Search"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Databricks Vector Search"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Databricks Vector Search"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
emb_dim = len(embeddings.embed_query("hello"))
```


## Databricks 벡터 검색 클라이언트 설정

```python
from databricks.vector_search.client import VectorSearchClient

vsc = VectorSearchClient()
```


## 벡터 검색 엔드포인트 생성
이 엔드포인트는 벡터 검색 인덱스를 생성하고 접근하는 데 사용됩니다.

```python
vsc.create_endpoint(name="vector_search_demo_endpoint", endpoint_type="STANDARD")
```


## 직접 벡터 접근 인덱스 생성
직접 벡터 접근 인덱스는 REST API 또는 SDK를 통해 임베딩 벡터와 메타데이터를 직접 읽고 쓸 수 있도록 지원합니다. 이 인덱스의 경우, 임베딩 벡터와 인덱스 업데이트를 직접 관리합니다.

```python
vector_search_endpoint_name = "vector_search_demo_endpoint"
index_name = "vector_search_demo.vector_search.state_of_the_union_index"

index = vsc.create_direct_access_index(
    endpoint_name=vector_search_endpoint_name,
    index_name=index_name,
    primary_key="id",
    embedding_dimension=emb_dim,
    embedding_vector_column="text_vector",
    schema={
        "id": "string",
        "text": "string",
        "text_vector": "array<float>",
        "source": "string",
    },
)

index.describe()
```


```python
<!--IMPORTS:[{"imported": "DatabricksVectorSearch", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.databricks_vector_search.DatabricksVectorSearch.html", "title": "Databricks Vector Search"}]-->
from langchain_community.vectorstores import DatabricksVectorSearch

dvs = DatabricksVectorSearch(
    index, text_column="text", embedding=embeddings, columns=["source"]
)
```


## 인덱스에 문서 추가

```python
dvs.add_documents(docs)
```


## 유사성 검색
유사성 검색에 대한 선택적 키워드 인수에는 검색할 문서 수(k)를 지정하는 것, [이 구문](https://docs.databricks.com/en/generative-ai/create-query-vector-search.html#use-filters-on-queries)을 기반으로 메타데이터 필터링을 위한 필터 사전, 그리고 ANN 또는 HYBRID일 수 있는 [query_type](https://api-docs.databricks.com/python/vector-search/databricks.vector_search.html#databricks.vector_search.index.VectorSearchIndex.similarity_search)이 포함됩니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
dvs.similarity_search(query)
print(docs[0].page_content)
```


## Delta 동기화 인덱스 작업

`DatabricksVectorSearch`를 사용하여 Delta 동기화 인덱스에서 검색할 수도 있습니다. Delta 동기화 인덱스는 Delta 테이블에서 자동으로 동기화됩니다. `add_text`/`add_documents`를 수동으로 호출할 필요가 없습니다. 자세한 내용은 [Databricks 문서 페이지](https://docs.databricks.com/en/generative-ai/vector-search.html#delta-sync-index-with-managed-embeddings)를 참조하세요.

```python
delta_sync_index = vsc.create_delta_sync_index(
    endpoint_name=vector_search_endpoint_name,
    source_table_name="vector_search_demo.vector_search.state_of_the_union",
    index_name="vector_search_demo.vector_search.state_of_the_union_index",
    pipeline_type="TRIGGERED",
    primary_key="id",
    embedding_source_column="text",
    embedding_model_endpoint_name="e5-small-v2",
)
dvs_delta_sync = DatabricksVectorSearch(delta_sync_index)
dvs_delta_sync.similarity_search(query)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)