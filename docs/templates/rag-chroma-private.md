---
description: 이 템플릿은 Ollama, GPT4All 및 Chroma를 사용하여 외부 API 없이 RAG를 수행하는 방법을 설명합니다.
---

# rag-chroma-private

이 템플릿은 외부 API에 의존하지 않고 RAG를 수행합니다.

Ollama LLM, GPT4All을 임베딩에 사용하고 Chroma를 벡터 저장소로 활용합니다.

벡터 저장소는 `chain.py`에서 생성되며 기본적으로 질문-답변을 위해 [에이전트에 대한 인기 블로그 게시물](https://lilianweng.github.io/posts/2023-06-23-agent/)을 인덱싱합니다.

## 환경 설정

환경을 설정하려면 Ollama를 다운로드해야 합니다.

[여기](https://python.langchain.com/docs/integrations/chat/ollama)에서 지침을 따르세요.

Ollama로 원하는 LLM을 선택할 수 있습니다.

이 템플릿은 `llama2:7b-chat`를 사용하며, `ollama pull llama2:7b-chat`를 통해 접근할 수 있습니다.

[여기](https://ollama.ai/library)에서 많은 다른 옵션을 확인할 수 있습니다.

이 패키지는 [GPT4All](https://python.langchain.com/docs/integrations/text_embedding/gpt4all) 임베딩도 사용합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package rag-chroma-private
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add rag-chroma-private
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_chroma_private import chain as rag_chroma_private_chain

add_routes(app, rag_chroma_private_chain, path="/rag-chroma-private")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다. LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움이 됩니다. LangSmith에 [여기](https://smith.langchain.com/)에서 가입할 수 있습니다. 접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 로컬에서 서버가 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/rag-chroma-private/playground](http://127.0.0.1:8000/rag-chroma-private/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-chroma-private")
```


이 패키지는 `chain.py`에서 벡터 데이터베이스에 문서를 생성하고 추가합니다. 기본적으로 에이전트에 대한 인기 블로그 게시물을 로드합니다. 그러나 [여기](https://python.langchain.com/docs/integrations/document_loaders)에서 많은 문서 로더 중에서 선택할 수 있습니다.