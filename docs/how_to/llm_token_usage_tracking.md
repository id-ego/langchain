---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/llm_token_usage_tracking.ipynb
description: LLM의 토큰 사용량을 추적하여 비용을 계산하는 방법을 안내하는 가이드입니다. LangChain 모델 호출에서 정보를 얻는
  방법을 설명합니다.
---

# LLM의 토큰 사용량 추적 방법

토큰 사용량을 추적하여 비용을 계산하는 것은 앱을 프로덕션에 배포하는 데 중요한 부분입니다. 이 가이드는 LangChain 모델 호출에서 이 정보를 얻는 방법을 설명합니다.

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:

- [LLMs](/docs/concepts/#llms)
:::

## LangSmith 사용하기

LLM 애플리케이션에서 토큰 사용량을 추적하는 데 [LangSmith](https://www.langchain.com/langsmith)를 사용할 수 있습니다. [LangSmith 빠른 시작 가이드](https://docs.smith.langchain.com/)를 참조하세요.

## 콜백 사용하기

여러 호출에 걸쳐 토큰 사용량을 추적할 수 있는 API 특정 콜백 컨텍스트 관리자가 있습니다. 특정 모델에 대해 이러한 통합이 가능한지 확인해야 합니다.

모델에 대해 이러한 통합이 불가능한 경우, [OpenAI 콜백 관리자](https://api.python.langchain.com/en/latest/_modules/langchain_community/callbacks/openai_info.html#OpenAICallbackHandler)의 구현을 조정하여 사용자 정의 콜백 관리자를 만들 수 있습니다.

### OpenAI

먼저 단일 Chat 모델 호출에 대한 토큰 사용량을 추적하는 매우 간단한 예를 살펴보겠습니다.

:::danger

콜백 핸들러는 현재 레거시 언어 모델(예: `langchain_openai.OpenAI`)에 대한 스트리밍 토큰 수를 지원하지 않습니다. 스트리밍 컨텍스트에서 지원을 원하시면 채팅 모델에 대한 해당 가이드를 [여기](/docs/how_to/chat_token_usage_tracking)에서 참조하세요.

:::

### 단일 호출

```python
<!--IMPORTS:[{"imported": "get_openai_callback", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.manager.get_openai_callback.html", "title": "How to track token usage for LLMs"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to track token usage for LLMs"}]-->
from langchain_community.callbacks import get_openai_callback
from langchain_openai import OpenAI

llm = OpenAI(model_name="gpt-3.5-turbo-instruct")

with get_openai_callback() as cb:
    result = llm.invoke("Tell me a joke")
    print(result)
    print("---")
print()

print(f"Total Tokens: {cb.total_tokens}")
print(f"Prompt Tokens: {cb.prompt_tokens}")
print(f"Completion Tokens: {cb.completion_tokens}")
print(f"Total Cost (USD): ${cb.total_cost}")
```

```output


Why don't scientists trust atoms?

Because they make up everything.
---

Total Tokens: 18
Prompt Tokens: 4
Completion Tokens: 14
Total Cost (USD): $3.4e-05
```

### 여러 호출

컨텍스트 관리자 내부의 모든 것이 추적됩니다. 다음은 체인에 대한 여러 호출을 순차적으로 추적하는 데 사용하는 예입니다. 이는 여러 단계를 사용할 수 있는 에이전트에도 적용됩니다.

```python
<!--IMPORTS:[{"imported": "get_openai_callback", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.manager.get_openai_callback.html", "title": "How to track token usage for LLMs"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to track token usage for LLMs"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to track token usage for LLMs"}]-->
from langchain_community.callbacks import get_openai_callback
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI

llm = OpenAI(model_name="gpt-3.5-turbo-instruct")

template = PromptTemplate.from_template("Tell me a joke about {topic}")
chain = template | llm

with get_openai_callback() as cb:
    response = chain.invoke({"topic": "birds"})
    print(response)
    response = chain.invoke({"topic": "fish"})
    print("--")
    print(response)


print()
print("---")
print(f"Total Tokens: {cb.total_tokens}")
print(f"Prompt Tokens: {cb.prompt_tokens}")
print(f"Completion Tokens: {cb.completion_tokens}")
print(f"Total Cost (USD): ${cb.total_cost}")
```

```output


Why did the chicken go to the seance?

To talk to the other side of the road!
--


Why did the fish need a lawyer?

Because it got caught in a net!

---
Total Tokens: 50
Prompt Tokens: 12
Completion Tokens: 38
Total Cost (USD): $9.400000000000001e-05
```

## 스트리밍

:::danger

`get_openai_callback`는 현재 레거시 언어 모델(예: `langchain_openai.OpenAI`)에 대한 스트리밍 토큰 수를 지원하지 않습니다. 스트리밍 컨텍스트에서 토큰을 정확하게 계산하려면 여러 가지 옵션이 있습니다:

- [이 가이드](/docs/how_to/chat_token_usage_tracking)에서 설명한 대로 채팅 모델을 사용하세요;
- 적절한 토크나이저를 사용하여 토큰을 계산하는 [사용자 정의 콜백 핸들러](/docs/how_to/custom_callbacks/)를 구현하세요;
- [LangSmith](https://www.langchain.com/langsmith)와 같은 모니터링 플랫폼을 사용하세요.
:::

레거시 언어 모델을 스트리밍 컨텍스트에서 사용할 때 토큰 수는 업데이트되지 않음을 유의하세요:

```python
<!--IMPORTS:[{"imported": "get_openai_callback", "source": "langchain_community.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.manager.get_openai_callback.html", "title": "How to track token usage for LLMs"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to track token usage for LLMs"}]-->
from langchain_community.callbacks import get_openai_callback
from langchain_openai import OpenAI

llm = OpenAI(model_name="gpt-3.5-turbo-instruct")

with get_openai_callback() as cb:
    for chunk in llm.stream("Tell me a joke"):
        print(chunk, end="", flush=True)
    print(result)
    print("---")
print()

print(f"Total Tokens: {cb.total_tokens}")
print(f"Prompt Tokens: {cb.prompt_tokens}")
print(f"Completion Tokens: {cb.completion_tokens}")
print(f"Total Cost (USD): ${cb.total_cost}")
```

```output


Why don't scientists trust atoms?

Because they make up everything!

Why don't scientists trust atoms?

Because they make up everything.
---

Total Tokens: 0
Prompt Tokens: 0
Completion Tokens: 0
Total Cost (USD): $0.0
```