---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/minimax.ipynb
description: Minimax는 기업과 개인을 위한 자연어 처리 모델을 제공하는 중국 스타트업입니다. Langchain을 사용하여 Minimax와
  상호작용하는 방법을 보여줍니다.
---

# 미니맥스

[미니맥스](https://api.minimax.chat)는 기업과 개인을 위한 자연어 처리 모델을 제공하는 중국 스타트업입니다.

이 예제는 Langchain을 사용하여 미니맥스와 상호작용하는 방법을 보여줍니다.

# 설정

이 노트북을 실행하려면 [미니맥스 계정](https://api.minimax.chat), [API 키](https://api.minimax.chat/user-center/basic-information/interface-key), 및 [그룹 ID](https://api.minimax.chat/user-center/basic-information)가 필요합니다.

# 단일 모델 호출

```python
<!--IMPORTS:[{"imported": "Minimax", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.minimax.Minimax.html", "title": "Minimax"}]-->
from langchain_community.llms import Minimax
```


```python
# Load the model
minimax = Minimax(minimax_api_key="YOUR_API_KEY", minimax_group_id="YOUR_GROUP_ID")
```


```python
# Prompt the model
minimax("What is the difference between panda and bear?")
```


# 연쇄 모델 호출

```python
# get api_key and group_id: https://api.minimax.chat/user-center/basic-information
# We need `MINIMAX_API_KEY` and `MINIMAX_GROUP_ID`

import os

os.environ["MINIMAX_API_KEY"] = "YOUR_API_KEY"
os.environ["MINIMAX_GROUP_ID"] = "YOUR_GROUP_ID"
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Minimax"}, {"imported": "Minimax", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.minimax.Minimax.html", "title": "Minimax"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Minimax"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import Minimax
from langchain_core.prompts import PromptTemplate
```


```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


```python
llm = Minimax()
```


```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


```python
question = "What NBA team won the Championship in the year Jay Zhou was born?"

llm_chain.run(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)