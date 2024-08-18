---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/bedrock.ipynb
description: Amazon Bedrock은 다양한 AI 회사의 고성능 기초 모델을 제공하는 완전 관리형 서비스입니다. 안전하고 책임감 있는
  AI 애플리케이션 구축을 지원합니다.
---

# 베드록

:::caution
현재 Amazon Bedrock 모델을 [텍스트 완성 모델](/docs/concepts/#llms)로 사용하는 페이지에 있습니다. Bedrock에서 사용할 수 있는 많은 인기 모델은 [채팅 완성 모델](/docs/concepts/#chat-models)입니다.

대신 [이 페이지](/docs/integrations/chat/bedrock/)를 찾고 있을 수 있습니다.
:::

> [Amazon Bedrock](https://aws.amazon.com/bedrock/)는 `AI21 Labs`, `Anthropic`, `Cohere`, `Meta`, `Stability AI`, `Amazon`과 같은 주요 AI 회사의 고성능 기초 모델(FMs)을 단일 API를 통해 제공하는 완전 관리형 서비스로, 보안, 프라이버시 및 책임 있는 AI로 생성 AI 애플리케이션을 구축하는 데 필요한 광범위한 기능을 제공합니다. `Amazon Bedrock`을 사용하면 사용 사례에 맞는 최고의 FMs을 쉽게 실험하고 평가할 수 있으며, 미세 조정 및 `Retrieval Augmented Generation`(`RAG`)과 같은 기술을 사용하여 자신의 데이터로 개인화하고, 기업 시스템 및 데이터 소스를 사용하여 작업을 실행하는 에이전트를 구축할 수 있습니다. `Amazon Bedrock`은 서버리스이므로 인프라를 관리할 필요가 없으며, 이미 익숙한 AWS 서비스를 사용하여 생성 AI 기능을 안전하게 통합하고 배포할 수 있습니다.

```python
%pip install --upgrade --quiet langchain_aws
```


```python
from langchain_aws import BedrockLLM

llm = BedrockLLM(
    credentials_profile_name="bedrock-admin", model_id="amazon.titan-text-express-v1"
)
```


### 맞춤형 모델

```python
custom_llm = BedrockLLM(
    credentials_profile_name="bedrock-admin",
    provider="cohere",
    model_id="<Custom model ARN>",  # ARN like 'arn:aws:bedrock:...' obtained via provisioning the custom model
    model_kwargs={"temperature": 1},
    streaming=True,
)

custom_llm.invoke(input="What is the recipe of mayonnaise?")
```


## Amazon Bedrock을 위한 가드레일

[Amazon Bedrock을 위한 가드레일](https://aws.amazon.com/bedrock/guardrails/)은 사용자 입력 및 모델 응답을 사용 사례 특정 정책에 따라 평가하고, 기본 모델에 관계없이 추가적인 안전 장치를 제공합니다. 가드레일은 Anthropic Claude, Meta Llama 2, Cohere Command, AI21 Labs Jurassic 및 Amazon Titan Text를 포함한 모델 전반에 적용될 수 있으며, 미세 조정된 모델에도 적용됩니다.  
**참고**: Amazon Bedrock을 위한 가드레일은 현재 미리보기 상태이며 일반적으로 사용할 수 없습니다. 이 기능에 접근하고 싶으시면 평소 AWS 지원 연락처를 통해 문의하시기 바랍니다.  
이 섹션에서는 추적 기능을 포함한 특정 가드레일이 설정된 Bedrock 언어 모델을 설정할 것입니다.

```python
<!--IMPORTS:[{"imported": "AsyncCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.AsyncCallbackHandler.html", "title": "Bedrock"}]-->
from typing import Any

from langchain_core.callbacks import AsyncCallbackHandler


class BedrockAsyncCallbackHandler(AsyncCallbackHandler):
    # Async callback handler that can be used to handle callbacks from langchain.

    async def on_llm_error(self, error: BaseException, **kwargs: Any) -> Any:
        reason = kwargs.get("reason")
        if reason == "GUARDRAIL_INTERVENED":
            print(f"Guardrails: {kwargs}")


# Guardrails for Amazon Bedrock with trace
llm = BedrockLLM(
    credentials_profile_name="bedrock-admin",
    model_id="<Model_ID>",
    model_kwargs={},
    guardrails={"id": "<Guardrail_ID>", "version": "<Version>", "trace": True},
    callbacks=[BedrockAsyncCallbackHandler()],
)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)