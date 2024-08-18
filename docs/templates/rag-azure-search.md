---
description: 이 템플릿은 Azure AI Search를 벡터 저장소로 사용하여 문서에서 RAG를 수행하는 방법을 설명합니다. Azure
  OpenAI 모델과 통합됩니다.
---

# rag-azure-search

이 템플릿은 [Azure AI Search](https://learn.microsoft.com/azure/search/search-what-is-azure-search)를 벡터 저장소로 사용하고 Azure OpenAI 채팅 및 임베딩 모델을 이용하여 문서에서 RAG를 수행합니다.

Azure AI Search와 함께 RAG에 대한 추가 세부정보는 [이 노트북](https://github.com/langchain-ai/langchain/blob/master/docs/docs/integrations/vectorstores/azuresearch.ipynb)을 참조하십시오.

## 환경 설정

***전제 조건:*** 기존 [Azure AI Search](https://learn.microsoft.com/azure/search/search-what-is-azure-search) 및 [Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/overview) 리소스.

***환경 변수:***

이 템플릿을 실행하려면 다음 환경 변수를 설정해야 합니다:

***필수:***

- AZURE_SEARCH_ENDPOINT - Azure AI Search 서비스의 엔드포인트.
- AZURE_SEARCH_KEY - Azure AI Search 서비스의 API 키.
- AZURE_OPENAI_ENDPOINT - Azure OpenAI 서비스의 엔드포인트.
- AZURE_OPENAI_API_KEY - Azure OpenAI 서비스의 API 키.
- AZURE_EMBEDDINGS_DEPLOYMENT - 임베딩에 사용할 Azure OpenAI 배포의 이름.
- AZURE_CHAT_DEPLOYMENT - 채팅에 사용할 Azure OpenAI 배포의 이름.

***선택 사항:***

- AZURE_SEARCH_INDEX_NAME - 사용할 기존 Azure AI Search 인덱스의 이름. 제공되지 않으면 "rag-azure-search"라는 이름의 인덱스가 생성됩니다.
- OPENAI_API_VERSION - 사용할 Azure OpenAI API 버전. 기본값은 "2023-05-15".

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-azure-search
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-azure-search
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_azure_search import chain as rag_azure_search_chain

add_routes(app, rag_azure_search_chain, path="/rag-azure-search")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.
접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-azure-search/playground](http://127.0.0.1:8000/rag-azure-search/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-azure-search")
```