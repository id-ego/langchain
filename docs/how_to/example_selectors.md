---
canonical: https://python.langchain.com/v0.2/docs/how_to/example_selectors/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/example_selectors.ipynb
sidebar_position: 1
---

# How to use example selectors

If you have a large number of examples, you may need to select which ones to include in the prompt. The Example Selector is the class responsible for doing so.

The base interface is defined as below:

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

The only method it needs to define is a `select_examples` method. This takes in the input variables and then returns a list of examples. It is up to each specific implementation as to how those examples are selected.

LangChain has a few different types of example selectors. For an overview of all these types, see the below table.

In this guide, we will walk through creating a custom example selector.

## Examples

In order to use an example selector, we need to create a list of examples. These should generally be example inputs and outputs. For this demo purpose, let's imagine we are selecting examples of how to translate English to Italian.

```python
examples = [
    {"input": "hi", "output": "ciao"},
    {"input": "bye", "output": "arrivederci"},
    {"input": "soccer", "output": "calcio"},
]
```

## Custom Example Selector

Let's write an example selector that chooses what example to pick based on the length of the word.

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

## Use in a Prompt

We can now use this example selector in a prompt

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
## Example Selector Types

| Name       | Description                                                                                 |
|------------|---------------------------------------------------------------------------------------------|
| Similarity | Uses semantic similarity between inputs and examples to decide which examples to choose.    |
| MMR        | Uses Max Marginal Relevance between inputs and examples to decide which examples to choose. |
| Length     | Selects examples based on how many can fit within a certain length                          |
| Ngram      | Uses ngram overlap between inputs and examples to decide which examples to choose.          |