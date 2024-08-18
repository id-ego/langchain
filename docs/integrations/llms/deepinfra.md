---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/deepinfra.ipynb
description: DeepInfra는 다양한 LLM 및 임베딩 모델에 대한 서버리스 추론 서비스를 제공하며, LangChain과의 통합 방법을
  안내합니다.
---

# DeepInfra

[DeepInfra](https://deepinfra.com/?utm_source=langchain)는 다양한 [LLM](https://deepinfra.com/models?utm_source=langchain) 및 [임베딩 모델](https://deepinfra.com/models?type=embeddings&utm_source=langchain)에 대한 접근을 제공하는 서버리스 추론 서비스입니다. 이 노트북에서는 DeepInfra와 함께 LangChain을 사용하는 방법을 설명합니다.

## 환경 API 키 설정
DeepInfra에서 API 키를 받아야 합니다. [로그인](https://deepinfra.com/login?from=%2Fdash)하고 새 토큰을 받아야 합니다.

서버리스 GPU 컴퓨팅을 1시간 무료로 제공받아 다양한 모델을 테스트할 수 있습니다. (자세한 내용은 [여기](https://github.com/deepinfra/deepctl#deepctl) 참조)
`deepctl auth token`으로 토큰을 출력할 수 있습니다.

```python
# get a new token: https://deepinfra.com/login?from=%2Fdash

from getpass import getpass

DEEPINFRA_API_TOKEN = getpass()
```

```output
 ········
```


```python
import os

os.environ["DEEPINFRA_API_TOKEN"] = DEEPINFRA_API_TOKEN
```


## DeepInfra 인스턴스 생성
모델 배포를 관리하기 위해 오픈 소스 [deepctl 도구](https://github.com/deepinfra/deepctl#deepctl)를 사용할 수도 있습니다. 사용 가능한 매개변수 목록은 [여기](https://deepinfra.com/databricks/dolly-v2-12b#API)에서 확인할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "DeepInfra", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.deepinfra.DeepInfra.html", "title": "DeepInfra"}]-->
from langchain_community.llms import DeepInfra

llm = DeepInfra(model_id="meta-llama/Llama-2-70b-chat-hf")
llm.model_kwargs = {
    "temperature": 0.7,
    "repetition_penalty": 1.2,
    "max_new_tokens": 250,
    "top_p": 0.9,
}
```


```python
# run inferences directly via wrapper
llm("Who let the dogs out?")
```


```output
'This is a question that has puzzled many people'
```


```python
# run streaming inference
for chunk in llm.stream("Who let the dogs out?"):
    print(chunk)
```


```output
 Will
 Smith
.
```


## 프롬프트 템플릿 생성
질문과 답변을 위한 프롬프트 템플릿을 생성하겠습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "DeepInfra"}]-->
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


## LLMChain 시작

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "DeepInfra"}]-->
from langchain.chains import LLMChain

llm_chain = LLMChain(prompt=prompt, llm=llm)
```


## LLMChain 실행
질문을 제공하고 LLMChain을 실행합니다.

```python
question = "Can penguins reach the North pole?"

llm_chain.run(question)
```


```output
"Penguins are found in Antarctica and the surrounding islands, which are located at the southernmost tip of the planet. The North Pole is located at the northernmost tip of the planet, and it would be a long journey for penguins to get there. In fact, penguins don't have the ability to fly or migrate over such long distances. So, no, penguins cannot reach the North Pole. "
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)