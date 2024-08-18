---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/hologres.ipynb
description: Hologres는 실시간 데이터 웨어하우징 서비스로, PostgreSQL과 호환되며 OLAP 및 벡터 데이터베이스 기능을 지원합니다.
---

# Hologres

> [Hologres](https://www.alibabacloud.com/help/en/hologres/latest/introduction)는 Alibaba Cloud에서 개발한 통합 실시간 데이터 웨어하우징 서비스입니다. Hologres를 사용하여 대량의 데이터를 실시간으로 작성, 업데이트, 처리 및 분석할 수 있습니다. Hologres는 표준 SQL 구문을 지원하며 PostgreSQL과 호환되며 대부분의 PostgreSQL 기능을 지원합니다. Hologres는 최대 페타바이트의 데이터에 대해 온라인 분석 처리(OLAP) 및 임시 분석을 지원하며, 높은 동시성과 낮은 대기 시간의 온라인 데이터 서비스를 제공합니다.

> Hologres는 [Proxima](https://www.alibabacloud.com/help/en/hologres/latest/vector-processing)를 채택하여 **벡터 데이터베이스** 기능을 제공합니다. Proxima는 Alibaba DAMO Academy에서 개발한 고성능 소프트웨어 라이브러리입니다. 이는 벡터의 최근접 이웃을 검색할 수 있게 해줍니다. Proxima는 Faiss와 같은 유사한 오픈 소스 소프트웨어보다 더 높은 안정성과 성능을 제공합니다. Proxima는 높은 처리량과 낮은 대기 시간으로 유사한 텍스트 또는 이미지 임베딩을 검색할 수 있게 해줍니다. Hologres는 Proxima와 깊게 통합되어 고성능 벡터 검색 서비스를 제공합니다.

이 노트북은 `Hologres Proxima` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다. Hologres 클라우드 인스턴스를 빠르게 배포하려면 [여기](https://www.alibabacloud.com/zh/product/hologres)를 클릭하세요.

```python
%pip install --upgrade --quiet  langchain_community hologres-vector
```


```python
<!--IMPORTS:[{"imported": "Hologres", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.hologres.Hologres.html", "title": "Hologres"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Hologres"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Hologres"}]-->
from langchain_community.vectorstores import Hologres
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


OpenAI API를 호출하여 문서를 분할하고 임베딩을 가져옵니다.

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Hologres"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


관련 ENVIRONMENTS를 설정하여 Hologres에 연결합니다.
```
export PG_HOST={host}
export PG_PORT={port} # Optional, default is 80
export PG_DATABASE={db_name} # Optional, default is postgres
export PG_USER={username}
export PG_PASSWORD={password}
```


그런 다음 임베딩과 문서를 Hologres에 저장합니다.

```python
import os

connection_string = Hologres.connection_string_from_db_params(
    host=os.environ.get("PGHOST", "localhost"),
    port=int(os.environ.get("PGPORT", "80")),
    database=os.environ.get("PGDATABASE", "postgres"),
    user=os.environ.get("PGUSER", "postgres"),
    password=os.environ.get("PGPASSWORD", "postgres"),
)

vector_db = Hologres.from_documents(
    docs,
    embeddings,
    connection_string=connection_string,
    table_name="langchain_example_embeddings",
)
```


데이터를 쿼리하고 검색합니다.

```python
query = "What did the president say about Ketanji Brown Jackson"
docs = vector_db.similarity_search(query)
```


```python
print(docs[0].page_content)
```

```output
Tonight. I call on the Senate to: Pass the Freedom to Vote Act. Pass the John Lewis Voting Rights Act. And while you’re at it, pass the Disclose Act so Americans can know who is funding our elections. 

Tonight, I’d like to honor someone who has dedicated his life to serve this country: Justice Stephen Breyer—an Army veteran, Constitutional scholar, and retiring Justice of the United States Supreme Court. Justice Breyer, thank you for your service. 

One of the most serious constitutional responsibilities a President has is nominating someone to serve on the United States Supreme Court. 

And I did that 4 days ago, when I nominated Circuit Court of Appeals Judge Ketanji Brown Jackson. One of our nation’s top legal minds, who will continue Justice Breyer’s legacy of excellence.
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)