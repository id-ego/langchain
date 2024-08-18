---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/titan_takeoff.ipynb
description: TitanML의 Titan Takeoff는 LLM을 로컬 하드웨어에 쉽게 배포할 수 있는 인퍼런스 서버입니다. 다양한 모델
  아키텍처를 지원합니다.
---

# 타이탄 이륙

`TitanML`은 기업이 훈련, 압축 및 추론 최적화 플랫폼을 통해 더 나은, 더 작고, 더 저렴하며, 더 빠른 NLP 모델을 구축하고 배포할 수 있도록 돕습니다.

우리의 추론 서버인 [타이탄 이륙](https://docs.titanml.co/docs/intro)은 단일 명령으로 하드웨어에서 LLM을 로컬로 배포할 수 있게 해줍니다. Falcon, Llama 2, GPT2, T5 등 대부분의 생성 모델 아키텍처를 지원합니다. 특정 모델에 문제가 발생하면 hello@titanml.co로 알려주십시오.

## 사용 예시
타이탄 이륙 서버를 사용하여 시작하는 데 도움이 되는 몇 가지 예시입니다. 이러한 명령을 실행하기 전에 이륙 서버가 백그라운드에서 시작되었는지 확인해야 합니다. 더 많은 정보는 [이륙 시작을 위한 문서 페이지](https://docs.titanml.co/docs/Docs/launching/)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "TitanTakeoff", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.titan_takeoff.TitanTakeoff.html", "title": "Titan Takeoff"}, {"imported": "CallbackManager", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.manager.CallbackManager.html", "title": "Titan Takeoff"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "Titan Takeoff"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Titan Takeoff"}]-->
import time

# Note importing TitanTakeoffPro instead of TitanTakeoff will work as well both use same object under the hood
from langchain_community.llms import TitanTakeoff
from langchain_core.callbacks import CallbackManager, StreamingStdOutCallbackHandler
from langchain_core.prompts import PromptTemplate
```


### 예시 1

기본 사용법으로, 이륙이 기본 포트(예: localhost:3000)에서 실행되고 있다고 가정합니다.

```python
llm = TitanTakeoff()
output = llm.invoke("What is the weather in London in August?")
print(output)
```


### 예시 2

포트 및 기타 생성 매개변수 지정

```python
llm = TitanTakeoff(port=3000)
# A comprehensive list of parameters can be found at https://docs.titanml.co/docs/next/apis/Takeoff%20inference_REST_API/generate#request
output = llm.invoke(
    "What is the largest rainforest in the world?",
    consumer_group="primary",
    min_new_tokens=128,
    max_new_tokens=512,
    no_repeat_ngram_size=2,
    sampling_topk=1,
    sampling_topp=1.0,
    sampling_temperature=1.0,
    repetition_penalty=1.0,
    regex_string="",
    json_schema=None,
)
print(output)
```


### 예시 3

여러 입력에 대해 생성 사용

```python
llm = TitanTakeoff()
rich_output = llm.generate(["What is Deep Learning?", "What is Machine Learning?"])
print(rich_output.generations)
```


### 예시 4

스트리밍 출력

```python
llm = TitanTakeoff(
    streaming=True, callback_manager=CallbackManager([StreamingStdOutCallbackHandler()])
)
prompt = "What is the capital of France?"
output = llm.invoke(prompt)
print(output)
```


### 예시 5

LCEL 사용

```python
llm = TitanTakeoff()
prompt = PromptTemplate.from_template("Tell me about {topic}")
chain = prompt | llm
output = chain.invoke({"topic": "the universe"})
print(output)
```


### 예시 6

타이탄 이륙 파이썬 래퍼를 사용하여 리더 시작. 이륙을 처음 실행하여 리더를 생성하지 않았거나 다른 리더를 추가하고 싶다면, 타이탄 이륙 객체를 초기화할 때 그렇게 할 수 있습니다. 시작하려는 모델 구성 목록을 `models` 매개변수로 전달하기만 하면 됩니다.

```python
# Model config for the llama model, where you can specify the following parameters:
#   model_name (str): The name of the model to use
#   device: (str): The device to use for inference, cuda or cpu
#   consumer_group (str): The consumer group to place the reader into
#   tensor_parallel (Optional[int]): The number of gpus you would like your model to be split across
#   max_seq_length (int): The maximum sequence length to use for inference, defaults to 512
#   max_batch_size (int_: The max batch size for continuous batching of requests
llama_model = {
    "model_name": "TheBloke/Llama-2-7b-Chat-AWQ",
    "device": "cuda",
    "consumer_group": "llama",
}
llm = TitanTakeoff(models=[llama_model])

# The model needs time to spin up, length of time need will depend on the size of model and your network connection speed
time.sleep(60)

prompt = "What is the capital of France?"
output = llm.invoke(prompt, consumer_group="llama")
print(output)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)