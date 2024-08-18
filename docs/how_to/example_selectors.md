---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/example_selectors.ipynb
description: 예제 선택기를 사용하여 많은 예제 중에서 선택하는 방법을 안내하는 문서입니다. 사용자 정의 선택기를 만드는 방법도 포함되어
  있습니다.
sidebar_position: 1
---

# 예제 선택기를 사용하는 방법

많은 수의 예제가 있는 경우, 프롬프트에 포함할 예제를 선택해야 할 수 있습니다. 예제 선택기는 이를 담당하는 클래스입니다.

기본 인터페이스는 아래와 같이 정의됩니다:

```python
class BaseExampleSelector(ABC):
    """Interface for selecting examples to include in prompts."""

    @abstractmethod
    def select_examples(self, input_variables: Dict[str, str]) -> List[dict]:
        """Select which examples to use based on the inputs."""
        
    @abstractmethod
    def add_example(self, example: Dict[str, str]) -> Any:
        """Add new example to store."""
```


정의해야 할 유일한 메서드는 `select_examples` 메서드입니다. 이 메서드는 입력 변수를 받아들이고 예제 목록을 반환합니다. 예제를 선택하는 방법은 각 특정 구현에 따라 다릅니다.

LangChain에는 몇 가지 다른 유형의 예제 선택기가 있습니다. 이러한 유형의 개요는 아래 표를 참조하세요.

이 가이드에서는 사용자 정의 예제 선택기를 만드는 방법을 설명합니다.

## 예제

예제 선택기를 사용하기 위해서는 예제 목록을 만들어야 합니다. 일반적으로 예제 입력 및 출력이어야 합니다. 이 데모 목적을 위해, 영어를 이탈리아어로 번역하는 예제를 선택한다고 가정해 보겠습니다.

```python
examples = [
    {"input": "hi", "output": "ciao"},
    {"input": "bye", "output": "arrivederci"},
    {"input": "soccer", "output": "calcio"},
]
```


## 사용자 정의 예제 선택기

단어의 길이에 따라 어떤 예제를 선택할지 결정하는 예제 선택기를 작성해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "BaseExampleSelector", "source": "langchain_core.example_selectors.base", "docs": "https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.base.BaseExampleSelector.html", "title": "How to use example selectors"}]-->
from langchain_core.example_selectors.base import BaseExampleSelector


class CustomExampleSelector(BaseExampleSelector):
    def __init__(self, examples):
        self.examples = examples

    def add_example(self, example):
        self.examples.append(example)

    def select_examples(self, input_variables):
        # This assumes knowledge that part of the input will be a 'text' key
        new_word = input_variables["input"]
        new_word_length = len(new_word)

        # Initialize variables to store the best match and its length difference
        best_match = None
        smallest_diff = float("inf")

        # Iterate through each example
        for example in self.examples:
            # Calculate the length difference with the first word of the example
            current_diff = abs(len(example["input"]) - new_word_length)

            # Update the best match if the current one is closer in length
            if current_diff < smallest_diff:
                smallest_diff = current_diff
                best_match = example

        return [best_match]
```


```python
example_selector = CustomExampleSelector(examples)
```


```python
example_selector.select_examples({"input": "okay"})
```


```output
[{'input': 'bye', 'output': 'arrivederci'}]
```


```python
example_selector.add_example({"input": "hand", "output": "mano"})
```


```python
example_selector.select_examples({"input": "okay"})
```


```output
[{'input': 'hand', 'output': 'mano'}]
```


## 프롬프트에서 사용하기

이제 이 예제 선택기를 프롬프트에서 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "FewShotPromptTemplate", "source": "langchain_core.prompts.few_shot", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotPromptTemplate.html", "title": "How to use example selectors"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts.prompt", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to use example selectors"}]-->
from langchain_core.prompts.few_shot import FewShotPromptTemplate
from langchain_core.prompts.prompt import PromptTemplate

example_prompt = PromptTemplate.from_template("Input: {input} -> Output: {output}")
```


```python
prompt = FewShotPromptTemplate(
    example_selector=example_selector,
    example_prompt=example_prompt,
    suffix="Input: {input} -> Output:",
    prefix="Translate the following words from English to Italian:",
    input_variables=["input"],
)

print(prompt.format(input="word"))
```

```output
Translate the following words from English to Italian:

Input: hand -> Output: mano

Input: word -> Output:
```

## 예제 선택기 유형

| 이름       | 설명                                                                                     |
|------------|------------------------------------------------------------------------------------------|
| 유사도     | 입력과 예제 간의 의미적 유사성을 사용하여 선택할 예제를 결정합니다.                     |
| MMR        | 입력과 예제 간의 최대 한계 관련성을 사용하여 선택할 예제를 결정합니다.                  |
| 길이       | 특정 길이 내에 얼마나 많은 예제가 들어갈 수 있는지에 따라 예제를 선택합니다.             |
| Ngram      | 입력과 예제 간의 n-그램 중복을 사용하여 선택할 예제를 결정합니다.                       |