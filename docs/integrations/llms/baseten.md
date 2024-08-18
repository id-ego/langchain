---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/baseten.ipynb
description: Baseten은 LangChain 생태계에서 LLMs 컴포넌트를 구현하는 제공업체로, Mistral 7B 모델을 사용한 예제를
  제공합니다.
---

# Baseten

[Baseten](https://baseten.co)는 LLMs 구성 요소를 구현하는 LangChain 생태계의 [공급자](/docs/integrations/providers/baseten)입니다.

이 예제는 LangChain과 함께 Baseten에서 호스팅되는 LLM인 Mistral 7B를 사용하는 방법을 보여줍니다.

# 설정

이 예제를 실행하려면 다음이 필요합니다:

* [Baseten 계정](https://baseten.co)
* [API 키](https://docs.baseten.co/observability/api-keys)

API 키를 `BASETEN_API_KEY`라는 환경 변수로 내보내십시오.

```sh
export BASETEN_API_KEY="paste_your_api_key_here"
```


# 단일 모델 호출

먼저, Baseten에 모델을 배포해야 합니다.

Mistral 및 Llama 2와 같은 기본 모델을 [Baseten 모델 라이브러리](https://app.baseten.co/explore/)에서 한 번의 클릭으로 배포하거나, 자신의 모델이 있는 경우 [Truss로 배포](https://truss.baseten.co/welcome)할 수 있습니다.

이 예제에서는 Mistral 7B로 작업할 것입니다. [여기에서 Mistral 7B를 배포](https://app.baseten.co/explore/mistral_7b_instruct)하고 모델 대시보드에서 찾은 배포된 모델의 ID를 따라가십시오.

```python
##Installing the langchain packages needed to use the integration
%pip install -qU langchain-community
```


```python
<!--IMPORTS:[{"imported": "Baseten", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.baseten.Baseten.html", "title": "Baseten"}]-->
from langchain_community.llms import Baseten
```


```python
# Load the model
mistral = Baseten(model="MODEL_ID", deployment="production")
```


```python
# Prompt the model
mistral("What is the Mistral wind?")
```


# 체인 모델 호출

우리는 하나 또는 여러 모델에 대한 여러 호출을 연결할 수 있으며, 이것이 Langchain의 핵심입니다!

예를 들어, 이 터미널 에뮬레이션 데모에서 GPT를 Mistral로 교체할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Baseten"}, {"imported": "ConversationBufferWindowMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer_window.ConversationBufferWindowMemory.html", "title": "Baseten"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Baseten"}]-->
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferWindowMemory
from langchain_core.prompts import PromptTemplate

template = """Assistant is a large language model trained by OpenAI.

Assistant is designed to be able to assist with a wide range of tasks, from answering simple questions to providing in-depth explanations and discussions on a wide range of topics. As a language model, Assistant is able to generate human-like text based on the input it receives, allowing it to engage in natural-sounding conversations and provide responses that are coherent and relevant to the topic at hand.

Assistant is constantly learning and improving, and its capabilities are constantly evolving. It is able to process and understand large amounts of text, and can use this knowledge to provide accurate and informative responses to a wide range of questions. Additionally, Assistant is able to generate its own text based on the input it receives, allowing it to engage in discussions and provide explanations and descriptions on a wide range of topics.

Overall, Assistant is a powerful tool that can help with a wide range of tasks and provide valuable insights and information on a wide range of topics. Whether you need help with a specific question or just want to have a conversation about a particular topic, Assistant is here to assist.

{history}
Human: {human_input}
Assistant:"""

prompt = PromptTemplate(input_variables=["history", "human_input"], template=template)


chatgpt_chain = LLMChain(
    llm=mistral,
    llm_kwargs={"max_length": 4096},
    prompt=prompt,
    verbose=True,
    memory=ConversationBufferWindowMemory(k=2),
)

output = chatgpt_chain.predict(
    human_input="I want you to act as a Linux terminal. I will type commands and you will reply with what the terminal should show. I want you to only reply with the terminal output inside one unique code block, and nothing else. Do not write explanations. Do not type commands unless I instruct you to do so. When I need to tell you something in English I will do so by putting text inside curly brackets {like this}. My first command is pwd."
)
print(output)
```


```python
output = chatgpt_chain.predict(human_input="ls ~")
print(output)
```


```python
output = chatgpt_chain.predict(human_input="cd ~")
print(output)
```


```python
output = chatgpt_chain.predict(
    human_input="""echo -e "x=lambda y:y*5+3;print('Result:' + str(x(6)))" > run.py && python3 run.py"""
)
print(output)
```


마지막 예제에서 볼 수 있듯이, 올바를 수도 있고 아닐 수도 있는 숫자를 출력하는 모델은 제공된 명령을 실제로 실행하는 것이 아니라, 가능성 있는 터미널 출력을 근사하고 있습니다. 그럼에도 불구하고 이 예제는 Mistral의 넓은 컨텍스트 창, 코드 생성 능력 및 대화 시퀀스에서도 주제를 유지하는 능력을 보여줍니다.

## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)