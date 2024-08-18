---
description: 이 문서는 개인 사진 컬렉션에 대한 비주얼 검색 및 질문-답변 기능을 구현하는 방법을 보여줍니다. 다중 모달 LLM을 활용합니다.
---

# rag-multi-modal-local

비주얼 검색은 iPhone 또는 Android 기기를 사용하는 많은 사람들에게 친숙한 애플리케이션입니다. 사용자가 자연어를 사용하여 사진을 검색할 수 있게 해줍니다.

오픈 소스 멀티 모달 LLM이 출시됨에 따라, 개인 사진 컬렉션을 위해 이러한 유형의 애플리케이션을 직접 구축할 수 있습니다.

이 템플릿은 개인 비주얼 검색 및 사진 컬렉션에 대한 질문-응답을 수행하는 방법을 보여줍니다.

이미지를 임베드하기 위해 [`nomic-embed-vision-v1`](https://huggingface.co/nomic-ai/nomic-embed-vision-v1) 멀티 모달 임베딩을 사용하고, 질문-응답을 위해 `Ollama`를 사용합니다.

질문이 주어지면, 관련 사진이 검색되어 선택한 오픈 소스 멀티 모달 LLM에 전달되어 답변이 생성됩니다.

## 입력

`/docs` 디렉토리에 사진 세트를 제공합니다.

기본적으로 이 템플릿은 3개의 음식 사진으로 구성된 장난감 컬렉션을 가지고 있습니다.

예를 들어 물어볼 수 있는 질문은 다음과 같습니다:
```
What kind of soft serve did I have?
```


실제로는 더 큰 이미지 코퍼스를 테스트할 수 있습니다.

이미지의 인덱스를 생성하려면 다음을 실행합니다:
```
poetry install
python ingest.py
```


## 저장소

이 템플릿은 [nomic-embed-vision-v1](https://huggingface.co/nomic-ai/nomic-embed-vision-v1) 멀티 모달 임베딩을 사용하여 이미지를 임베드합니다.

앱을 처음 실행할 때, 멀티모달 임베딩 모델이 자동으로 다운로드됩니다.

`rag_chroma_multi_modal/ingest.py`에서 `OpenCLIPEmbeddings`와 같은 대체 모델을 선택할 수 있습니다.
```
langchain_experimental.open_clip import OpenCLIPEmbeddings

embedding_function=OpenCLIPEmbeddings(
        model_name="ViT-H-14", checkpoint="laion2b_s32b_b79k"
        )

vectorstore_mmembd = Chroma(
    collection_name="multi-modal-rag",
    persist_directory=str(re_vectorstore_path),
    embedding_function=embedding_function
)
```


## LLM

이 템플릿은 [Ollama](https://python.langchain.com/docs/integrations/chat/ollama#multi-modal)를 사용합니다.

Ollama의 최신 버전을 다운로드하세요: https://ollama.ai/

오픈 소스 멀티 모달 LLM을 가져옵니다: 예를 들어, https://ollama.ai/library/bakllava

```
ollama pull bakllava
```


앱은 기본적으로 `bakllava`로 구성되어 있습니다. 그러나 다른 다운로드된 모델을 위해 `chain.py` 및 `ingest.py`에서 이를 변경할 수 있습니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 만들고 이를 유일한 패키지로 설치하려면 다음을 수행할 수 있습니다:

```shell
langchain app new my-app --package rag-chroma-multi-modal
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-chroma-multi-modal
```


그리고 `server.py` 파일에 다음 코드를 추가합니다:
```python
from rag_chroma_multi_modal import chain as rag_chroma_multi_modal_chain

add_routes(app, rag_chroma_multi_modal_chain, path="/rag-chroma-multi-modal")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
여기에서 LangSmith에 가입할 수 있습니다 [여기](https://smith.langchain.com/).
접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면, 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-chroma-multi-modal/playground](http://127.0.0.1:8000/rag-chroma-multi-modal/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-chroma-multi-modal")
```