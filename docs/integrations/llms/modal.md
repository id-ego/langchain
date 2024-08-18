---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/modal.ipynb
description: Modal 클라우드 플랫폼을 사용하여 Python 스크립트로 서버리스 클라우드 컴퓨팅에 접근하고 LangChain과 통합하는
  방법을 설명합니다.
---

# 모달

[모달 클라우드 플랫폼](https://modal.com/docs/guide)은 로컬 컴퓨터의 Python 스크립트에서 서버리스 클라우드 컴퓨팅에 대한 편리한 주문형 액세스를 제공합니다.  
`modal`을 사용하여 LLM API에 의존하는 대신 자신만의 맞춤형 LLM 모델을 실행하세요.

이 예제는 LangChain을 사용하여 `modal` HTTPS [웹 엔드포인트](https://modal.com/docs/guide/webhooks)와 상호작용하는 방법을 설명합니다.

[*LangChain을 이용한 질문-답변*](https://modal.com/docs/guide/ex/potus_speech_qanda)은 `Modal`과 함께 LangChain을 사용하는 또 다른 예제입니다. 이 예제에서 Modal은 LangChain 애플리케이션을 엔드 투 엔드로 실행하고 OpenAI를 LLM API로 사용합니다.

```python
%pip install --upgrade --quiet  modal
```


```python
# Register an account with Modal and get a new token.

!modal token new
```
  
```output
Launching login page in your browser window...
If this is not showing up, please copy this URL into your web browser manually:
https://modal.com/token-flow/tf-Dzm3Y01234mqmm1234Vcu3
```
  
[`langchain.llms.modal.Modal`](https://github.com/langchain-ai/langchain/blame/master/langchain/llms/modal.py) 통합 클래스는 다음 JSON 인터페이스를 준수하는 웹 엔드포인트가 있는 Modal 애플리케이션을 배포해야 합니다:

1. LLM 프롬프트는 `"prompt"` 키 아래에 `str` 값으로 수락됩니다.
2. LLM 응답은 `"prompt"` 키 아래에 `str` 값으로 반환됩니다.

**예제 요청 JSON:**

```json
{
    "prompt": "Identify yourself, bot!",
    "extra": "args are allowed",
}
```


**예제 응답 JSON:**

```json
{
    "prompt": "This is the LLM speaking",
}
```


이 인터페이스를 충족하는 '더미' Modal 웹 엔드포인트 함수의 예는 다음과 같습니다.

```python
...
...

class Request(BaseModel):
    prompt: str

@stub.function()
@modal.web_endpoint(method="POST")
def web(request: Request):
    _ = request  # ignore input
    return {"prompt": "hello world"}
```


* 이 인터페이스를 충족하는 엔드포인트를 설정하는 기본 사항은 Modal의 [웹 엔드포인트](https://modal.com/docs/guide/webhooks#passing-arguments-to-web-endpoints) 가이드를 참조하세요.  
* 맞춤형 LLM을 위한 출발점으로 Modal의 ['AutoGPTQ로 Falcon-40B 실행하기'](https://modal.com/docs/guide/ex/falcon_gptq) 오픈 소스 LLM 예제를 참조하세요!

배포된 Modal 웹 엔드포인트가 있으면 그 URL을 `langchain.llms.modal.Modal` LLM 클래스에 전달할 수 있습니다. 이 클래스는 체인의 빌딩 블록으로 기능할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Modal"}, {"imported": "Modal", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.modal.Modal.html", "title": "Modal"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Modal"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import Modal
from langchain_core.prompts import PromptTemplate
```


```python
template = """Question: {question}

Answer: Let's think step by step."""

prompt = PromptTemplate.from_template(template)
```


```python
endpoint_url = "https://ecorp--custom-llm-endpoint.modal.run"  # REPLACE ME with your deployed Modal web endpoint's URL
llm = Modal(endpoint_url=endpoint_url)
```


```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


```python
question = "What NFL team won the Super Bowl in the year Justin Beiber was born?"

llm_chain.run(question)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)  
- LLM [사용 방법 가이드](/docs/how_to/#llms)