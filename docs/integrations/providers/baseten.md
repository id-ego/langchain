---
description: Baseten은 ML 모델을 효율적으로 배포하고 제공하는 인프라를 제공하는 플랫폼입니다. GPU를 활용하여 맞춤형 모델을 실행할
  수 있습니다.
---

# Baseten

> [Baseten](https://baseten.co)는 ML 모델을 성능 좋고, 확장 가능하며, 비용 효율적으로 배포하고 제공하는 데 필요한 모든 인프라를 제공하는 공급자입니다.

> 모델 추론 플랫폼으로서, `Baseten`은 LangChain 생태계의 `Provider`입니다. 현재 `Baseten` 통합은 단일 `Component`, LLM을 구현하고 있지만, 더 많은 것이 계획되어 있습니다!

> `Baseten`은 Llama 2 또는 Mistral과 같은 오픈 소스 모델을 실행하고 전용 GPU에서 독점 또는 미세 조정된 모델을 실행할 수 있게 해줍니다. OpenAI와 같은 공급자에 익숙하다면, Baseten 사용에는 몇 가지 차이점이 있습니다:

> * 토큰당 지불하는 대신, 사용한 GPU 분당 지불합니다.
> * Baseten의 모든 모델은 최대한의 사용자 정의를 위해 [Truss](https://truss.baseten.co/welcome), 우리의 오픈 소스 모델 패키징 프레임워크를 사용합니다.
> * 일부 [OpenAI ChatCompletions 호환 모델](https://docs.baseten.co/api-reference/openai)이 있지만, `Truss`를 사용하여 자신의 I/O 사양을 정의할 수 있습니다.

> 모델 ID 및 배포에 대해 [자세히 알아보세요](https://docs.baseten.co/deploy/lifecycle).

> Baseten에 대한 자세한 내용은 [Baseten 문서](https://docs.baseten.co/)에서 확인하세요.

## 설치 및 설정

LangChain과 함께 Baseten 모델을 사용하려면 두 가지가 필요합니다:

- [Baseten 계정](https://baseten.co)
- [API 키](https://docs.baseten.co/observability/api-keys)

API 키를 `BASETEN_API_KEY`라는 환경 변수로 내보내세요.

```sh
export BASETEN_API_KEY="paste_your_api_key_here"
```


## LLMs

[사용 예시](/docs/integrations/llms/baseten)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "Baseten", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.baseten.Baseten.html", "title": "Baseten"}]-->
from langchain_community.llms import Baseten
```