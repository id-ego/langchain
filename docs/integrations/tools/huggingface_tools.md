---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/huggingface_tools.ipynb
description: HuggingFace Hub 도구를 사용하여 텍스트 I/O를 지원하는 도구를 직접 로드하는 방법에 대한 안내입니다.
---

# HuggingFace Hub 도구

> 텍스트 I/O를 지원하는 [Huggingface 도구](https://huggingface.co/docs/transformers/v4.29.0/en/custom_tools)는 `load_huggingface_tool` 함수를 사용하여 직접 로드할 수 있습니다.

```python
# Requires transformers>=4.29.0 and huggingface_hub>=0.14.1
%pip install --upgrade --quiet  transformers huggingface_hub > /dev/null
```


```python
%pip install --upgrade --quiet  langchain-community
```


```python
<!--IMPORTS:[{"imported": "load_huggingface_tool", "source": "langchain_community.agent_toolkits.load_tools", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_huggingface_tool.html", "title": "HuggingFace Hub Tools"}]-->
from langchain_community.agent_toolkits.load_tools import load_huggingface_tool

tool = load_huggingface_tool("lysandre/hf-model-downloads")

print(f"{tool.name}: {tool.description}")
```

```output
model_download_counter: This is a tool that returns the most downloaded model of a given task on the Hugging Face Hub. It takes the name of the category (such as text-classification, depth-estimation, etc), and returns the name of the checkpoint
```


```python
tool.run("text-classification")
```


```output
'facebook/bart-large-mnli'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)