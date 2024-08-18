---
description: 이 문서는 PostgreSQL과 pgvector를 결합하여 의미 검색 및 RAG를 구현하는 템플릿에 대한 설정 및 사용 방법을
  안내합니다.
---

# sql-pgvector

이 템플릿은 사용자가 `pgvector`를 사용하여 PostgreSQL과 의미 검색 / RAG를 결합할 수 있도록 합니다.

이는 [RAG empowered SQL cookbook](https://github.com/langchain-ai/langchain/blob/master/cookbook/retrieval_in_sql.ipynb)에서 보여준 대로 [PGVector](https://github.com/pgvector/pgvector) 확장을 사용합니다.

## 환경 설정

`ChatOpenAI`를 LLM으로 사용하는 경우, `OPENAI_API_KEY`가 환경에 설정되어 있는지 확인하세요. `chain.py` 내에서 LLM과 임베딩 모델을 모두 변경할 수 있습니다.

그리고 템플릿에서 사용할 다음 환경 변수를 구성할 수 있습니다 (기본값은 괄호 안에 있습니다):

- `POSTGRES_USER` (postgres)
- `POSTGRES_PASSWORD` (test)
- `POSTGRES_DB` (vectordb)
- `POSTGRES_HOST` (localhost)
- `POSTGRES_PORT` (5432)

Postgres 인스턴스가 없는 경우, Docker에서 로컬로 실행할 수 있습니다:

```bash
docker run \
  --name some-postgres \
  -e POSTGRES_PASSWORD=test \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_DB=vectordb \
  -p 5432:5432 \
  postgres:16
```


그리고 나중에 다시 시작하려면 위에서 정의한 `--name`을 사용하세요:
```bash
docker start some-postgres
```


### PostgreSQL 데이터베이스 설정

`pgvector` 확장을 활성화하는 것 외에도 SQL 쿼리 내에서 의미 검색을 실행하기 전에 몇 가지 설정이 필요합니다.

PostgreSQL 데이터베이스에서 RAG를 실행하려면 원하는 특정 열에 대한 임베딩을 생성해야 합니다.

이 과정은 [RAG empowered SQL cookbook](https://github.com/langchain-ai/langchain/blob/master/cookbook/retrieval_in_sql.ipynb)에서 다루어지지만, 전체 접근 방식은 다음과 같습니다:
1. 열에서 고유 값을 쿼리합니다.
2. 해당 값에 대한 임베딩을 생성합니다.
3. 임베딩을 별도의 열이나 보조 테이블에 저장합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package sql-pgvector
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add sql-pgvector
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from sql_pgvector import chain as sql_pgvector_chain

add_routes(app, sql_pgvector_chain, path="/sql-pgvector")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기서](https://smith.langchain.com/) 가입할 수 있습니다.
접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면, 다음과 같이 LangServe 인스턴스를 직접 실행할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다:
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/sql-pgvector/playground](http://127.0.0.1:8000/sql-pgvector/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/sql-pgvector")
```