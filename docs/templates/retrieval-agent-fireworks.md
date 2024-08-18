---
description: 이 패키지는 FireworksAI에서 호스팅되는 오픈 소스 모델을 사용하여 Arxiv에서 검색을 수행하는 에이전트 아키텍처를
  제공합니다.
---

# retrieval-agent-fireworks

이 패키지는 에이전트 아키텍처를 사용하여 FireworksAI에 호스팅된 오픈 소스 모델을 통해 검색을 수행합니다. 기본적으로 이 패키지는 Arxiv에서 검색을 수행합니다.

우리는 이 블로그에서 함수 호출로 합리적인 결과를 제공하는 것으로 나타난 `Mixtral8x7b-instruct-v0.1`을 사용할 것입니다. 비록 이 작업을 위해 미세 조정되지 않았습니다: https://huggingface.co/blog/open-source-llms-as-agents

## 환경 설정

OSS 모델을 실행하는 다양한 훌륭한 방법이 있습니다. 우리는 모델을 실행하는 쉬운 방법으로 FireworksAI를 사용할 것입니다. 자세한 내용은 [여기](https://python.langchain.com/docs/integrations/providers/fireworks)를 참조하세요.

Fireworks에 접근하기 위해 `FIREWORKS_API_KEY` 환경 변수를 설정하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package retrieval-agent-fireworks
```


기존 프로젝트에 추가하려면 다음 명령을 실행하면 됩니다:

```shell
langchain app add retrieval-agent-fireworks
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from retrieval_agent_fireworks import chain as retrieval_agent_fireworks_chain

add_routes(app, retrieval_agent_fireworks_chain, path="/retrieval-agent-fireworks")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버그하는 데 도움을 줄 것입니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 방문하세요.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

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
플레이그라운드는 [http://127.0.0.1:8000/retrieval-agent-fireworks/playground](http://127.0.0.1:8000/retrieval-agent-fireworks/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/retrieval-agent-fireworks")
```