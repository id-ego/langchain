---
description: 이 문서는 Lantern을 사용한 RAG 구현을 위한 템플릿과 환경 설정 방법을 안내합니다. PostgreSQL 기반의 벡터
  데이터베이스입니다.
---

# rag_lantern

이 템플릿은 Lantern을 사용하여 RAG를 수행합니다.

[Lantern](https://lantern.dev)은 [PostgreSQL](https://en.wikipedia.org/wiki/PostgreSQL) 위에 구축된 오픈 소스 벡터 데이터베이스입니다. 데이터베이스 내에서 벡터 검색 및 임베딩 생성을 가능하게 합니다.

## 환경 설정

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정합니다.

`OPENAI_API_KEY`를 얻으려면 OpenAI 계정의 [API 키](https://platform.openai.com/account/api-keys)로 이동하여 새 비밀 키를 생성합니다.

`LANTERN_URL` 및 `LANTERN_SERVICE_KEY`를 찾으려면 Lantern 프로젝트의 [API 설정](https://lantern.dev/dashboard/project/_/settings/api)으로 이동합니다.

- `LANTERN_URL`은 프로젝트 URL에 해당합니다.
- `LANTERN_SERVICE_KEY`는 `service_role` API 키에 해당합니다.

```shell
export LANTERN_URL=
export LANTERN_SERVICE_KEY=
export OPENAI_API_KEY=
```


## Lantern 데이터베이스 설정

아직 Lantern 데이터베이스를 설정하지 않았다면 다음 단계를 따라 설정합니다.

1. [https://lantern.dev](https://lantern.dev)로 이동하여 Lantern 데이터베이스를 생성합니다.
2. 좋아하는 SQL 클라이언트에서 SQL 편집기로 이동하여 다음 스크립트를 실행하여 데이터베이스를 벡터 저장소로 설정합니다:
   
   ```sql
   -- Create a table to store your documents
   create table
     documents (
       id uuid primary key,
       content text, -- corresponds to Document.pageContent
       metadata jsonb, -- corresponds to Document.metadata
       embedding REAL[1536] -- 1536 works for OpenAI embeddings, change as needed
     );
   
   -- Create a function to search for documents
   create function match_documents (
     query_embedding REAL[1536],
     filter jsonb default '{}'
   ) returns table (
     id uuid,
     content text,
     metadata jsonb,
     similarity float
   ) language plpgsql as $$
   #variable_conflict use_column
   begin
     return query
     select
       id,
       content,
       metadata,
       1 - (documents.embedding <=> query_embedding) as similarity
     from documents
     where metadata @> filter
     order by documents.embedding <=> query_embedding;
   end;
   $$;
   ```


## 환경 변수 설정

[`Lantern`](https://python.langchain.com/docs/integrations/vectorstores/lantern) 및 [`OpenAIEmbeddings`](https://python.langchain.com/docs/integrations/text_embedding/openai)를 사용하므로 API 키를 로드해야 합니다.

## 사용법

먼저 LangChain CLI를 설치합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-lantern
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-lantern
```


그리고 `server.py` 파일에 다음 코드를 추가합니다:

```python
from rag_lantern.chain import chain as rag_lantern_chain

add_routes(app, rag_lantern_chain, path="/rag-lantern")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
여기에서 LangSmith에 가입할 수 있습니다 [여기](https://smith.langchain.com/).
접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-lantern/playground](http://127.0.0.1:8000/rag-lantern/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-lantern")
```