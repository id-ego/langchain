---
description: 이 템플릿은 Vertex AI PaLM2를 사용하여 Chuck Norris에 대한 농담을 생성하는 방법을 안내합니다. 환경
  설정 및 사용법을 포함합니다.
---

# vertexai-chuck-norris

이 템플릿은 Vertex AI PaLM2를 사용하여 Chuck Norris에 대한 농담을 만듭니다.

## 환경 설정

먼저, 활성화된 청구 계정이 있는 Google Cloud 프로젝트가 있고 [gcloud CLI가 설치되어 있는지](https://cloud.google.com/sdk/docs/install) 확인하세요.

[애플리케이션 기본 자격 증명](https://cloud.google.com/docs/authentication/provide-credentials-adc)을 구성하세요:

```shell
gcloud auth application-default login
```


사용할 기본 Google Cloud 프로젝트를 설정하려면 이 명령을 실행하고 사용하려는 프로젝트의 [프로젝트 ID](https://support.google.com/googleapi/answer/7014113?hl=en)를 설정하세요:
```shell
gcloud config set project [PROJECT-ID]
```


프로젝트에 대해 [Vertex AI API](https://console.cloud.google.com/apis/library/aiplatform.googleapis.com)를 활성화하세요:
```shell
gcloud services enable aiplatform.googleapis.com
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 만들고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package pirate-speak
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add vertexai-chuck-norris
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from vertexai_chuck_norris.chain import chain as vertexai_chuck_norris_chain

add_routes(app, vertexai_chuck_norris_chain, path="/vertexai-chuck-norris")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
LangSmith에 [여기서](https://smith.langchain.com/) 가입할 수 있습니다.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/vertexai-chuck-norris/playground](http://127.0.0.1:8000/vertexai-chuck-norris/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/vertexai-chuck-norris")
```