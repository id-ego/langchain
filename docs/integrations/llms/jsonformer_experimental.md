---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/jsonformer_experimental.ipynb
description: JSONFormer는 JSON Schema의 하위 집합을 구조적으로 디코딩하기 위해 로컬 Hugging Face 파이프라인
  모델을 래핑하는 라이브러리입니다.
---

# JSONFormer

[JSONFormer](https://github.com/1rgs/jsonformer)는 JSON Schema의 하위 집합에 대한 구조적 디코딩을 위해 로컬 Hugging Face 파이프라인 모델을 래핑하는 라이브러리입니다.

구조 토큰을 채운 다음 모델에서 콘텐츠 토큰을 샘플링하여 작동합니다.

**경고 - 이 모듈은 아직 실험적입니다**

```python
%pip install --upgrade --quiet  jsonformer > /dev/null
```


### Hugging Face 기준선

먼저, 구조적 디코딩 없이 모델의 출력을 확인하여 질적 기준선을 설정해 봅시다.

```python
import logging

logging.basicConfig(level=logging.ERROR)
```


```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "JSONFormer"}]-->
import json
import os

import requests
from langchain_core.tools import tool

HF_TOKEN = os.environ.get("HUGGINGFACE_API_KEY")


@tool
def ask_star_coder(query: str, temperature: float = 1.0, max_new_tokens: float = 250):
    """Query the BigCode StarCoder model about coding questions."""
    url = "https://api-inference.huggingface.co/models/bigcode/starcoder"
    headers = {
        "Authorization": f"Bearer {HF_TOKEN}",
        "content-type": "application/json",
    }
    payload = {
        "inputs": f"{query}\n\nAnswer:",
        "temperature": temperature,
        "max_new_tokens": int(max_new_tokens),
    }
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    response.raise_for_status()
    return json.loads(response.content.decode("utf-8"))
```


```python
prompt = """You must respond using JSON format, with a single action and single action input.
You may 'ask_star_coder' for help on coding problems.

{arg_schema}

EXAMPLES
----
Human: "So what's all this about a GIL?"
AI Assistant:{{
  "action": "ask_star_coder",
  "action_input": {{"query": "What is a GIL?", "temperature": 0.0, "max_new_tokens": 100}}"
}}
Observation: "The GIL is python's Global Interpreter Lock"
Human: "Could you please write a calculator program in LISP?"
AI Assistant:{{
  "action": "ask_star_coder",
  "action_input": {{"query": "Write a calculator program in LISP", "temperature": 0.0, "max_new_tokens": 250}}
}}
Observation: "(defun add (x y) (+ x y))\n(defun sub (x y) (- x y ))"
Human: "What's the difference between an SVM and an LLM?"
AI Assistant:{{
  "action": "ask_star_coder",
  "action_input": {{"query": "What's the difference between SGD and an SVM?", "temperature": 1.0, "max_new_tokens": 250}}
}}
Observation: "SGD stands for stochastic gradient descent, while an SVM is a Support Vector Machine."

BEGIN! Answer the Human's question as best as you are able.
------
Human: 'What's the difference between an iterator and an iterable?'
AI Assistant:""".format(arg_schema=ask_star_coder.args)
```


```python
<!--IMPORTS:[{"imported": "HuggingFacePipeline", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_pipeline.HuggingFacePipeline.html", "title": "JSONFormer"}]-->
from langchain_huggingface import HuggingFacePipeline
from transformers import pipeline

hf_model = pipeline(
    "text-generation", model="cerebras/Cerebras-GPT-590M", max_new_tokens=200
)

original_model = HuggingFacePipeline(pipeline=hf_model)

generated = original_model.predict(prompt, stop=["Observation:", "Human:"])
print(generated)
```

```output
Setting `pad_token_id` to `eos_token_id`:50256 for open-end generation.
``````output
 'What's the difference between an iterator and an iterable?'
```

***그렇게 인상적이지 않네요, 그렇죠? JSON 형식을 전혀 따르지 않았어요! 구조적 디코더로 다시 시도해 봅시다.***

## JSONFormer LLM 래퍼

이제 모델에 Action 입력의 JSON Schema를 제공하여 다시 시도해 봅시다.

```python
decoder_schema = {
    "title": "Decoding Schema",
    "type": "object",
    "properties": {
        "action": {"type": "string", "default": ask_star_coder.name},
        "action_input": {
            "type": "object",
            "properties": ask_star_coder.args,
        },
    },
}
```


```python
<!--IMPORTS:[{"imported": "JsonFormer", "source": "langchain_experimental.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_experimental.llms.jsonformer_decoder.JsonFormer.html", "title": "JSONFormer"}]-->
from langchain_experimental.llms import JsonFormer

json_former = JsonFormer(json_schema=decoder_schema, pipeline=hf_model)
```


```python
results = json_former.predict(prompt, stop=["Observation:", "Human:"])
print(results)
```

```output
{"action": "ask_star_coder", "action_input": {"query": "What's the difference between an iterator and an iter", "temperature": 0.0, "max_new_tokens": 50.0}}
```

**보아라! 파싱 오류가 없습니다.**

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)