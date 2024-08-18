---
description: 이 문서는 Intel® Xeon® Scalable 프로세서에서 Chroma와 텍스트 생성 추론을 사용한 RAG 예제를 제공합니다.
---

# RAG 예제 인텔 제온
이 템플릿은 인텔® 제온® 확장 가능 프로세서에서 Chroma 및 텍스트 생성 추론을 사용하여 RAG를 수행합니다.  
인텔® 제온® 확장 가능 프로세서는 더 높은 성능을 위한 내장 가속기를 특징으로 하며, 뛰어난 AI 성능과 함께 가장 수요가 많은 작업 요구 사항을 위한 고급 보안 기술을 제공합니다. 모든 클라우드 선택과 애플리케이션 이식성을 제공하므로 [인텔® 제온® 확장 가능 프로세서](https://www.intel.com/content/www/us/en/products/details/processors/xeon/scalable.html)를 확인해 주세요.

## 환경 설정
인텔® 제온® 확장 가능 프로세서에서 [🤗 text-generation-inference](https://github.com/huggingface/text-generation-inference)를 사용하려면 다음 단계를 따르세요:

### 인텔 제온 서버에서 로컬 서버 인스턴스 시작:
```bash
model=Intel/neural-chat-7b-v3-3
volume=$PWD/data # share a volume with the Docker container to avoid downloading weights every run

docker run --shm-size 1g -p 8080:80 -v $volume:/data ghcr.io/huggingface/text-generation-inference:1.4 --model-id $model
```


`LLAMA-2`와 같은 제한된 모델의 경우, 위의 도커 실행 명령에 -e HUGGING_FACE_HUB_TOKEN=\<token\>을 유효한 Hugging Face Hub 읽기 토큰과 함께 전달해야 합니다.

접근 토큰을 얻으려면 이 링크 [huggingface token](https://huggingface.co/docs/hub/security-tokens)를 따라가고, `HUGGINGFACEHUB_API_TOKEN` 환경 변수를 토큰으로 내보내세요.

```bash
export HUGGINGFACEHUB_API_TOKEN=<token> 
```


엔드포인트가 작동하는지 확인하기 위해 요청을 보내세요:

```bash
curl localhost:8080/generate -X POST -d '{"inputs":"Which NFL team won the Super Bowl in the 2010 season?","parameters":{"max_new_tokens":128, "do_sample": true}}'   -H 'Content-Type: application/json'
```


자세한 내용은 [text-generation-inference](https://github.com/huggingface/text-generation-inference)를 참조하세요.

## 데이터로 채우기

DB를 예제 데이터로 채우고 싶다면 아래 명령어를 실행할 수 있습니다:
```shell
poetry install
poetry run python ingest.py
```


스크립트는 Nike `nke-10k-2023.pdf`의 Edgar 10k 제출 데이터에서 섹션을 처리하고 Chroma 데이터베이스에 저장합니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package intel-rag-xeon
```


기존 프로젝트에 추가하려면 다음 명령어를 실행하면 됩니다:

```shell
langchain app add intel-rag-xeon
```


그리고 다음 코드를 `server.py` 파일에 추가하세요:
```python
from intel_rag_xeon import chain as xeon_rag_chain

add_routes(app, xeon_rag_chain, path="/intel-rag-xeon")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다. LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다. LangSmith에 가입하려면 [여기](https://smith.langchain.com/)를 클릭하세요. 접근 권한이 없다면 이 섹션을 건너뛸 수 있습니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있다면 다음과 같이 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 FastAPI 앱이 시작되며 서버가 로컬에서 실행됩니다.
[http://localhost:8000](http://localhost:8000)

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있습니다.  
플레이그라운드는 [http://127.0.0.1:8000/intel-rag-xeon/playground](http://127.0.0.1:8000/intel-rag-xeon/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/intel-rag-xeon")
```