---
description: 다양한 도메인별 검색기를 쿼리하여 가장 관련성 높은 문서를 선택하는 QA 애플리케이션에 대한 설명입니다.
---

# 여러 인덱스를 사용한 RAG (퓨전)

여러 도메인별 검색기를 쿼리하고 검색된 결과 전체에서 가장 관련성 높은 문서를 선택하는 QA 애플리케이션입니다.

## 환경 설정

이 애플리케이션은 PubMed, ArXiv, Wikipedia 및 [Kay AI](https://www.kay.ai) (SEC 제출 문서용)를 쿼리합니다.

무료 Kay AI 계정을 생성하고 [여기에서 API 키를 받으세요](https://www.kay.ai).
그런 다음 환경 변수를 설정하십시오:

```bash
export KAY_API_KEY="<YOUR_API_KEY>"
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 만들고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-multi-index-fusion
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-multi-index-fusion
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from rag_multi_index_fusion import chain as rag_multi_index_fusion_chain

add_routes(app, rag_multi_index_fusion_chain, path="/rag-multi-index-fusion")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기에서 가입할 수 있습니다](https://smith.langchain.com/).
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되고 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-multi-index-fusion/playground](http://127.0.0.1:8000/rag-multi-index-fusion/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-multi-index-fusion")
```