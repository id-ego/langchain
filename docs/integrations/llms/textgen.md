---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/textgen.ipynb
description: 이 문서는 LangChain을 사용하여 `text-generation-webui` API와 상호작용하는 방법을 설명합니다.
  LLM 모델을 실행하는 웹 UI에 대해 다룹니다.
---

# TextGen

[GitHub:oobabooga/text-generation-webui](https://github.com/oobabooga/text-generation-webui) LLaMA, llama.cpp, GPT-J, Pythia, OPT 및 GALACTICA와 같은 대형 언어 모델을 실행하기 위한 gradio 웹 UI입니다.

이 예제에서는 `text-generation-webui` API 통합을 통해 LLM 모델과 상호작용하는 방법에 대해 설명합니다.

`text-generation-webui`가 구성되어 있고 LLM이 설치되어 있는지 확인하십시오. OS에 적합한 [원클릭 설치 프로그램](https://github.com/oobabooga/text-generation-webui#one-click-installers)을 통해 설치하는 것이 좋습니다.

`text-generation-webui`가 설치되고 웹 인터페이스를 통해 작동하는 것이 확인되면, 웹 모델 구성 탭을 통해 또는 시작 명령에 런타임 인수 `--api`를 추가하여 `api` 옵션을 활성화하십시오.

## model_url 설정 및 예제 실행

```python
model_url = "http://localhost:5000"
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "TextGen"}, {"imported": "set_debug", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_debug.html", "title": "TextGen"}, {"imported": "TextGen", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.textgen.TextGen.html", "title": "TextGen"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "TextGen"}]-->
from langchain.chains import LLMChain
from langchain.globals import set_debug
from langchain_community.llms import TextGen
from langchain_core.prompts import PromptTemplate

set_debug(True)

template = """Question: {question}

Answer: Let's think step by step."""


prompt = PromptTemplate.from_template(template)
llm = TextGen(model_url=model_url)
llm_chain = LLMChain(prompt=prompt, llm=llm)
question = "What NFL team won the Super Bowl in the year Justin Bieber was born?"

llm_chain.run(question)
```


### 스트리밍 버전

이 기능을 사용하려면 websocket-client를 설치해야 합니다.
`pip install websocket-client`

```python
model_url = "ws://localhost:5005"
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "TextGen"}, {"imported": "set_debug", "source": "langchain.globals", "docs": "https://api.python.langchain.com/en/latest/globals/langchain.globals.set_debug.html", "title": "TextGen"}, {"imported": "TextGen", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.textgen.TextGen.html", "title": "TextGen"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "TextGen"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "TextGen"}]-->
from langchain.chains import LLMChain
from langchain.globals import set_debug
from langchain_community.llms import TextGen
from langchain_core.callbacks import StreamingStdOutCallbackHandler
from langchain_core.prompts import PromptTemplate

set_debug(True)

template = """Question: {question}

Answer: Let's think step by step."""


prompt = PromptTemplate.from_template(template)
llm = TextGen(
    model_url=model_url, streaming=True, callbacks=[StreamingStdOutCallbackHandler()]
)
llm_chain = LLMChain(prompt=prompt, llm=llm)
question = "What NFL team won the Super Bowl in the year Justin Bieber was born?"

llm_chain.run(question)
```


```python
llm = TextGen(model_url=model_url, streaming=True)
for chunk in llm.stream("Ask 'Hi, how are you?' like a pirate:'", stop=["'", "\n"]):
    print(chunk, end="", flush=True)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)