---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/volcengine_maas/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/volcengine_maas.ipynb
---

# Volc Engine Maas

This notebook provides you with a guide on how to get started with Volc Engine's MaaS llm models.

```python
# Install the package
%pip install --upgrade --quiet  volcengine
```

```python
<!--IMPORTS:[{"imported": "VolcEngineMaasLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.volcengine_maas.VolcEngineMaasLLM.html", "title": "Volc Engine Maas"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "Volc Engine Maas"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Volc Engine Maas"}]-->
from langchain_community.llms import VolcEngineMaasLLM
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import PromptTemplate
```

```python
llm = VolcEngineMaasLLM(volc_engine_maas_ak="your ak", volc_engine_maas_sk="your sk")
```

or you can set access_key and secret_key in your environment variables
```bash
export VOLC_ACCESSKEY=YOUR_AK
export VOLC_SECRETKEY=YOUR_SK
```

```python
chain = PromptTemplate.from_template("给我讲个笑话") | llm | StrOutputParser()
chain.invoke({})
```

```output
'好的，下面是一个笑话：\n\n 大学暑假我配了隐形眼镜，回家给爷爷说，我现在配了隐形眼镜。\n 爷爷让我给他看看，于是，我用小镊子夹了一片给爷爷看。\n 爷爷看完便准备出门，边走还边说：“真高级啊，还真是隐形眼镜！”\n 等爷爷出去后我才发现，我刚没夹起来！'
```

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)