---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/indexing.ipynb
description: LangChain 인덱싱 API를 사용하여 문서를 벡터 스토어에 동기화하고 중복 및 변경되지 않은 콘텐츠 처리를 최적화하는
  방법을 설명합니다.
---

# LangChain 인덱싱 API 사용 방법

여기에서는 LangChain 인덱싱 API를 사용한 기본 인덱싱 워크플로우를 살펴보겠습니다.

인덱싱 API는 모든 소스에서 문서를 로드하고 벡터 저장소와 동기화 상태를 유지할 수 있게 해줍니다. 구체적으로, 다음을 도와줍니다:

* 벡터 저장소에 중복된 콘텐츠를 작성하지 않도록 방지
* 변경되지 않은 콘텐츠를 다시 작성하지 않도록 방지
* 변경되지 않은 콘텐츠에 대해 임베딩을 다시 계산하지 않도록 방지

이 모든 것은 시간과 비용을 절약하고 벡터 검색 결과를 개선하는 데 도움이 됩니다.

중요하게도, 인덱싱 API는 원본 문서에 대해 여러 변환 단계를 거친 문서에서도 작동합니다 (예: 텍스트 청크화).

## 작동 방식

LangChain 인덱싱은 벡터 저장소에 문서 쓰기를 추적하는 레코드 관리자(`RecordManager`)를 사용합니다.

콘텐츠를 인덱싱할 때 각 문서에 대해 해시가 계산되며, 다음 정보가 레코드 관리자에 저장됩니다:

- 문서 해시 (페이지 콘텐츠와 메타데이터의 해시)
- 작성 시간
- 소스 ID -- 각 문서는 이 문서의 궁극적인 출처를 결정할 수 있도록 메타데이터에 정보를 포함해야 합니다.

## 삭제 모드

문서를 벡터 저장소에 인덱싱할 때, 벡터 저장소에 있는 기존 문서 중 일부를 삭제해야 할 수 있습니다. 특정 상황에서는 새로 인덱싱되는 문서와 동일한 소스에서 파생된 기존 문서를 제거하고 싶을 수 있습니다. 다른 경우에는 모든 기존 문서를 일괄 삭제하고 싶을 수 있습니다. 인덱싱 API 삭제 모드는 원하는 동작을 선택할 수 있게 해줍니다:

| 정리 모드 | 콘텐츠 중복 제거 | 병렬 가능 | 삭제된 소스 문서 정리 | 소스 문서 및/또는 파생 문서의 변형 정리 | 정리 타이밍 |
|-----------|------------------|-----------|-----------------------|------------------------------------------|--------------|
| 없음      | ✅               | ✅        | ❌                    | ❌                                       | -            |
| 증분      | ✅               | ✅        | ❌                    | ✅                                       | 지속적으로   |
| 전체      | ✅               | ❌        | ✅                    | ✅                                       | 인덱싱 종료 시 |

`없음`은 자동 정리를 수행하지 않으며, 사용자가 수동으로 오래된 콘텐츠를 정리할 수 있게 합니다.

`증분` 및 `전체`는 다음과 같은 자동 정리를 제공합니다:

* 소스 문서 또는 파생 문서의 콘텐츠가 **변경된** 경우, `증분` 또는 `전체` 모드는 이전 버전의 콘텐츠를 정리(삭제)합니다.
* 소스 문서가 **삭제된** 경우(현재 인덱싱되고 있는 문서에 포함되지 않음), `전체` 정리 모드는 벡터 저장소에서 이를 올바르게 삭제하지만, `증분` 모드는 삭제하지 않습니다.

콘텐츠가 변형될 때(예: 소스 PDF 파일이 수정됨) 인덱싱 중에 새로운 버전과 이전 버전이 모두 사용자에게 반환될 수 있는 기간이 있습니다. 이는 새로운 콘텐츠가 작성된 후, 이전 버전이 삭제되기 전 발생합니다.

* `증분` 인덱싱은 정리를 지속적으로 수행할 수 있어 이 기간을 최소화합니다.
* `전체` 모드는 모든 배치가 작성된 후 정리를 수행합니다.

## 요구 사항

