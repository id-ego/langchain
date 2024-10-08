---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/sparkllm/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/sparkllm.ipynb
---

# SparkLLM
[SparkLLM](https://xinghuo.xfyun.cn/spark) is a large-scale cognitive model independently developed by iFLYTEK.
It has cross-domain knowledge and language understanding ability by learning a large amount of texts, codes and images.
It can understand and perform tasks based on natural dialogue.

## Prerequisite
- Get SparkLLM's app_id, api_key and api_secret from [iFlyTek SparkLLM API Console](https://console.xfyun.cn/services/bm3) (for more info, see [iFlyTek SparkLLM Intro](https://xinghuo.xfyun.cn/sparkapi) ), then set environment variables `IFLYTEK_SPARK_APP_ID`, `IFLYTEK_SPARK_API_KEY` and `IFLYTEK_SPARK_API_SECRET` or pass parameters when creating `ChatSparkLLM` as the demo above.

## Use SparkLLM

```python
import os

os.environ["IFLYTEK_SPARK_APP_ID"] = "app_id"
os.environ["IFLYTEK_SPARK_API_KEY"] = "api_key"
os.environ["IFLYTEK_SPARK_API_SECRET"] = "api_secret"
```

```python
<!--IMPORTS:[{"imported": "SparkLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.sparkllm.SparkLLM.html", "title": "SparkLLM"}]-->
from langchain_community.llms import SparkLLM

# Load the model
llm = SparkLLM()

res = llm.invoke("What's your name?")
print(res)
```
```output
/Users/liugddx/code/langchain/libs/core/langchain_core/_api/deprecation.py:117: LangChainDeprecationWarning: The function `__call__` was deprecated in LangChain 0.1.7 and will be removed in 0.2.0. Use invoke instead.
  warn_deprecated(
``````output
My name is iFLYTEK Spark. How can I assist you today?
```

```python
res = llm.generate(prompts=["hello!"])
res
```

```output
LLMResult(generations=[[Generation(text='Hello! How can I assist you today?')]], llm_output=None, run=[RunInfo(run_id=UUID('d8cdcd41-a698-4cbf-a28d-e74f9cd2037b'))])
```

```python
for res in llm.stream("foo:"):
    print(res)
```
```output
Hello! How can I assist you today?
```

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)