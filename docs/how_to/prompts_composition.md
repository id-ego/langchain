---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/prompts_composition.ipynb
description: 프롬프트를 구성하는 방법에 대한 가이드를 제공하며, 문자열 및 채팅 프롬프트의 구성 요소 재사용을 설명합니다.
sidebar_position: 5
---

# 프롬프트를 함께 구성하는 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [프롬프트 템플릿](/docs/concepts/#prompt-templates)

:::

LangChain은 프롬프트의 다양한 부분을 함께 구성할 수 있는 사용자 친화적인 인터페이스를 제공합니다. 문자열 프롬프트 또는 채팅 프롬프트를 사용하여 이를 수행할 수 있습니다. 이러한 방식으로 프롬프트를 구성하면 구성 요소를 쉽게 재사용할 수 있습니다.

## 문자열 프롬프트 구성

문자열 프롬프트 작업 시 각 템플릿이 함께 연결됩니다. 프롬프트를 직접 사용하거나 문자열로 작업할 수 있습니다(목록의 첫 번째 요소는 프롬프트여야 합니다).

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to compose prompts together"}]-->
from langchain_core.prompts import PromptTemplate

prompt = (
    PromptTemplate.from_template("Tell me a joke about {topic}")
    + ", make it funny"
    + "\n\nand in {language}"
)

prompt
```


```output
PromptTemplate(input_variables=['language', 'topic'], template='Tell me a joke about {topic}, make it funny\n\nand in {language}')
```


```python
prompt.format(topic="sports", language="spanish")
```


```output
'Tell me a joke about sports, make it funny\n\nand in spanish'
```


## 채팅 프롬프트 구성

채팅 프롬프트는 메시지 목록으로 구성됩니다. 위의 예와 유사하게 채팅 프롬프트 템플릿을 연결할 수 있습니다. 각 새로운 요소는 최종 프롬프트의 새로운 메시지입니다.

먼저, [`ChatPromptTemplate`](https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html)를 [`SystemMessage`](https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html)로 초기화합시다.

```python
<!--IMPORTS:[{"imported": "AIMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.ai.AIMessage.html", "title": "How to compose prompts together"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "How to compose prompts together"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "How to compose prompts together"}]-->
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage

prompt = SystemMessage(content="You are a nice pirate")
```


그런 다음 다른 메시지 *또는* 메시지 템플릿과 결합하여 파이프라인을 쉽게 생성할 수 있습니다. 변수가 형식화되지 않을 때는 `Message`를 사용하고, 변수가 형식화될 때는 `MessageTemplate`을 사용합니다. 문자열만 사용할 수도 있습니다(참고: 이는 자동으로 [`HumanMessagePromptTemplate`](https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.HumanMessagePromptTemplate.html)로 추론됩니다).

```python
new_prompt = (
    prompt + HumanMessage(content="hi") + AIMessage(content="what?") + "{input}"
)
```


내부적으로, 이는 ChatPromptTemplate 클래스의 인스턴스를 생성하므로 이전과 동일하게 사용할 수 있습니다!

```python
new_prompt.format_messages(input="i said hi")
```


```output
[SystemMessage(content='You are a nice pirate'),
 HumanMessage(content='hi'),
 AIMessage(content='what?'),
 HumanMessage(content='i said hi')]
```


## PipelinePrompt 사용하기

LangChain에는 프롬프트의 일부를 재사용하고 싶을 때 유용한 [`PipelinePromptTemplate`](https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.pipeline.PipelinePromptTemplate.html)라는 클래스가 포함되어 있습니다. PipelinePrompt는 두 가지 주요 부분으로 구성됩니다:

- 최종 프롬프트: 반환되는 최종 프롬프트
- 파이프라인 프롬프트: 문자열 이름과 프롬프트 템플릿으로 구성된 튜플 목록입니다. 각 프롬프트 템플릿은 형식화된 후 동일한 이름의 변수로 향후 프롬프트 템플릿에 전달됩니다.

```python
<!--IMPORTS:[{"imported": "PipelinePromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.pipeline.PipelinePromptTemplate.html", "title": "How to compose prompts together"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to compose prompts together"}]-->
from langchain_core.prompts import PipelinePromptTemplate, PromptTemplate

full_template = """{introduction}

{example}

{start}"""
full_prompt = PromptTemplate.from_template(full_template)

introduction_template = """You are impersonating {person}."""
introduction_prompt = PromptTemplate.from_template(introduction_template)

example_template = """Here's an example of an interaction:

Q: {example_q}
A: {example_a}"""
example_prompt = PromptTemplate.from_template(example_template)

start_template = """Now, do this for real!

Q: {input}
A:"""
start_prompt = PromptTemplate.from_template(start_template)

input_prompts = [
    ("introduction", introduction_prompt),
    ("example", example_prompt),
    ("start", start_prompt),
]
pipeline_prompt = PipelinePromptTemplate(
    final_prompt=full_prompt, pipeline_prompts=input_prompts
)

pipeline_prompt.input_variables
```


```output
['person', 'example_a', 'example_q', 'input']
```


```python
print(
    pipeline_prompt.format(
        person="Elon Musk",
        example_q="What's your favorite car?",
        example_a="Tesla",
        input="What's your favorite social media site?",
    )
)
```

```output
You are impersonating Elon Musk.

Here's an example of an interaction:

Q: What's your favorite car?
A: Tesla

Now, do this for real!

Q: What's your favorite social media site?
A:
```


## 다음 단계

이제 프롬프트를 함께 구성하는 방법을 배웠습니다.

다음으로, 이 섹션의 프롬프트 템플릿에 대한 다른 사용 방법 가이드를 확인하세요, 예를 들어 [프롬프트 템플릿에 몇 가지 샷 예제를 추가하기](/docs/how_to/few_shot_examples_chat).