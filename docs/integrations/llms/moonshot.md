---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/moonshot.ipynb
description: MoonshotChat은 Moonshot의 LLM 서비스를 LangChain을 통해 활용하는 방법을 설명하는 문서입니다.
---

# MoonshotChat

[Moonshot](https://platform.moonshot.cn/)은 기업과 개인을 위한 LLM 서비스를 제공하는 중국 스타트업입니다.

이 예제는 LangChain을 사용하여 Moonshot과 상호작용하는 방법을 설명합니다.

```python
<!--IMPORTS:[{"imported": "Moonshot", "source": "langchain_community.llms.moonshot", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.moonshot.Moonshot.html", "title": "MoonshotChat"}]-->
from langchain_community.llms.moonshot import Moonshot
```


```python
import os

# Generate your api key from: https://platform.moonshot.cn/console/api-keys
os.environ["MOONSHOT_API_KEY"] = "MOONSHOT_API_KEY"
```


```python
llm = Moonshot()
# or use a specific model
# Available models: https://platform.moonshot.cn/docs
# llm = Moonshot(model="moonshot-v1-128k")
```


```python
# Prompt the model
llm.invoke("What is the difference between panda and bear?")
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)