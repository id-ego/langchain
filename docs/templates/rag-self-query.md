---
description: 이 템플릿은 LLM을 사용하여 비구조적 쿼리를 구조적 쿼리로 변환하는 RAG 자기 쿼리 검색 기법을 수행합니다.
---

# rag-self-query

이 템플릿은 자기 쿼리 검색 기술을 사용하여 RAG를 수행합니다. 주요 아이디어는 LLM이 비구조적 쿼리를 구조적 쿼리로 변환하도록 하는 것입니다. 이 작동 방식에 대한 [문서](https://python.langchain.com/docs/modules/data_connection/retrievers/self_query)를 참조하세요.

## 환경 설정

이 템플릿에서는 OpenAI 모델과 Elasticsearch 벡터 저장소를 사용할 것이지만, 이 접근 방식은 모든 LLM/ChatModel 및 [여러 벡터 저장소](https://python.langchain.com/docs/integrations/retrievers/self_query/)에 일반화됩니다.

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하세요.

Elasticsearch 인스턴스에 연결하기 위해 다음 환경 변수를 사용하세요:

```bash
export ELASTIC_CLOUD_ID = <ClOUD_ID>
export ELASTIC_USERNAME = <ClOUD_USERNAME>
export ELASTIC_PASSWORD = <ClOUD_PASSWORD>
```

Docker를 사용한 로컬 개발의 경우, 다음을 사용하세요:

```bash
export ES_URL = "http://localhost:9200"
docker run -p 9200:9200 -e "discovery.type=single-node" -e "xpack.security.enabled=false" -e "xpack.security.http.ssl.enabled=false" docker.elastic.co/elasticsearch/elasticsearch:8.9.0
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U "langchain-cli[serve]"
```


새 LangChain 프로젝트를 만들고 이 패키지만 설치하려면 다음을 수행할 수 있습니다:

```shell
langchain app new my-app --package rag-self-query
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-self-query
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_self_query import chain

add_routes(app, chain, path="/rag-elasticsearch")
```


샘플 데이터로 벡터 저장소를 채우려면, 디렉토리의 루트에서 다음을 실행하세요:
```bash
python ingest.py
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며, 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-elasticsearch/playground](http://127.0.0.1:8000/rag-elasticsearch/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-self-query")
```