1. 인덱싱 API와 독립적으로 콘텐츠로 미리 채워진 저장소와 함께 사용하지 마십시오. 레코드 관리자는 이전에 레코드가 삽입되었다는 것을 알지 못합니다.
2. 다음을 지원하는 LangChain `vectorstore`와만 작동합니다:
   * ID로 문서 추가 (`ids` 인수와 함께 `add_documents` 메서드)
   * ID로 삭제 (`ids` 인수와 함께 `delete` 메서드)

호환 가능한 벡터 저장소: `Aerospike`, `AnalyticDB`, `AstraDB`, `AwaDB`, `AzureCosmosDBNoSqlVectorSearch`, `AzureCosmosDBVectorSearch`, `Bagel`, `Cassandra`, `Chroma`, `CouchbaseVectorStore`, `DashVector`, `DatabricksVectorSearch`, `DeepLake`, `Dingo`, `ElasticVectorSearch`, `ElasticsearchStore`, `FAISS`, `HanaDB`, `Milvus`, `MongoDBAtlasVectorSearch`, `MyScale`, `OpenSearchVectorSearch`, `PGVector`, `Pinecone`, `Qdrant`, `Redis`, `Rockset`, `ScaNN`, `SingleStoreDB`, `SupabaseVectorStore`, `SurrealDBStore`, `TimescaleVector`, `Vald`, `VDMS`, `Vearch`, `VespaStore`, `Weaviate`, `Yellowbrick`, `ZepVectorStore`, `TencentVectorDB`, `OpenSearchVectorSearch`.

## 주의 사항

레코드 관리자는 어떤 콘텐츠를 정리할 수 있는지 결정하기 위해 시간 기반 메커니즘에 의존합니다 (`전체` 또는 `증분` 정리 모드 사용 시).

두 작업이 연속으로 실행되고 첫 번째 작업이 시계 시간이 변경되기 전에 완료되면 두 번째 작업이 콘텐츠를 정리하지 못할 수 있습니다.

이는 다음과 같은 이유로 실제 환경에서는 문제가 될 가능성이 낮습니다:

1. RecordManager는 더 높은 해상도의 타임스탬프를 사용합니다.
2. 첫 번째 작업과 두 번째 작업 실행 사이에 데이터가 변경되어야 하며, 작업 간의 시간 간격이 작으면 이는 가능성이 낮아집니다.
3. 인덱싱 작업은 일반적으로 몇 밀리초 이상 소요됩니다.

## 빠른 시작

```python
<!--IMPORTS:[{"imported": "SQLRecordManager", "source": "langchain.indexes", "docs": "https://api.python.langchain.com/en/latest/indexes/langchain.indexes._sql_record_manager.SQLRecordManager.html", "title": "How to use the LangChain indexing API"}, {"imported": "index", "source": "langchain.indexes", "docs": "https://api.python.langchain.com/en/latest/indexing/langchain_core.indexing.api.index.html", "title": "How to use the LangChain indexing API"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to use the LangChain indexing API"}, {"imported": "ElasticsearchStore", "source": "langchain_elasticsearch", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_elasticsearch.vectorstores.ElasticsearchStore.html", "title": "How to use the LangChain indexing API"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to use the LangChain indexing API"}]-->
from langchain.indexes import SQLRecordManager, index
from langchain_core.documents import Document
from langchain_elasticsearch import ElasticsearchStore
from langchain_openai import OpenAIEmbeddings
```


벡터 저장소를 초기화하고 임베딩을 설정합니다:

```python
collection_name = "test_index"

embedding = OpenAIEmbeddings()

vectorstore = ElasticsearchStore(
    es_url="http://localhost:9200", index_name="test_index", embedding=embedding
)
```


적절한 네임스페이스로 레코드 관리자를 초기화합니다.

**제안:** 벡터 저장소와 벡터 저장소의 컬렉션 이름을 모두 고려한 네임스페이스를 사용하십시오; 예: 'redis/my_docs', 'chromadb/my_docs' 또는 'postgres/my_docs'.

```python
namespace = f"elasticsearch/{collection_name}"
record_manager = SQLRecordManager(
    namespace, db_url="sqlite:///record_manager_cache.sql"
)
```


레코드 관리자를 사용하기 전에 스키마를 생성합니다.

```python
record_manager.create_schema()
```


테스트 문서를 인덱싱해 봅시다:

```python
doc1 = Document(page_content="kitty", metadata={"source": "kitty.txt"})
doc2 = Document(page_content="doggy", metadata={"source": "doggy.txt"})
```


빈 벡터 저장소에 인덱싱:

