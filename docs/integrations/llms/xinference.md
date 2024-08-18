---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/xinference.ipynb
description: Xinference는 LLM, 음성 인식 모델 및 다중 모달 모델을 지원하는 강력한 라이브러리로, 로컬 및 분산 클러스터에서
  사용할 수 있습니다.
---

# Xorbits Inference (Xinference)

[Xinference](https://github.com/xorbitsai/inference)는 LLM, 음성 인식 모델 및 멀티모달 모델을 지원하도록 설계된 강력하고 다재다능한 라이브러리입니다. 이 라이브러리는 노트북에서도 사용할 수 있습니다. chatglm, baichuan, whisper, vicuna, orca 등 GGML과 호환되는 다양한 모델을 지원합니다. 이 노트북은 LangChain과 함께 Xinference를 사용하는 방법을 보여줍니다.

## 설치

PyPI를 통해 `Xinference`를 설치하세요:

```python
%pip install --upgrade --quiet  "xinference[all]"
```


## Xinference를 로컬 또는 분산 클러스터에 배포하기

로컬 배포를 위해 `xinference`를 실행하세요.

클러스터에 Xinference를 배포하려면 먼저 `xinference-supervisor`를 사용하여 Xinference 감독자를 시작하세요. 포트를 지정하려면 -p 옵션을, 호스트를 지정하려면 -H 옵션을 사용할 수 있습니다. 기본 포트는 9997입니다.

그런 다음, 각 서버에서 `xinference-worker`를 사용하여 Xinference 작업자를 시작하세요.

자세한 정보는 [Xinference](https://github.com/xorbitsai/inference)의 README 파일을 참조하세요.
## 래퍼

LangChain과 함께 Xinference를 사용하려면 먼저 모델을 시작해야 합니다. 이를 위해 명령줄 인터페이스(CLI)를 사용할 수 있습니다:

```python
!xinference launch -n vicuna-v1.3 -f ggmlv3 -q q4_0
```

```output
Model uid: 7167b2b0-2a04-11ee-83f0-d29396a3f064
```

모델 UID가 반환되어 사용 가능합니다. 이제 LangChain과 함께 Xinference를 사용할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "Xinference", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.xinference.Xinference.html", "title": "Xorbits Inference (Xinference)"}]-->
from langchain_community.llms import Xinference

llm = Xinference(
    server_url="http://0.0.0.0:9997", model_uid="7167b2b0-2a04-11ee-83f0-d29396a3f064"
)

llm(
    prompt="Q: where can we visit in the capital of France? A:",
    generate_config={"max_tokens": 1024, "stream": True},
)
```


```output
' You can visit the Eiffel Tower, Notre-Dame Cathedral, the Louvre Museum, and many other historical sites in Paris, the capital of France.'
```


### LLMChain과 통합하기

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Xorbits Inference (Xinference)"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Xorbits Inference (Xinference)"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

template = "Where can we visit in the capital of {country}?"

prompt = PromptTemplate.from_template(template)

llm_chain = LLMChain(prompt=prompt, llm=llm)

generated = llm_chain.run(country="France")
print(generated)
```

```output

A: You can visit many places in Paris, such as the Eiffel Tower, the Louvre Museum, Notre-Dame Cathedral, the Champs-Elysées, Montmartre, Sacré-Cœur, and the Palace of Versailles.
```

마지막으로, 더 이상 모델을 사용할 필요가 없을 때 모델을 종료하세요:

```python
!xinference terminate --model-uid "7167b2b0-2a04-11ee-83f0-d29396a3f064"
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)