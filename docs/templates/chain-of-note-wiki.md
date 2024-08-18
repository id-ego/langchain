---
description: Chain-of-Note를 구현한 문서로, Wikipedia를 활용한 정보 검색 방법을 설명합니다. Anthropic 모델을
  사용하여 LangChain 프로젝트를 설정합니다.
---

# Chain-of-Note (위키백과)

Yu 외의 저자들이 설명한 대로 Chain-of-Note를 구현합니다. 검색을 위해 위키백과를 사용합니다.

여기에서 사용되는 프롬프트를 확인하세요: https://smith.langchain.com/hub/bagatur/chain-of-note-wiki.

## 환경 설정

Anthropic claude-3-sonnet-20240229 채팅 모델을 사용합니다. Anthropic API 키를 설정하세요:
```bash
export ANTHROPIC_API_KEY="..."
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI가 설치되어 있어야 합니다:

```shell
pip install -U "langchain-cli[serve]"
```


새로운 LangChain 프로젝트를 생성하고 이 패키지만 설치하려면 다음을 실행하세요:

```shell
langchain app new my-app --package chain-of-note-wiki
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add chain-of-note-wiki
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from chain_of_note_wiki import chain as chain_of_note_wiki_chain

add_routes(app, chain_of_note_wiki_chain, path="/chain-of-note-wiki")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
여기에서 LangSmith에 가입할 수 있습니다: [여기](https://smith.langchain.com/).
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며, 서버는 로컬에서 실행됩니다:
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/chain-of-note-wiki/playground](http://127.0.0.1:8000/chain-of-note-wiki/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/chain-of-note-wiki")
```