---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/yuan2.ipynb
description: Yuan2.0는 IEIT System이 개발한 차세대 대형 언어 모델로, 다양한 데이터로 사전 훈련되어 텍스트 생성을 지원합니다.
---

# Yuan2.0

[Yuan2.0](https://github.com/IEIT-Yuan/Yuan-2.0)는 IEIT 시스템에서 개발한 새로운 세대의 기본 대형 언어 모델입니다. 우리는 Yuan 2.0-102B, Yuan 2.0-51B 및 Yuan 2.0-2B의 세 가지 모델을 모두 발표했습니다. 또한 다른 개발자를 위한 사전 훈련, 미세 조정 및 추론 서비스에 대한 관련 스크립트를 제공합니다. Yuan2.0은 Yuan1.0을 기반으로 하며, 모델의 의미, 수학, 추론, 코드, 지식 및 기타 측면에 대한 이해를 향상시키기 위해 더 넓은 범위의 고품질 사전 훈련 데이터와 지침 미세 조정 데이터 세트를 활용합니다.

이 예제는 텍스트 생성을 위해 `Yuan2.0`(2B/51B/102B) 추론과 상호 작용하는 방법에 대해 설명합니다.

Yuan2.0은 추론 서비스를 설정하여 사용자가 결과를 얻기 위해 추론 API를 요청하기만 하면 됩니다. 이는 [Yuan2.0 Inference-Server](https://github.com/IEIT-Yuan/Yuan-2.0/blob/main/docs/inference_server.md)에서 소개됩니다.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Yuan2.0"}, {"imported": "Yuan2", "source": "langchain_community.llms.yuan2", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.yuan2.Yuan2.html", "title": "Yuan2.0"}]-->
from langchain.chains import LLMChain
from langchain_community.llms.yuan2 import Yuan2
```


```python
# default infer_api for a local deployed Yuan2.0 inference server
infer_api = "http://127.0.0.1:8000/yuan"

# direct access endpoint in a proxied environment
# import os
# os.environ["no_proxy"]="localhost,127.0.0.1,::1"

yuan_llm = Yuan2(
    infer_api=infer_api,
    max_tokens=2048,
    temp=1.0,
    top_p=0.9,
    use_history=False,
)

# turn on use_history only when you want the Yuan2.0 to keep track of the conversation history
# and send the accumulated context to the backend model api, which make it stateful. By default it is stateless.
# llm.use_history = True
```


```python
question = "请介绍一下中国。"
```


```python
print(yuan_llm.invoke(question))
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)