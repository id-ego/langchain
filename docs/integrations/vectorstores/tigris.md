---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/vectorstores/tigris.ipynb
description: Tigris는 고성능 벡터 검색 애플리케이션 구축을 간소화하는 오픈 소스 서버리스 NoSQL 데이터베이스 및 검색 플랫폼입니다.
---

# Tigris

> [Tigris](https://tigrisdata.com)는 고성능 벡터 검색 애플리케이션 구축을 단순화하기 위해 설계된 오픈 소스 서버리스 NoSQL 데이터베이스 및 검색 플랫폼입니다.  
`Tigris`는 여러 도구를 관리하고 운영하며 동기화하는 인프라 복잡성을 제거하여 훌륭한 애플리케이션 구축에 집중할 수 있도록 합니다.

이 노트북은 Tigris를 벡터 저장소로 사용하는 방법을 안내합니다.

**사전 요구 사항**
1. OpenAI 계정. [여기](https://platform.openai.com/)에서 계정을 등록할 수 있습니다.
2. [무료 Tigris 계정 등록](https://console.preview.tigrisdata.cloud). Tigris 계정을 등록한 후 `vectordemo`라는 새 프로젝트를 생성하세요. 다음으로, 프로젝트를 생성한 지역의 *Uri*, **clientId** 및 **clientSecret**을 기록해 두세요. 이 모든 정보는 프로젝트의 **Application Keys** 섹션에서 확인할 수 있습니다.

먼저 의존성을 설치합시다:

```python
%pip install --upgrade --quiet  tigrisdb openapi-schema-pydantic langchain-openai langchain-community tiktoken
```


환경에 `OpenAI` API 키와 `Tigris` 자격 증명을 로드하겠습니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
os.environ["TIGRIS_PROJECT"] = getpass.getpass("Tigris Project Name:")
os.environ["TIGRIS_CLIENT_ID"] = getpass.getpass("Tigris Client Id:")
os.environ["TIGRIS_CLIENT_SECRET"] = getpass.getpass("Tigris Client Secret:")
```


```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "Tigris"}, {"imported": "Tigris", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.tigris.Tigris.html", "title": "Tigris"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "Tigris"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "Tigris"}]-->
from langchain_community.document_loaders import TextLoader
from langchain_community.vectorstores import Tigris
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter
```


### Tigris 벡터 저장소 초기화
테스트 데이터셋을 가져옵니다:

```python
loader = TextLoader("../../../state_of_the_union.txt")
documents = loader.load()
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
docs = text_splitter.split_documents(documents)

embeddings = OpenAIEmbeddings()
```


```python
vector_store = Tigris.from_documents(docs, embeddings, index_name="my_embeddings")
```


### 유사성 검색

```python
query = "What did the president say about Ketanji Brown Jackson"
found_docs = vector_store.similarity_search(query)
print(found_docs)
```


### 점수(벡터 거리)가 있는 유사성 검색

```python
query = "What did the president say about Ketanji Brown Jackson"
result = vector_store.similarity_search_with_score(query)
for doc, score in result:
    print(f"document={doc}, score={score}")
```


## 관련

- 벡터 저장소 [개념 가이드](/docs/concepts/#vector-stores)
- 벡터 저장소 [사용 방법 가이드](/docs/how_to/#vector-stores)