---
description: 이 템플릿은 OpenSearch를 사용하여 RAG(정보 검색 증강 생성)를 수행하는 방법을 설명합니다. 환경 설정 및 사용법을
  안내합니다.
---

# rag-opensearch

이 템플릿은 [OpenSearch](https://python.langchain.com/docs/integrations/vectorstores/opensearch)를 사용하여 RAG를 수행합니다.

## 환경 설정

다음 환경 변수를 설정하십시오.

- `OPENAI_API_KEY` - OpenAI Embeddings 및 모델에 접근하기 위해 필요합니다.

기본값을 사용하지 않는 경우 OpenSearch 관련 변수를 선택적으로 설정하십시오:

- `OPENSEARCH_URL` - 호스팅된 OpenSearch 인스턴스의 URL
- `OPENSEARCH_USERNAME` - OpenSearch 인스턴스의 사용자 이름
- `OPENSEARCH_PASSWORD` - OpenSearch 인스턴스의 비밀번호
- `OPENSEARCH_INDEX_NAME` - 인덱스의 이름

기본 OpenSearch 인스턴스를 도커에서 실행하려면 다음 명령어를 사용할 수 있습니다.
```shell
docker run -p 9200:9200 -p 9600:9600 -e "discovery.type=single-node" --name opensearch-node -d opensearchproject/opensearch:latest
```


참고: 더미 문서가 포함된 `langchain-test`라는 더미 인덱스를 로드하려면 패키지 내에서 `python dummy_index_setup.py`를 실행하십시오.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-opensearch
```


기존 프로젝트에 추가하려면 다음 명령어를 실행하면 됩니다:

```shell
langchain app add rag-opensearch
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from rag_opensearch import chain as rag_opensearch_chain

add_routes(app, rag_opensearch_chain, path="/rag-opensearch")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며, 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-opensearch/playground](http://127.0.0.1:8000/rag-opensearch/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-opensearch")
```