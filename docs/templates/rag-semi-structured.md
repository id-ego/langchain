---
description: 이 문서는 PDF와 같은 반구조적 데이터에서 RAG를 수행하는 템플릿을 제공합니다. 환경 설정 및 사용 방법에 대한 안내가
  포함되어 있습니다.
---

# rag-semi-structured

이 템플릿은 텍스트와 테이블이 포함된 PDF와 같은 반구조적 데이터에서 RAG를 수행합니다.

참고로 [이 요리책](https://github.com/langchain-ai/langchain/blob/master/cookbook/Semi_Structured_RAG.ipynb)을 참조하세요.

## 환경 설정

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하세요.

이것은 PDF 파싱을 위해 [Unstructured](https://unstructured-io.github.io/unstructured/)를 사용하며, 일부 시스템 수준의 패키지 설치가 필요합니다.

Mac에서는 다음과 같이 필요한 패키지를 설치할 수 있습니다:

```shell
brew install tesseract poppler
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-semi-structured
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-semi-structured
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_semi_structured import chain as rag_semi_structured_chain

add_routes(app, rag_semi_structured_chain, path="/rag-semi-structured")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
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


이것은 FastAPI 앱을 시작하며, 서버는 로컬에서 실행되고 있습니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-semi-structured/playground](http://127.0.0.1:8000/rag-semi-structured/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-semi-structured")
```


템플릿에 연결하는 방법에 대한 자세한 내용은 Jupyter 노트북 `rag_semi_structured`를 참조하세요.