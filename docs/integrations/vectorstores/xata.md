---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/xata.ipynb
description: Xata는 PostgreSQL 기반의 서버리스 데이터 플랫폼으로, 벡터 저장소로 사용하기 위한 Python SDK와 UI를
  제공합니다.
---

# Xata

> [Xata](https://xata.io)는 PostgreSQL 기반의 서버리스 데이터 플랫폼입니다. 데이터베이스와 상호작용하기 위한 Python SDK와 데이터를 관리하기 위한 UI를 제공합니다.  
Xata는 모든 테이블에 추가할 수 있는 네이티브 벡터 유형을 가지고 있으며, 유사성 검색을 지원합니다. LangChain은 벡터를 Xata에 직접 삽입하고 주어진 벡터의 가장 가까운 이웃을 쿼리하여, Xata와 함께 모든 LangChain Embeddings 통합을 사용할 수 있도록 합니다.

이 노트북은 Xata를 VectorStore로 사용하는 방법을 안내합니다.

## 설정

### 벡터 저장소로 사용할 데이터베이스 생성

[Xata UI](https://app.xata.io)에서 새 데이터베이스를 생성합니다. 원하는 이름으로 지정할 수 있으며, 이 노트북에서는 `langchain`을 사용할 것입니다.  
테이블을 생성하고, 원하는 이름으로 지정할 수 있지만, 우리는 `vectors`를 사용할 것입니다. UI를 통해 다음 열을 추가합니다:

* `content` 유형 "Text". 이는 `Document.pageContent` 값을 저장하는 데 사용됩니다.
* `embedding` 유형 "Vector". 사용하려는 모델에서 사용하는 차원을 사용합니다. 이 노트북에서는 1536 차원의 OpenAI 임베딩을 사용합니다.
* `source` 유형 "Text". 이 예제에서 메타데이터 열로 사용됩니다.
* 메타데이터로 사용하고 싶은 다른 열. 이들은 `Document.metadata` 객체에서 채워집니다. 예를 들어, `Document.metadata` 객체에 `title` 속성이 있다면, 테이블에 `title` 열을 생성할 수 있으며, 이 열은 채워질 것입니다.

먼저 종속성을 설치합시다:

```python
%pip install --upgrade --quiet  xata langchain-openai langchain-community tiktoken langchain
```


OpenAI 키를 환경에 로드합시다. 키가 없다면 OpenAI 계정을 생성하고 [이 페이지](https://platform.openai.com/account/api-keys)에서 키를 생성할 수 있습니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```


마찬가지로, Xata에 대한 환경 변수를 가져와야 합니다. [계정 설정](https://app.xata.io/settings)으로 가서 새 API 키를 생성할 수 있습니다. 데이터베이스 URL을 찾으려면 생성한 데이터베이스의 설정 페이지로 가십시오. 데이터베이스 URL은 다음과 같은 형식이어야 합니다: `https://demo-uni3q8.eu-west-1.xata.sh/db/langchain`.

```python
api_key = getpass.getpass("Xata API key: ")
db_url = input("Xata database URL (copy it from your DB settings):")
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Xata"}, {"imported": "XataVectorStore", "source": "langchain_community.vectorstores.xata", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.xata.XataVectorStore.html", "title": "Xata"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Xata"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Xata"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores.xata import XataVectorStore
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


### Xata 벡터 저장소 생성
테스트 데이터 세트를 가져옵니다:

```python
loader = TextLoader("../../how_to/state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


이제 Xata 테이블에 의해 지원되는 실제 벡터 저장소를 생성합니다.

```python
vector_store = XataVectorStore.from_documents(
    docs, embeddings, api_key=api_key, db_url=db_url, table_name="vectors"
)
```


위 명령을 실행한 후, Xata UI로 가면 문서와 그 임베딩이 함께 로드된 것을 볼 수 있어야 합니다. 이미 벡터 내용을 포함하고 있는 기존 Xata 테이블을 사용하려면, XataVectorStore 생성자를 초기화합니다:

```python
vector_store = XataVectorStore(
    api_key=api_key, db_url=db_url, embedding=embeddings, table_name="vectors"
)
```


### 유사성 검색

```python
query = "What did the president say about Ketanji Brown Jackson"
found_docs = vector_store.similarity_search(query)
print(found_docs)
```


### 점수(벡터 거리)를 통한 유사성 검색

```python
query = "What did the president say about Ketanji Brown Jackson"
result = vector_store.similarity_search_with_score(query)
for doc, score in result:
    print(f"document={doc}, score={score}")
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)