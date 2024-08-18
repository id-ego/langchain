---
description: 이 문서는 MongoDB와 OpenAI를 사용하여 RAG(정보 검색-생성)를 수행하는 템플릿에 대한 환경 설정 및 사용법을
  안내합니다.
---

# rag-mongo

이 템플릿은 MongoDB와 OpenAI를 사용하여 RAG를 수행합니다.

## 환경 설정

MongoDB URI와 OpenAI API KEY라는 두 개의 환경 변수를 내보내야 합니다.  
MongoDB URI가 없는 경우, 아래의 `Mongo 설정` 섹션을 참조하여 설정 방법을 확인하세요.

```shell
export MONGO_URI=...
export OPENAI_API_KEY=...
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-mongo
```


기존 프로젝트에 추가하려면 다음 명령을 실행하면 됩니다:

```shell
langchain app add rag-mongo
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_mongo import chain as rag_mongo_chain

add_routes(app, rag_mongo_chain, path="/rag-mongo")
```


데이터 수집 파이프라인을 설정하려면 `server.py` 파일에 다음 코드를 추가할 수 있습니다:
```python
from rag_mongo import ingest as rag_mongo_ingest

add_routes(app, rag_mongo_ingest, path="/rag-mongo-ingest")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.  
LangSmith는 LangChain 애플리케이션을 추적하고 모니터링하며 디버깅하는 데 도움을 줄 것입니다.  
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요.  
접근할 수 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


연결할 Mongo 검색 인덱스가 이미 없는 경우, 진행하기 전에 아래의 `MongoDB 설정` 섹션을 참조하세요.

연결할 MongoDB 검색 인덱스가 있는 경우, `rag_mongo/chain.py`에서 연결 세부정보를 수정하세요.

이 디렉토리 내에 있다면, 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.  
플레이그라운드는 [http://127.0.0.1:8000/rag-mongo/playground](http://127.0.0.1:8000/rag-mongo/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-mongo")
```


추가적인 맥락은 [이 노트북](https://colab.research.google.com/drive/1cr2HBAHyBmwKUerJq2if0JaNhy-hIq7I#scrollTo=TZp7_CBfxTOB)을 참조하세요.

## MongoDB 설정

MongoDB 계정을 설정하고 데이터를 수집해야 하는 경우 이 단계를 사용하세요.  
먼저 표준 MongoDB Atlas 설정 지침을 [여기](https://www.mongodb.com/docs/atlas/getting-started/)에서 따릅니다.

1. 계정을 생성합니다 (아직 하지 않았다면)
2. 새 프로젝트를 생성합니다 (아직 하지 않았다면)
3. MongoDB URI를 찾습니다.

배포 개요 페이지로 이동하여 데이터베이스에 연결하여 이 작업을 수행할 수 있습니다.

그런 다음 사용 가능한 드라이버를 살펴봅니다.

그 중에서 URI가 나열된 것을 볼 수 있습니다.

그것을 로컬 환경 변수로 설정합시다:

```shell
export MONGO_URI=...
```


4. OpenAI에 대한 환경 변수도 설정합시다 (LLM으로 사용할 것입니다).

```shell
export OPENAI_API_KEY=...
```


5. 이제 데이터를 수집해 보겠습니다! 이 디렉토리로 이동하여 `ingest.py`의 코드를 실행하면 됩니다, 예를 들어:

```shell
python ingest.py
```


원하는 데이터로 수집할 수 있도록 변경할 수 있다는 점에 유의하세요 (그리고 변경해야 합니다!).

6. 이제 데이터에 대한 벡터 인덱스를 설정해야 합니다.

먼저 데이터베이스가 있는 클러스터에 연결합니다.

그런 다음 모든 컬렉션이 나열된 곳으로 이동합니다.

원하는 컬렉션을 찾아 해당 컬렉션의 검색 인덱스를 확인합니다.

아마도 비어 있을 것이며, 새로운 인덱스를 생성하고 싶습니다:

JSON 편집기를 사용하여 생성할 것입니다.

다음 JSON을 붙여넣습니다:

```text
 {
   "mappings": {
     "dynamic": true,
     "fields": {
       "embedding": {
         "dimensions": 1536,
         "similarity": "cosine",
         "type": "knnVector"
       }
     }
   }
 }
```


그런 다음 "다음"을 클릭하고 "검색 인덱스 생성"을 클릭합니다. 조금 시간이 걸리겠지만, 그러면 데이터에 대한 인덱스가 생성될 것입니다!