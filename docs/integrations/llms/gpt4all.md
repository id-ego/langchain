---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/gpt4all.ipynb
description: GPT4All은 코드, 이야기 및 대화를 포함한 방대한 데이터로 훈련된 오픈소스 챗봇 생태계입니다. LangChain을 통해
  상호작용하는 방법을 설명합니다.
---

# GPT4All

[GitHub:nomic-ai/gpt4all](https://github.com/nomic-ai/gpt4all) 대규모의 깨끗한 어시스턴트 데이터(코드, 이야기 및 대화 포함)로 훈련된 오픈 소스 챗봇의 생태계입니다.

이 예제는 LangChain을 사용하여 `GPT4All` 모델과 상호작용하는 방법을 설명합니다.

```python
%pip install --upgrade --quiet langchain-community gpt4all
```


### GPT4All 가져오기

```python
<!--IMPORTS:[{"imported": "GPT4All", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.gpt4all.GPT4All.html", "title": "GPT4All"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "GPT4All"}]-->
from langchain_community.llms import GPT4All
from langchain_core.prompts import PromptTemplate
```


### LLM에 전달할 질문 설정

```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


### 모델 지정

로컬에서 실행하려면 호환 가능한 ggml 형식의 모델을 다운로드하십시오.

[gpt4all 페이지](https://gpt4all.io/index.html)에는 유용한 `모델 탐색기` 섹션이 있습니다:

* 관심 있는 모델 선택
* UI를 사용하여 다운로드하고 `.bin` 파일을 `local_path`로 이동합니다(아래에 명시됨)

자세한 내용은 https://github.com/nomic-ai/gpt4all를 방문하십시오.

* * *

이 통합은 아직 [`.stream()`](https://python.langchain.com/v0.2/docs/how_to/streaming/) 메서드를 통해 청크로 스트리밍하는 것을 지원하지 않습니다. 아래 예제는 `streaming=True`와 함께 콜백 핸들러를 사용합니다:

```python
local_path = (
    "./models/Meta-Llama-3-8B-Instruct.Q4_0.gguf"  # replace with your local file path
)
```


```python
<!--IMPORTS:[{"imported": "BaseCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.base.BaseCallbackHandler.html", "title": "GPT4All"}]-->
from langchain_core.callbacks import BaseCallbackHandler

count = 0


class MyCustomHandler(BaseCallbackHandler):
    def on_llm_new_token(self, token: str, **kwargs) -> None:
        global count
        if count < 10:
            print(f"Token: {token}")
            count += 1


# Verbose is required to pass to the callback manager
llm = GPT4All(model=local_path, callbacks=[MyCustomHandler()], streaming=True)

# If you want to use a custom model add the backend parameter
# Check https://docs.gpt4all.io/gpt4all_python.html for supported backends
# llm = GPT4All(model=local_path, backend="gptj", callbacks=callbacks, streaming=True)

chain = prompt | llm

question = "What NFL team won the Super Bowl in the year Justin Bieber was born?"

# Streamed tokens will be logged/aggregated via the passed callback
res = chain.invoke({"question": question})
```

```output
Token:  Justin
Token:  Bieber
Token:  was
Token:  born
Token:  on
Token:  March
Token:  
Token: 1
Token: ,
Token:
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)