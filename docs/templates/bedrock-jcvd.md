---
description: 이 문서는 Amazon Bedrock에서 Anthropic의 Claude를 사용하여 JCVD처럼 행동하는 LangChain
  템플릿에 대한 개요와 환경 설정을 제공합니다.
---

# Bedrock JCVD 🕺🥋

## 개요

LangChain 템플릿으로 [Amazon Bedrock의 Anthropic의 Claude](https://aws.amazon.com/bedrock/claude/)를 사용하여 JCVD처럼 동작합니다.

> 나는 챗봇의 프레드 아스테어입니다! 🕺

'

## 환경 설정

### AWS 자격 증명

이 템플릿은 [Boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html), Python용 AWS SDK를 사용하여 [Amazon Bedrock](https://aws.amazon.com/bedrock/)을 호출합니다. 요청을 하려면 AWS 자격 증명 *및* AWS 리전을 구성해야 합니다.

> 이를 수행하는 방법에 대한 정보는 [AWS Boto3 문서](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html) (개발자 가이드 > 자격 증명)를 참조하세요.

### 기본 모델

기본적으로 이 템플릿은 [Anthropic의 Claude v2](https://aws.amazon.com/about-aws/whats-new/2023/08/claude-2-foundation-model-anthropic-amazon-bedrock/) (`anthropic.claude-v2`)를 사용합니다.

> 특정 모델에 대한 접근을 요청하려면 [Amazon Bedrock 사용자 가이드](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html) (모델 접근)를 확인하세요.

다른 모델을 사용하려면 환경 변수 `BEDROCK_JCVD_MODEL_ID`를 설정하세요. 기본 모델 목록은 [Amazon Bedrock 사용자 가이드](https://docs.aws.amazon.com/bedrock/latest/userguide/model-ids-arns.html) (API 사용 > API 작업 > 추론 실행 > 기본 모델 ID)에서 확인할 수 있습니다.

> 사용 가능한 모델의 전체 목록(기본 및 [사용자 정의 모델](https://docs.aws.amazon.com/bedrock/latest/userguide/custom-models.html) 포함)은 [Amazon Bedrock 콘솔](https://docs.aws.amazon.com/bedrock/latest/userguide/using-console.html)에서 **기본 모델** 아래 또는 [`aws bedrock list-foundation-models`](https://docs.aws.amazon.com/cli/latest/reference/bedrock/list-foundation-models.html) 호출을 통해 확인할 수 있습니다.

## 사용법

이 패키지를 사용하려면 먼저 LangChain CLI를 설치해야 합니다:

```shell
pip install -U langchain-cli
```


새 LangChain 프로젝트를 생성하고 이를 유일한 패키지로 설치하려면 다음과 같이 할 수 있습니다:

```shell
langchain app new my-app --package bedrock-jcvd
```


기존 프로젝트에 추가하려면 다음을 실행하면 됩니다:

```shell
langchain app add bedrock-jcvd
```


그리고 `server.py` 파일에 다음 코드를 추가하세요:
```python
from bedrock_jcvd import chain as bedrock_jcvd_chain

add_routes(app, bedrock_jcvd_chain, path="/bedrock-jcvd")
```


(선택 사항) 이제 LangSmith를 구성해 보겠습니다.
LangSmith는 LangChain 애플리케이션을 추적, 모니터링 및 디버깅하는 데 도움을 줄 것입니다.
LangSmith에 [여기서](https://smith.langchain.com/) 가입할 수 있습니다.
접근 권한이 없으면 이 섹션을 건너뛸 수 있습니다.

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

또한 [http://127.0.0.1:8000/bedrock-jcvd/playground](http://127.0.0.1:8000/bedrock-jcvd/playground)에서 플레이그라운드에 접근할 수 있습니다.