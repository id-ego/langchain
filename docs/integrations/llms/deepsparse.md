---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/deepsparse.ipynb
description: 이 문서는 LangChain 내에서 DeepSparse 추론 런타임을 사용하는 방법을 설치 및 설정, 예제와 함께 설명합니다.
---

# DeepSparse

이 페이지는 LangChain 내에서 [DeepSparse](https://github.com/neuralmagic/deepsparse) 추론 런타임을 사용하는 방법을 다룹니다. 설치 및 설정과 DeepSparse 사용 예제로 나뉘어 있습니다.

## 설치 및 설정

- `pip install deepsparse`로 Python 패키지를 설치합니다.
- [SparseZoo 모델](https://sparsezoo.neuralmagic.com/?useCase=text_generation)을 선택하거나 Optimum을 사용하여 지원 모델을 ONNX로 내보냅니다. [링크](https://github.com/neuralmagic/notebooks/blob/main/notebooks/opt-text-generation-deepsparse-quickstart/OPT_Text_Generation_DeepSparse_Quickstart.ipynb)

모든 모델에 대한 통합 인터페이스를 제공하는 DeepSparse LLM 래퍼가 존재합니다:

```python
<!--IMPORTS:[{"imported": "DeepSparse", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.deepsparse.DeepSparse.html", "title": "DeepSparse"}]-->
from langchain_community.llms import DeepSparse

llm = DeepSparse(
    model="zoo:nlg/text_generation/codegen_mono-350m/pytorch/huggingface/bigpython_bigquery_thepile/base-none"
)

print(llm.invoke("def fib():"))
```


추가 매개변수는 `config` 매개변수를 사용하여 전달할 수 있습니다:

```python
config = {"max_generated_tokens": 256}

llm = DeepSparse(
    model="zoo:nlg/text_generation/codegen_mono-350m/pytorch/huggingface/bigpython_bigquery_thepile/base-none",
    config=config,
)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)