---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/gradient.ipynb
description: 이 문서는 Langchain을 사용하여 Gradient API를 통해 LLM을 미세 조정하고 완성을 얻는 방법을 설명합니다.
---

# 그래디언트

`Gradient`는 간단한 웹 API를 통해 LLM을 미세 조정하고 완성을 얻을 수 있게 해줍니다.

이 노트북에서는 Langchain을 [Gradient](https://gradient.ai/)와 함께 사용하는 방법을 다룹니다.

## 임포트

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Gradient"}, {"imported": "GradientLLM", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.gradient_ai.GradientLLM.html", "title": "Gradient"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Gradient"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import GradientLLM
from langchain_core.prompts import PromptTemplate
```


## 환경 API 키 설정
Gradient AI에서 API 키를 받아야 합니다. 다양한 모델을 테스트하고 미세 조정하기 위해 $10의 무료 크레딧이 제공됩니다.

```python
import os
from getpass import getpass

if not os.environ.get("GRADIENT_ACCESS_TOKEN", None):
    # Access token under https://auth.gradient.ai/select-workspace
    os.environ["GRADIENT_ACCESS_TOKEN"] = getpass("gradient.ai access token:")
if not os.environ.get("GRADIENT_WORKSPACE_ID", None):
    # `ID` listed in `$ gradient workspace list`
    # also displayed after login at at https://auth.gradient.ai/select-workspace
    os.environ["GRADIENT_WORKSPACE_ID"] = getpass("gradient.ai workspace id:")
```


선택 사항: 현재 배포된 모델을 얻기 위해 환경 변수 `GRADIENT_ACCESS_TOKEN` 및 `GRADIENT_WORKSPACE_ID`를 검증합니다. `gradientai` Python 패키지를 사용합니다.

```python
%pip install --upgrade --quiet  gradientai
```

```output
Requirement already satisfied: gradientai in /home/michi/.venv/lib/python3.10/site-packages (1.0.0)
Requirement already satisfied: aenum>=3.1.11 in /home/michi/.venv/lib/python3.10/site-packages (from gradientai) (3.1.15)
Requirement already satisfied: pydantic<2.0.0,>=1.10.5 in /home/michi/.venv/lib/python3.10/site-packages (from gradientai) (1.10.12)
Requirement already satisfied: python-dateutil>=2.8.2 in /home/michi/.venv/lib/python3.10/site-packages (from gradientai) (2.8.2)
Requirement already satisfied: urllib3>=1.25.3 in /home/michi/.venv/lib/python3.10/site-packages (from gradientai) (1.26.16)
Requirement already satisfied: typing-extensions>=4.2.0 in /home/michi/.venv/lib/python3.10/site-packages (from pydantic<2.0.0,>=1.10.5->gradientai) (4.5.0)
Requirement already satisfied: six>=1.5 in /home/michi/.venv/lib/python3.10/site-packages (from python-dateutil>=2.8.2->gradientai) (1.16.0)
```


```python
import gradientai

client = gradientai.Gradient()

models = client.list_models(only_base=True)
for model in models:
    print(model.id)
```

```output
99148c6d-c2a0-4fbe-a4a7-e7c05bdb8a09_base_ml_model
f0b97d96-51a8-4040-8b22-7940ee1fa24e_base_ml_model
cc2dafce-9e6e-4a23-a918-cad6ba89e42e_base_ml_model
```


```python
new_model = models[-1].create_model_adapter(name="my_model_adapter")
new_model.id, new_model.name
```


```output
('674119b5-f19e-4856-add2-767ae7f7d7ef_model_adapter', 'my_model_adapter')
```


## 그래디언트 인스턴스 생성
모델, 생성된 최대 토큰 수, 온도 등과 같은 다양한 매개변수를 지정할 수 있습니다.

나중에 모델을 미세 조정하고자 하므로, `674119b5-f19e-4856-add2-767ae7f7d7ef_model_adapter` ID의 model_adapter를 선택하지만, 기본 모델이나 미세 조정 가능한 모델을 사용할 수 있습니다.

```python
llm = GradientLLM(
    # `ID` listed in `$ gradient model list`
    model="674119b5-f19e-4856-add2-767ae7f7d7ef_model_adapter",
    # # optional: set new credentials, they default to environment variables
    # gradient_workspace_id=os.environ["GRADIENT_WORKSPACE_ID"],
    # gradient_access_token=os.environ["GRADIENT_ACCESS_TOKEN"],
    model_kwargs=dict(max_generated_token_count=128),
)
```


## 프롬프트 템플릿 생성
질문과 답변을 위한 프롬프트 템플릿을 생성합니다.

```python
template = """Question: {question}

Answer: """

prompt = PromptTemplate.from_template(template)
```


## LLMChain 시작

```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


## LLMChain 실행
질문을 제공하고 LLMChain을 실행합니다.

```python
question = "What NFL team won the Super Bowl in 1994?"

llm_chain.run(question=question)
```


```output
'\nThe San Francisco 49ers won the Super Bowl in 1994.'
```


# 결과 개선하기 (선택 사항)
음 - 그건 잘못된 정보입니다 - 샌프란시스코 49ers는 이기지 않았습니다.
질문에 대한 올바른 답변은 `댈러스 카우보이스!`입니다.

프롬프트 템플릿을 사용하여 올바른 답변에 대해 미세 조정하여 정답의 확률을 높여보겠습니다.

```python
dataset = [
    {
        "inputs": template.format(question="What NFL team won the Super Bowl in 1994?")
        + " The Dallas Cowboys!"
    }
]
dataset
```


```output
[{'inputs': 'Question: What NFL team won the Super Bowl in 1994?\n\nAnswer:  The Dallas Cowboys!'}]
```


```python
new_model.fine_tune(samples=dataset)
```


```output
FineTuneResponse(number_of_trainable_tokens=27, sum_loss=78.17996)
```


```python
# we can keep the llm_chain, as the registered model just got refreshed on the gradient.ai servers.
llm_chain.run(question=question)
```


```output
'The Dallas Cowboys'
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)