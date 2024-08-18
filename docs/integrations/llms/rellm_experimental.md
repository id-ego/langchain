---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/rellm_experimental.ipynb
description: RELLM은 로컬 Hugging Face 파이프라인 모델을 위한 라이브러리로, 구조화된 디코딩을 위해 정규 표현식을 사용하여
  토큰을 생성합니다.
---

# RELLM

[RELLM](https://github.com/r2d4/rellm)은 구조화된 디코딩을 위해 로컬 Hugging Face 파이프라인 모델을 래핑하는 라이브러리입니다.

이 라이브러리는 토큰을 한 번에 하나씩 생성하는 방식으로 작동합니다. 각 단계에서 제공된 부분 정규 표현식에 맞지 않는 토큰을 마스킹합니다.

**경고 - 이 모듈은 아직 실험적입니다**

```python
%pip install --upgrade --quiet  rellm langchain-huggingface > /dev/null
```


### Hugging Face 기준선

먼저, 구조화된 디코딩 없이 모델의 출력을 확인하여 정성적 기준선을 설정해 봅시다.

```python
import logging

logging.basicConfig(level=logging.ERROR)
prompt = """Human: "What's the capital of the United States?"
AI Assistant:{
  "action": "Final Answer",
  "action_input": "The capital of the United States is Washington D.C."
}
Human: "What's the capital of Pennsylvania?"
AI Assistant:{
  "action": "Final Answer",
  "action_input": "The capital of Pennsylvania is Harrisburg."
}
Human: "What 2 + 5?"
AI Assistant:{
  "action": "Final Answer",
  "action_input": "2 + 5 = 7."
}
Human: 'What's the capital of Maryland?'
AI Assistant:"""
```


```python
<!--IMPORTS:[{"imported": "HuggingFacePipeline", "source": "langchain_huggingface", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_huggingface.llms.huggingface_pipeline.HuggingFacePipeline.html", "title": "RELLM"}]-->
from langchain_huggingface import HuggingFacePipeline
from transformers import pipeline

hf_model = pipeline(
    "text-generation", model="cerebras/Cerebras-GPT-590M", max_new_tokens=200
)

original_model = HuggingFacePipeline(pipeline=hf_model)

generated = original_model.generate([prompt], stop=["Human:"])
print(generated)
```

```output
Setting `pad_token_id` to `eos_token_id`:50256 for open-end generation.
``````output
generations=[[Generation(text=' "What\'s the capital of Maryland?"\n', generation_info=None)]] llm_output=None
```

***그렇게 인상적이지 않네요, 그렇죠? 질문에 답하지 않았고 JSON 형식도 전혀 따르지 않았습니다! 구조화된 디코더로 다시 시도해 봅시다.***

## RELLM LLM 래퍼

이제 JSON 구조화 형식에 맞는 정규 표현식을 제공하여 다시 시도해 봅시다.

```python
import regex  # Note this is the regex library NOT python's re stdlib module

# We'll choose a regex that matches to a structured json string that looks like:
# {
#  "action": "Final Answer",
# "action_input": string or dict
# }
pattern = regex.compile(
    r'\{\s*"action":\s*"Final Answer",\s*"action_input":\s*(\{.*\}|"[^"]*")\s*\}\nHuman:'
)
```


```python
<!--IMPORTS:[{"imported": "RELLM", "source": "langchain_experimental.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_experimental.llms.rellm_decoder.RELLM.html", "title": "RELLM"}]-->
from langchain_experimental.llms import RELLM

model = RELLM(pipeline=hf_model, regex=pattern, max_new_tokens=200)

generated = model.predict(prompt, stop=["Human:"])
print(generated)
```

```output
{"action": "Final Answer",
  "action_input": "The capital of Maryland is Baltimore."
}
```

**바로 그거죠! 파싱 오류가 없습니다.**

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)