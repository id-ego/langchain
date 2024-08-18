---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/openllm.ipynb
description: OpenLLM은 오픈소스 대형 언어 모델을 운영하고, 클라우드 또는 온프레미스에 배포하여 강력한 AI 앱을 구축할 수 있는
  플랫폼입니다.
---

# OpenLLM

[🦾 OpenLLM](https://github.com/bentoml/OpenLLM)은 대규모 언어 모델(LLM)을 운영하기 위한 개방형 플랫폼입니다. 개발자가 오픈 소스 LLM으로 쉽게 추론을 실행하고, 클라우드 또는 온프레미스에 배포하며, 강력한 AI 앱을 구축할 수 있도록 합니다.

## 설치

[PyPI](https://pypi.org/project/openllm/)를 통해 `openllm`을 설치합니다.

```python
%pip install --upgrade --quiet  openllm
```


## OpenLLM 서버 로컬에서 시작하기

LLM 서버를 시작하려면 `openllm start` 명령어를 사용합니다. 예를 들어, dolly-v2 서버를 시작하려면 터미널에서 다음 명령어를 실행합니다:

```bash
openllm start dolly-v2
```


## 래퍼

```python
<!--IMPORTS:[{"imported": "OpenLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.openllm.OpenLLM.html", "title": "OpenLLM"}]-->
from langchain_community.llms import OpenLLM

server_url = "http://localhost:3000"  # Replace with remote host if you are running on a remote server
llm = OpenLLM(server_url=server_url)
```


### 선택 사항: 로컬 LLM 추론

현재 프로세스에서 OpenLLM이 관리하는 LLM을 로컬에서 초기화할 수도 있습니다. 이는 개발 목적으로 유용하며 개발자가 다양한 유형의 LLM을 빠르게 시도할 수 있도록 합니다.

LLM 애플리케이션을 프로덕션으로 이동할 때는 OpenLLM 서버를 별도로 배포하고 위에서 설명한 `server_url` 옵션을 통해 접근하는 것을 권장합니다.

LangChain 래퍼를 통해 로컬에서 LLM을 로드하려면:

```python
<!--IMPORTS:[{"imported": "OpenLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.openllm.OpenLLM.html", "title": "OpenLLM"}]-->
from langchain_community.llms import OpenLLM

llm = OpenLLM(
    model_name="dolly-v2",
    model_id="databricks/dolly-v2-3b",
    temperature=0.94,
    repetition_penalty=1.2,
)
```


### LLMChain과 통합하기

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "OpenLLM"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "OpenLLM"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

template = "What is a good name for a company that makes {product}?"

prompt = PromptTemplate.from_template(template)

llm_chain = LLMChain(prompt=prompt, llm=llm)

generated = llm_chain.run(product="mechanical keyboard")
print(generated)
```

```output
iLkb
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)