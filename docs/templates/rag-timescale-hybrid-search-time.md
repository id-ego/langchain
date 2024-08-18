---
description: 이 문서는 타임스케일 벡터와 자기 쿼리 검색기를 사용하여 유사성과 시간 기반 하이브리드 검색을 수행하는 방법을 설명합니다.
---

# 하이브리드 검색을 위한 타임스케일 벡터와 RAG

이 템플릿은 유사성과 시간에 대한 하이브리드 검색을 수행하기 위해 셀프 쿼리 리트리버와 함께 타임스케일 벡터를 사용하는 방법을 보여줍니다. 이는 데이터에 강력한 시간 기반 요소가 있는 경우에 유용합니다. 이러한 데이터의 몇 가지 예는 다음과 같습니다:
- 뉴스 기사 (정치, 비즈니스 등)
- 블로그 게시물, 문서 또는 기타 게시된 자료 (공개 또는 비공식).
- 소셜 미디어 게시물
- 모든 종류의 변경 로그
- 메시지

이러한 항목은 종종 유사성과 시간 모두에 의해 검색됩니다. 예를 들어: 2022년의 토요타 트럭에 대한 모든 뉴스를 보여주세요.

[타임스케일 벡터](https://www.timescale.com/ai?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)는 특정 시간 범위 내에서 임베딩을 검색할 때 자동 테이블 파티셔닝을 활용하여 데이터를 격리함으로써 우수한 성능을 제공합니다.

Langchain의 셀프 쿼리 리트리버는 사용자 쿼리의 텍스트에서 시간 범위(및 기타 검색 기준)를 유추할 수 있게 해줍니다.

## 타임스케일 벡터란?
**[타임스케일 벡터](https://www.timescale.com/ai?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)는 AI 애플리케이션을 위한 PostgreSQL++입니다.**

타임스케일 벡터는 `PostgreSQL`에서 수십억 개의 벡터 임베딩을 효율적으로 저장하고 쿼리할 수 있게 해줍니다.
- DiskANN에서 영감을 받은 인덱싱 알고리즘을 통해 1B+ 벡터에 대해 더 빠르고 정확한 유사성 검색을 지원하는 `pgvector`를 향상시킵니다.
- 자동 시간 기반 파티셔닝 및 인덱싱을 통해 빠른 시간 기반 벡터 검색을 가능하게 합니다.
- 벡터 임베딩 및 관계형 데이터를 쿼리하기 위한 친숙한 SQL 인터페이스를 제공합니다.

타임스케일 벡터는 POC에서 프로덕션까지 확장 가능한 AI를 위한 클라우드 PostgreSQL입니다:
- 관계형 메타데이터, 벡터 임베딩 및 시계열 데이터를 단일 데이터베이스에 저장할 수 있도록 하여 운영을 간소화합니다.
- 스트리밍 백업 및 복제, 고가용성 및 행 수준 보안과 같은 엔터프라이즈급 기능을 갖춘 견고한 PostgreSQL 기반의 이점을 누립니다.
- 엔터프라이즈급 보안 및 규정을 준수하여 걱정 없는 경험을 제공합니다.

### 타임스케일 벡터에 접근하는 방법
타임스케일 벡터는 클라우드 PostgreSQL 플랫폼인 [타임스케일](https://www.timescale.com/products?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)에서 사용할 수 있습니다. (현재 자체 호스팅 버전은 없습니다.)

- LangChain 사용자는 타임스케일 벡터에 대해 90일 무료 체험을 제공합니다.
- 시작하려면 [가입](https://console.cloud.timescale.com/signup?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)하여 타임스케일에 새 데이터베이스를 만들고 이 노트북을 따르세요!
- 타임스케일 벡터를 파이썬에서 사용하는 방법에 대한 자세한 내용은 [설치 지침](https://github.com/timescale/python-vector)을 참조하세요.

## 환경 설정

이 템플릿은 벡터 저장소로 타임스케일 벡터를 사용하며 `TIMESCALES_SERVICE_URL`이 필요합니다. 계정이 없으신 경우 [여기](https://console.cloud.timescale.com/signup?utm_campaign=vectorlaunch&utm_source=langchain&utm_medium=referral)에서 90일 무료 체험에 가입하세요.

샘플 데이터 세트를 로드하려면 `LOAD_SAMPLE_DATA=1`로 설정하세요. 자신의 데이터 세트를 로드하려면 아래 섹션을 참조하세요.

OpenAI 모델에 접근하기 위해 `OPENAI_API_KEY` 환경 변수를 설정하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 만들고 이 패키지만 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-timescale-hybrid-search-time
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-timescale-hybrid-search-time
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_timescale_hybrid_search.chain import chain as rag_timescale_hybrid_search_chain

add_routes(app, rag_timescale_hybrid_search_chain, path="/rag-timescale-hybrid-search")
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


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-timescale-hybrid-search/playground](http://127.0.0.1:8000/rag-timescale-hybrid-search/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-timescale-hybrid-search")
```


## 자신의 데이터 세트 로드하기

자신의 데이터 세트를 로드하려면 `chain.py`의 `DATASET SPECIFIC CODE` 섹션에서 코드를 수정해야 합니다.
이 코드는 컬렉션의 이름, 데이터를 로드하는 방법, 컬렉션의 내용 및 모든 메타데이터에 대한 인간 언어 설명을 정의합니다. 인간 언어 설명은 셀프 쿼리 리트리버가 LLM이 타임스케일 벡터에서 데이터를 검색할 때 질문을 메타데이터 필터로 변환하는 데 도움을 주기 위해 사용됩니다.