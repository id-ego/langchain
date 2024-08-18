---
description: 이 문서는 대화형 검색을 위한 템플릿으로, 대화 기록과 검색된 문서를 LLM에 전달하여 통합하는 방법을 설명합니다.
---

# rag-timescale-conversation

이 템플릿은 가장 인기 있는 LLM 사용 사례 중 하나인 [대화형](https://python.langchain.com/docs/expression_language/cookbook/retrieval#conversational-retrieval-chain) [검색](https://python.langchain.com/docs/use_cases/question_answering/)에 사용됩니다.

대화 기록과 검색된 문서를 LLM에 전달하여 통합합니다.

## 환경 설정

이 템플릿은 벡터 저장소로 Timescale Vector를 사용하며 `TIMESCALES_SERVICE_URL`이 필요합니다. 계정이 없으신 경우 [여기](https://console.cloud.timescale.com/signup?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)에서 90일 무료 체험에 가입하세요.

샘플 데이터 세트를 로드하려면 `LOAD_SAMPLE_DATA=1`로 설정합니다. 자신의 데이터 세트를 로드하려면 아래 섹션을 참조하세요.

OpenAI 모델에 접근하려면 `OPENAI_API_KEY` 환경 변수를 설정하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U "langchain-cli[serve]"
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-timescale-conversation
```


기존 프로젝트에 추가하고 싶다면 다음을 실행하면 됩니다:

```shell
langchain app add rag-timescale-conversation
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_timescale_conversation import chain as rag_timescale_conversation_chain

add_routes(app, rag_timescale_conversation_chain, path="/rag-timescale_conversation")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없으시면 이 섹션을 건너뛸 수 있습니다.

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
플레이그라운드는 [http://127.0.0.1:8000/rag-timescale-conversation/playground](http://127.0.0.1:8000/rag-timescale-conversation/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-timescale-conversation")
```


예제 사용법은 `rag_conversation.ipynb` 노트북을 참조하세요.

## 자신의 데이터 세트 로드하기

자신의 데이터 세트를 로드하려면 `load_dataset` 함수를 생성해야 합니다. `load_sample_dataset.py` 파일에 정의된 `load_ts_git_dataset` 함수에서 예제를 확인할 수 있습니다. 그런 다음 이 함수를 독립 실행형 함수(예: bash 스크립트)로 실행하거나 chain.py에 추가할 수 있습니다(단, 이 경우 한 번만 실행해야 합니다).