---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/edenai.ipynb
description: Eden AI는 최고의 AI 제공업체를 통합하여 사용자가 인공지능의 잠재력을 최대한 활용할 수 있도록 돕는 혁신적인 플랫폼입니다.
---

# 에덴 AI

에덴 AI는 최고의 AI 제공업체를 통합하여 AI 환경을 혁신하고, 사용자가 무한한 가능성을 열고 인공지능의 진정한 잠재력을 활용할 수 있도록 합니다. 올인원 종합 플랫폼을 통해 사용자는 AI 기능을 신속하게 배포할 수 있으며, 단일 API를 통해 AI 기능의 전체 범위에 쉽게 접근할 수 있습니다. (웹사이트: https://edenai.co/)

이 예제는 LangChain을 사용하여 에덴 AI 모델과 상호작용하는 방법을 설명합니다.

* * *

에덴 AI의 API에 접근하려면 API 키가 필요합니다.

API 키는 계정을 생성하여 https://app.edenai.run/user/register 에서 얻을 수 있으며, 여기 https://app.edenai.run/admin/account/settings 로 이동합니다.

키를 얻은 후에는 다음 명령어를 실행하여 환경 변수를 설정해야 합니다:

```bash
export EDENAI_API_KEY="..."
```


환경 변수를 설정하고 싶지 않다면, 에덴 AI LLM 클래스를 초기화할 때 edenai_api_key라는 이름의 매개변수를 통해 직접 키를 전달할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "EdenAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.edenai.EdenAI.html", "title": "Eden AI"}]-->
from langchain_community.llms import EdenAI
```


```python
llm = EdenAI(edenai_api_key="...", provider="openai", temperature=0.2, max_tokens=250)
```


## 모델 호출하기

에덴 AI API는 여러 제공업체를 통합하여 각기 다른 모델을 제공합니다.

특정 모델에 접근하려면 인스턴스화할 때 'model'을 추가하면 됩니다.

예를 들어, GPT3.5와 같은 OpenAI에서 제공하는 모델을 살펴보겠습니다.

### 텍스트 생성

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Eden AI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Eden AI"}]-->
from langchain.chains import LLMChain
from langchain_core.prompts import PromptTemplate

llm = EdenAI(
    feature="text",
    provider="openai",
    model="gpt-3.5-turbo-instruct",
    temperature=0.2,
    max_tokens=250,
)

prompt = """
User: Answer the following yes/no question by reasoning step by step. Can a dog drive a car?
Assistant:
"""

llm(prompt)
```


### 이미지 생성

```python
import base64
from io import BytesIO

from PIL import Image


def print_base64_image(base64_string):
    # Decode the base64 string into binary data
    decoded_data = base64.b64decode(base64_string)

    # Create an in-memory stream to read the binary data
    image_stream = BytesIO(decoded_data)

    # Open the image using PIL
    image = Image.open(image_stream)

    # Display the image
    image.show()
```


```python
text2image = EdenAI(feature="image", provider="openai", resolution="512x512")
```


```python
image_output = text2image("A cat riding a motorcycle by Picasso")
```


```python
print_base64_image(image_output)
```


### 콜백을 이용한 텍스트 생성

```python
<!--IMPORTS:[{"imported": "EdenAI", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.edenai.EdenAI.html", "title": "Eden AI"}, {"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "Eden AI"}]-->
from langchain_community.llms import EdenAI
from langchain_core.callbacks import StreamingStdOutCallbackHandler

llm = EdenAI(
    callbacks=[StreamingStdOutCallbackHandler()],
    feature="text",
    provider="openai",
    temperature=0.2,
    max_tokens=250,
)
prompt = """
User: Answer the following yes/no question by reasoning step by step. Can a dog drive a car?
Assistant:
"""
print(llm.invoke(prompt))
```


## 호출 체인

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Eden AI"}, {"imported": "SimpleSequentialChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.sequential.SimpleSequentialChain.html", "title": "Eden AI"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Eden AI"}]-->
from langchain.chains import LLMChain, SimpleSequentialChain
from langchain_core.prompts import PromptTemplate
```


```python
llm = EdenAI(feature="text", provider="openai", temperature=0.2, max_tokens=250)
text2image = EdenAI(feature="image", provider="openai", resolution="512x512")
```


```python
prompt = PromptTemplate(
    input_variables=["product"],
    template="What is a good name for a company that makes {product}?",
)

chain = LLMChain(llm=llm, prompt=prompt)
```


```python
second_prompt = PromptTemplate(
    input_variables=["company_name"],
    template="Write a description of a logo for this company: {company_name}, the logo should not contain text at all ",
)
chain_two = LLMChain(llm=llm, prompt=second_prompt)
```


```python
third_prompt = PromptTemplate(
    input_variables=["company_logo_description"],
    template="{company_logo_description}",
)
chain_three = LLMChain(llm=text2image, prompt=third_prompt)
```


```python
# Run the chain specifying only the input variable for the first chain.
overall_chain = SimpleSequentialChain(
    chains=[chain, chain_two, chain_three], verbose=True
)
output = overall_chain.run("hats")
```


```python
# print the image
print_base64_image(output)
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)