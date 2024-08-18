---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/koboldai.ipynb
description: KoboldAI API를 사용하여 LangChain과 통합하는 방법을 설명하는 문서입니다. 다양한 AI 모델로 AI 지원 작성을
  지원합니다.
---

# KoboldAI API

[KoboldAI](https://github.com/KoboldAI/KoboldAI-Client)는 "다양한 로컬 및 원격 AI 모델을 사용한 AI 지원 작성을 위한 브라우저 기반 프론트엔드..."입니다. 이는 langchain에서 사용할 수 있는 공개 및 로컬 API를 가지고 있습니다.

이 예제는 해당 API와 함께 LangChain을 사용하는 방법을 설명합니다.

문서는 브라우저에서 엔드포인트 끝에 /api를 추가하여 찾을 수 있습니다 (예: http://127.0.0.1/:5000/api).

```python
<!--IMPORTS:[{"imported": "KoboldApiLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.koboldai.KoboldApiLLM.html", "title": "KoboldAI API"}]-->
from langchain_community.llms import KoboldApiLLM
```


아래에 보이는 엔드포인트를 --api 또는 --public-api로 웹 UI를 시작한 후 출력된 것으로 교체하십시오.

선택적으로, 온도나 최대 길이와 같은 매개변수를 전달할 수 있습니다.

```python
llm = KoboldApiLLM(endpoint="http://192.168.1.144:5000", max_length=80)
```


```python
response = llm.invoke(
    "### Instruction:\nWhat is the first book of the bible?\n### Response:"
)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)