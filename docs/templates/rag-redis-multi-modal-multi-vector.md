---
description: 이 템플릿은 슬라이드 덱을 위한 시각적 도우미를 생성하여 이미지 요약 및 질문 응답을 지원합니다.
---

# rag-redis-multi-modal-multi-vector

다중 모달 LLM은 이미지에 대한 질문 응답을 수행할 수 있는 시각적 도우미를 가능하게 합니다.

이 템플릿은 종종 그래프나 그림과 같은 시각적 요소를 포함하는 슬라이드 데크를 위한 시각적 도우미를 생성합니다.

각 슬라이드에 대한 이미지 요약을 생성하기 위해 GPT-4V를 사용하고, 요약을 포함시켜 Redis에 저장합니다.

질문이 주어지면, 관련 슬라이드를 검색하여 GPT-4V에 전달하여 답변을 합성합니다.

## 입력

슬라이드 데크를 `/docs` 디렉토리에 PDF 형식으로 제공하십시오.

기본적으로 이 템플릿은 NVIDIA의 최근 수익에 대한 슬라이드 데크를 포함하고 있습니다.

질문 예시는 다음과 같습니다:
```
1/ how much can H100 TensorRT improve LLama2 inference performance?
2/ what is the % change in GPU accelerated applications from 2020 to 2023?
```


슬라이드 데크의 인덱스를 생성하려면 다음을 실행하십시오:
```
poetry install
poetry shell
python ingest.py
```


## 저장소

다음은 템플릿이 슬라이드의 인덱스를 생성하는 데 사용할 프로세스입니다 (자세한 내용은 [블로그](https://blog.langchain.dev/multi-modal-rag-template/) 참조):

* 슬라이드를 이미지 모음으로 추출
* 각 이미지를 요약하기 위해 GPT-4V 사용
* 원본 이미지에 대한 링크와 함께 텍스트 임베딩을 사용하여 이미지 요약을 포함
* 이미지 요약과 사용자 입력 질문 간의 유사성에 따라 관련 이미지를 검색
* 해당 이미지를 GPT-4V에 전달하여 답변 합성

### Redis
이 템플릿은 [Redis](https://redis.com)를 사용하여 [MultiVectorRetriever](https://python.langchain.com/docs/modules/data_connection/retrievers/multi_vector)를 지원합니다:
- Redis를 [VectorStore](https://python.langchain.com/docs/integrations/vectorstores/redis)로 사용 (이미지 요약 임베딩 저장 및 인덱싱)
- Redis를 [ByteStore](https://python.langchain.com/docs/integrations/stores/redis)로 사용 (이미지 저장)

[클라우드](https://redis.com/try-free) (무료) 또는 [docker](https://redis.io/docs/install/install-stack/docker/)를 사용하여 Redis 인스턴스를 배포해야 합니다.

이렇게 하면 URL로 사용할 수 있는 접근 가능한 Redis 엔드포인트가 제공됩니다. 로컬로 배포하는 경우 `redis://localhost:6379`를 사용하십시오.

## LLM

앱은 텍스트 입력과 이미지 요약(텍스트) 간의 유사성을 기반으로 이미지를 검색하고, 이미지를 GPT-4V에 전달하여 답변을 합성합니다.

## 환경 설정

OpenAI GPT-4V에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하십시오.

Redis 데이터베이스에 접근하기 위해 `REDIS_URL` 환경 변수를 설정하십시오.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이 패키지만 설치하려면 다음을 수행할 수 있습니다:

```shell
langchain app new my-app --package rag-redis-multi-modal-multi-vector
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-redis-multi-modal-multi-vector
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from rag_redis_multi_modal_multi_vector import chain as rag_redis_multi_modal_chain_mv

add_routes(app, rag_redis_multi_modal_chain_mv, path="/rag-redis-multi-modal-multi-vector")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
여기에서 LangSmith에 가입할 수 있습니다 [여기](https://smith.langchain.com/).
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-redis-multi-modal-multi-vector/playground](http://127.0.0.1:8000/rag-redis-multi-modal-multi-vector/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-redis-multi-modal-multi-vector")
```