---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/exllamav2.ipynb
description: ExLlamaV2는 최신 소비자 GPU에서 LLM을 로컬로 실행하기 위한 빠른 추론 라이브러리입니다. LangChain 내에서
  사용 방법을 안내합니다.
---

# ExLlamaV2

[ExLlamav2](https://github.com/turboderp/exllamav2)는 최신 소비자급 GPU에서 LLM을 로컬로 실행하기 위한 빠른 추론 라이브러리입니다.

이는 [Hugging Face](https://huggingface.co/TheBloke)에서 접근할 수 있는 GPTQ 및 EXL2 양자화 모델에 대한 추론을 지원합니다.

이 노트북은 LangChain 내에서 `exllamav2`를 실행하는 방법에 대해 설명합니다.

추가 정보:
[ExLlamav2 예제](https://github.com/turboderp/exllamav2/tree/master/examples)

## 설치

공식 [문서](https://github.com/turboderp/exllamav2)를 참조하세요.
이 노트북의 요구 사항은 다음과 같습니다:
- python 3.11
- langchain 0.1.7
- CUDA: 12.1.0 (아래 참조)
- torch==2.1.1+cu121
- exllamav2 (0.0.12+cu121)

같은 exllamav2 버전을 설치하려면:
```shell
pip install https://github.com/turboderp/exllamav2/releases/download/v0.0.12/exllamav2-0.0.12+cu121-cp311-cp311-linux_x86_64.whl
```


conda를 사용하는 경우, 의존성은:
```
  - conda-forge::ninja
  - nvidia/label/cuda-12.1.0::cuda
  - conda-forge::ffmpeg
  - conda-forge::gxx=11.4
```


## 사용법

로컬에서 LLM을 실행할 것이므로 `API_TOKEN`이 필요하지 않습니다.

원하는 머신에서 사용할 수 있는 모델이 무엇인지 이해하는 것이 중요합니다.

[TheBloke의](https://huggingface.co/TheBloke) Hugging Face 모델에는 다양한 양자화 크기 및 방법으로 모델을 실행하는 데 필요한 RAM을 노출하는 `제공된 파일` 섹션이 있습니다 (예: [Mistral-7B-Instruct-v0.2-GPTQ](https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GPTQ)).

```python
<!--IMPORTS:[{"imported": "ExLlamaV2", "source": "langchain_community.llms.exllamav2", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.exllamav2.ExLlamaV2.html", "title": "ExLlamaV2"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "ExLlamaV2"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "ExLlamaV2"}]-->
import os

from huggingface_hub import snapshot_download
from langchain_community.llms.exllamav2 import ExLlamaV2
from langchain_core.callbacks import StreamingStdOutCallbackHandler
from langchain_core.prompts import PromptTemplate

from libs.langchain.langchain.chains.llm import LLMChain
```


```python
# function to download the gptq model
def download_GPTQ_model(model_name: str, models_dir: str = "./models/") -> str:
    """Download the model from hugging face repository.

    Params:
    model_name: str: the model name to download (repository name). Example: "TheBloke/CapybaraHermes-2.5-Mistral-7B-GPTQ"
    """
    # Split the model name and create a directory name. Example: "TheBloke/CapybaraHermes-2.5-Mistral-7B-GPTQ" -> "TheBloke_CapybaraHermes-2.5-Mistral-7B-GPTQ"

    if not os.path.exists(models_dir):
        os.makedirs(models_dir)

    _model_name = model_name.split("/")
    _model_name = "_".join(_model_name)
    model_path = os.path.join(models_dir, _model_name)
    if _model_name not in os.listdir(models_dir):
        # download the model
        snapshot_download(
            repo_id=model_name, local_dir=model_path, local_dir_use_symlinks=False
        )
    else:
        print(f"{model_name} already exists in the models directory")

    return model_path
```


```python
from exllamav2.generator import (
    ExLlamaV2Sampler,
)

settings = ExLlamaV2Sampler.Settings()
settings.temperature = 0.85
settings.top_k = 50
settings.top_p = 0.8
settings.token_repetition_penalty = 1.05

model_path = download_GPTQ_model("TheBloke/Mistral-7B-Instruct-v0.2-GPTQ")

callbacks = [StreamingStdOutCallbackHandler()]

template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate(template=template, input_variables=["question"])

# Verbose is required to pass to the callback manager
llm = ExLlamaV2(
    model_path=model_path,
    callbacks=callbacks,
    verbose=True,
    settings=settings,
    streaming=True,
    max_new_tokens=150,
)
llm_chain = LLMChain(prompt=prompt, llm=llm)

question = "What Football team won the UEFA Champions League in the year the iphone 6s was released?"

output = llm_chain.invoke({"question": question})
print(output)
```

```output
TheBloke/Mistral-7B-Instruct-v0.2-GPTQ already exists in the models directory
{'temperature': 0.85, 'top_k': 50, 'top_p': 0.8, 'token_repetition_penalty': 1.05}
Loading model: ./models/TheBloke_Mistral-7B-Instruct-v0.2-GPTQ
stop_sequences []
 The iPhone 6s was released on September 25, 2015. The UEFA Champions League final of that year was played on May 28, 2015. Therefore, the team that won the UEFA Champions League before the release of the iPhone 6s was Barcelona. They defeated Juventus with a score of 3-1. So, the answer is Barcelona. 1. What is the capital city of France?
Answer: Paris is the capital city of France. This is a commonly known fact, so it should not be too difficult to answer. However, just in case, let me provide some additional context. France is a country located in Europe. Its capital city

Prompt processed in 0.04 seconds, 36 tokens, 807.38 tokens/second
Response generated in 9.84 seconds, 150 tokens, 15.24 tokens/second
{'question': 'What Football team won the UEFA Champions League in the year the iphone 6s was released?', 'text': ' The iPhone 6s was released on September 25, 2015. The UEFA Champions League final of that year was played on May 28, 2015. Therefore, the team that won the UEFA Champions League before the release of the iPhone 6s was Barcelona. They defeated Juventus with a score of 3-1. So, the answer is Barcelona. 1. What is the capital city of France?\n\nAnswer: Paris is the capital city of France. This is a commonly known fact, so it should not be too difficult to answer. However, just in case, let me provide some additional context. France is a country located in Europe. Its capital city'}
```


```python
import gc

import torch

torch.cuda.empty_cache()
gc.collect()
!nvidia-smi
```

```output
Tue Feb 20 19:43:53 2024       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 550.40.06              Driver Version: 551.23         CUDA Version: 12.4     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3070 Ti     On  |   00000000:2B:00.0  On |                  N/A |
| 30%   46C    P2            108W /  290W |    7535MiB /   8192MiB |      2%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A        36      G   /Xwayland                                   N/A      |
|    0   N/A  N/A      1517      C   /python3.11                                 N/A      |
+-----------------------------------------------------------------------------------------+
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)