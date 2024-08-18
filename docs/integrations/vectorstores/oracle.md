---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/oracle.ipynb
description: Oracle AI 벡터 검색은 의미 기반 쿼리를 통해 비즈니스 데이터와 비구조적 데이터를 효과적으로 결합하여 데이터 단편화를
  해소합니다.
---

# 오라클 AI 벡터 검색: 벡터 저장소

오라클 AI 벡터 검색은 키워드가 아닌 의미에 기반하여 데이터를 쿼리할 수 있도록 설계된 인공지능(AI) 작업 부하를 위한 시스템입니다.  
오라클 AI 벡터 검색의 가장 큰 장점 중 하나는 비구조적 데이터에 대한 의미 검색을 비즈니스 데이터에 대한 관계형 검색과 하나의 시스템에서 결합할 수 있다는 것입니다.  
이는 강력할 뿐만 아니라 여러 시스템 간의 데이터 단편화 문제를 없애주므로 훨씬 더 효과적입니다.  

또한, 귀하의 벡터는 다음과 같은 오라클 데이터베이스의 가장 강력한 기능을 활용할 수 있습니다:

* [파티셔닝 지원](https://www.oracle.com/database/technologies/partitioning.html)
* [실제 애플리케이션 클러스터 확장성](https://www.oracle.com/database/real-application-clusters/)
* [엑사데이터 스마트 스캔](https://www.oracle.com/database/technologies/exadata/software/smartscan/)
* [지리적으로 분산된 데이터베이스에서의 샤드 처리](https://www.oracle.com/database/distributed-database/)
* [트랜잭션](https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/transactions.html)
* [병렬 SQL](https://docs.oracle.com/en/database/oracle/oracle-database/21/vldbg/parallel-exec-intro.html#GUID-D28717E4-0F77-44F5-BB4E-234C31D4E4BA)
* [재해 복구](https://www.oracle.com/database/data-guard/)
* [보안](https://www.oracle.com/security/database-security/)
* [오라클 머신 러닝](https://www.oracle.com/artificial-intelligence/database-machine-learning/)
* [오라클 그래프 데이터베이스](https://www.oracle.com/database/integrated-graph-database/)
* [오라클 공간 및 그래프](https://www.oracle.com/database/spatial/)
* [오라클 블록체인](https://docs.oracle.com/en/database/oracle/oracle-database/23/arpls/dbms_blockchain_table.html#GUID-B469E277-978E-4378-A8C1-26D3FF96C9A6)
* [JSON](https://docs.oracle.com/en/database/oracle/oracle-database/23/adjsn/json-in-oracle-database.html)

오라클 데이터베이스를 처음 시작하는 경우, 데이터베이스 환경 설정에 대한 훌륭한 소개를 제공하는 [무료 오라클 23 AI](https://www.oracle.com/database/free/#resources)를 탐색하는 것을 고려해 보십시오. 데이터베이스 작업 시 기본적으로 시스템 사용자를 사용하는 것을 피하는 것이 좋습니다. 대신 보안 및 사용자 정의를 강화하기 위해 자신의 사용자를 생성할 수 있습니다. 사용자 생성에 대한 자세한 단계는 [종합 가이드](https://github.com/langchain-ai/langchain/blob/master/cookbook/oracleai_demo.ipynb)를 참조하십시오. 이 가이드에서는 오라클에서 사용자를 설정하는 방법도 보여줍니다. 또한, 사용자 권한을 이해하는 것은 데이터베이스 보안을 효과적으로 관리하는 데 중요합니다. 이 주제에 대한 자세한 내용은 사용자 계정 및 보안 관리를 위한 공식 [오라클 가이드](https://docs.oracle.com/en/database/oracle/oracle-database/19/admqs/administering-user-accounts-and-security.html#GUID-36B21D72-1BBB-46C9-A0C9-F0D2A8591B8D)를 통해 알아볼 수 있습니다.

### 오라클 AI 벡터 검색을 위한 Langchain 사용 전제 조건

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

오라클 AI 벡터 검색과 함께 Langchain을 사용하려면 오라클 파이썬 클라이언트 드라이버를 설치하십시오. 

```python
# pip install oracledb
```


### 오라클 AI 벡터 검색에 연결하기

다음 샘플 코드는 오라클 데이터베이스에 연결하는 방법을 보여줍니다. 기본적으로 python-oracledb는 오라클 데이터베이스에 직접 연결하는 'Thin' 모드로 실행됩니다. 이 모드는 오라클 클라이언트 라이브러리가 필요하지 않습니다. 그러나 python-oracledb가 이를 사용할 때 추가 기능이 제공됩니다. 오라클 클라이언트 라이브러리가 사용될 때 python-oracledb는 'Thick' 모드에 있다고 합니다. 두 모드 모두 Python 데이터베이스 API v2.0 사양을 지원하는 포괄적인 기능을 가지고 있습니다. 각 모드에서 지원되는 기능에 대한 [가이드](https://python-oracledb.readthedocs.io/en/latest/user_guide/appendix_a.html#featuresummary)를 참조하십시오. Thin 모드를 사용할 수 없는 경우 Thick 모드로 전환하는 것이 좋습니다.

```python
import oracledb

username = "username"
password = "password"
dsn = "ipaddress:port/orclpdb1"

try:
    connection = oracledb.connect(user=username, password=password, dsn=dsn)
    print("Connection successful!")
except Exception as e:
    print("Connection failed!")
```


### 오라클 AI 벡터 검색을 사용하기 위한 필수 종속성 가져오기

```python
<!--IMPORTS:[{"imported": "OracleVS", "source": "langchain_community.vectorstores.oraclevs", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.oraclevs.OracleVS.html", "title": "Oracle AI Vector Search: Vector Store"}, {"imported": "DistanceStrategy", "source": "langchain_community.vectorstores.utils", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.utils.DistanceStrategy.html", "title": "Oracle AI Vector Search: Vector Store"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Oracle AI Vector Search: Vector Store"}, {"imported": "HuggingFaceEmbeddings", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_huggingface.embeddings.huggingface.HuggingFaceEmbeddings.html", "title": "Oracle AI Vector Search: Vector Store"}]-->
from langchain_community.vectorstores import oraclevs
from langchain_community.vectorstores.oraclevs import OracleVS
from langchain_community.vectorstores.utils import DistanceStrategy
from langchain_core.documents import Document
from langchain_huggingface import HuggingFaceEmbeddings
```


### 문서 로드

```python
# Define a list of documents (The examples below are 5 random documents from Oracle Concepts Manual )

documents_json_list = [
    {
        "id": "cncpt_15.5.3.2.2_P4",
        "text": "If the answer to any preceding questions is yes, then the database stops the search and allocates space from the specified tablespace; otherwise, space is allocated from the database default shared temporary tablespace.",
        "link": "https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/logical-storage-structures.html#GUID-5387D7B2-C0CA-4C1E-811B-C7EB9B636442",
    },
    {
        "id": "cncpt_15.5.5_P1",
        "text": "A tablespace can be online (accessible) or offline (not accessible) whenever the database is open.\nA tablespace is usually online so that its data is available to users. The SYSTEM tablespace and temporary tablespaces cannot be taken offline.",
        "link": "https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/logical-storage-structures.html#GUID-D02B2220-E6F5-40D9-AFB5-BC69BCEF6CD4",
    },
    {
        "id": "cncpt_22.3.4.3.1_P2",
        "text": "The database stores LOBs differently from other data types. Creating a LOB column implicitly creates a LOB segment and a LOB index. The tablespace containing the LOB segment and LOB index, which are always stored together, may be different from the tablespace containing the table.\nSometimes the database can store small amounts of LOB data in the table itself rather than in a separate LOB segment.",
        "link": "https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/concepts-for-database-developers.html#GUID-3C50EAB8-FC39-4BB3-B680-4EACCE49E866",
    },
    {
        "id": "cncpt_22.3.4.3.1_P3",
        "text": "The LOB segment stores data in pieces called chunks. A chunk is a logically contiguous set of data blocks and is the smallest unit of allocation for a LOB. A row in the table stores a pointer called a LOB locator, which points to the LOB index. When the table is queried, the database uses the LOB index to quickly locate the LOB chunks.",
        "link": "https://docs.oracle.com/en/database/oracle/oracle-database/23/cncpt/concepts-for-database-developers.html#GUID-3C50EAB8-FC39-4BB3-B680-4EACCE49E866",
    },
]
```


```python
# Create Langchain Documents

documents_langchain = []

for doc in documents_json_list:
    metadata = {"id": doc["id"], "link": doc["link"]}
    doc_langchain = Document(page_content=doc["text"], metadata=metadata)
    documents_langchain.append(doc_langchain)
```


### AI 벡터 검색을 사용하여 다양한 거리 메트릭으로 벡터 저장소 생성

먼저 서로 다른 거리 함수로 세 개의 벡터 저장소를 생성합니다. 아직 인덱스를 생성하지 않았기 때문에 현재는 테이블만 생성됩니다. 나중에 이 벡터 저장소를 사용하여 HNSW 인덱스를 생성할 것입니다. 오라클 AI 벡터 검색이 지원하는 다양한 유형의 인덱스에 대해 더 알고 싶다면 다음 [가이드](https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/manage-different-categories-vector-indexes.html)를 참조하십시오.

오라클 데이터베이스에 수동으로 연결하면 세 개의 테이블이 표시됩니다: Documents_DOT, Documents_COSINE 및 Documents_EUCLIDEAN.

그런 다음 IVF 인덱스를 생성하는 데 사용될 Documents_DOT_IVF, Documents_COSINE_IVF 및 Documents_EUCLIDEAN_IVF라는 세 개의 추가 테이블을 생성합니다.

```python
# Ingest documents into Oracle Vector Store using different distance strategies

# When using our API calls, start by initializing your vector store with a subset of your documents
# through from_documents(), then incrementally add more documents using add_texts().
# This approach prevents system overload and ensures efficient document processing.

model = HuggingFaceEmbeddings(model_name="sentence-transformers/all-mpnet-base-v2")

vector_store_dot = OracleVS.from_documents(
    documents_langchain,
    model,
    client=connection,
    table_name="Documents_DOT",
    distance_strategy=DistanceStrategy.DOT_PRODUCT,
)
vector_store_max = OracleVS.from_documents(
    documents_langchain,
    model,
    client=connection,
    table_name="Documents_COSINE",
    distance_strategy=DistanceStrategy.COSINE,
)
vector_store_euclidean = OracleVS.from_documents(
    documents_langchain,
    model,
    client=connection,
    table_name="Documents_EUCLIDEAN",
    distance_strategy=DistanceStrategy.EUCLIDEAN_DISTANCE,
)

# Ingest documents into Oracle Vector Store using different distance strategies
vector_store_dot_ivf = OracleVS.from_documents(
    documents_langchain,
    model,
    client=connection,
    table_name="Documents_DOT_IVF",
    distance_strategy=DistanceStrategy.DOT_PRODUCT,
)
vector_store_max_ivf = OracleVS.from_documents(
    documents_langchain,
    model,
    client=connection,
    table_name="Documents_COSINE_IVF",
    distance_strategy=DistanceStrategy.COSINE,
)
vector_store_euclidean_ivf = OracleVS.from_documents(
    documents_langchain,
    model,
    client=connection,
    table_name="Documents_EUCLIDEAN_IVF",
    distance_strategy=DistanceStrategy.EUCLIDEAN_DISTANCE,
)
```


### 텍스트에 대한 추가 및 삭제 작업 시연, 기본 유사성 검색 포함

```python
def manage_texts(vector_stores):
    """
    Adds texts to each vector store, demonstrates error handling for duplicate additions,
    and performs deletion of texts. Showcases similarity searches and index creation for each vector store.

    Args:
    - vector_stores (list): A list of OracleVS instances.
    """
    texts = ["Rohan", "Shailendra"]
    metadata = [
        {"id": "100", "link": "Document Example Test 1"},
        {"id": "101", "link": "Document Example Test 2"},
    ]

    for i, vs in enumerate(vector_stores, start=1):
        # Adding texts
        try:
            vs.add_texts(texts, metadata)
            print(f"\n\n\nAdd texts complete for vector store {i}\n\n\n")
        except Exception as ex:
            print(f"\n\n\nExpected error on duplicate add for vector store {i}\n\n\n")

        # Deleting texts using the value of 'id'
        vs.delete([metadata[0]["id"]])
        print(f"\n\n\nDelete texts complete for vector store {i}\n\n\n")

        # Similarity search
        results = vs.similarity_search("How are LOBS stored in Oracle Database", 2)
        print(f"\n\n\nSimilarity search results for vector store {i}: {results}\n\n\n")


vector_store_list = [
    vector_store_dot,
    vector_store_max,
    vector_store_euclidean,
    vector_store_dot_ivf,
    vector_store_max_ivf,
    vector_store_euclidean_ivf,
]
manage_texts(vector_store_list)
```


### 각 거리 전략에 대한 특정 매개변수로 인덱스 생성 시연

```python
def create_search_indices(connection):
    """
    Creates search indices for the vector stores, each with specific parameters tailored to their distance strategy.
    """
    # Index for DOT_PRODUCT strategy
    # Notice we are creating a HNSW index with default parameters
    # This will default to creating a HNSW index with 8 Parallel Workers and use the Default Accuracy used by Oracle AI Vector Search
    oraclevs.create_index(
        connection,
        vector_store_dot,
        params={"idx_name": "hnsw_idx1", "idx_type": "HNSW"},
    )

    # Index for COSINE strategy with specific parameters
    # Notice we are creating a HNSW index with parallel 16 and Target Accuracy Specification as 97 percent
    oraclevs.create_index(
        connection,
        vector_store_max,
        params={
            "idx_name": "hnsw_idx2",
            "idx_type": "HNSW",
            "accuracy": 97,
            "parallel": 16,
        },
    )

    # Index for EUCLIDEAN_DISTANCE strategy with specific parameters
    # Notice we are creating a HNSW index by specifying Power User Parameters which are neighbors = 64 and efConstruction = 100
    oraclevs.create_index(
        connection,
        vector_store_euclidean,
        params={
            "idx_name": "hnsw_idx3",
            "idx_type": "HNSW",
            "neighbors": 64,
            "efConstruction": 100,
        },
    )

    # Index for DOT_PRODUCT strategy with specific parameters
    # Notice we are creating an IVF index with default parameters
    # This will default to creating an IVF index with 8 Parallel Workers and use the Default Accuracy used by Oracle AI Vector Search
    oraclevs.create_index(
        connection,
        vector_store_dot_ivf,
        params={
            "idx_name": "ivf_idx1",
            "idx_type": "IVF",
        },
    )

    # Index for COSINE strategy with specific parameters
    # Notice we are creating an IVF index with parallel 32 and Target Accuracy Specification as 90 percent
    oraclevs.create_index(
        connection,
        vector_store_max_ivf,
        params={
            "idx_name": "ivf_idx2",
            "idx_type": "IVF",
            "accuracy": 90,
            "parallel": 32,
        },
    )

    # Index for EUCLIDEAN_DISTANCE strategy with specific parameters
    # Notice we are creating an IVF index by specifying Power User Parameters which is neighbor_part = 64
    oraclevs.create_index(
        connection,
        vector_store_euclidean_ivf,
        params={"idx_name": "ivf_idx3", "idx_type": "IVF", "neighbor_part": 64},
    )

    print("Index creation complete.")


create_search_indices(connection)
```


### 모든 여섯 개의 벡터 저장소에서 고급 검색 시연, 속성 필터링 유무에 따라 – 필터링을 통해 문서 ID 101만 선택하고 다른 것은 선택하지 않습니다.

```python
# Conduct advanced searches after creating the indices
def conduct_advanced_searches(vector_stores):
    query = "How are LOBS stored in Oracle Database"
    # Constructing a filter for direct comparison against document metadata
    # This filter aims to include documents whose metadata 'id' is exactly '2'
    filter_criteria = {"id": ["101"]}  # Direct comparison filter

    for i, vs in enumerate(vector_stores, start=1):
        print(f"\n--- Vector Store {i} Advanced Searches ---")
        # Similarity search without a filter
        print("\nSimilarity search results without filter:")
        print(vs.similarity_search(query, 2))

        # Similarity search with a filter
        print("\nSimilarity search results with filter:")
        print(vs.similarity_search(query, 2, filter=filter_criteria))

        # Similarity search with relevance score
        print("\nSimilarity search with relevance score:")
        print(vs.similarity_search_with_score(query, 2))

        # Similarity search with relevance score with filter
        print("\nSimilarity search with relevance score with filter:")
        print(vs.similarity_search_with_score(query, 2, filter=filter_criteria))

        # Max marginal relevance search
        print("\nMax marginal relevance search results:")
        print(vs.max_marginal_relevance_search(query, 2, fetch_k=20, lambda_mult=0.5))

        # Max marginal relevance search with filter
        print("\nMax marginal relevance search results with filter:")
        print(
            vs.max_marginal_relevance_search(
                query, 2, fetch_k=20, lambda_mult=0.5, filter=filter_criteria
            )
        )


conduct_advanced_searches(vector_store_list)
```


### 종합 데모  
오라클 AI 벡터 검색을 활용하여 종합 RAG 파이프라인을 구축하기 위한 전체 데모 가이드인 [오라클 AI 벡터 검색 종합 데모 가이드](https://github.com/langchain-ai/langchain/tree/master/cookbook/oracleai_demo.ipynb)를 참조하십시오.

## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)