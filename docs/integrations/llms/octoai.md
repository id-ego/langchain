---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/octoai.ipynb
description: OctoAI는 AI 모델을 애플리케이션에 통합할 수 있는 효율적인 컴퓨팅 서비스를 제공합니다. LangChain을 통해 LLM
  엔드포인트와 상호작용하는 방법을 소개합니다.
---

# OctoAI

[OctoAI](https://docs.octoai.cloud/docs)는 효율적인 컴퓨팅에 쉽게 접근할 수 있도록 하며, 사용자가 선택한 AI 모델을 애플리케이션에 통합할 수 있게 해줍니다. `OctoAI` 컴퓨팅 서비스는 AI 애플리케이션을 쉽게 실행하고 조정하며 확장할 수 있도록 도와줍니다.

이 예제는 LangChain을 사용하여 `OctoAI` [LLM 엔드포인트](https://octoai.cloud/templates)와 상호작용하는 방법을 설명합니다.

## 설정

예제 앱을 실행하려면 두 가지 간단한 단계를 수행해야 합니다:

1. [당신의 OctoAI 계정 페이지](https://octoai.cloud/settings)에서 API 토큰을 받습니다.
2. 아래 코드 셀에 API 키를 붙여넣습니다.

참고: 다른 LLM 모델을 사용하고 싶다면, 모델을 컨테이너화하고 [Python에서 컨테이너 빌드하기](https://octo.ai/docs/bring-your-own-model/advanced-build-a-container-from-scratch-in-python) 및 [컨테이너에서 사용자 정의 엔드포인트 만들기](https://octo.ai/docs/bring-your-own-model/create-custom-endpoints-from-a-container/create-custom-endpoints-from-a-container)를 따라 직접 사용자 정의 OctoAI 엔드포인트를 만들 수 있으며, 그 후 `OCTOAI_API_BASE` 환경 변수를 업데이트하면 됩니다.

```python
import os

os.environ["OCTOAI_API_TOKEN"] = "OCTOAI_API_TOKEN"
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "OctoAI"}, {"imported": "OctoAIEndpoint", "source": "langchain_community.llms.octoai_endpoint", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.octoai_endpoint.OctoAIEndpoint.html", "title": "OctoAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "OctoAI"}]-->
from langchain.chains import LLMChain
from langchain_community.llms.octoai_endpoint import OctoAIEndpoint
from langchain_core.prompts import PromptTemplate
```


## 예제

```python
template = """Below is an instruction that describes a task. Write a response that appropriately completes the request.\n Instruction:\n{question}\n Response: """
prompt = PromptTemplate.from_template(template)
```


```python
llm = OctoAIEndpoint(
    model_name="llama-2-13b-chat-fp16",
    max_tokens=200,
    presence_penalty=0,
    temperature=0.1,
    top_p=0.9,
)
```


```python
question = "Who was Leonardo da Vinci?"

chain = prompt | llm

print(chain.invoke(question))
```


레오나르도 다 빈치는 진정한 르네상스 인물이었습니다. 그는 1452년 이탈리아 빈치에서 태어났으며, 예술, 과학, 공학, 수학 등 다양한 분야에서의 작업으로 알려져 있습니다. 그는 역사상 가장 위대한 화가 중 한 명으로 여겨지며, 그의 가장 유명한 작품으로는 모나리자와 최후의 만찬이 있습니다. 그의 예술 외에도, 다 빈치는 공학과 해부학에 중요한 기여를 했으며, 그의 기계 및 발명 디자인은 그의 시대를 수세기 앞서갔습니다. 그는 또한 그의 생각과 아이디어에 대한 귀중한 통찰을 제공하는 방대한 일지와 그림으로도 알려져 있습니다. 다 빈치의 유산은 오늘날 전 세계의 예술가, 과학자 및 사상가들에게 영감을 주고 영향을 미치고 있습니다.

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)