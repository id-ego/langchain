---
description: 이 문서는 guardrails-ai를 사용하여 LLM 출력을 검증하는 GuardrailsOutputParser 설정 및 사용
  방법에 대해 설명합니다.
---

# guardrails-output-parser

이 템플릿은 [guardrails-ai](https://github.com/guardrails-ai/guardrails)를 사용하여 LLM 출력을 검증합니다.

`GuardrailsOutputParser`는 `chain.py`에 설정되어 있습니다.

기본 예제는 욕설을 방지합니다.

## 환경 설정

`OPENAI_API_KEY` 환경 변수를 설정하여 OpenAI 모델에 접근합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package guardrails-output-parser
```


기존 프로젝트에 추가하려면 다음 명령어를 실행하면 됩니다:

```shell
langchain app add guardrails-output-parser
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from guardrails_output_parser.chain import chain as guardrails_output_parser_chain

add_routes(app, guardrails_output_parser_chain, path="/guardrails-output-parser")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요.
접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/guardrails-output-parser/playground](http://127.0.0.1:8000/guardrails-output-parser/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/guardrails-output-parser")
```


Guardrails가 욕설을 찾지 못하면 번역된 출력이 그대로 반환됩니다. Guardrails가 욕설을 찾으면 빈 문자열이 반환됩니다.