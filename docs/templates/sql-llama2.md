---
description: 이 템플릿은 자연어를 사용하여 SQL 데이터베이스와 상호작용할 수 있도록 하며, 2023 NBA 로스터의 예제 데이터베이스를
  포함합니다.
---

# sql-llama2

이 템플릿은 사용자가 자연어를 사용하여 SQL 데이터베이스와 상호작용할 수 있게 해줍니다.

이 템플릿은 [Replicate](https://python.langchain.com/docs/integrations/llms/replicate)에서 호스팅되는 LLamA2-13b를 사용하지만, [Fireworks](https://python.langchain.com/docs/integrations/chat/fireworks)를 포함하여 LLaMA2를 지원하는 모든 API에 맞게 조정할 수 있습니다.

이 템플릿에는 2023 NBA 로스터의 예제 데이터베이스가 포함되어 있습니다.

이 데이터베이스를 구축하는 방법에 대한 자세한 내용은 [여기](https://github.com/facebookresearch/llama-recipes/blob/main/demo_apps/StructuredLlama.ipynb)를 참조하십시오.

## 환경 설정

`REPLICATE_API_TOKEN`이 환경에 설정되어 있는지 확인하십시오.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package sql-llama2
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add sql-llama2
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from sql_llama2 import chain as sql_llama2_chain

add_routes(app, sql_llama2_chain, path="/sql-llama2")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 방문하십시오.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면, 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 볼 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/sql-llama2/playground](http://127.0.0.1:8000/sql-llama2/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/sql-llama2")
```