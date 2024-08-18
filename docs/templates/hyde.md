---
description: HyDE는 가상의 문서를 생성하여 쿼리와 유사한 실제 문서를 검색하는 방법입니다. RAG와 함께 사용되어 검색 성능을 향상시킵니다.
---

# 하이드

이 템플릿은 RAG와 함께 HyDE를 사용합니다.

Hyde는 가상의 문서 임베딩(Hypothetical Document Embeddings, HyDE)을 의미하는 검색 방법입니다. 이는 들어오는 쿼리에 대한 가상의 문서를 생성하여 검색을 향상시키는 데 사용되는 방법입니다.

문서는 임베딩된 후, 그 임베딩을 사용하여 가상의 문서와 유사한 실제 문서를 조회합니다.

기본 개념은 가상의 문서가 쿼리보다 임베딩 공간에서 더 가까울 수 있다는 것입니다.

자세한 설명은 [여기](https://arxiv.org/abs/2212.10496)에서 확인할 수 있습니다.

## 환경 설정

`OPENAI_API_KEY` 환경 변수를 설정하여 OpenAI 모델에 접근합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package hyde
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add hyde
```


그리고 `server.py` 파일에 다음 코드를 추가합니다:
```python
from hyde.chain import chain as hyde_chain

add_routes(app, hyde_chain, path="/hyde")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적하고 모니터링하며 디버깅하는 데 도움을 줍니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 방문하세요.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

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
플레이그라운드는 [http://127.0.0.1:8000/hyde/playground](http://127.0.0.1:8000/hyde/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/hyde")
```