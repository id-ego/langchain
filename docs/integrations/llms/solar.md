---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/solar.ipynb
description: 이 문서는 Solar LLM의 커뮤니티 통합이 더 이상 지원되지 않음을 알리며, 대신 ChatUpstage를 사용하도록 안내합니다.
---

# 태양

*이 커뮤니티 통합은 더 이상 지원되지 않습니다. 대신 [`ChatUpstage`](../../chat/upstage)를 사용하여 채팅 모델 커넥터를 통해 Solar LLM에 접근해야 합니다.*

```python
<!--IMPORTS:[{"imported": "Solar", "source": "langchain_community.llms.solar", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.solar.Solar.html", "title": "Solar"}]-->
import os

from langchain_community.llms.solar import Solar

os.environ["SOLAR_API_KEY"] = "SOLAR_API_KEY"
llm = Solar()
llm.invoke("tell me a story?")
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Solar"}, {"imported": "Solar", "source": "langchain_community.llms.solar", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.solar.Solar.html", "title": "Solar"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Solar"}]-->
from langchain.chains import LLMChain
from langchain_community.llms.solar import Solar
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)

llm = Solar()
llm_chain = LLMChain(prompt=prompt, llm=llm)

question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)