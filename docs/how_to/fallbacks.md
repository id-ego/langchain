---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/fallbacks.ipynb
description: 언어 모델을 사용할 때 API 오류에 대비한 대체 계획인 폴백을 추가하는 방법에 대해 설명합니다. LLM 및 전체 실행 가능성에서
  적용 가능합니다.
keywords:
- LCEL
- fallbacks
---

# 실행 가능한 항목에 폴백 추가하는 방법

언어 모델을 사용할 때, 기본 API에서 발생하는 문제(예: 속도 제한 또는 다운타임)를 자주 접할 수 있습니다. 따라서 LLM 애플리케이션을 프로덕션으로 이동할 때 이러한 문제에 대비하는 것이 점점 더 중요해집니다. 그래서 우리는 폴백 개념을 도입했습니다.

**폴백**은 비상 시 사용할 수 있는 대체 계획입니다.

중요하게도, 폴백은 LLM 수준뿐만 아니라 전체 실행 가능한 항목 수준에서도 적용할 수 있습니다. 이는 종종 서로 다른 모델이 서로 다른 프롬프트를 요구하기 때문에 중요합니다. 따라서 OpenAI 호출이 실패하면 같은 프롬프트를 Anthropic에 보내고 싶지 않을 것입니다. 아마도 다른 프롬프트 템플릿을 사용하고 다른 버전을 보내고 싶을 것입니다.

## LLM API 오류에 대한 폴백

이는 아마도 폴백의 가장 일반적인 사용 사례일 것입니다. LLM API에 대한 요청은 다양한 이유로 실패할 수 있습니다. API가 다운되었거나, 속도 제한에 걸렸거나, 여러 가지 이유가 있을 수 있습니다. 따라서 폴백을 사용하면 이러한 유형의 문제로부터 보호할 수 있습니다.

중요: 기본적으로 많은 LLM 래퍼는 오류를 포착하고 재시도합니다. 폴백을 사용할 때는 이를 끄는 것이 좋습니다. 그렇지 않으면 첫 번째 래퍼가 계속 재시도하고 실패하지 않을 것입니다.

```python
%pip install --upgrade --quiet  langchain langchain-openai
```


```python
<!--IMPORTS:[{"imported": "ChatAnthropic", "source": "langchain_anthropic", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_anthropic.chat_models.ChatAnthropic.html", "title": "How to add fallbacks to a runnable"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to add fallbacks to a runnable"}]-->
from langchain_anthropic import ChatAnthropic
from langchain_openai import ChatOpenAI
```


먼저, OpenAI에서 RateLimitError에 걸렸을 때 발생하는 일을 모의해 보겠습니다.

```python
from unittest.mock import patch

import httpx
from openai import RateLimitError

request = httpx.Request("GET", "/")
response = httpx.Response(200, request=request)
error = RateLimitError("rate limit", response=response, body="")
```


```python
# Note that we set max_retries = 0 to avoid retrying on RateLimits, etc
openai_llm = ChatOpenAI(model="gpt-3.5-turbo-0125", max_retries=0)
anthropic_llm = ChatAnthropic(model="claude-3-haiku-20240307")
llm = openai_llm.with_fallbacks([anthropic_llm])
```


```python
# Let's use just the OpenAI LLm first, to show that we run into an error
with patch("openai.resources.chat.completions.Completions.create", side_effect=error):
    try:
        print(openai_llm.invoke("Why did the chicken cross the road?"))
    except RateLimitError:
        print("Hit error")
```

```output
Hit error
```


```python
# Now let's try with fallbacks to Anthropic
with patch("openai.resources.chat.completions.Completions.create", side_effect=error):
    try:
        print(llm.invoke("Why did the chicken cross the road?"))
    except RateLimitError:
        print("Hit error")
```

```output
content=' I don\'t actually know why the chicken crossed the road, but here are some possible humorous answers:\n\n- To get to the other side!\n\n- It was too chicken to just stand there. \n\n- It wanted a change of scenery.\n\n- It wanted to show the possum it could be done.\n\n- It was on its way to a poultry farmers\' convention.\n\nThe joke plays on the double meaning of "the other side" - literally crossing the road to the other side, or the "other side" meaning the afterlife. So it\'s an anti-joke, with a silly or unexpected pun as the answer.' additional_kwargs={} example=False
```

우리는 "폴백이 있는 LLM"을 일반 LLM처럼 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to add fallbacks to a runnable"}]-->
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You're a nice assistant who always includes a compliment in your response",
        ),
        ("human", "Why did the {animal} cross the road"),
    ]
)
chain = prompt | llm
with patch("openai.resources.chat.completions.Completions.create", side_effect=error):
    try:
        print(chain.invoke({"animal": "kangaroo"}))
    except RateLimitError:
        print("Hit error")
