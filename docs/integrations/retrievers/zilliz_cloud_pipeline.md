---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/zilliz_cloud_pipeline.ipynb
description: Zilliz Cloud Pipeline을 사용하여 비정형 데이터를 검색 가능한 벡터 컬렉션으로 변환하는 방법을 설명합니다.
  LangChain Retriever와 함께 사용합니다.
---

# Zilliz Cloud 파이프라인

> [Zilliz Cloud 파이프라인](https://docs.zilliz.com/docs/pipelines)은 비구조화된 데이터를 검색 가능한 벡터 컬렉션으로 변환하며, 데이터의 임베딩, 수집, 검색 및 삭제를 연결합니다.
> 
> Zilliz Cloud 파이프라인은 Zilliz Cloud 콘솔과 RestFul API를 통해 사용할 수 있습니다.

이 노트북은 Zilliz Cloud 파이프라인을 준비하고 LangChain 리트리버를 통해 사용하는 방법을 보여줍니다.

## Zilliz Cloud 파이프라인 준비하기

LangChain 리트리버를 위한 파이프라인을 준비하려면 Zilliz Cloud에서 서비스를 생성하고 구성해야 합니다.

**1. 데이터베이스 설정**

- [Zilliz Cloud에 등록하기](https://docs.zilliz.com/docs/register-with-zilliz-cloud)
- [클러스터 생성하기](https://docs.zilliz.com/docs/create-cluster)

**2. 파이프라인 생성하기**

- [문서 수집, 검색, 삭제](https://docs.zilliz.com/docs/pipelines-doc-data)
- [텍스트 수집, 검색, 삭제](https://docs.zilliz.com/docs/pipelines-text-data)

## LangChain 리트리버 사용하기

```python
%pip install --upgrade --quiet langchain-milvus
```


```python
<!--IMPORTS:[{"imported": "ZillizCloudPipelineRetriever", "source": "langchain_milvus", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_milvus.retrievers.zilliz_cloud_pipeline_retriever.ZillizCloudPipelineRetriever.html", "title": "Zilliz Cloud Pipeline"}]-->
from langchain_milvus import ZillizCloudPipelineRetriever

retriever = ZillizCloudPipelineRetriever(
    pipeline_ids={
        "ingestion": "<YOUR_INGESTION_PIPELINE_ID>",  # skip this line if you do NOT need to add documents
        "search": "<YOUR_SEARCH_PIPELINE_ID>",  # skip this line if you do NOT need to get relevant documents
        "deletion": "<YOUR_DELETION_PIPELINE_ID>",  # skip this line if you do NOT need to delete documents
    },
    token="<YOUR_ZILLIZ_CLOUD_API_KEY>",
)
```


### 문서 추가하기

문서를 추가하려면 `add_texts` 또는 `add_doc_url` 메서드를 사용할 수 있으며, 이는 텍스트 목록 또는 해당 메타데이터와 함께 presigned/public url에서 문서를 저장소에 삽입합니다.

- **텍스트 수집 파이프라인**을 사용하는 경우, `add_texts` 메서드를 사용할 수 있으며, 이는 해당 메타데이터와 함께 텍스트 배치를 Zilliz Cloud 스토리지에 삽입합니다.
  
  **인수:**
  - `texts`: 텍스트 문자열 목록.
  - `metadata`: 수집 파이프라인에서 요구하는 보존 필드로 삽입될 메타데이터의 키-값 딕셔너리. 기본값은 None입니다.

```python
# retriever.add_texts(
#     texts = ["example text 1e", "example text 2"],
#     metadata={"<FIELD_NAME>": "<FIELD_VALUE>"}  # skip this line if no preserved field is required by the ingestion pipeline
#     )
```


- **문서 수집 파이프라인**을 사용하는 경우, `add_doc_url` 메서드를 사용할 수 있으며, 이는 해당 메타데이터와 함께 url에서 문서를 Zilliz Cloud 스토리지에 삽입합니다.
  
  **인수:**
  - `doc_url`: 문서 url.
  - `metadata`: 수집 파이프라인에서 요구하는 보존 필드로 삽입될 메타데이터의 키-값 딕셔너리. 기본값은 None입니다.

다음 예제는 메타데이터로 milvus 버전이 필요한 문서 수집 파이프라인과 함께 작동합니다. 우리는 Milvus v2.3.x에서 엔티티를 삭제하는 방법을 설명하는 [예제 문서](https://publicdataset.zillizcloud.com/milvus_doc.md)를 사용할 것입니다.

```python
retriever.add_doc_url(
    doc_url="https://publicdataset.zillizcloud.com/milvus_doc.md",
    metadata={"version": "v2.3.x"},
)
```


```output
{'token_usage': 1247, 'doc_name': 'milvus_doc.md', 'num_chunks': 6}
```


### 관련 문서 가져오기

리트리버를 쿼리하려면 `get_relevant_documents` 메서드를 사용할 수 있으며, 이는 LangChain Document 객체 목록을 반환합니다.

**인수:**
- `query`: 관련 문서를 찾기 위한 문자열.
- `top_k`: 결과 수. 기본값은 10입니다.
- `offset`: 검색 결과에서 건너뛸 레코드 수. 기본값은 0입니다.
- `output_fields`: 출력에 표시할 추가 필드.
- `filter`: 검색 결과를 필터링하기 위한 Milvus 표현식. 기본값은 ""입니다.
- `run_manager`: 사용할 콜백 핸들러.

```python
retriever.get_relevant_documents(
    "Can users delete entities by complex boolean expressions?"
)
```


```output
[Document(page_content='# Delete Entities\nThis topic describes how to delete entities in Milvus.  \nMilvus supports deleting entities by primary key or complex boolean expressions. Deleting entities by primary key is much faster and lighter than deleting them by complex boolean expressions. This is because Milvus executes queries first when deleting data by complex boolean expressions.  \nDeleted entities can still be retrieved immediately after the deletion if the consistency level is set lower than Strong.\nEntities deleted beyond the pre-specified span of time for Time Travel cannot be retrieved again.\nFrequent deletion operations will impact the system performance.  \nBefore deleting entities by comlpex boolean expressions, make sure the collection has been loaded.\nDeleting entities by complex boolean expressions is not an atomic operation. Therefore, if it fails halfway through, some data may still be deleted.\nDeleting entities by complex boolean expressions is supported only when the consistency is set to Bounded. For details, see Consistency.\\\n\\\n# Delete Entities\n## Prepare boolean expression\nPrepare the boolean expression that filters the entities to delete.  \nMilvus supports deleting entities by primary key or complex boolean expressions. For more information on expression rules and supported operators, see Boolean Expression Rules.', metadata={'id': 448986959321277978, 'distance': 0.7871403694152832}),
 Document(page_content='# Delete Entities\n## Prepare boolean expression\n### Simple boolean expression\nUse a simple expression to filter data with primary key values of 0 and 1:  \n```python\nexpr = "book_id in [0,1]"\n```\\\n\\\n# Delete Entities\n## Prepare boolean expression\n### Complex boolean expression\nTo filter entities that meet specific conditions, define complex boolean expressions.  \nFilter entities whose word_count is greater than or equal to 11000:  \n```python\nexpr = "word_count >= 11000"\n```  \nFilter entities whose book_name is not Unknown:  \n```python\nexpr = "book_name != Unknown"\n```  \nFilter entities whose primary key values are greater than 5 and word_count is smaller than or equal to 9999:  \n```python\nexpr = "book_id > 5 && word_count <= 9999"\n```', metadata={'id': 448986959321277979, 'distance': 0.7775762677192688}),
 Document(page_content='# Delete Entities\n## Delete entities\nDelete the entities with the boolean expression you created. Milvus returns the ID list of the deleted entities.\n```python\nfrom pymilvus import Collection\ncollection = Collection("book")      # Get an existing collection.\ncollection.delete(expr)\n```  \nParameter\tDescription\nexpr\tBoolean expression that specifies the entities to delete.\npartition_name (optional)\tName of the partition to delete entities from.\\\n\\\n# Upsert Entities\nThis topic describes how to upsert entities in Milvus.  \nUpserting is a combination of insert and delete operations. In the context of a Milvus vector database, an upsert is a data-level operation that will overwrite an existing entity if a specified field already exists in a collection, and insert a new entity if the specified value doesn’t already exist.  \nThe following example upserts 3,000 rows of randomly generated data as the example data. When performing upsert operations, it\'s important to note that the operation may compromise performance. This is because the operation involves deleting data during execution.', metadata={'id': 448986959321277980, 'distance': 0.680284857749939}),
 Document(page_content='# Upsert Entities\n## Flush data\nWhen data is upserted into Milvus it is updated and inserted into segments. Segments have to reach a certain size to be sealed and indexed. Unsealed segments will be searched brute force. In order to avoid this with any remainder data, it is best to call flush(). The flush() call will seal any remaining segments and send them for indexing. It is important to only call this method at the end of an upsert session. Calling it too often will cause fragmented data that will need to be cleaned later on.\\\n\\\n# Upsert Entities\n## Limits\nUpdating primary key fields is not supported by upsert().\nupsert() is not applicable and an error can occur if autoID is set to True for primary key fields.', metadata={'id': 448986959321277983, 'distance': 0.5672488212585449}),
 Document(page_content='# Upsert Entities\n## Prepare data\nFirst, prepare the data to upsert. The type of data to upsert must match the schema of the collection, otherwise Milvus will raise an exception.  \nMilvus supports default values for scalar fields, excluding a primary key field. This indicates that some fields can be left empty during data inserts or upserts. For more information, refer to Create a Collection.  \n```python\n# Generate data to upsert\n\nimport random\nnb = 3000\ndim = 8\nvectors = [[random.random() for _ in range(dim)] for _ in range(nb)]\ndata = [\n[i for i in range(nb)],\n[str(i) for i in range(nb)],\n[i for i in range(10000, 10000+nb)],\nvectors,\n[str("dy"*i) for i in range(nb)]\n]\n```', metadata={'id': 448986959321277981, 'distance': 0.5107149481773376}),
 Document(page_content='# Upsert Entities\n## Upsert data\nUpsert the data to the collection.  \n```python\nfrom pymilvus import Collection\ncollection = Collection("book") # Get an existing collection.\nmr = collection.upsert(data)\n```  \nParameter\tDescription\ndata\tData to upsert into Milvus.\npartition_name (optional)\tName of the partition to upsert data into.\ntimeout (optional)\tAn optional duration of time in seconds to allow for the RPC. If it is set to None, the client keeps waiting until the server responds or error occurs.\nAfter upserting entities into a collection that has previously been indexed, you do not need to re-index the collection, as Milvus will automatically create an index for the newly upserted data. For more information, refer to Can indexes be created after inserting vectors?', metadata={'id': 448986959321277982, 'distance': 0.4341375529766083})]
```


## 관련 자료

- 리트리버 [개념 가이드](/docs/concepts/#retrievers)
- 리트리버 [사용 방법 가이드](/docs/how_to/#retrievers)