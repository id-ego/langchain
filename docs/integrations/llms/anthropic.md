---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/anthropic.ipynb
description: 이 문서는 LangChain을 사용하여 Anthropic 모델과 상호작용하는 방법을 설명합니다. 설치 및 환경 설정에 대한
  정보를 포함합니다.
sidebar_class_name: hidden
sidebar_label: Anthropic
---

# AnthropicLLM

:::caution
현재 Anthropic 레거시 Claude 2 모델을 [텍스트 완성 모델](/docs/concepts/#llms)로 사용하는 방법에 대한 문서 페이지에 있습니다. 최신의 가장 인기 있는 Anthropic 모델은 [채팅 완성 모델](/docs/concepts/#chat-models)이며, 텍스트 완성 모델은 더 이상 사용되지 않습니다.

대신 [이 페이지](/docs/integrations/chat/anthropic/)를 찾고 계실 것입니다.
:::

이 예제는 LangChain을 사용하여 `Anthropic` 모델과 상호작용하는 방법을 설명합니다.

## 설치

```python
%pip install -qU langchain-anthropic
```


## 환경 설정

[Anthropic](https://console.anthropic.com/settings/keys) API 키를 가져오고 `ANTHROPIC_API_KEY` 환경 변수를 설정해야 합니다:

```python
import os
from getpass import getpass

os.environ["ANTHROPIC_API_KEY"] = getpass()
```


## 사용법

```python
<!--IMPORTS:[{"imported": "AnthropicLLM", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_anthropic.llms.AnthropicLLM.html", "title": "AnthropicLLM"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "AnthropicLLM"}]-->
from langchain_anthropic import AnthropicLLM
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)

model = AnthropicLLM(model="claude-2.1")

chain = prompt | model

chain.invoke({"question": "What is LangChain?"})
```


```output
'\nLangChain is a decentralized blockchain network that leverages AI and machine learning to provide language translation services.'
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)