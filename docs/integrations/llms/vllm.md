---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/vllm/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/vllm.ipynb
---

# vLLM

[vLLM](https://vllm.readthedocs.io/en/latest/index.html) is a fast and easy-to-use library for LLM inference and serving, offering:

* State-of-the-art serving throughput 
* Efficient management of attention key and value memory with PagedAttention
* Continuous batching of incoming requests
* Optimized CUDA kernels

This notebooks goes over how to use a LLM with langchain and vLLM.

To use, you should have the `vllm` python package installed.

```python
%pip install --upgrade --quiet  vllm -q
```

```python
<!--IMPORTS:[{"imported": "VLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.vllm.VLLM.html", "title": "vLLM"}]-->
from langchain_community.llms import VLLM

llm = VLLM(
    model="mosaicml/mpt-7b",
    trust_remote_code=True,  # mandatory for hf models
    max_new_tokens=128,
    top_k=10,
    top_p=0.95,
    temperature=0.8,
)

print(llm.invoke("What is the capital of France ?"))
```
```output
INFO 08-06 11:37:33 llm_engine.py:70] Initializing an LLM engine with config: model='mosaicml/mpt-7b', tokenizer='mosaicml/mpt-7b', tokenizer_mode=auto, trust_remote_code=True, dtype=torch.bfloat16, use_dummy_weights=False, download_dir=None, use_np_weights=False, tensor_parallel_size=1, seed=0)
INFO 08-06 11:37:41 llm_engine.py:196] # GPU blocks: 861, # CPU blocks: 512
``````output
Processed prompts: 100%|██████████| 1/1 [00:00<00:00,  2.00it/s]
``````output

What is the capital of France ? The capital of France is Paris.
``````output

```
## Integrate the model in an LLMChain

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "vLLM"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "vLLM"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

llm_chain = LLMChain(prompt=prompt, llm=llm)

question = "Who was the US president in the year the first Pokemon game was released?"

print(llm_chain.invoke(question))
```
```output
Processed prompts: 100%|██████████| 1/1 [00:01<00:00,  1.34s/it]
``````output


1. The first Pokemon game was released in 1996.
2. The president was Bill Clinton.
3. Clinton was president from 1993 to 2001.
4. The answer is Clinton.
``````output

```
## Distributed Inference

vLLM supports distributed tensor-parallel inference and serving. 

To run multi-GPU inference with the LLM class, set the `tensor_parallel_size` argument to the number of GPUs you want to use. For example, to run inference on 4 GPUs

```python
<!--IMPORTS:[{"imported": "VLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.vllm.VLLM.html", "title": "vLLM"}]-->
from langchain_community.llms import VLLM

llm = VLLM(
    model="mosaicml/mpt-30b",
    tensor_parallel_size=4,
    trust_remote_code=True,  # mandatory for hf models
)

llm.invoke("What is the future of AI?")
```

## Quantization

vLLM supports `awq` quantization. To enable it, pass `quantization` to `vllm_kwargs`.

```python
llm_q = VLLM(
    model="TheBloke/Llama-2-7b-Chat-AWQ",
    trust_remote_code=True,
    max_new_tokens=512,
    vllm_kwargs={"quantization": "awq"},
)
```

## OpenAI-Compatible Server

vLLM can be deployed as a server that mimics the OpenAI API protocol. This allows vLLM to be used as a drop-in replacement for applications using OpenAI API.

This server can be queried in the same format as OpenAI API.

### OpenAI-Compatible Completion

```python
<!--IMPORTS:[{"imported": "VLLMOpenAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.vllm.VLLMOpenAI.html", "title": "vLLM"}]-->
from langchain_community.llms import VLLMOpenAI

llm = VLLMOpenAI(
    openai_api_key="EMPTY",
    openai_api_base="http://localhost:8000/v1",
    model_name="tiiuae/falcon-7b",
    model_kwargs={"stop": ["."]},
)
print(llm.invoke("Rome is"))
```
```output
 a city that is filled with history, ancient buildings, and art around every corner
```

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)