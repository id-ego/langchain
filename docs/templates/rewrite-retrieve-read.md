---
description: 이 문서는 RAG 최적화를 위한 쿼리 변환 방법을 구현한 템플릿으로, OpenAI 모델에 접근하기 위한 환경 설정을 안내합니다.
---

# rewrite_retrieve_read

이 템플릿은 RAG 최적화를 위해 논문 [Query Rewriting for Retrieval-Augmented Large Language Models](https://arxiv.org/pdf/2305.14283.pdf)에서 쿼리 변환(재작성) 방법을 구현합니다.

## 환경 설정

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rewrite_retrieve_read
```


기존 프로젝트에 추가하려면 다음 명령어를 실행하면 됩니다:

```shell
langchain app add rewrite_retrieve_read
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rewrite_retrieve_read.chain import chain as rewrite_retrieve_read_chain

add_routes(app, rewrite_retrieve_read_chain, path="/rewrite-retrieve-read")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음 명령어로 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이 명령어는 FastAPI 앱을 시작하며, 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rewrite_retrieve_read/playground](http://127.0.0.1:8000/rewrite_retrieve_read/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rewrite_retrieve_read")
```