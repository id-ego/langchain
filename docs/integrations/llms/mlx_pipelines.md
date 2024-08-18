---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/mlx_pipelines.ipynb
description: MLX 모델을 로컬에서 실행하는 방법과 MLX 커뮤니티의 다양한 모델을 활용하는 방법을 소개합니다.
---

# MLX 로컬 파이프라인

MLX 모델은 `MLXPipeline` 클래스를 통해 로컬에서 실행할 수 있습니다.

[MLX 커뮤니티](https://huggingface.co/mlx-community)는 150개 이상의 모델을 호스팅하며, 모두 오픈 소스이고 Hugging Face Model Hub에서 공개적으로 이용 가능합니다. 이 플랫폼은 사람들이 쉽게 협력하고 ML을 함께 구축할 수 있도록 합니다.

이들은 LangChain에서 이 로컬 파이프라인 래퍼를 통해 호출하거나 MlXPipeline 클래스를 통해 호스팅된 추론 엔드포인트를 호출하여 사용할 수 있습니다. mlx에 대한 자세한 내용은 [예제 레포지토리](https://github.com/ml-explore/mlx-examples/tree/main/llms) 노트를 참조하세요.

사용하려면 `mlx-lm` 파이썬 [패키지를 설치해야](https://pypi.org/project/mlx-lm/) 하며, [transformers](https://pypi.org/project/transformers/)도 설치해야 합니다. `huggingface_hub`도 설치할 수 있습니다.

```python
%pip install --upgrade --quiet  mlx-lm transformers huggingface_hub
```


### 모델 로딩

모델은 `from_model_id` 메서드를 사용하여 모델 매개변수를 지정하여 로딩할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "MLXPipeline", "source": "langchain_community.llms.mlx_pipeline", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.mlx_pipeline.MLXPipeline.html", "title": "MLX Local Pipelines"}]-->
from langchain_community.llms.mlx_pipeline import MLXPipeline

pipe = MLXPipeline.from_model_id(
    "mlx-community/quantized-gemma-2b-it",
    pipeline_kwargs={"max_tokens": 10, "temp": 0.1},
)
```


기존의 `transformers` 파이프라인을 직접 전달하여 로딩할 수도 있습니다.

```python
from mlx_lm import load

model, tokenizer = load("mlx-community/quantized-gemma-2b-it")
pipe = MLXPipeline(model=model, tokenizer=tokenizer)
```


### 체인 생성

모델이 메모리에 로드되면, 프롬프트와 조합하여 체인을 형성할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "MLX Local Pipelines"}]-->
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

chain = prompt | pipe

question = "What is electroencephalography?"

print(chain.invoke({"question": question}))
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)