---
description: 다양한 시각 자료를 포함한 슬라이드 덱을 위한 시각 비서 템플릿으로, GPT-4V를 활용해 이미지 요약 및 질문 응답을 수행합니다.
---

# rag-chroma-multi-modal-multi-vector

다중 모달 LLM은 이미지에 대한 질문 응답을 수행할 수 있는 시각적 도우미를 가능하게 합니다.

이 템플릿은 종종 그래프나 도표와 같은 시각 자료를 포함하는 슬라이드 데크를 위한 시각적 도우미를 생성합니다.

각 슬라이드에 대한 이미지 요약을 생성하기 위해 GPT-4V를 사용하고, 요약을 포함시키며, 이를 Chroma에 저장합니다.

질문이 주어지면, 관련 슬라이드가 검색되어 GPT-4V에 전달되어 답변이 합성됩니다.

## 입력

슬라이드 데크를 `/docs` 디렉토리에 pdf 형식으로 제공하십시오.

기본적으로 이 템플릿은 공개 기술 회사인 DataDog의 Q3 수익에 대한 슬라이드 데크를 포함하고 있습니다.

질문 예시는 다음과 같습니다:
```
How many customers does Datadog have?
What is Datadog platform % Y/Y growth in FY20, FY21, and FY22?
```


슬라이드 데크의 인덱스를 생성하려면 다음을 실행하십시오:
```
poetry install
python ingest.py
```


## 저장소

다음은 템플릿이 슬라이드의 인덱스를 생성하는 데 사용할 프로세스입니다 (자세한 내용은 [블로그](https://blog.langchain.dev/multi-modal-rag-template/) 참조):

* 슬라이드를 이미지 모음으로 추출
* 각 이미지를 요약하기 위해 GPT-4V 사용
* 원본 이미지에 대한 링크와 함께 텍스트 임베딩을 사용하여 이미지 요약을 포함
* 이미지 요약과 사용자 입력 질문 간의 유사성을 기반으로 관련 이미지를 검색
* 해당 이미지를 GPT-4V에 전달하여 답변 합성

기본적으로 [LocalFileStore](https://python.langchain.com/docs/integrations/stores/file_system)를 사용하여 이미지를 저장하고 Chroma를 사용하여 요약을 저장합니다.

프로덕션에서는 Redis와 같은 원격 옵션을 사용하는 것이 바람직할 수 있습니다.

`chain.py`와 `ingest.py`에서 `local_file_store` 플래그를 설정하여 두 옵션 간에 전환할 수 있습니다.

Redis의 경우, 템플릿은 [UpstashRedisByteStore](https://python.langchain.com/docs/integrations/stores/upstash_redis)를 사용합니다.

REST API가 제공되는 Redis를 위해 Upstash를 사용하여 이미지를 저장합니다.

[여기](https://upstash.com/)에 로그인하고 데이터베이스를 생성하십시오.

이렇게 하면 다음과 같은 REST API를 얻을 수 있습니다:

* `UPSTASH_URL`
* `UPSTASH_TOKEN`

데이터베이스에 접근하기 위해 `UPSTASH_URL` 및 `UPSTASH_TOKEN`을 환경 변수로 설정하십시오.

이미지 요약을 저장하고 인덱싱하기 위해 Chroma를 사용하며, 이는 템플릿 디렉토리에서 로컬로 생성됩니다.

## LLM

앱은 텍스트 입력과 이미지 요약 간의 유사성을 기반으로 이미지를 검색하고, 이미지를 GPT-4V에 전달합니다.

## 환경 설정

OpenAI GPT-4V에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하십시오.

`UpstashRedisByteStore`를 사용하는 경우 데이터베이스에 접근하기 위해 `UPSTASH_URL` 및 `UPSTASH_TOKEN`을 환경 변수로 설정하십시오.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-chroma-multi-modal-multi-vector
```


기존 프로젝트에 추가하려면 다음을 실행하십시오:

```shell
langchain app add rag-chroma-multi-modal-multi-vector
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from rag_chroma_multi_modal_multi_vector import chain as rag_chroma_multi_modal_chain_mv

add_routes(app, rag_chroma_multi_modal_chain_mv, path="/rag-chroma-multi-modal-multi-vector")
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


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿을 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-chroma-multi-modal-multi-vector/playground](http://127.0.0.1:8000/rag-chroma-multi-modal-multi-vector/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-chroma-multi-modal-multi-vector")
```