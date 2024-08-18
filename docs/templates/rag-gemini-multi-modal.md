---
description: 다중 모달 LLM을 활용한 슬라이드 덱 시각 보조 도구로, 이미지 질문 응답 기능을 제공합니다. OpenCLIP 임베딩을 사용합니다.
---

# rag-gemini-multi-modal

다중 모달 LLM은 이미지에 대한 질문-응답을 수행할 수 있는 시각적 도우미를 가능하게 합니다.

이 템플릿은 종종 그래프나 그림과 같은 시각적 요소를 포함하는 슬라이드 덱을 위한 시각적 도우미를 생성합니다.

OpenCLIP 임베딩을 사용하여 모든 슬라이드 이미지를 임베딩하고 이를 Chroma에 저장합니다.

질문이 주어지면 관련 슬라이드를 검색하여 [Google Gemini](https://deepmind.google/technologies/gemini/#introduction)로 전달하여 답변을 생성합니다.

## 입력

슬라이드 덱을 `/docs` 디렉토리에 pdf 형식으로 제공하십시오.

기본적으로 이 템플릿은 공개 기술 회사인 DataDog의 Q3 수익에 대한 슬라이드 덱을 포함하고 있습니다.

예시 질문은 다음과 같습니다:
```
How many customers does Datadog have?
What is Datadog platform % Y/Y growth in FY20, FY21, and FY22?
```


슬라이드 덱의 인덱스를 생성하려면 다음을 실행하십시오:
```
poetry install
python ingest.py
```


## 저장소

이 템플릿은 [OpenCLIP](https://github.com/mlfoundations/open_clip) 다중 모달 임베딩을 사용하여 이미지를 임베딩합니다.

다양한 임베딩 모델 옵션을 선택할 수 있습니다(결과는 [여기](https://github.com/mlfoundations/open_clip/blob/main/docs/openclip_results.csv)에서 확인하십시오).

앱을 처음 실행하면 다중 모달 임베딩 모델이 자동으로 다운로드됩니다.

기본적으로 LangChain은 중간 성능이지만 메모리 요구 사항이 낮은 임베딩 모델인 `ViT-H-14`를 사용합니다.

대체 `OpenCLIPEmbeddings` 모델을 `rag_chroma_multi_modal/ingest.py`에서 선택할 수 있습니다:
```
vectorstore_mmembd = Chroma(
    collection_name="multi-modal-rag",
    persist_directory=str(re_vectorstore_path),
    embedding_function=OpenCLIPEmbeddings(
        model_name="ViT-H-14", checkpoint="laion2b_s32b_b79k"
    ),
)
```


## LLM

앱은 다중 모달 임베딩을 사용하여 이미지를 검색하고 이를 Google Gemini에 전달합니다.

## 환경 설정

Gemini에 접근하기 위해 `GOOGLE_API_KEY` 환경 변수를 설정하십시오.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음을 수행할 수 있습니다:

```shell
langchain app new my-app --package rag-gemini-multi-modal
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-gemini-multi-modal
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from rag_gemini_multi_modal import chain as rag_gemini_multi_modal_chain

add_routes(app, rag_gemini_multi_modal_chain, path="/rag-gemini-multi-modal")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줍니다.
LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 방문하십시오.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-gemini-multi-modal/playground](http://127.0.0.1:8000/rag-gemini-multi-modal/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-gemini-multi-modal")
```