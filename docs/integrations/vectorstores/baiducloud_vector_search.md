---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/baiducloud_vector_search.ipynb
description: 바이두 클라우드 ElasticSearch VectorSearch는 구조화/비구조화 데이터에 대한 고성능 검색 및 분석 서비스를
  제공합니다.
---

# 바이두 클라우드 엘라스틱서치 벡터검색

> [바이두 클라우드 벡터검색](https://cloud.baidu.com/doc/BES/index.html?from=productToDoc)은 완전 관리형, 기업 수준의 분산 검색 및 분석 서비스로, 오픈 소스와 100% 호환됩니다. 바이두 클라우드 벡터검색은 구조화된/비구조화된 데이터에 대한 저비용, 고성능 및 신뢰할 수 있는 검색 및 분석 플랫폼 수준의 제품 서비스를 제공합니다. 벡터 데이터베이스로서 여러 인덱스 유형과 유사도 거리 방법을 지원합니다.

> `바이두 클라우드 엘라스틱서치`는 클러스터 권한을 자유롭게 구성할 수 있는 권한 관리 메커니즘을 제공합니다. 이를 통해 데이터 보안을 더욱 강화할 수 있습니다.

이 노트북은 `바이두 클라우드 엘라스틱서치 벡터스토어`와 관련된 기능을 사용하는 방법을 보여줍니다. 실행하려면 [바이두 클라우드 엘라스틱서치](https://cloud.baidu.com/product/bes.html) 인스턴스가 실행 중이어야 합니다:

[도움 문서](https://cloud.baidu.com/doc/BES/s/8llyn0hh4)를 읽어 바이두 클라우드 엘라스틱서치 인스턴스에 빠르게 익숙해지고 구성하세요.

인스턴스가 실행 중이면 문서를 분할하고, 임베딩을 얻고, 바이두 클라우드 엘라스틱서치 인스턴스에 연결하고, 문서를 인덱싱하고, 벡터 검색을 수행하는 다음 단계를 따르세요.

먼저 다음 Python 패키지를 설치해야 합니다.

```python
%pip install --upgrade --quiet langchain-community elasticsearch == 7.11.0
```


먼저, `QianfanEmbeddings`를 사용하고 싶으므로 Qianfan AK와 SK를 얻어야 합니다. QianFan에 대한 자세한 내용은 [바이두 Qianfan 워크숍](https://cloud.baidu.com/product/wenxinworkshop)과 관련이 있습니다.

```python
import getpass
import os

os.environ["QIANFAN_AK"] = getpass.getpass("Your Qianfan AK:")
os.environ["QIANFAN_SK"] = getpass.getpass("Your Qianfan SK:")
```


둘째, 문서를 분할하고 임베딩을 얻습니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Baidu Cloud ElasticSearch VectorSearch"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Baidu Cloud ElasticSearch VectorSearch"}, {"imported": "QianfanEmbeddingsEndpoint", "source": "langchain_community.embeddings", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.baidu_qianfan_endpoint.QianfanEmbeddingsEndpoint.html", "title": "Baidu Cloud ElasticSearch VectorSearch"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import CharacterTextSplitter

loader = TextLoader("../../../state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

from langchain_community.embeddings import QianfanEmbeddingsEndpoint

embeddings = QianfanEmbeddingsEndpoint()
```


그런 다음, 바이두 엘라스틱서치에 접근 가능한 인스턴스를 생성합니다.

```python
<!--IMPORTS:[{"imported": "BESVectorStore", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.baiducloud_vector_search.BESVectorStore.html", "title": "Baidu Cloud ElasticSearch VectorSearch"}]-->
# Create a bes instance and index docs.
from langchain_community.vectorstores import BESVectorStore

bes = BESVectorStore.from_documents(
    documents=docs,
    embedding=embeddings,
    bes_url="your bes cluster url",
    index_name="your vector index",
)
bes.client.indices.refresh(index="your vector index")
```


마지막으로, 쿼리하고 데이터를 검색합니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = bes.similarity_search(query)
print(docs[0].page_content)
```


사용 중 문제가 발생하면 <mailto:liuboyao@baidu.com> 또는 <mailto:chenweixu01@baidu.com>으로 언제든지 문의해 주시면 최선을 다해 지원하겠습니다.

## 관련

- 벡터 스토어 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 스토어 [사용 방법 가이드](/docs/how_to/#vector-stores)