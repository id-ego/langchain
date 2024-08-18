---
description: NVIDIA 모델과 Milvus 벡터 저장소를 사용하여 RAG를 수행하는 템플릿입니다. 환경 설정 및 사용 방법을 안내합니다.
---

# nvidia-rag-canonical

이 템플릿은 Milvus 벡터 스토어와 NVIDIA 모델(임베딩 및 채팅)을 사용하여 RAG를 수행합니다.

## 환경 설정

NVIDIA API 키를 환경 변수로 내보내야 합니다.  
NVIDIA API 키가 없는 경우, 다음 단계를 따라 생성할 수 있습니다:  
1. AI 솔루션 카탈로그, 컨테이너, 모델 등을 호스팅하는 [NVIDIA GPU Cloud](https://catalog.ngc.nvidia.com/) 서비스에 무료 계정을 생성합니다.  
2. `Catalog > AI Foundation Models > (API 엔드포인트가 있는 모델)`로 이동합니다.  
3. `API` 옵션을 선택하고 `Generate Key`를 클릭합니다.  
4. 생성된 키를 `NVIDIA_API_KEY`로 저장합니다. 그 후, 엔드포인트에 접근할 수 있어야 합니다.  

```shell
export NVIDIA_API_KEY=...
```


Milvus 벡터 스토어 호스팅에 대한 지침은 하단 섹션을 참조하세요.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


NVIDIA 모델을 사용하려면 Langchain NVIDIA AI Endpoints 패키지를 설치합니다:  
```shell
pip install -U langchain_nvidia_aiplay
```


새 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package nvidia-rag-canonical
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add nvidia-rag-canonical
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:  
```python
from nvidia_rag_canonical import chain as nvidia_rag_canonical_chain

add_routes(app, nvidia_rag_canonical_chain, path="/nvidia-rag-canonical")
```


데이터 수집 파이프라인을 설정하려면 `server.py` 파일에 다음 코드를 추가할 수 있습니다:  
```python
from nvidia_rag_canonical import ingest as nvidia_rag_ingest

add_routes(app, nvidia_rag_ingest, path="/nvidia-rag-ingest")
```
  
데이터 수집 API로 수집된 파일의 경우, 새로 수집된 파일이 검색 가능해지려면 서버를 재시작해야 합니다.

(선택 사항) 이제 LangSmith를 구성해 보겠습니다.  
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.  
LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다.  
접근할 수 없는 경우, 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


연결할 Milvus 벡터 스토어가 이미 없는 경우, 진행하기 전에 아래의 `Milvus Setup` 섹션을 참조하세요.

연결할 Milvus 벡터 스토어가 있는 경우, `nvidia_rag_canonical/chain.py`에서 연결 세부 정보를 수정하세요.

이 디렉토리 내에 있다면, 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.  
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.  
플레이그라운드는 [http://127.0.0.1:8000/nvidia-rag-canonical/playground](http://127.0.0.1:8000/nvidia-rag-canonical/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/nvidia-rag-canonical")
```


## Milvus 설정

Milvus 벡터 스토어를 생성하고 데이터를 수집해야 하는 경우 이 단계를 사용하세요.  
먼저 표준 Milvus 설정 지침을 [여기](https://milvus.io/docs/install_standalone-docker.md)에서 따릅니다.

1. Docker Compose YAML 파일을 다운로드합니다.  
   ```shell
   wget https://github.com/milvus-io/milvus/releases/download/v2.3.3/milvus-standalone-docker-compose.yml -O docker-compose.yml
   ```
  
2. Milvus 벡터 스토어 컨테이너를 시작합니다.  
   ```shell
   sudo docker compose up -d
   ```
  
3. Milvus 컨테이너와 상호작용하기 위해 PyMilvus 패키지를 설치합니다.  
   ```shell
   pip install pymilvus
   ```
  
4. 이제 데이터를 수집해 보겠습니다! 이 디렉토리로 이동하여 `ingest.py`의 코드를 실행하면 됩니다, 예를 들어:  
   
   ```shell
   python ingest.py
   ```
  
   
   원하는 데이터로 수집할 수 있도록 변경할 수 있습니다(그리고 변경해야 합니다!).