---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/openlm.ipynb
description: OpenLM은 HTTP를 통해 다양한 추론 엔드포인트를 호출할 수 있는 OpenAI 호환 LLM 제공업체입니다. LangChain과의
  사용법을 안내합니다.
---

# OpenLM
[OpenLM](https://github.com/r2d4/openlm)은 다양한 추론 엔드포인트를 HTTP를 통해 직접 호출할 수 있는 제로 의존성 OpenAI 호환 LLM 제공자입니다.

OpenAI API의 드롭인 대체로 사용될 수 있도록 OpenAI Completion 클래스를 구현합니다. 이 변경 사항은 최소한의 추가 코드로 BaseOpenAI를 활용합니다.

이 예제에서는 LangChain을 사용하여 OpenAI와 HuggingFace 모두와 상호작용하는 방법을 설명합니다. 두 API 키가 필요합니다.

### 설정
종속성을 설치하고 API 키를 설정합니다.

```python
# Uncomment to install openlm and openai if you haven't already

%pip install --upgrade --quiet  openlm
%pip install --upgrade --quiet  langchain-openai
```


```python
import os
from getpass import getpass

# Check if OPENAI_API_KEY environment variable is set
if "OPENAI_API_KEY" not in os.environ:
    print("Enter your OpenAI API key:")
    os.environ["OPENAI_API_KEY"] = getpass()

# Check if HF_API_TOKEN environment variable is set
if "HF_API_TOKEN" not in os.environ:
    print("Enter your HuggingFace Hub API key:")
    os.environ["HF_API_TOKEN"] = getpass()
```


### OpenLM과 함께 LangChain 사용하기

여기서는 LLMChain에서 두 모델, OpenAI의 `text-davinci-003`과 HuggingFace의 `gpt2`를 호출할 것입니다.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "OpenLM"}, {"imported": "OpenLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.openlm.OpenLM.html", "title": "OpenLM"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "OpenLM"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import OpenLM
from langchain_core.prompts import PromptTemplate
```


```python
question = "What is the capital of France?"
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)

for model in ["text-davinci-003", "huggingface.co/gpt2"]:
    llm = OpenLM(model=model)
    llm_chain = LLMChain(prompt=prompt, llm=llm)
    result = llm_chain.run(question)
    print(
        """Model: {}
Result: {}""".format(model, result)
    )
```

```output
Model: text-davinci-003
Result:  France is a country in Europe. The capital of France is Paris.
Model: huggingface.co/gpt2
Result: Question: What is the capital of France?

Answer: Let's think step by step. I am not going to lie, this is a complicated issue, and I don't see any solutions to all this, but it is still far more
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)