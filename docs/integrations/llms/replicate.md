---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/replicate.ipynb
description: Replicate는 클라우드에서 머신러닝 모델을 실행할 수 있는 플랫폼으로, LangChain을 통해 모델과 상호작용하는 방법을
  설명합니다.
---

# 복제

> [복제](https://replicate.com/blog/machine-learning-needs-better-tools)는 클라우드에서 머신 러닝 모델을 실행합니다. 몇 줄의 코드로 실행할 수 있는 오픈 소스 모델 라이브러리가 있습니다. 자신의 머신 러닝 모델을 구축하는 경우, 복제를 통해 대규모로 배포하는 것이 용이합니다.

이 예제는 LangChain을 사용하여 `복제` [모델](https://replicate.com/explore)과 상호작용하는 방법을 설명합니다.

## 설정

```python
# magics to auto-reload external modules in case you are making changes to langchain while working on this notebook
%load_ext autoreload
%autoreload 2
```


이 노트북을 실행하려면 [복제](https://replicate.com) 계정을 만들고 [복제 파이썬 클라이언트](https://github.com/replicate/replicate-python)를 설치해야 합니다.

```python
!poetry run pip install replicate
```

```output
Collecting replicate
  Using cached replicate-0.25.1-py3-none-any.whl.metadata (24 kB)
Requirement already satisfied: httpx<1,>=0.21.0 in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from replicate) (0.24.1)
Requirement already satisfied: packaging in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from replicate) (23.2)
Requirement already satisfied: pydantic>1.10.7 in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from replicate) (1.10.14)
Requirement already satisfied: typing-extensions>=4.5.0 in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from replicate) (4.10.0)
Requirement already satisfied: certifi in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from httpx<1,>=0.21.0->replicate) (2024.2.2)
Requirement already satisfied: httpcore<0.18.0,>=0.15.0 in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from httpx<1,>=0.21.0->replicate) (0.17.3)
Requirement already satisfied: idna in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from httpx<1,>=0.21.0->replicate) (3.6)
Requirement already satisfied: sniffio in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from httpx<1,>=0.21.0->replicate) (1.3.1)
Requirement already satisfied: h11<0.15,>=0.13 in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from httpcore<0.18.0,>=0.15.0->httpx<1,>=0.21.0->replicate) (0.14.0)
Requirement already satisfied: anyio<5.0,>=3.0 in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from httpcore<0.18.0,>=0.15.0->httpx<1,>=0.21.0->replicate) (3.7.1)
Requirement already satisfied: exceptiongroup in /Users/charlieholtz/miniconda3/envs/langchain/lib/python3.9/site-packages (from anyio<5.0,>=3.0->httpcore<0.18.0,>=0.15.0->httpx<1,>=0.21.0->replicate) (1.2.0)
Using cached replicate-0.25.1-py3-none-any.whl (39 kB)
Installing collected packages: replicate
Successfully installed replicate-0.25.1
```


```python
# get a token: https://replicate.com/account

from getpass import getpass

REPLICATE_API_TOKEN = getpass()
```


```python
import os

os.environ["REPLICATE_API_TOKEN"] = REPLICATE_API_TOKEN
```


```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Replicate"}, {"imported": "Replicate", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.replicate.Replicate.html", "title": "Replicate"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Replicate"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import Replicate
from langchain_core.prompts import PromptTemplate
```


## 모델 호출

[복제 탐색 페이지](https://replicate.com/explore)에서 모델을 찾아 모델 이름과 버전을 다음 형식으로 붙여넣습니다: model_name/version.

예를 들어, 여기 [`Meta Llama 3`](https://replicate.com/meta/meta-llama-3-8b-instruct)가 있습니다.

```python
llm = Replicate(
    model="meta/meta-llama-3-8b-instruct",
    model_kwargs={"temperature": 0.75, "max_length": 500, "top_p": 1},
)
prompt = """
User: Answer the following yes/no question by reasoning step by step. Can a dog drive a car?
Assistant:
"""
llm(prompt)
```


```output
"Let's break this down step by step:\n\n1. A dog is a living being, specifically a mammal.\n2. Dogs do not possess the cognitive abilities or physical characteristics necessary to operate a vehicle, such as a car.\n3. Operating a car requires complex mental and physical abilities, including:\n\t* Understanding of traffic laws and rules\n\t* Ability to read and comprehend road signs\n\t* Ability to make decisions quickly and accurately\n\t* Ability to physically manipulate the vehicle's controls (e.g., steering wheel, pedals)\n4. Dogs do not possess any of these abilities. They are unable to read or comprehend written language, let alone complex traffic laws.\n5. Dogs also lack the physical dexterity and coordination to operate a vehicle's controls. Their paws and claws are not adapted for grasping or manipulating small, precise objects like a steering wheel or pedals.\n6. Therefore, it is not possible for a dog to drive a car.\n\nAnswer: No."
```


또 다른 예로, 이 [dolly 모델](https://replicate.com/replicate/dolly-v2-12b)의 경우 API 탭을 클릭합니다. 모델 이름/버전은 다음과 같습니다: `replicate/dolly-v2-12b:ef0e1aefc61f8e096ebe4db6b2bacc297daf2ef6899f0f7e001ec445893500e5`

`model` 매개변수만 필요하지만, 초기화할 때 다른 모델 매개변수를 추가할 수 있습니다.

예를 들어, 안정적인 확산을 실행하고 이미지 크기를 변경하고 싶다면:

```
Replicate(model="stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", input={'image_dimensions': '512x512'})
```


*모델의 첫 번째 출력만 반환됩니다.*

```python
llm = Replicate(
    model="replicate/dolly-v2-12b:ef0e1aefc61f8e096ebe4db6b2bacc297daf2ef6899f0f7e001ec445893500e5"
)
```


```python
prompt = """
Answer the following yes/no question by reasoning step by step.
Can a dog drive a car?
"""
llm(prompt)
```


```output
'No, dogs lack some of the brain functions required to operate a motor vehicle. They cannot focus and react in time to accelerate or brake correctly. Additionally, they do not have enough muscle control to properly operate a steering wheel.\n\n'
```


이 구문을 사용하여 모든 복제 모델을 호출할 수 있습니다. 예를 들어, 안정적인 확산을 호출할 수 있습니다.

```python
text2image = Replicate(
    model="stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf",
    model_kwargs={"image_dimensions": "512x512"},
)
```


```python
image_output = text2image("A cat riding a motorcycle by Picasso")
image_output
```


```output
'https://pbxt.replicate.delivery/bqQq4KtzwrrYL9Bub9e7NvMTDeEMm5E9VZueTXkLE7kWumIjA/out-0.png'
```


모델은 URL을 생성합니다. 이를 렌더링해 봅시다.

```python
!poetry run pip install Pillow
```

```output
Requirement already satisfied: Pillow in /Users/bagatur/langchain/.venv/lib/python3.9/site-packages (9.5.0)

[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m A new release of pip is available: [0m[31;49m23.2[0m[39;49m -> [0m[32;49m23.2.1[0m
[1m[[0m[34;49mnotice[0m[1;39;49m][0m[39;49m To update, run: [0m[32;49mpip install --upgrade pip[0m
```


```python
from io import BytesIO

import requests
from PIL import Image

response = requests.get(image_output)
img = Image.open(BytesIO(response.content))

img
```


## 스트리밍 응답
생성되는 동안 응답을 스트리밍할 수 있으며, 이는 시간이 많이 소요되는 생성물에 대해 사용자에게 상호작용성을 보여주는 데 유용합니다. 자세한 내용은 [스트리밍](/docs/how_to/streaming_llm) 문서를 참조하세요.

```python
<!--IMPORTS:[{"imported": "StreamingStdOutCallbackHandler", "source": "langchain_core.callbacks", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_core.callbacks.streaming_stdout.StreamingStdOutCallbackHandler.html", "title": "Replicate"}]-->
from langchain_core.callbacks import StreamingStdOutCallbackHandler

llm = Replicate(
    streaming=True,
    callbacks=[StreamingStdOutCallbackHandler()],
    model="a16z-infra/llama13b-v2-chat:df7690f1994d94e96ad9d568eac121aecf50684a0b0963b25a41cc40061269e5",
    model_kwargs={"temperature": 0.75, "max_length": 500, "top_p": 1},
)
prompt = """
User: Answer the following yes/no question by reasoning step by step. Can a dog drive a car?
Assistant:
"""
_ = llm.invoke(prompt)
```

```output
1. Dogs do not have the physical ability to operate a vehicle.
```

# 중지 시퀀스
중지 시퀀스를 지정할 수도 있습니다. 생성에 대해 확실한 중지 시퀀스가 있는 경우, 하나 이상의 중지 시퀀스에 도달하면 생성 작업을 취소하는 것이 더 좋습니다(비용이 저렴하고 빠릅니다!). 중지 시퀀스는 스트리밍 모드 여부와 관계없이 작동하며, 복제는 중지 시퀀스까지의 생성에 대해서만 요금을 부과합니다.

```python
import time

llm = Replicate(
    model="a16z-infra/llama13b-v2-chat:df7690f1994d94e96ad9d568eac121aecf50684a0b0963b25a41cc40061269e5",
    model_kwargs={"temperature": 0.01, "max_length": 500, "top_p": 1},
)

prompt = """
User: What is the best way to learn python?
Assistant:
"""
start_time = time.perf_counter()
raw_output = llm.invoke(prompt)  # raw output, no stop
end_time = time.perf_counter()
print(f"Raw output:\n {raw_output}")
print(f"Raw output runtime: {end_time - start_time} seconds")

start_time = time.perf_counter()
stopped_output = llm.invoke(prompt, stop=["\n\n"])  # stop on double newlines
end_time = time.perf_counter()
print(f"Stopped output:\n {stopped_output}")
print(f"Stopped output runtime: {end_time - start_time} seconds")
```

```output
Raw output:
 There are several ways to learn Python, and the best method for you will depend on your learning style and goals. Here are a few suggestions:

1. Online tutorials and courses: Websites such as Codecademy, Coursera, and edX offer interactive coding lessons and courses that can help you get started with Python. These courses are often designed for beginners and cover the basics of Python programming.
2. Books: There are many books available that can teach you Python, ranging from introductory texts to more advanced manuals. Some popular options include "Python Crash Course" by Eric Matthes, "Automate the Boring Stuff with Python" by Al Sweigart, and "Python for Data Analysis" by Wes McKinney.
3. Videos: YouTube and other video platforms have a wealth of tutorials and lectures on Python programming. Many of these videos are created by experienced programmers and can provide detailed explanations and examples of Python concepts.
4. Practice: One of the best ways to learn Python is to practice writing code. Start with simple programs and gradually work your way up to more complex projects. As you gain experience, you'll become more comfortable with the language and develop a better understanding of its capabilities.
5. Join a community: There are many online communities and forums dedicated to Python programming, such as Reddit's r/learnpython community. These communities can provide support, resources, and feedback as you learn.
6. Take online courses: Many universities and organizations offer online courses on Python programming. These courses can provide a structured learning experience and often include exercises and assignments to help you practice your skills.
7. Use a Python IDE: An Integrated Development Environment (IDE) is a software application that provides an interface for writing, debugging, and testing code. Popular Python IDEs include PyCharm, Visual Studio Code, and Spyder. These tools can help you write more efficient code and provide features such as code completion, debugging, and project management.


Which of the above options do you think is the best way to learn Python?
Raw output runtime: 25.27470933299992 seconds
Stopped output:
 There are several ways to learn Python, and the best method for you will depend on your learning style and goals. Here are some suggestions:
Stopped output runtime: 25.77039254200008 seconds
```

## 호출 체인
LangChain의 전체 목적은... 체인입니다! 다음은 이를 수행하는 방법의 예입니다.

```python
<!--IMPORTS:[{"imported": "SimpleSequentialChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.sequential.SimpleSequentialChain.html", "title": "Replicate"}]-->
from langchain.chains import SimpleSequentialChain
```


먼저, 이 모델의 LLM을 flan-5로 정의하고 text2image를 안정적인 확산 모델로 정의합시다.

```python
dolly_llm = Replicate(
    model="replicate/dolly-v2-12b:ef0e1aefc61f8e096ebe4db6b2bacc297daf2ef6899f0f7e001ec445893500e5"
)
text2image = Replicate(
    model="stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"
)
```


체인의 첫 번째 프롬프트

```python
prompt = PromptTemplate(
    input_variables=["product"],
    template="What is a good name for a company that makes {product}?",
)

chain = LLMChain(llm=dolly_llm, prompt=prompt)
```


회사 설명을 위한 로고를 얻기 위한 두 번째 프롬프트

```python
second_prompt = PromptTemplate(
    input_variables=["company_name"],
    template="Write a description of a logo for this company: {company_name}",
)
chain_two = LLMChain(llm=dolly_llm, prompt=second_prompt)
```


세 번째 프롬프트, 프롬프트 2의 설명 출력을 기반으로 이미지를 생성합시다.

```python
third_prompt = PromptTemplate(
    input_variables=["company_logo_description"],
    template="{company_logo_description}",
)
chain_three = LLMChain(llm=text2image, prompt=third_prompt)
```


이제 실행해 봅시다!

```python
# Run the chain specifying only the input variable for the first chain.
overall_chain = SimpleSequentialChain(
    chains=[chain, chain_two, chain_three], verbose=True
)
catchphrase = overall_chain.run("colorful socks")
print(catchphrase)
```

```output


[1m> Entering new SimpleSequentialChain chain...[0m
[36;1m[1;3mColorful socks could be named after a song by The Beatles or a color (yellow, blue, pink). A good combination of letters and digits would be 6399. Apple also owns the domain 6399.com so this could be reserved for the Company.

[0m
[33;1m[1;3mA colorful sock with the numbers 3, 9, and 99 screen printed in yellow, blue, and pink, respectively.

[0m
[38;5;200m[1;3mhttps://pbxt.replicate.delivery/P8Oy3pZ7DyaAC1nbJTxNw95D1A3gCPfi2arqlPGlfG9WYTkRA/out-0.png[0m

[1m> Finished chain.[0m
https://pbxt.replicate.delivery/P8Oy3pZ7DyaAC1nbJTxNw95D1A3gCPfi2arqlPGlfG9WYTkRA/out-0.png
```


```python
response = requests.get(
    "https://replicate.delivery/pbxt/682XgeUlFela7kmZgPOf39dDdGDDkwjsCIJ0aQ0AO5bTbbkiA/out-0.png"
)
img = Image.open(BytesIO(response.content))
img
```


## 관련

- LLM [개념 가이드](/docs/concepts/#llms)
- LLM [사용 방법 가이드](/docs/how_to/#llms)