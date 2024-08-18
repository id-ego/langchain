---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/sparkllm.ipynb
description: SparkLLM은 iFLYTEK이 독립적으로 개발한 대규모 인지 모델로, 자연어 대화를 기반으로 다양한 작업을 이해하고 수행합니다.
---

# SparkLLM
[SparkLLM](https://xinghuo.xfyun.cn/spark)는 iFLYTEK이 독립적으로 개발한 대규모 인지 모델입니다.  
많은 텍스트, 코드 및 이미지를 학습하여 교차 도메인 지식과 언어 이해 능력을 가지고 있습니다.  
자연 대화를 기반으로 작업을 이해하고 수행할 수 있습니다.

## Prerequisite
- [iFlyTek SparkLLM API Console](https://console.xfyun.cn/services/bm3)에서 SparkLLM의 app_id, api_key 및 api_secret을 가져옵니다 (자세한 내용은 [iFlyTek SparkLLM Intro](https://xinghuo.xfyun.cn/sparkapi) 참조). 그런 다음 환경 변수 `IFLYTEK_SPARK_APP_ID`, `IFLYTEK_SPARK_API_KEY` 및 `IFLYTEK_SPARK_API_SECRET`를 설정하거나 위의 데모와 같이 `ChatSparkLLM`을 생성할 때 매개변수를 전달합니다.

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

- LLM [개념 가이드](/docs/concepts/#llms)  
- LLM [사용 방법 가이드](/docs/how_to/#llms)