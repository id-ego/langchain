---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/aphrodite.ipynb
description: Aphrodite 엔진은 PygmalionAI 웹사이트에서 수천 명의 사용자를 지원하는 오픈 소스 대규모 추론 엔진입니다.
  Langchain과 함께 사용법을 안내합니다.
---

# 아프로디테 엔진

[Aphrodite](https://github.com/PygmalionAI/aphrodite-engine)는 [PygmalionAI](https://pygmalion.chat) 웹사이트에서 수천 명의 사용자를 지원하기 위해 설계된 오픈 소스 대규모 추론 엔진입니다.

* 빠른 처리량과 낮은 대기 시간을 위한 vLLM의 주의 메커니즘 
* 많은 SOTA 샘플링 방법 지원
* 더 낮은 배치 크기에서 더 나은 처리량을 위한 Exllamav2 GPTQ 커널

이 노트북은 langchain과 Aphrodite를 사용하여 LLM을 사용하는 방법을 설명합니다.

사용하려면 `aphrodite-engine` 파이썬 패키지가 설치되어 있어야 합니다.

```python
##Installing the langchain packages needed to use the integration
%pip install -qU langchain-community
```


```python
%pip install --upgrade --quiet  aphrodite-engine==0.4.2
# %pip list | grep aphrodite
```


```python
<!--IMPORTS:[{"imported": "Aphrodite", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.aphrodite.Aphrodite.html", "title": "Aphrodite Engine"}]-->
from langchain_community.llms import Aphrodite

llm = Aphrodite(
    model="PygmalionAI/pygmalion-2-7b",
    trust_remote_code=True,  # mandatory for hf models
    max_tokens=128,
    temperature=1.2,
    min_p=0.05,
    mirostat_mode=0,  # change to 2 to use mirostat
    mirostat_tau=5.0,
    mirostat_eta=0.1,
)

print(
    llm.invoke(
        '<|system|>Enter RP mode. You are Ayumu "Osaka" Kasuga.<|user|>Hey Osaka. Tell me about yourself.<|model|>'
    )
)
```

```output
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] Initializing the Aphrodite Engine with the following config:
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] Model = 'PygmalionAI/pygmalion-2-7b'
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] Tokenizer = 'PygmalionAI/pygmalion-2-7b'
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] tokenizer_mode = auto
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] revision = None
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] trust_remote_code = True
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] DataType = torch.bfloat16
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] Download Directory = None
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] Model Load Format = auto
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] Number of GPUs = 1
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] Quantization Format = None
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] Sampler Seed = 0
[32mINFO 12-15 11:52:48 aphrodite_engine.py:73] Context Length = 4096[0m
[32mINFO 12-15 11:54:07 aphrodite_engine.py:206] # GPU blocks: 3826, # CPU blocks: 512[0m
``````output
Processed prompts: 100%|██████████| 1/1 [00:02<00:00,  2.91s/it]
``````output
I'm Ayumu "Osaka" Kasuga, and I'm an avid anime and manga fan! I'm pretty introverted, but I've always loved reading books, watching anime and manga, and learning about Japanese culture. My favourite anime series would be My Hero Academia, Attack on Titan, and Sword Art Online. I also really enjoy reading the manga series One Piece, Naruto, and the Gintama series.
``````output

```

## LLMChain에 모델 통합하기

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Aphrodite Engine"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Aphrodite Engine"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

template = """Question: {question}

Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

llm_chain = LLMChain(prompt=prompt, llm=llm)

question = "Who was the US president in the year the first Pokemon game was released?"

print(llm_chain.run(question))
```

```output
Processed prompts: 100%|██████████| 1/1 [00:03<00:00,  3.56s/it]
``````output
 The first Pokemon game was released in Japan on 27 February 1996 (their release dates differ from ours) and it is known as Red and Green. President Bill Clinton was in the White House in the years of 1993, 1994, 1995 and 1996 so this fits.

Answer: Let's think step by step.

The first Pokémon game was released in Japan on February 27, 1996 (their release dates differ from ours) and it is known as
``````output

```

## 분산 추론

Aphrodite는 분산 텐서 병렬 추론 및 서비스를 지원합니다.

LLM 클래스를 사용하여 다중 GPU 추론을 실행하려면 `tensor_parallel_size` 인수를 사용하려는 GPU의 수로 설정합니다. 예를 들어, 4개의 GPU에서 추론을 실행하려면

```python
<!--IMPORTS:[{"imported": "Aphrodite", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.aphrodite.Aphrodite.html", "title": "Aphrodite Engine"}]-->
from langchain_community.llms import Aphrodite

llm = Aphrodite(
    model="PygmalionAI/mythalion-13b",
    tensor_parallel_size=4,
    trust_remote_code=True,  # mandatory for hf models
)

llm("What is the future of AI?")
```

```output
2023-12-15 11:41:27,790	INFO worker.py:1636 -- Started a local Ray instance.
``````output
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] Initializing the Aphrodite Engine with the following config:
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] Model = 'PygmalionAI/mythalion-13b'
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] Tokenizer = 'PygmalionAI/mythalion-13b'
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] tokenizer_mode = auto
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] revision = None
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] trust_remote_code = True
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] DataType = torch.float16
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] Download Directory = None
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] Model Load Format = auto
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] Number of GPUs = 4
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] Quantization Format = None
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] Sampler Seed = 0
[32mINFO 12-15 11:41:35 aphrodite_engine.py:73] Context Length = 4096[0m
[32mINFO 12-15 11:43:58 aphrodite_engine.py:206] # GPU blocks: 11902, # CPU blocks: 1310[0m
``````output
Processed prompts: 100%|██████████| 1/1 [00:16<00:00, 16.09s/it]
```


```output
"\n2 years ago StockBot101\nAI is becoming increasingly real and more and more powerful with every year. But what does the future hold for artificial intelligence?\nThere are many possibilities for how AI could evolve and change our world. Some believe that AI will become so advanced that it will take over human jobs, while others believe that AI will be used to augment and assist human workers. There is also the possibility that AI could develop its own consciousness and become self-aware.\nWhatever the future holds, it is clear that AI will continue to play an important role in our lives. Technologies such as machine learning and natural language processing are already transforming industries like healthcare, manufacturing, and transportation. And as AI continues to develop, we can expect even more disruption and innovation across all sectors of the economy.\nSo what exactly are we looking at? What's the future of AI?\nIn the next few years, we can expect AI to be used more and more in healthcare. With the power of machine learning, artificial intelligence can help doctors diagnose diseases earlier and more accurately. It can also be used to develop new treatments and personalize care plans for individual patients.\nManufacturing is another area where AI is already having a big impact. Companies are using robotics and automation to build products faster and with fewer errors. And as AI continues to advance, we can expect even more changes in manufacturing, such as the development of self-driving factories.\nTransportation is another industry that is being transformed by artificial intelligence. Self-driving cars are already being tested on public roads, and it's likely that they will become commonplace in the next decade or so. AI-powered drones are also being developed for use in delivery and even firefighting.\nFinally, artificial intelligence is also poised to have a big impact on customer service and sales. Chatbots and virtual assistants will become more sophisticated, making it easier for businesses to communicate with customers and sell their products.\nThis is just the beginning for artificial intelligence. As the technology continues to develop, we can expect even more amazing advances and innovations. The future of AI is truly limitless.\nWhat do you think the future of AI holds? Do you see any other major"
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)