---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/tongyi/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/tongyi.ipynb
---

# Tongyi Qwen
Tongyi Qwen is a large-scale language model developed by Alibaba's Damo Academy. It is capable of understanding user intent through natural language understanding and semantic analysis, based on user input in natural language. It provides services and assistance to users in different domains and tasks. By providing clear and detailed instructions, you can obtain results that better align with your expectations.

## Setting up

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

## Using in a chain

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

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)