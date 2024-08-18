---
description: Zep를 사용하여 RAG 대화 앱을 구축하는 템플릿으로, 문서 수집, 임베딩, 검색 및 대화 체인을 포함합니다.
---

# rag-conversation-zep

이 템플릿은 Zep를 사용하여 RAG 대화 앱을 구축하는 방법을 보여줍니다.

이 템플릿에 포함된 내용:
- 문서 집합으로 [Zep 문서 컬렉션](https://docs.getzep.com/sdk/documents/)을 채우기 (컬렉션은 다른 벡터 데이터베이스의 인덱스와 유사합니다).
- Zep의 [통합 임베딩](https://docs.getzep.com/deployment/embeddings/) 기능을 사용하여 문서를 벡터로 임베딩합니다.
- Zep의 하드웨어 가속 [최대 한계 관련성](https://docs.getzep.com/sdk/search_query/) (MMR) 재순위를 사용하여 문서를 검색하는 LangChain [ZepVectorStore Retriever](https://docs.getzep.com/sdk/documents/)를 구성합니다.
- RAG 대화 앱을 구축하는 데 필요한 프롬프트, 간단한 채팅 기록 데이터 구조 및 기타 구성 요소.
- RAG 대화 체인.

## [Zep - LLM 앱을 위한 빠르고 확장 가능한 빌딩 블록](https://www.getzep.com/)에 대하여
Zep는 LLM 앱을 프로덕션화하기 위한 오픈 소스 플랫폼입니다. LangChain 또는 LlamaIndex에서 구축한 프로토타입이나 사용자 지정 앱을 코드 재작성 없이 몇 분 만에 프로덕션으로 전환할 수 있습니다.

주요 기능:

- 빠름! Zep의 비동기 추출기는 채팅 루프와 독립적으로 작동하여 쾌적한 사용자 경험을 보장합니다.
- 요약 전략에 관계없이 과거 메시지에 대한 접근이 가능한 장기 메모리 지속성.
- 구성 가능한 메시지 창을 기반으로 메모리 메시지를 자동 요약합니다. 일련의 요약이 저장되어 향후 요약 전략에 유연성을 제공합니다.
- 메모리와 메타데이터에 대한 하이브리드 검색, 메시지가 생성 시 자동으로 임베딩됩니다.
- 메시지에서 명명된 개체를 자동으로 추출하고 메시지 메타데이터에 저장하는 개체 추출기.
- 프롬프트 조립에 대한 세밀한 제어를 가능하게 하는 메모리와 요약의 자동 토큰 수 계산.
- Python 및 JavaScript SDK.

Zep 프로젝트: https://github.com/getzep/zep | 문서: https://docs.getzep.com/

## 환경 설정

[빠른 시작 가이드](https://docs.getzep.com/deployment/quickstart/)를 따라 Zep 서비스를 설정합니다.

## Zep 컬렉션에 문서 수집하기

`python ingest.py`를 실행하여 테스트 문서를 Zep 컬렉션에 수집합니다. 파일을 검토하여 컬렉션 이름과 문서 출처를 수정합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U "langchain-cli[serve]"
```


새 LangChain 프로젝트를 만들고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-conversation-zep
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-conversation-zep
```


그리고 `server.py` 파일에 다음 코드를 추가합니다:
```python
from rag_conversation_zep import chain as rag_conversation_zep_chain

add_routes(app, rag_conversation_zep_chain, path="/rag-conversation-zep")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
여기에서 LangSmith에 가입할 수 있습니다 [여기](https://smith.langchain.com/).
접근할 수 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿을 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 볼 수 있습니다.
플레이그라운드에 접근하려면 [http://127.0.0.1:8000/rag-conversation-zep/playground](http://127.0.0.1:8000/rag-conversation-zep/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-conversation-zep")
```