---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/konko.ipynb
description: Konko API는 애플리케이션 개발자가 LLM 선택, 통합, 미세 조정 및 배포를 통해 효율적으로 애플리케이션을 구축할 수
  있도록 지원합니다.
sidebar_label: Konko
---

# Konko

> [Konko](https://www.konko.ai/) API는 애플리케이션 개발자를 돕기 위해 설계된 완전 관리형 웹 API입니다:

1. **적합한** 오픈 소스 또는 독점 LLM을 선택합니다.
2. **선도적인** 애플리케이션 프레임워크 및 완전 관리형 API와의 통합을 통해 애플리케이션을 더 빠르게 구축합니다.
3. **비용의 일부로** 업계 최고의 성능을 달성하기 위해 더 작은 오픈 소스 LLM을 미세 조정합니다.
4. **보안, 개인 정보, 처리량 및 지연 SLA**를 충족하는 프로덕션 규모의 API를 배포하며, Konko AI의 SOC 2 준수 다중 클라우드 인프라를 사용하여 인프라 설정이나 관리 없이 가능합니다.

이 예제는 LangChain을 사용하여 `Konko` 완료 [모델](https://docs.konko.ai/docs/list-of-models#konko-hosted-models-for-completion)과 상호작용하는 방법을 설명합니다.

이 노트북을 실행하려면 Konko API 키가 필요합니다. 웹 앱에 로그인하여 [API 키를 생성](https://platform.konko.ai/settings/api-keys)하여 모델에 접근하세요.

#### 환경 변수 설정

1. 다음에 대한 환경 변수를 설정할 수 있습니다:
   1. KONKO_API_KEY (필수)
   2. OPENAI_API_KEY (선택)
2. 현재 셸 세션에서 export 명령을 사용하세요:

```shell
export KONKO_API_KEY={your_KONKO_API_KEY_here}
export OPENAI_API_KEY={your_OPENAI_API_KEY_here} #Optional
```


## 모델 호출

[Konko 개요 페이지](https://docs.konko.ai/docs/list-of-models)에서 모델을 찾으세요.

Konko 인스턴스에서 실행 중인 모델 목록을 찾는 또 다른 방법은 이 [엔드포인트](https://docs.konko.ai/reference/get-models)를 통해 가능합니다.

여기서 모델을 초기화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "Konko", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.konko.Konko.html", "title": "Konko"}]-->
from langchain_community.llms import Konko

llm = Konko(model="mistralai/mistral-7b-v0.1", temperature=0.1, max_tokens=128)

input_ = """You are a helpful assistant. Explain Big Bang Theory briefly."""
print(llm.invoke(input_))
```

```output


Answer:
The Big Bang Theory is a theory that explains the origin of the universe. According to the theory, the universe began with a single point of infinite density and temperature. This point is called the singularity. The singularity exploded and expanded rapidly. The expansion of the universe is still continuing.
The Big Bang Theory is a theory that explains the origin of the universe. According to the theory, the universe began with a single point of infinite density and temperature. This point is called the singularity. The singularity exploded and expanded rapidly. The expansion of the universe is still continuing.

Question
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)