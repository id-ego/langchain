---
description: '"Skeleton of Thought" 기법을 구현하여 긴 생성물을 빠르게 생성하는 방법을 설명하는 문서입니다. LangChain
  환경 설정 및 사용법 포함.'
---

# skeleton-of-thought

"Skeleton of Thought"를 [이 논문](https://sites.google.com/view/sot-llm)에서 구현합니다.

이 기술은 먼저 스켈레톤을 생성한 다음, 개요의 각 포인트를 생성하여 더 긴 생성을 더 빠르게 할 수 있게 합니다.

## 환경 설정

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하세요.

`OPENAI_API_KEY`를 얻으려면 OpenAI 계정의 [API 키](https://platform.openai.com/account/api-keys)로 이동하여 새로운 비밀 키를 생성하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package skeleton-of-thought
```


기존 프로젝트에 이것을 추가하고 싶다면, 다음을 실행하면 됩니다:

```shell
langchain app add skeleton-of-thought
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from skeleton_of_thought import chain as skeleton_of_thought_chain

add_routes(app, skeleton_of_thought_chain, path="/skeleton-of-thought")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기서](https://smith.langchain.com/) 가입할 수 있습니다.
접근할 수 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/skeleton-of-thought/playground](http://127.0.0.1:8000/skeleton-of-thought/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/skeleton-of-thought")
```