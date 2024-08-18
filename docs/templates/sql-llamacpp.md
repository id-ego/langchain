---
description: 이 템플릿은 자연어를 사용하여 SQL 데이터베이스와 상호작용할 수 있도록 하며, Mistral-7b 모델을 활용합니다.
---

# sql-llamacpp

이 템플릿은 사용자가 자연어를 사용하여 SQL 데이터베이스와 상호작용할 수 있도록 합니다.

이것은 [Mistral-7b](https://mistral.ai/news/announcing-mistral-7b/)를 [llama.cpp](https://github.com/ggerganov/llama.cpp)를 통해 사용하여 Mac 노트북에서 로컬로 추론을 실행합니다.

## 환경 설정

환경을 설정하려면 다음 단계를 사용하십시오:

```shell
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-arm64.sh
bash Miniforge3-MacOSX-arm64.sh
conda create -n llama python=3.9.16
conda activate /Users/rlm/miniforge3/envs/llama
CMAKE_ARGS="-DLLAMA_METAL=on" FORCE_CMAKE=1 pip install -U llama-cpp-python --no-cache-dir
```


## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새로운 LangChain 프로젝트를 만들고 이 패키지만 설치하려면 다음을 수행할 수 있습니다:

```shell
langchain app new my-app --package sql-llamacpp
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add sql-llamacpp
```


그리고 `server.py` 파일에 다음 코드를 추가하십시오:
```python
from sql_llamacpp import chain as sql_llamacpp_chain

add_routes(app, sql_llamacpp_chain, path="/sql-llamacpp")
```


이 패키지는 [여기](https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF)에서 Mistral-7b 모델을 다운로드합니다. 다른 파일을 선택하고 다운로드 경로를 지정할 수 있습니다 ( [여기](https://huggingface.co/TheBloke)에서 찾아보세요).

이 패키지에는 2023 NBA 로스터의 예제 DB가 포함되어 있습니다. 이 DB를 구축하는 방법에 대한 지침은 [여기](https://github.com/facebookresearch/llama-recipes/blob/main/demo_apps/StructuredLlama.ipynb)에서 확인할 수 있습니다.

(선택 사항) LangChain 애플리케이션의 추적, 모니터링 및 디버깅을 위해 LangSmith를 구성하십시오. LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 방문하십시오. 접근 권한이 없는 경우 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 안에 있다면, 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되고 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.
플레이그라운드는 [http://127.0.0.1:8000/sql-llamacpp/playground](http://127.0.0.1:8000/sql-llamacpp/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/sql-llamacpp")
```