```python
def _clear():
    """Hacky helper method to clear content. See the `full` mode section to to understand why it works."""
    index([], record_manager, vectorstore, cleanup="full", source_id_key="source")
```


### `없음` 삭제 모드

이 모드는 오래된 콘텐츠 버전의 자동 정리를 수행하지 않지만, 여전히 콘텐츠 중복 제거를 처리합니다.

```python
_clear()
```


```python
index(
    [doc1, doc1, doc1, doc1, doc1],
    record_manager,
    vectorstore,
    cleanup=None,
    source_id_key="source",
)
```


```output
{'num_added': 1, 'num_updated': 0, 'num_skipped': 0, 'num_deleted': 0}
```


```python
_clear()
```


```python
index([doc1, doc2], record_manager, vectorstore, cleanup=None, source_id_key="source")
```


```output
{'num_added': 2, 'num_updated': 0, 'num_skipped': 0, 'num_deleted': 0}
```


두 번째 시도에서는 모든 콘텐츠가 건너뛰어집니다:

```python
index([doc1, doc2], record_manager, vectorstore, cleanup=None, source_id_key="source")
```


```output
{'num_added': 0, 'num_updated': 0, 'num_skipped': 2, 'num_deleted': 0}
```


### `"증분"` 삭제 모드

```python
_clear()
```


```python
index(
    [doc1, doc2],
    record_manager,
    vectorstore,
    cleanup="incremental",
    source_id_key="source",
)
```


```output
{'num_added': 2, 'num_updated': 0, 'num_skipped': 0, 'num_deleted': 0}
```


다시 인덱싱하면 두 문서가 **건너뛰어져야 합니다** -- 임베딩 작업도 건너뛰어집니다!

```python
index(
    [doc1, doc2],
    record_manager,
    vectorstore,
    cleanup="incremental",
    source_id_key="source",
)
```


```output
{'num_added': 0, 'num_updated': 0, 'num_skipped': 2, 'num_deleted': 0}
```


증분 인덱싱 모드로 문서를 제공하지 않으면 아무것도 변경되지 않습니다.

```python
index([], record_manager, vectorstore, cleanup="incremental", source_id_key="source")
```


```output
{'num_added': 0, 'num_updated': 0, 'num_skipped': 0, 'num_deleted': 0}
```


문서를 변형하면 새로운 버전이 작성되고 동일한 소스를 공유하는 모든 이전 버전이 삭제됩니다.

```python
changed_doc_2 = Document(page_content="puppy", metadata={"source": "doggy.txt"})
```


```python
index(
    [changed_doc_2],
    record_manager,
    vectorstore,
    cleanup="incremental",
    source_id_key="source",
)
```


```output
{'num_added': 1, 'num_updated': 0, 'num_skipped': 0, 'num_deleted': 1}
```


### `"전체"` 삭제 모드

`전체` 모드에서는 사용자가 인덱싱 함수에 인덱싱해야 할 콘텐츠의 `전체` 우주를 전달해야 합니다.

인덱싱 함수에 전달되지 않고 벡터 저장소에 존재하는 문서는 삭제됩니다!

이 동작은 소스 문서 삭제를 처리하는 데 유용합니다.

```python
_clear()
```


```python
all_docs = [doc1, doc2]
```


```python
index(all_docs, record_manager, vectorstore, cleanup="full", source_id_key="source")
```


```output
{'num_added': 2, 'num_updated': 0, 'num_skipped': 0, 'num_deleted': 0}
```


누군가 첫 번째 문서를 삭제했다고 가정해 보십시오:

```python
del all_docs[0]
```


```python
all_docs
```


```output
[Document(page_content='doggy', metadata={'source': 'doggy.txt'})]
```


전체 모드를 사용하면 삭제된 콘텐츠도 정리됩니다.

```python
index(all_docs, record_manager, vectorstore, cleanup="full", source_id_key="source")
```


```output
{'num_added': 0, 'num_updated': 0, 'num_skipped': 1, 'num_deleted': 1}
```


## 출처

메타데이터 속성에는 `source`라는 필드가 포함되어 있습니다. 이 소스는 주어진 문서와 관련된 *궁극적인* 출처를 가리켜야 합니다.

예를 들어, 이러한 문서가 일부 부모 문서의 청크를 나타내는 경우, 두 문서의 `source`는 동일해야 하며 부모 문서를 참조해야 합니다.