```

```output
content=" I don't actually know why the kangaroo crossed the road, but I can take a guess! Here are some possible reasons:\n\n- To get to the other side (the classic joke answer!)\n\n- It was trying to find some food or water \n\n- It was trying to find a mate during mating season\n\n- It was fleeing from a predator or perceived threat\n\n- It was disoriented and crossed accidentally \n\n- It was following a herd of other kangaroos who were crossing\n\n- It wanted a change of scenery or environment \n\n- It was trying to reach a new habitat or territory\n\nThe real reason is unknown without more context, but hopefully one of those potential explanations does the joke justice! Let me know if you have any other animal jokes I can try to decipher." additional_kwargs={} example=False
```

## 시퀀스에 대한 폴백

우리는 또한 시퀀스 자체에 대한 폴백을 생성할 수 있습니다. 여기서는 두 가지 다른 모델인 ChatOpenAI와 일반 OpenAI(채팅 모델을 사용하지 않음)로 이를 수행합니다. OpenAI는 채팅 모델이 아니기 때문에, 아마도 다른 프롬프트를 원할 것입니다.

```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to add fallbacks to a runnable"}]-->
# First let's create a chain with a ChatModel
# We add in a string output parser here so the outputs between the two are the same type
from langchain_core.output_parsers import StrOutputParser

chat_prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You're a nice assistant who always includes a compliment in your response",
        ),
        ("human", "Why did the {animal} cross the road"),
    ]
)
# Here we're going to use a bad model name to easily create a chain that will error
chat_model = ChatOpenAI(model="gpt-fake")
bad_chain = chat_prompt | chat_model | StrOutputParser()
```


```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to add fallbacks to a runnable"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "How to add fallbacks to a runnable"}]-->
# Now lets create a chain with the normal OpenAI model
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI

prompt_template = """Instructions: You should always include a compliment in your response.

Question: Why did the {animal} cross the road?"""
prompt = PromptTemplate.from_template(prompt_template)
llm = OpenAI()
good_chain = prompt | llm
```


```python
# We can now create a final chain which combines the two
chain = bad_chain.with_fallbacks([good_chain])
chain.invoke({"animal": "turtle"})
```


```output
'\n\nAnswer: The turtle crossed the road to get to the other side, and I have to say he had some impressive determination.'
```


## 긴 입력에 대한 폴백

LLM의 큰 제한 요소 중 하나는 컨텍스트 창입니다. 일반적으로 LLM에 보내기 전에 프롬프트의 길이를 계산하고 추적할 수 있지만, 그것이 어렵거나 복잡한 상황에서는 더 긴 컨텍스트 길이를 가진 모델로 폴백할 수 있습니다.

```python
short_llm = ChatOpenAI()
long_llm = ChatOpenAI(model="gpt-3.5-turbo-16k")
llm = short_llm.with_fallbacks([long_llm])
```


```python
inputs = "What is the next number: " + ", ".join(["one", "two"] * 3000)
```


```python
try:
    print(short_llm.invoke(inputs))
except Exception as e:
    print(e)
```

```output
This model's maximum context length is 4097 tokens. However, your messages resulted in 12012 tokens. Please reduce the length of the messages.
```


```python
try:
    print(llm.invoke(inputs))
except Exception as e:
    print(e)
```

```output
content='The next number in the sequence is two.' additional_kwargs={} example=False
```

## 더 나은 모델로의 폴백

종종 우리는 모델에게 특정 형식(예: JSON)으로 출력하도록 요청합니다. GPT-3.5와 같은 모델은 이를 잘 수행할 수 있지만, 때때로 어려움을 겪습니다. 이는 자연스럽게 폴백을 지시합니다. 우리는 GPT-3.5(더 빠르고 저렴함)로 시도할 수 있지만, 파싱이 실패하면 GPT-4를 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "DatetimeOutputParser", "source": "langchain.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain.output_parsers.datetime.DatetimeOutputParser.html", "title": "How to add fallbacks to a runnable"}]-->
from langchain.output_parsers import DatetimeOutputParser
```


```python
prompt = ChatPromptTemplate.from_template(
    "what time was {event} (in %Y-%m-%dT%H:%M:%S.%fZ format - only return this value)"
)
```


```python
# In this case we are going to do the fallbacks on the LLM + output parser level
# Because the error will get raised in the OutputParser
openai_35 = ChatOpenAI() | DatetimeOutputParser()
openai_4 = ChatOpenAI(model="gpt-4") | DatetimeOutputParser()
```


```python
only_35 = prompt | openai_35
fallback_4 = prompt | openai_35.with_fallbacks([openai_4])
```


```python
try:
    print(only_35.invoke({"event": "the superbowl in 1994"}))
except Exception as e:
    print(f"Error: {e}")
```

```output
Error: Could not parse datetime string: The Super Bowl in 1994 took place on January 30th at 3:30 PM local time. Converting this to the specified format (%Y-%m-%dT%H:%M:%S.%fZ) results in: 1994-01-30T15:30:00.000Z
```


```python
try:
    print(fallback_4.invoke({"event": "the superbowl in 1994"}))
except Exception as e:
    print(f"Error: {e}")
```

```output
1994-01-30 15:30:00
```