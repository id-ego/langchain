---
description: 이 문서는 JaguarDB와 OpenAI를 사용하여 RAG(정보 검색 증강 생성)를 수행하는 템플릿을 제공합니다. 환경 설정
  및 사용법을 안내합니다.
---

# rag-jaguardb

이 템플릿은 JaguarDB와 OpenAI를 사용하여 RAG를 수행합니다.

## 환경 설정

Jaguar URI와 OpenAI API KEY를 환경 변수로 내보내야 합니다. 
JaguarDB가 설정되어 있지 않은 경우, 설정 방법에 대한 지침은 하단의 `Setup Jaguar` 섹션을 참조하십시오.

```shell
export JAGUAR_API_KEY=...
export OPENAI_API_KEY=...
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-jaguardb
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-jagaurdb
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from rag_jaguardb import chain as rag_jaguardb

add_routes(app, rag_jaguardb_chain, path="/rag-jaguardb")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.  
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.  
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하십시오.  
접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면, 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며, 서버는 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.  
플레이그라운드는 [http://127.0.0.1:8000/rag-jaguardb/playground](http://127.0.0.1:8000/rag-jaguardb/playground)에서 접근할 수 있습니다.  

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-jaguardb")
```


## JaguarDB 설정

JaguarDB를 활용하려면 docker pull 및 docker run 명령어를 사용하여 JaguarDB를 빠르게 설정할 수 있습니다.

```shell
docker pull jaguardb/jaguardb 
docker run -d -p 8888:8888 --name jaguardb jaguardb/jaguardb
```


JaguarDB 서버와 상호작용하기 위해 JaguarDB 클라이언트 터미널을 실행하려면:

```shell
docker exec -it jaguardb /home/jaguar/jaguar/bin/jag
```


또 다른 옵션은 Linux에서 이미 빌드된 JaguarDB 바이너리 패키지를 다운로드하고 단일 노드 또는 클러스터의 노드에 데이터베이스를 배포하는 것입니다.  
이 간소화된 프로세스를 통해 JaguarDB를 빠르게 시작하고 강력한 기능과 기능을 활용할 수 있습니다. [여기](http://www.jaguardb.com/download.html).