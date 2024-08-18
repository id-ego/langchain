---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/few_shot_examples_chat.ipynb
description: 챗 모델에 예시 입력과 출력을 제공하는 방법을 안내합니다. Few-shot 기법으로 모델 성능을 향상시키는 방법을 다룹니다.
sidebar_position: 2
---

# 챗 모델에서 몇 가지 샷 예제 사용 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [프롬프트 템플릿](/docs/concepts/#prompt-templates)
- [예제 선택기](/docs/concepts/#example-selectors)
- [챗 모델](/docs/concepts/#chat-model)
- [벡터 스토어](/docs/concepts/#vector-stores)

:::

이 가이드는 예제 입력 및 출력으로 챗 모델에 프롬프트를 제공하는 방법을 다룹니다. 모델에 몇 가지 예제를 제공하는 것을 몇 샷(few-shot)이라고 하며, 이는 생성 과정을 안내하는 간단하면서도 강력한 방법으로, 경우에 따라 모델 성능을 극적으로 향상시킬 수 있습니다.

몇 샷 프롬프트를 수행하는 최선의 방법에 대한 확고한 합의는 없는 것 같으며, 최적의 프롬프트 조합은 모델에 따라 다를 수 있습니다. 따라서 우리는 [FewShotChatMessagePromptTemplate](https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotChatMessagePromptTemplate.html?highlight=fewshot#langchain_core.prompts.few_shot.FewShotChatMessagePromptTemplate)와 같은 몇 샷 프롬프트 템플릿을 유연한 시작점으로 제공하며, 필요에 따라 수정하거나 교체할 수 있습니다.

몇 샷 프롬프트 템플릿의 목표는 입력에 따라 동적으로 예제를 선택하고, 그런 다음 모델에 제공할 최종 프롬프트에서 예제를 형식화하는 것입니다.

**참고:** 다음 코드 예제는 챗 모델에만 해당되며, `FewShotChatMessagePromptTemplates`는 순수 문자열이 아닌 형식화된 [챗 메시지](/docs/concepts/#message-types)를 출력하도록 설계되었습니다. 완료 모델(LLMs)과 호환되는 순수 문자열 템플릿에 대한 유사한 몇 샷 프롬프트 예제는 [few-shot 프롬프트 템플릿](/docs/how_to/few_shot_examples/) 가이드를 참조하세요.

## 고정된 예제

가장 기본적이고 일반적인 몇 샷 프롬프트 기법은 고정된 프롬프트 예제를 사용하는 것입니다. 이렇게 하면 체인을 선택하고 평가할 수 있으며, 프로덕션에서 추가적인 이동 부품에 대해 걱정할 필요가 없습니다.

템플릿의 기본 구성 요소는 다음과 같습니다:
- `examples`: 최종 프롬프트에 포함할 사전 예제 목록입니다.
- `example_prompt`: 각 예제를 [`format_messages`](https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html?highlight=format_messages#langchain_core.prompts.chat.ChatPromptTemplate.format_messages) 메서드를 통해 1개 이상의 메시지로 변환합니다. 일반적인 예는 각 예제를 하나의 인간 메시지와 하나의 AI 메시지 응답으로 변환하거나, 인간 메시지 다음에 함수 호출 메시지를 추가하는 것입니다.

아래는 간단한 시연입니다. 먼저 포함할 예제를 정의합니다. LLM에 익숙하지 않은 수학 연산자를 "🦜" 이모지로 표시해 보겠습니다:

```python
%pip install -qU langchain langchain-openai langchain-chroma

import os
from getpass import getpass

os.environ["OPENAI_API_KEY"] = getpass()
```


이 표현의 결과가 무엇인지 모델에 물어보면 실패할 것입니다:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use few shot examples in chat models"}]-->
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0.0)

model.invoke("What is 2 🦜 9?")
```


```output
AIMessage(content='The expression "2 🦜 9" is not a standard mathematical operation or equation. It appears to be a combination of the number 2 and the parrot emoji 🦜 followed by the number 9. It does not have a specific mathematical meaning.', response_metadata={'token_usage': {'completion_tokens': 54, 'prompt_tokens': 17, 'total_tokens': 71}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-aad12dda-5c47-4a1e-9949-6fe94e03242a-0', usage_metadata={'input_tokens': 17, 'output_tokens': 54, 'total_tokens': 71})
```


이제 LLM에 작업할 예제를 제공하면 어떤 일이 발생하는지 살펴보겠습니다. 아래에 몇 가지를 정의하겠습니다:

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to use few shot examples in chat models"}, {"imported": "FewShotChatMessagePromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotChatMessagePromptTemplate.html", "title": "How to use few shot examples in chat models"}]-->
from langchain_core.prompts import ChatPromptTemplate, FewShotChatMessagePromptTemplate

examples = [
    {"input": "2 🦜 2", "output": "4"},
    {"input": "2 🦜 3", "output": "5"},
]
```


다음으로, 이를 몇 샷 프롬프트 템플릿으로 조합합니다.

```python
# This is a prompt template used to format each individual example.
example_prompt = ChatPromptTemplate.from_messages(
    [
        ("human", "{input}"),
        ("ai", "{output}"),
    ]
)
few_shot_prompt = FewShotChatMessagePromptTemplate(
    example_prompt=example_prompt,
    examples=examples,
)

print(few_shot_prompt.invoke({}).to_messages())
```

```output
[HumanMessage(content='2 🦜 2'), AIMessage(content='4'), HumanMessage(content='2 🦜 3'), AIMessage(content='5')]
```

마지막으로, 아래와 같이 최종 프롬프트를 조립하고, `few_shot_prompt`를 `from_messages` 팩토리 메서드에 직접 전달하여 모델과 함께 사용합니다:

```python
final_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a wondrous wizard of math."),
        few_shot_prompt,
        ("human", "{input}"),
    ]
)
```


이제 모델에 초기 질문을 하고 결과를 확인해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use few shot examples in chat models"}]-->
from langchain_openai import ChatOpenAI

chain = final_prompt | model

chain.invoke({"input": "What is 2 🦜 9?"})
```


```output
AIMessage(content='11', response_metadata={'token_usage': {'completion_tokens': 1, 'prompt_tokens': 60, 'total_tokens': 61}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-5ec4e051-262f-408e-ad00-3f2ebeb561c3-0', usage_metadata={'input_tokens': 60, 'output_tokens': 1, 'total_tokens': 61})
```


모델이 주어진 몇 샷 예제에서 앵무새 이모지가 덧셈을 의미한다고 추론한 것을 확인할 수 있습니다!

## 동적 몇 샷 프롬프트

때때로 입력에 따라 전체 집합에서 몇 가지 예제만 선택하고 싶을 수 있습니다. 이를 위해 `FewShotChatMessagePromptTemplate`에 전달된 `examples`를 `example_selector`로 교체할 수 있습니다. 다른 구성 요소는 위와 동일하게 유지됩니다! 우리의 동적 몇 샷 프롬프트 템플릿은 다음과 같습니다:

- `example_selector`: 주어진 입력에 대해 몇 샷 예제를 선택하고 반환되는 순서를 담당합니다. 이는 [BaseExampleSelector](https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.base.BaseExampleSelector.html?highlight=baseexampleselector#langchain_core.example_selectors.base.BaseExampleSelector) 인터페이스를 구현합니다. 일반적인 예는 벡터스토어 기반의 [SemanticSimilarityExampleSelector](https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.semantic_similarity.SemanticSimilarityExampleSelector.html?highlight=semanticsimilarityexampleselector#langchain_core.example_selectors.semantic_similarity.SemanticSimilarityExampleSelector)입니다.
- `example_prompt`: 각 예제를 [`format_messages`](https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html?highlight=chatprompttemplate#langchain_core.prompts.chat.ChatPromptTemplate.format_messages) 메서드를 통해 1개 이상의 메시지로 변환합니다. 일반적인 예는 각 예제를 하나의 인간 메시지와 하나의 AI 메시지 응답으로 변환하거나, 인간 메시지 다음에 함수 호출 메시지를 추가하는 것입니다.

이들은 다시 다른 메시지 및 챗 템플릿과 결합하여 최종 프롬프트를 조립할 수 있습니다.

`SemanticSimilarityExampleSelector`와 함께 예제를 살펴보겠습니다. 이 구현은 벡터스토어를 사용하여 의미적 유사성을 기반으로 예제를 선택하므로, 먼저 스토어를 채워야 합니다. 기본 아이디어는 텍스트 입력과 가장 유사한 예제를 검색하고 반환하는 것이므로, 키를 고려하기보다는 프롬프트 예제의 `values`를 임베딩합니다:

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to use few shot examples in chat models"}, {"imported": "SemanticSimilarityExampleSelector", "source": "langchain_core.example_selectors", "docs": "https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.semantic_similarity.SemanticSimilarityExampleSelector.html", "title": "How to use few shot examples in chat models"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to use few shot examples in chat models"}]-->
from langchain_chroma import Chroma
from langchain_core.example_selectors import SemanticSimilarityExampleSelector
from langchain_openai import OpenAIEmbeddings

examples = [
    {"input": "2 🦜 2", "output": "4"},
    {"input": "2 🦜 3", "output": "5"},
    {"input": "2 🦜 4", "output": "6"},
    {"input": "What did the cow say to the moon?", "output": "nothing at all"},
    {
        "input": "Write me a poem about the moon",
        "output": "One for the moon, and one for me, who are we to talk about the moon?",
    },
]

to_vectorize = [" ".join(example.values()) for example in examples]
embeddings = OpenAIEmbeddings()
vectorstore = Chroma.from_texts(to_vectorize, embeddings, metadatas=examples)
```


### `example_selector` 생성

벡터스토어가 생성되면 `example_selector`를 생성할 수 있습니다. 여기서는 독립적으로 호출하고, 입력에 가장 가까운 두 예제를 가져오도록 `k`를 설정합니다.

```python
example_selector = SemanticSimilarityExampleSelector(
    vectorstore=vectorstore,
    k=2,
)

# The prompt template will load examples by passing the input do the `select_examples` method
example_selector.select_examples({"input": "horse"})
```


```output
[{'input': 'What did the cow say to the moon?', 'output': 'nothing at all'},
 {'input': '2 🦜 4', 'output': '6'}]
```


### 프롬프트 템플릿 생성

이제 위에서 생성한 `example_selector`를 사용하여 프롬프트 템플릿을 조립합니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to use few shot examples in chat models"}, {"imported": "FewShotChatMessagePromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotChatMessagePromptTemplate.html", "title": "How to use few shot examples in chat models"}]-->
from langchain_core.prompts import ChatPromptTemplate, FewShotChatMessagePromptTemplate

# Define the few-shot prompt.
few_shot_prompt = FewShotChatMessagePromptTemplate(
    # The input variables select the values to pass to the example_selector
    input_variables=["input"],
    example_selector=example_selector,
    # Define how each example will be formatted.
    # In this case, each example will become 2 messages:
    # 1 human, and 1 AI
    example_prompt=ChatPromptTemplate.from_messages(
        [("human", "{input}"), ("ai", "{output}")]
    ),
)

print(few_shot_prompt.invoke(input="What's 3 🦜 3?").to_messages())
```

```output
[HumanMessage(content='2 🦜 3'), AIMessage(content='5'), HumanMessage(content='2 🦜 4'), AIMessage(content='6')]
```

그리고 이 몇 샷 챗 메시지 프롬프트 템플릿을 다른 챗 프롬프트 템플릿에 전달할 수 있습니다:

```python
final_prompt = ChatPromptTemplate.from_messages(
    [
        ("system", "You are a wondrous wizard of math."),
        few_shot_prompt,
        ("human", "{input}"),
    ]
)

print(few_shot_prompt.invoke(input="What's 3 🦜 3?"))
```

```output
messages=[HumanMessage(content='2 🦜 3'), AIMessage(content='5'), HumanMessage(content='2 🦜 4'), AIMessage(content='6')]
```

### 챗 모델과 함께 사용

마지막으로, 모델을 몇 샷 프롬프트에 연결할 수 있습니다.

```python
chain = final_prompt | ChatOpenAI(model="gpt-3.5-turbo-0125", temperature=0.0)

chain.invoke({"input": "What's 3 🦜 3?"})
```


```output
AIMessage(content='6', response_metadata={'token_usage': {'completion_tokens': 1, 'prompt_tokens': 60, 'total_tokens': 61}, 'model_name': 'gpt-3.5-turbo-0125', 'system_fingerprint': None, 'finish_reason': 'stop', 'logprobs': None}, id='run-d1863e5e-17cd-4e9d-bf7a-b9f118747a65-0', usage_metadata={'input_tokens': 60, 'output_tokens': 1, 'total_tokens': 61})
```


## 다음 단계

이제 챗 프롬프트에 몇 샷 예제를 추가하는 방법을 배웠습니다.

다음으로, 이 섹션의 프롬프트 템플릿에 대한 다른 사용 방법 가이드를 확인하거나, [텍스트 완성 모델과 함께 몇 샷 사용하기](/docs/how_to/few_shot_examples) 관련 가이드를 확인하거나, 다른 [예제 선택기 사용 방법 가이드](/docs/how_to/example_selectors/)를 확인하세요.