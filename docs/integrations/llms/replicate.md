---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/replicate/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/replicate.ipynb
---

# Replicate

> [Replicate](https://replicate.com/blog/machine-learning-needs-better-tools) runs machine learning models in the cloud. We have a library of open-source models that you can run with a few lines of code. If you're building your own machine learning models, Replicate makes it easy to deploy them at scale.

This example goes over how to use LangChain to interact with `Replicate` [models](https://replicate.com/explore)

## Setup

```python
# magics to auto-reload external modules in case you are making changes to langchain while working on this notebook
%load_ext autoreload
%autoreload 2
```

To run this notebook, you'll need to create a [replicate](https://replicate.com) account and install the [replicate python client](https://github.com/replicate/replicate-python).

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

## Calling a model

Find a model on the [replicate explore page](https://replicate.com/explore), and then paste in the model name and version in this format: model_name/version.

For example, here is [`Meta Llama 3`](https://replicate.com/meta/meta-llama-3-8b-instruct).

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

As another example, for this [dolly model](https://replicate.com/replicate/dolly-v2-12b), click on the API tab. The model name/version would be: `replicate/dolly-v2-12b:ef0e1aefc61f8e096ebe4db6b2bacc297daf2ef6899f0f7e001ec445893500e5`

Only the `model` param is required, but we can add other model params when initializing.

For example, if we were running stable diffusion and wanted to change the image dimensions:

```
Replicate(model="stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf", input={'image_dimensions': '512x512'})
```

*Note that only the first output of a model will be returned.*

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

We can call any replicate model using this syntax. For example, we can call stable diffusion.

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

The model spits out a URL. Let's render it.

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

## Streaming Response
You can optionally stream the response as it is produced, which is helpful to show interactivity to users for time-consuming generations. See detailed docs on [Streaming](/docs/how_to/streaming_llm) for more information.

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
# Stop Sequences
You can also specify stop sequences. If you have a definite stop sequence for the generation that you are going to parse with anyway, it is better (cheaper and faster!) to just cancel the generation once one or more stop sequences are reached, rather than letting the model ramble on till the specified `max_length`. Stop sequences work regardless of whether you are in streaming mode or not, and Replicate only charges you for the generation up until the stop sequence.

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
## Chaining Calls
The whole point of langchain is to... chain! Here's an example of how do that.

```python
<!--IMPORTS:[{"imported": "SimpleSequentialChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.sequential.SimpleSequentialChain.html", "title": "Replicate"}]-->
from langchain.chains import SimpleSequentialChain
```

First, let's define the LLM for this model as a flan-5, and text2image as a stable diffusion model.

```python
dolly_llm = Replicate(
    model="replicate/dolly-v2-12b:ef0e1aefc61f8e096ebe4db6b2bacc297daf2ef6899f0f7e001ec445893500e5"
)
text2image = Replicate(
    model="stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"
)
```

First prompt in the chain

```python
prompt = PromptTemplate(
    input_variables=["product"],
    template="What is a good name for a company that makes {product}?",
)

chain = LLMChain(llm=dolly_llm, prompt=prompt)
```

Second prompt to get the logo for company description

```python
second_prompt = PromptTemplate(
    input_variables=["company_name"],
    template="Write a description of a logo for this company: {company_name}",
)
chain_two = LLMChain(llm=dolly_llm, prompt=second_prompt)
```

Third prompt, let's create the image based on the description output from prompt 2

```python
third_prompt = PromptTemplate(
    input_variables=["company_logo_description"],
    template="{company_logo_description}",
)
chain_three = LLMChain(llm=text2image, prompt=third_prompt)
```

Now let's run it!

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

## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)