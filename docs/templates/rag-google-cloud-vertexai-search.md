---
description: 이 템플릿은 Google Vertex AI Search와 PaLM 2를 활용하여 문서 기반 질문에 답변하는 RAG 애플리케이션을
  구축하는 방법을 안내합니다.
---

# rag-google-cloud-vertexai-search

이 템플릿은 기계 학습 기반 검색 서비스인 Google Vertex AI Search와 PaLM 2 for Chat (chat-bison)을 활용하는 애플리케이션입니다. 이 애플리케이션은 문서를 기반으로 질문에 답하기 위해 Retrieval 체인을 사용합니다.

Vertex AI Search로 RAG 애플리케이션을 구축하는 것에 대한 더 많은 맥락은 [여기](https://cloud.google.com/generative-ai-app-builder/docs/enterprise-search-introduction)를 확인하세요.

## 환경 설정

이 템플릿을 사용하기 전에 Vertex AI Search에 인증되어 있는지 확인하세요. 인증 가이드는 [여기](https://cloud.google.com/generative-ai-app-builder/docs/authentication)를 참조하세요.

다음 항목을 생성해야 합니다:

- 검색 애플리케이션 [여기](https://cloud.google.com/generative-ai-app-builder/docs/create-engine-es)에서 생성
- 데이터 저장소 [여기](https://cloud.google.com/generative-ai-app-builder/docs/create-data-store-es)에서 생성

이 템플릿을 테스트하기에 적합한 데이터셋은 Alphabet Earnings Reports로, [여기](https://abc.xyz/investor/)에서 찾을 수 있습니다. 데이터는 `gs://cloud-samples-data/gen-app-builder/search/alphabet-investor-pdfs`에서도 사용할 수 있습니다.

다음 환경 변수를 설정하세요:

* `GOOGLE_CLOUD_PROJECT_ID` - 귀하의 Google Cloud 프로젝트 ID.
* `DATA_STORE_ID` - Vertex AI Search의 데이터 저장소 ID로, 데이터 저장소 세부정보 페이지에서 찾을 수 있는 36자 알파벳 숫자 값입니다.
* `MODEL_TYPE` - Vertex AI Search의 모델 유형.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-google-cloud-vertexai-search
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-google-cloud-vertexai-search
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:

```python
from rag_google_cloud_vertexai_search.chain import chain as rag_google_cloud_vertexai_search_chain

add_routes(app, rag_google_cloud_vertexai_search_chain, path="/rag-google-cloud-vertexai-search")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 로컬에서 [http://localhost:8000](http://localhost:8000)에서 서버가 실행됩니다.

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-google-cloud-vertexai-search/playground](http://127.0.0.1:8000/rag-google-cloud-vertexai-search/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-google-cloud-vertexai-search")
```