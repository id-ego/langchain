---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/tongyi.ipynb
description: Tongyi Qwen은 Alibaba의 Damo Academy에서 개발한 대규모 언어 모델로, 자연어 이해를 통해 사용자 요구를
  지원합니다.
---

# 통이 쿼엔
통이 쿼엔은 알리바바 다모 아카데미에서 개발한 대규모 언어 모델입니다. 자연어 이해 및 의미 분석을 통해 사용자 입력에 기반하여 사용자 의도를 이해할 수 있습니다. 다양한 도메인과 작업에서 사용자에게 서비스와 지원을 제공합니다. 명확하고 상세한 지침을 제공함으로써 기대에 더 잘 부합하는 결과를 얻을 수 있습니다.

## 설정하기

```python
# Install the package
%pip install --upgrade --quiet  langchain-community dashscope
```


```python
# Get a new token: https://help.aliyun.com/document_detail/611472.html?spm=a2c4g.2399481.0.0
from getpass import getpass

DASHSCOPE_API_KEY = getpass()
```

```output
 ········
```


```python
import os

os.environ["DASHSCOPE_API_KEY"] = DASHSCOPE_API_KEY
```


```python
<!--IMPORTS:[{"imported": "Tongyi", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.tongyi.Tongyi.html", "title": "Tongyi Qwen"}]-->
from langchain_community.llms import Tongyi
```


```python
Tongyi().invoke("What NFL team won the Super Bowl in the year Justin Bieber was born?")
```


```output
'Justin Bieber was born on March 1, 1994. The Super Bowl that took place in the same year was Super Bowl XXVIII, which was played on January 30, 1994. The winner of that Super Bowl was the Dallas Cowboys, who defeated the Buffalo Bills with a score of 30-13.'
```


## 체인에서 사용하기

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Tongyi Qwen"}]-->
from langchain_core.prompts import PromptTemplate
```


```python
llm = Tongyi()
```


```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


```python
chain = prompt | llm
```


```python
question = "What NFL team won the Super Bowl in the year Justin Bieber was born?"

chain.invoke({"question": question})
```


```output
'Justin Bieber was born on March 1, 1994. The Super Bowl that took place in the same calendar year was Super Bowl XXVIII, which was played on January 30, 1994. The winner of Super Bowl XXVIII was the Dallas Cowboys, who defeated the Buffalo Bills with a score of 30-13.'
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)