일반적으로 `source`는 항상 지정되어야 합니다. `증분` 모드를 **절대** 사용하지 않을 경우에만 `None`을 사용하고, 어떤 이유로 `source` 필드를 올바르게 지정할 수 없는 경우에만 사용하십시오.

```python
<!--IMPORTS:[{"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "How to use the LangChain indexing API"}]-->
from langchain_text_splitters import CharacterTextSplitter
```


```python
doc1 = Document(
    page_content="kitty kitty kitty kitty kitty", metadata={"source": "kitty.txt"}
)
doc2 = Document(page_content="doggy doggy the doggy", metadata={"source": "doggy.txt"})
```


```python
new_docs = CharacterTextSplitter(
    separator="t", keep_separator=True, chunk_size=12, chunk_overlap=2
).split_documents([doc1, doc2])
new_docs
```


```output
[Document(page_content='kitty kit', metadata={'source': 'kitty.txt'}),
 Document(page_content='tty kitty ki', metadata={'source': 'kitty.txt'}),
 Document(page_content='tty kitty', metadata={'source': 'kitty.txt'}),
 Document(page_content='doggy doggy', metadata={'source': 'doggy.txt'}),
 Document(page_content='the doggy', metadata={'source': 'doggy.txt'})]
```


```python
_clear()
```


```python
index(
    new_docs,
    record_manager,
    vectorstore,
    cleanup="incremental",
    source_id_key="source",
)
```


```output
{'num_added': 5, 'num_updated': 0, 'num_skipped': 0, 'num_deleted': 0}
```


```python
changed_doggy_docs = [
    Document(page_content="woof woof", metadata={"source": "doggy.txt"}),
    Document(page_content="woof woof woof", metadata={"source": "doggy.txt"}),
]
```


이는 `doggy.txt` 소스와 관련된 문서의 이전 버전을 삭제하고 새 버전으로 교체해야 합니다.

```python
index(
    changed_doggy_docs,
    record_manager,
    vectorstore,
    cleanup="incremental",
    source_id_key="source",
)
```


```output
{'num_added': 2, 'num_updated': 0, 'num_skipped': 0, 'num_deleted': 2}
```


```python
vectorstore.similarity_search("dog", k=30)
```


```output
[Document(page_content='woof woof', metadata={'source': 'doggy.txt'}),
 Document(page_content='woof woof woof', metadata={'source': 'doggy.txt'}),
 Document(page_content='tty kitty', metadata={'source': 'kitty.txt'}),
 Document(page_content='tty kitty ki', metadata={'source': 'kitty.txt'}),
 Document(page_content='kitty kit', metadata={'source': 'kitty.txt'})]
```


## 로더와 함께 사용하기

인덱싱은 문서의 반복 가능 객체 또는 로더를 수용할 수 있습니다.

**주의:** 로더는 **반드시** 소스 키를 올바르게 설정해야 합니다.

```python
<!--IMPORTS:[{"imported": "BaseLoader", "source": "langchain_core.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_core.document_loaders.base.BaseLoader.html", "title": "How to use the LangChain indexing API"}]-->
from langchain_core.document_loaders import BaseLoader


class MyCustomLoader(BaseLoader):
    def lazy_load(self):
        text_splitter = CharacterTextSplitter(
            separator="t", keep_separator=True, chunk_size=12, chunk_overlap=2
        )
        docs = [
            Document(page_content="woof woof", metadata={"source": "doggy.txt"}),
            Document(page_content="woof woof woof", metadata={"source": "doggy.txt"}),
        ]
        yield from text_splitter.split_documents(docs)

    def load(self):
        return list(self.lazy_load())
```


```python
_clear()
```


```python
loader = MyCustomLoader()
```


```python
loader.load()
```


```output
[Document(page_content='woof woof', metadata={'source': 'doggy.txt'}),
 Document(page_content='woof woof woof', metadata={'source': 'doggy.txt'})]
```


```python
index(loader, record_manager, vectorstore, cleanup="full", source_id_key="source")
```


```output
{'num_added': 2, 'num_updated': 0, 'num_skipped': 0, 'num_deleted': 0}
```


```python
vectorstore.similarity_search("dog", k=30)
```


```output
[Document(page_content='woof woof', metadata={'source': 'doggy.txt'}),
 Document(page_content='woof woof woof', metadata={'source': 'doggy.txt'})]
```