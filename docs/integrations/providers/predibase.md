---
description: LangChain과 Predibase 모델을 사용하는 방법에 대해 알아보세요. 설치, 인증 및 LLM 통합 예제를 포함합니다.
---

# Predibase

LangChain을 Predibase의 모델과 함께 사용하는 방법을 배우세요.

## 설정
- [Predibase](https://predibase.com/) 계정을 만들고 [API 키](https://docs.predibase.com/sdk-guide/intro)를 생성하세요.
- `pip install predibase`로 Predibase Python 클라이언트를 설치하세요.
- API 키를 사용하여 인증하세요.

### LLM

Predibase는 LLM 모듈을 구현하여 LangChain과 통합됩니다. 아래에 짧은 예제를 보거나 LLM > Integrations > Predibase 아래의 전체 노트북을 확인할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Predibase", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.predibase.Predibase.html", "title": "Predibase"}]-->
import os
os.environ["PREDIBASE_API_TOKEN"] = "{PREDIBASE_API_TOKEN}"

from langchain_community.llms import Predibase

model = Predibase(
    model="mistral-7b",
    predibase_api_key=os.environ.get("PREDIBASE_API_TOKEN"),
    predibase_sdk_version=None,  # optional parameter (defaults to the latest Predibase SDK version if omitted)
)

response = model.invoke("Can you recommend me a nice dry wine?")
print(response)
```


Predibase는 또한 `model` 인수로 제공된 기본 모델에 대해 미세 조정된 Predibase 호스팅 및 HuggingFace 호스팅 어댑터를 지원합니다:

```python
<!--IMPORTS:[{"imported": "Predibase", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.predibase.Predibase.html", "title": "Predibase"}]-->
import os
os.environ["PREDIBASE_API_TOKEN"] = "{PREDIBASE_API_TOKEN}"

from langchain_community.llms import Predibase

# The fine-tuned adapter is hosted at Predibase (adapter_version must be specified).
model = Predibase(
    model="mistral-7b",
    predibase_api_key=os.environ.get("PREDIBASE_API_TOKEN"),
    predibase_sdk_version=None,  # optional parameter (defaults to the latest Predibase SDK version if omitted)
    adapter_id="e2e_nlg",
    adapter_version=1,
)

response = model.invoke("Can you recommend me a nice dry wine?")
print(response)
```


Predibase는 또한 `model` 인수로 제공된 기본 모델에 대해 미세 조정된 어댑터를 지원합니다:

```python
<!--IMPORTS:[{"imported": "Predibase", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.predibase.Predibase.html", "title": "Predibase"}]-->
import os
os.environ["PREDIBASE_API_TOKEN"] = "{PREDIBASE_API_TOKEN}"

from langchain_community.llms import Predibase

# The fine-tuned adapter is hosted at HuggingFace (adapter_version does not apply and will be ignored).
model = Predibase(
    model="mistral-7b",
    predibase_api_key=os.environ.get("PREDIBASE_API_TOKEN"),
    predibase_sdk_version=None,  # optional parameter (defaults to the latest Predibase SDK version if omitted)
    adapter_id="predibase/e2e_nlg",
)

response = model.invoke("Can you recommend me a nice dry wine?")
print(response)
```