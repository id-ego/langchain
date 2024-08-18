---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/baiduvectordb.ipynb
description: 바이두 벡터DB는 다차원 벡터 데이터를 저장, 검색 및 분석하는 강력한 분산 데이터베이스 서비스입니다. 높은 성능과 확장성을
  자랑합니다.
---

# Baidu VectorDB

> [Baidu VectorDB](https://cloud.baidu.com/product/vdb.html)는 Baidu Intelligent Cloud에 의해 세심하게 개발되고 완전히 관리되는 강력한 기업 수준의 분산 데이터베이스 서비스입니다. 이 서비스는 다차원 벡터 데이터를 저장, 검색 및 분석하는 뛰어난 능력으로 두드러집니다. VectorDB의 핵심은 Baidu의 독점 "Mochow" 벡터 데이터베이스 커널에서 운영되며, 이는 높은 성능, 가용성 및 보안성을 보장하며, 뛰어난 확장성과 사용자 친화성을 제공합니다.

> 이 데이터베이스 서비스는 다양한 사용 사례에 맞춰 다양한 인덱스 유형 및 유사성 계산 방법을 지원합니다. VectorDB의 두드러진 기능은 최대 100억 개의 벡터 규모를 관리할 수 있는 능력으로, 밀리초 수준의 쿼리 지연 시간으로 초당 수백만 개의 쿼리를 지원하며 인상적인 쿼리 성능을 유지합니다.

이 통합을 사용하려면 `pip install -qU langchain-community`로 `langchain-community`를 설치해야 합니다.

이 노트북은 Baidu VectorDB와 관련된 기능을 사용하는 방법을 보여줍니다.

실행하려면 [데이터베이스 인스턴스.](https://cloud.baidu.com/doc/VDB/s/hlrsoazuf)가 필요합니다.

```python
!pip3 install pymochow
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Baidu VectorDB"}, {"imported": "FakeEmbeddings", "source": "langchain_community.embeddings.fake", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.FakeEmbeddings.html", "title": "Baidu VectorDB"}, {"imported": "BaiduVectorDB", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.baiduvectordb.BaiduVectorDB.html", "title": "Baidu VectorDB"}, {"imported": "ConnectionParams", "source": "langchain_community.vectorstores.baiduvectordb", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.baiduvectordb.ConnectionParams.html", "title": "Baidu VectorDB"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Baidu VectorDB"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings.fake import FakeEmbeddings
from langchain_community.vectorstores import BaiduVectorDB
from langchain_community.vectorstores.baiduvectordb import ConnectionParams
from langchain_text_splitters import CharacterTextSplitter
```


```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)
embeddings = FakeEmbeddings(size=128)
```


```python
conn_params = ConnectionParams(
    endpoint="http://192.168.xx.xx:xxxx", account="root", api_key="****"
)

vector_db = BaiduVectorDB.from_documents(
    docs, embeddings, connection_params=conn_params, drop_old=True
)
```


```python
query = "What did the president say about Ketanji Brown Jackson"
docs = vector_db.similarity_search(query)
docs[0].page_content
```


```python
vector_db = BaiduVectorDB(embeddings, conn_params)
vector_db.add_texts(["Ankush went to Princeton"])
query = "Where did Ankush go to college?"
docs = vector_db.max_marginal_relevance_search(query)
docs[0].page_content
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)