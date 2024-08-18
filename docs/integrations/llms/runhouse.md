---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/runhouse.ipynb
description: Runhouse는 사용자와 환경 간의 원격 컴퓨팅 및 데이터 처리를 가능하게 하며, LangChain을 통해 GPU 모델과
  상호작용할 수 있습니다.
---

# Runhouse

[Runhouse](https://github.com/run-house/runhouse)는 환경과 사용자 간의 원격 컴퓨팅 및 데이터 처리를 가능하게 합니다. [Runhouse 문서](https://www.run.house/docs)를 참조하세요.

이 예제는 LangChain과 [Runhouse](https://github.com/run-house/runhouse)를 사용하여 자신의 GPU에서 호스팅되는 모델이나 AWS, GCP, AWS 또는 Lambda의 온디맨드 GPU와 상호작용하는 방법을 설명합니다.

**참고**: 코드는 `Runhouse` 대신 `SelfHosted`라는 이름을 사용합니다.

```python
%pip install --upgrade --quiet  runhouse
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Runhouse"}, {"imported": "SelfHostedHuggingFaceLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.self_hosted_hugging_face.SelfHostedHuggingFaceLLM.html", "title": "Runhouse"}, {"imported": "SelfHostedPipeline", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.self_hosted.SelfHostedPipeline.html", "title": "Runhouse"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Runhouse"}]-->
import runhouse as rh
from langchain.chains import LLMChain
from langchain_community.llms import SelfHostedHuggingFaceLLM, SelfHostedPipeline
from langchain_core.prompts import PromptTemplate
```

```output
INFO | 2023-04-17 16:47:36,173 | No auth token provided, so not using RNS API to save and load configs
```


```python
# For an on-demand A100 with GCP, Azure, or Lambda
gpu = rh.cluster(name="rh-a10x", instance_type="A100:1", use_spot=False)

# For an on-demand A10G with AWS (no single A100s on AWS)
# gpu = rh.cluster(name='rh-a10x', instance_type='g5.2xlarge', provider='aws')

# For an existing cluster
# gpu = rh.cluster(ips=['<ip of the cluster>'],
#                  ssh_creds={'ssh_user': '...', 'ssh_private_key':'<path_to_key>'},
#                  name='rh-a10x')
```


```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


```python
llm = SelfHostedHuggingFaceLLM(
    model_id="gpt2", hardware=gpu, model_reqs=["pip:./", "transformers", "torch"]
)
```


```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```

```output
INFO | 2023-02-17 05:42:23,537 | Running _generate_text via gRPC
INFO | 2023-02-17 05:42:24,016 | Time to send message: 0.48 seconds
```


```output
"\n\nLet's say we're talking sports teams who won the Super Bowl in the year Justin Beiber"
```


SelfHostedHuggingFaceLLM 인터페이스를 통해 더 많은 커스텀 모델을 로드할 수도 있습니다:

```python
llm = SelfHostedHuggingFaceLLM(
    model_id="google/flan-t5-small",
    task="text2text-generation",
    hardware=gpu,
)
```


```python
llm("What is the capital of Germany?")
```

```output
INFO | 2023-02-17 05:54:21,681 | Running _generate_text via gRPC
INFO | 2023-02-17 05:54:21,937 | Time to send message: 0.25 seconds
```


```output
'berlin'
```


커스텀 로드 기능을 사용하여 원격 하드웨어에서 커스텀 파이프라인을 직접 로드할 수 있습니다:

```python
def load_pipeline():
    from transformers import (
        AutoModelForCausalLM,
        AutoTokenizer,
        pipeline,
    )

    model_id = "gpt2"
    tokenizer = AutoTokenizer.from_pretrained(model_id)
    model = AutoModelForCausalLM.from_pretrained(model_id)
    pipe = pipeline(
        "text-generation", model=model, tokenizer=tokenizer, max_new_tokens=10
    )
    return pipe


def inference_fn(pipeline, prompt, stop=None):
    return pipeline(prompt)[0]["generated_text"][len(prompt) :]
```


```python
llm = SelfHostedHuggingFaceLLM(
    model_load_fn=load_pipeline, hardware=gpu, inference_fn=inference_fn
)
```


```python
llm("Who is the current US president?")
```

```output
INFO | 2023-02-17 05:42:59,219 | Running _generate_text via gRPC
INFO | 2023-02-17 05:42:59,522 | Time to send message: 0.3 seconds
```


```output
'john w. bush'
```


파이프라인을 모델에 직접 전송할 수 있지만, 이는 작은 모델(<2 Gb)에만 작동하며 꽤 느릴 것입니다:

```python
pipeline = load_pipeline()
llm = SelfHostedPipeline.from_pipeline(
    pipeline=pipeline, hardware=gpu, model_reqs=["pip:./", "transformers", "torch"]
)
```


대신, 하드웨어의 파일 시스템으로 전송할 수도 있으며, 이는 훨씬 더 빠릅니다.

```python
import pickle

rh.blob(pickle.dumps(pipeline), path="models/pipeline.pkl").save().to(
    gpu, path="models"
)

llm = SelfHostedPipeline.from_pipeline(pipeline="models/pipeline.pkl", hardware=gpu)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)