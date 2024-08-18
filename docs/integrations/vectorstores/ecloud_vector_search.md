---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/ecloud_vector_search.ipynb
description: 중국 모바일 ECloud VectorSearch는 구조화/비구조화 데이터에 대한 저비용, 고성능의 검색 및 분석 서비스를 제공합니다.
---

# 차이나 모바일 ECloud ElasticSearch 벡터 검색

> [차이나 모바일 ECloud 벡터 검색](https://ecloud.10086.cn/portal/product/elasticsearch)은 완전 관리형 기업 수준의 분산 검색 및 분석 서비스입니다. 차이나 모바일 ECloud 벡터 검색은 구조화된/비구조화된 데이터에 대한 저비용, 고성능 및 신뢰할 수 있는 검색 및 분석 플랫폼 수준의 제품 서비스를 제공합니다. 벡터 데이터베이스로서 여러 인덱스 유형과 유사성 거리 방법을 지원합니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

이 노트북은 `ECloud ElasticSearch VectorStore`와 관련된 기능을 사용하는 방법을 보여줍니다. 실행하려면 [차이나 모바일 ECloud 벡터 검색](https://ecloud.10086.cn/portal/product/elasticsearch) 인스턴스가 실행 중이어야 합니다:

[도움 문서](https://ecloud.10086.cn/op-help-center/doc/category/1094)를 읽어 차이나 모바일 ECloud ElasticSearch 인스턴스를 빠르게 익히고 구성하세요.

인스턴스가 실행 중인 후, 문서를 분할하고, 임베딩을 얻고, 바이두 클라우드 엘라스틱서치 인스턴스에 연결하고, 문서를 인덱싱하고, 벡터 검색을 수행하는 다음 단계를 따르세요.

```python
#!pip install elasticsearch == 7.10.1
```


먼저, `OpenAIEmbeddings`를 사용하려고 하므로 OpenAI API 키를 가져와야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


둘째, 문서를 분할하고 임베딩을 얻습니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "China Mobile ECloud ElasticSearch VectorSearch"}, {"imported": "EcloudESVectorStore", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.ecloud_vector_search.EcloudESVectorStore.html", "title": "China Mobile ECloud ElasticSearch VectorSearch"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "China Mobile ECloud ElasticSearch VectorSearch"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "China Mobile ECloud ElasticSearch VectorSearch"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import EcloudESVectorStore
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
loader = TextLoader("../../../state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()

ES_URL = "http://localhost:9200"
USER = "your user name"
PASSWORD = "your password"
indexname = "your index name"
```


그런 다음, 문서를 인덱싱합니다.

```python
docsearch = EcloudESVectorStore.from_documents(
    docs,
    embeddings,
    es_url=ES_URL,
    user=USER,
    password=PASSWORD,
    index_name=indexname,
    refresh_indices=True,
)
```


마지막으로, 쿼리하고 데이터를 검색합니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = docsearch.similarity_search(query, k=10)
print(docs[0].page_content)
```


일반적으로 사용되는 사례

```python
def test_dense_float_vectore_lsh_cosine() -> None:
    """
    Test indexing with vectore type knn_dense_float_vector and  model-similarity of lsh-cosine
    this mapping is compatible with model of exact and similarity of l2/cosine
    this mapping is compatible with model of lsh and similarity of cosine
    """
    docsearch = EcloudESVectorStore.from_documents(
        docs,
        embeddings,
        es_url=ES_URL,
        user=USER,
        password=PASSWORD,
        index_name=indexname,
        refresh_indices=True,
        text_field="my_text",
        vector_field="my_vec",
        vector_type="knn_dense_float_vector",
        vector_params={"model": "lsh", "similarity": "cosine", "L": 99, "k": 1},
    )

    docs = docsearch.similarity_search(
        query,
        k=10,
        search_params={
            "model": "exact",
            "vector_field": "my_vec",
            "text_field": "my_text",
        },
    )
    print(docs[0].page_content)

    docs = docsearch.similarity_search(
        query,
        k=10,
        search_params={
            "model": "exact",
            "similarity": "l2",
            "vector_field": "my_vec",
            "text_field": "my_text",
        },
    )
    print(docs[0].page_content)

    docs = docsearch.similarity_search(
        query,
        k=10,
        search_params={
            "model": "exact",
            "similarity": "cosine",
            "vector_field": "my_vec",
            "text_field": "my_text",
        },
    )
    print(docs[0].page_content)

    docs = docsearch.similarity_search(
        query,
        k=10,
        search_params={
            "model": "lsh",
            "similarity": "cosine",
            "candidates": 10,
            "vector_field": "my_vec",
            "text_field": "my_text",
        },
    )
    print(docs[0].page_content)
```


필터 사례와 함께

```python
def test_dense_float_vectore_exact_with_filter() -> None:
    """
    Test indexing with vectore type knn_dense_float_vector and default model/similarity
    this mapping is compatible with model of exact and similarity of l2/cosine
    """
    docsearch = EcloudESVectorStore.from_documents(
        docs,
        embeddings,
        es_url=ES_URL,
        user=USER,
        password=PASSWORD,
        index_name=indexname,
        refresh_indices=True,
        text_field="my_text",
        vector_field="my_vec",
        vector_type="knn_dense_float_vector",
    )
    # filter={"match_all": {}} ,default
    docs = docsearch.similarity_search(
        query,
        k=10,
        filter={"match_all": {}},
        search_params={
            "model": "exact",
            "vector_field": "my_vec",
            "text_field": "my_text",
        },
    )
    print(docs[0].page_content)

    # filter={"term": {"my_text": "Jackson"}}
    docs = docsearch.similarity_search(
        query,
        k=10,
        filter={"term": {"my_text": "Jackson"}},
        search_params={
            "model": "exact",
            "vector_field": "my_vec",
            "text_field": "my_text",
        },
    )
    print(docs[0].page_content)

    # filter={"term": {"my_text": "president"}}
    docs = docsearch.similarity_search(
        query,
        k=10,
        filter={"term": {"my_text": "president"}},
        search_params={
            "model": "exact",
            "similarity": "l2",
            "vector_field": "my_vec",
            "text_field": "my_text",
        },
    )
    print(docs[0].page_content)
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)