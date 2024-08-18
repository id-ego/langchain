---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/gooseai.ipynb
description: GooseAI는 API를 통해 제공되는 완전 관리형 NLP 서비스입니다. 이 문서는 GooseAI와 Langchain 사용
  방법을 설명합니다.
---

# GooseAI

`GooseAI`는 API를 통해 제공되는 완전 관리형 NLP-as-a-Service입니다. GooseAI는 [이 모델들](https://goose.ai/docs/models)에 대한 접근을 제공합니다.

이 노트북은 [GooseAI](https://goose.ai/)와 함께 Langchain을 사용하는 방법을 설명합니다.

## Install openai
`GooseAI` API를 사용하려면 `openai` 패키지가 필요합니다. `pip install openai`를 사용하여 `openai`를 설치하세요.

```python
%pip install --upgrade --quiet  langchain-openai
```


## Imports

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "GooseAI"}, {"imported": "GooseAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.gooseai.GooseAI.html", "title": "GooseAI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "GooseAI"}]-->
import os

from langchain.chains import LLMChain
from langchain_community.llms import GooseAI
from langchain_core.prompts import PromptTemplate
```


## Set the Environment API Key
GooseAI에서 API 키를 받아야 합니다. 다양한 모델을 테스트하기 위해 $10의 무료 크레딧이 제공됩니다.

```python
from getpass import getpass

GOOSEAI_API_KEY = getpass()
```


```python
os.environ["GOOSEAI_API_KEY"] = GOOSEAI_API_KEY
```


## Create the GooseAI instance
모델 이름, 생성된 최대 토큰 수, 온도 등과 같은 다양한 매개변수를 지정할 수 있습니다.

```python
llm = GooseAI()
```


## Create a Prompt Template
질문과 답변을 위한 프롬프트 템플릿을 생성할 것입니다.

```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


## Initiate the LLMChain

```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


## Run the LLMChain
질문을 제공하고 LLMChain을 실행하세요.

```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```


## Related

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)