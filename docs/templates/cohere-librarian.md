---
description: Cohere를 활용한 라이브러리 시스템을 구축하는 템플릿으로, 다양한 기능을 가진 체인을 전환하는 방법을 보여줍니다.
---

# cohere-librarian

이 템플릿은 Cohere를 사서로 변환합니다.

이것은 서로 다른 작업을 처리할 수 있는 체인 간에 전환하기 위한 라우터의 사용을 보여줍니다: Cohere 임베딩을 사용하는 벡터 데이터베이스; 도서관에 대한 정보가 포함된 프롬프트가 있는 채팅 봇; 그리고 마지막으로 인터넷에 접근할 수 있는 RAG 채팅 봇입니다.

도서 추천의 더 완전한 데모를 위해, books_with_blurbs.csv를 다음 데이터셋의 더 큰 샘플로 교체하는 것을 고려해 보세요: https://www.kaggle.com/datasets/jdobrow/57000-books-with-metadata-and-blurbs/ .

## 환경 설정

Cohere 모델에 접근하기 위해 `COHERE_API_KEY` 환경 변수를 설정하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package cohere-librarian
```


기존 프로젝트에 추가하고 싶다면, 다음을 실행하면 됩니다:

```shell
langchain app add cohere-librarian
```


그리고 다음 코드를 `server.py` 파일에 추가하세요:
```python
from cohere_librarian.chain import chain as cohere_librarian_chain

add_routes(app, cohere_librarian_chain, path="/cohere-librarian")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
여기에서 LangSmith에 가입할 수 있습니다 [여기](https://smith.langchain.com/).
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


이렇게 하면 FastAPI 앱이 시작되며 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://localhost:8000/docs](http://localhost:8000/docs)에서 볼 수 있습니다.
플레이그라운드는 [http://localhost:8000/cohere-librarian/playground](http://localhost:8000/cohere-librarian/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/cohere-librarian")
```