---
description: AWS Bedrock 서비스와 연결하여 Anthropic Claude로 텍스트 생성 및 Amazon Titan으로 텍스트 임베딩을
  사용하는 RAG 템플릿입니다.
---

# rag-aws-bedrock

이 템플릿은 관리형 서버인 AWS Bedrock 서비스와 연결하도록 설계되었습니다. 이 서비스는 일련의 기초 모델을 제공합니다.

주로 텍스트 생성을 위해 `Anthropic Claude`를 사용하고, 텍스트 임베딩을 위해 `Amazon Titan`을 사용하며, FAISS를 벡터 저장소로 활용합니다.

RAG 파이프라인에 대한 추가 정보는 [이 노트북](https://github.com/aws-samples/amazon-bedrock-workshop/blob/main/03_QuestionAnswering/01_qa_w_rag_claude.ipynb)을 참조하세요.

## 환경 설정

이 패키지를 사용하기 전에 `boto3`가 AWS 계정과 함께 작동하도록 구성되었는지 확인하세요.

`boto3`를 설정하고 구성하는 방법에 대한 자세한 내용은 [이 페이지](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html#configuration)를 방문하세요.

또한 FAISS 벡터 저장소와 작업하기 위해 `faiss-cpu` 패키지를 설치해야 합니다:

```bash
pip install faiss-cpu
```


다음 환경 변수를 설정하여 AWS 프로필 및 지역을 반영해야 합니다(기본 AWS 프로필 및 `us-east-1` 지역을 사용하지 않는 경우):

* `AWS_DEFAULT_REGION`
* `AWS_PROFILE`

## 사용법

먼저, LangChain CLI를 설치하세요:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이것을 유일한 패키지로 설치하려면:

```shell
langchain app new my-app --package rag-aws-bedrock
```


기존 프로젝트에 이 패키지를 추가하려면:

```shell
langchain app add rag-aws-bedrock
```


그런 다음 `server.py` 파일에 다음 코드를 추가하세요:
```python
from rag_aws_bedrock import chain as rag_aws_bedrock_chain

add_routes(app, rag_aws_bedrock_chain, path="/rag-aws-bedrock")
```


(선택 사항) LangSmith에 접근할 수 있는 경우, LangChain 애플리케이션을 추적, 모니터링 및 디버깅하도록 구성할 수 있습니다. 접근할 수 없는 경우 이 섹션을 건너뛰어도 됩니다.

```shell
export LANGCHAIN_TRACING_V2=true
export LANGCHAIN_API_KEY=<your-api-key>
export LANGCHAIN_PROJECT=<your-project>  # if not specified, defaults to "default"
```


이 디렉토리 내에 있는 경우 다음을 통해 LangServe 인스턴스를 직접 시작할 수 있습니다:

```shell
langchain serve
```


이렇게 하면 [http://localhost:8000](http://localhost:8000)에서 로컬로 실행되는 서버와 함께 FastAPI 앱이 시작됩니다.

모든 템플릿은 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)에서 확인할 수 있으며, 플레이그라운드는 [http://127.0.0.1:8000/rag-aws-bedrock/playground](http://127.0.0.1:8000/rag-aws-bedrock/playground)에서 접근할 수 있습니다.

코드에서 템플릿에 접근하려면:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/rag-aws-bedrock")
```