---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/relyt.ipynb
description: Relyt는 대량의 데이터를 온라인으로 분석할 수 있는 클라우드 네이티브 데이터 웨어하우스 서비스입니다. ANSI SQL 2003과
  호환됩니다.
---

# Relyt

> [Relyt](https://docs.relyt.cn/docs/vector-engine/use/)는 대량의 데이터를 온라인으로 분석하기 위해 설계된 클라우드 네이티브 데이터 웨어하우징 서비스입니다.

> `Relyt`는 ANSI SQL 2003 구문 및 PostgreSQL과 Oracle 데이터베이스 생태계와 호환됩니다. Relyt는 행 저장소와 열 저장소도 지원합니다. Relyt는 페타바이트의 데이터를 오프라인에서 높은 성능 수준으로 처리하며, 고도로 동시적인 온라인 쿼리를 지원합니다.

이 노트북은 `Relyt` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.
실행하려면 [Relyt](https://docs.relyt.cn/) 인스턴스가 실행 중이어야 합니다:
- [Relyt 벡터 데이터베이스](https://docs.relyt.cn/docs/vector-engine/use/) 사용. 여기 클릭하여 빠르게 배포하세요.

```python
%pip install "pgvecto_rs[sdk]" langchain-community
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Relyt"}, {"imported": "FakeEmbeddings", "source": "langchain_community.embeddings.fake", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_community.embeddings.fake.FakeEmbeddings.html", "title": "Relyt"}, {"imported": "Relyt", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.relyt.Relyt.html", "title": "Relyt"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Relyt"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.embeddings.fake import FakeEmbeddings
from langchain_community.vectorstores import Relyt
from langchain_text_splitters import CharacterTextSplitter
```


문서를 분할하고 커뮤니티 API를 호출하여 임베딩을 가져옵니다.

```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = FakeEmbeddings(size=1536)
```


관련 ENVIRONMENTS를 설정하여 Relyt에 연결합니다.
```
export PG_HOST={your_relyt_hostname}
export PG_PORT={your_relyt_port} # Optional, default is 5432
export PG_DATABASE={your_database} # Optional, default is postgres
export PG_USER={database_username}
export PG_PASSWORD={database_password}
```


그런 다음 임베딩과 문서를 Relyt에 저장합니다.

```python
import os

connection_string = Relyt.connection_string_from_db_params(
    driver=os.environ.get("PG_DRIVER", "psycopg2cffi"),
    host=os.environ.get("PG_HOST", "localhost"),
    port=int(os.environ.get("PG_PORT", "5432")),
    database=os.environ.get("PG_DATABASE", "postgres"),
    user=os.environ.get("PG_USER", "postgres"),
    password=os.environ.get("PG_PASSWORD", "postgres"),
)

vector_db = Relyt.from_documents(
    docs,
    embeddings,
    connection_string=connection_string,
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