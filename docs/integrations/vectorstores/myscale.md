---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/myscale.ipynb
description: MyScale은 AI 애플리케이션에 최적화된 클라우드 기반 데이터베이스로, 오픈 소스 ClickHouse를 기반으로 합니다.
---

# MyScale

> [MyScale](https://docs.myscale.com/en/overview/)는 오픈 소스 [ClickHouse](https://github.com/ClickHouse/ClickHouse) 위에 구축된 AI 애플리케이션 및 솔루션에 최적화된 클라우드 기반 데이터베이스입니다.

이 노트북은 `MyScale` 벡터 데이터베이스와 관련된 기능을 사용하는 방법을 보여줍니다.

## 환경 설정

```python
%pip install --upgrade --quiet  clickhouse-connect langchain-community
```


OpenAIEmbeddings를 사용하려면 OpenAI API 키를 받아야 합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
os.environ["OPENAI_API_BASE"] = getpass.getpass("OpenAI Base:")
os.environ["MYSCALE_HOST"] = getpass.getpass("MyScale Host:")
os.environ["MYSCALE_PORT"] = getpass.getpass("MyScale Port:")
os.environ["MYSCALE_USERNAME"] = getpass.getpass("MyScale Username:")
os.environ["MYSCALE_PASSWORD"] = getpass.getpass("MyScale Password:")
```


myscale 인덱스의 매개변수를 설정하는 두 가지 방법이 있습니다.

1. 환경 변수
   
   앱을 실행하기 전에 `export`로 환경 변수를 설정하십시오:
`export MYSCALE_HOST='<your-endpoints-url>' MYSCALE_PORT=<your-endpoints-port> MYSCALE_USERNAME=<your-username> MYSCALE_PASSWORD=<your-password> ...`
   
   귀하의 계정, 비밀번호 및 기타 정보는 우리의 SaaS에서 쉽게 찾을 수 있습니다. 자세한 내용은 [이 문서](https://docs.myscale.com/en/cluster-management/)를 참조하십시오.
   
   `MyScaleSettings` 아래의 모든 속성은 접두사 `MYSCALE_`로 설정할 수 있으며 대소문자를 구분하지 않습니다.
2. 매개변수로 `MyScaleSettings` 객체 생성
   
   ```python
   from langchain_community.vectorstores import MyScale, MyScaleSettings
   config = MyScaleSetting(host="<your-backend-url>", port=8443, ...)
   index = MyScale(embedding_function, config)
   index.add_documents(...)
   ```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "MyScale"}, {"imported": "MyScale", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.myscale.MyScale.html", "title": "MyScale"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "MyScale"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "MyScale"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import MyScale
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "MyScale"}]-->
from langchain_community.document_loaders import TextLoader

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


```python
for d in docs:
    d.metadata = {"some": "metadata"}
docsearch = MyScale.from_documents(docs, embeddings)

query = "What did the president say about Ketanji Brown Jackson"
docs = docsearch.similarity_search(query)
```

```output
Inserting data...: 100%|██████████| 42/42 [00:15<00:00,  2.66it/s]
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

## 연결 정보 및 데이터 스키마 가져오기

```python
print(str(docsearch))
```


## 필터링

myscale SQL의 WHERE 문에 직접 접근할 수 있습니다. 표준 SQL에 따라 `WHERE` 절을 작성할 수 있습니다.

**참고**: SQL 인젝션에 주의하십시오. 이 인터페이스는 최종 사용자가 직접 호출해서는 안 됩니다.

설정에서 `column_map`을 사용자 정의한 경우 다음과 같이 필터로 검색할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "MyScale"}, {"imported": "MyScale", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.myscale.MyScale.html", "title": "MyScale"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import MyScale

loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()

for i, d in enumerate(docs):
    d.metadata = {"doc_id": i}

docsearch = MyScale.from_documents(docs, embeddings)
```

```output
Inserting data...: 100%|██████████| 42/42 [00:15<00:00,  2.68it/s]
```

### 점수와 함께 유사성 검색

반환된 거리 점수는 코사인 거리입니다. 따라서 낮은 점수가 더 좋습니다.

```python
meta = docsearch.metadata_column
output = docsearch.similarity_search_with_relevance_scores(
    "What did the president say about Ketanji Brown Jackson?",
    k=4,
    where_str=f"{meta}.doc_id<10",
)
for d, dist in output:
    print(dist, d.metadata, d.page_content[:20] + "...")
```

```output
0.229655921459198 {'doc_id': 0} Madam Speaker, Madam...
0.24506962299346924 {'doc_id': 8} And so many families...
0.24786919355392456 {'doc_id': 1} Groups of citizens b...
0.24875116348266602 {'doc_id': 6} And I’m taking robus...
```

## 데이터 삭제

`.drop()` 메서드를 사용하여 테이블을 삭제하거나 `.delete()` 메서드를 사용하여 데이터를 부분적으로 삭제할 수 있습니다.

```python
# use directly a `where_str` to delete
docsearch.delete(where_str=f"{docsearch.metadata_column}.doc_id < 5")
meta = docsearch.metadata_column
output = docsearch.similarity_search_with_relevance_scores(
    "What did the president say about Ketanji Brown Jackson?",
    k=4,
    where_str=f"{meta}.doc_id<10",
)
for d, dist in output:
    print(dist, d.metadata, d.page_content[:20] + "...")
```

```output
0.24506962299346924 {'doc_id': 8} And so many families...
0.24875116348266602 {'doc_id': 6} And I’m taking robus...
0.26027143001556396 {'doc_id': 7} We see the unity amo...
0.26390212774276733 {'doc_id': 9} And unlike the $2 Tr...
```


```python
docsearch.drop()
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)