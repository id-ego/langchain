---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/example_selectors_mmr.ipynb
description: 최대 주변 관련성(MMR)을 기반으로 입력과 유사하면서도 다양성을 최적화하여 예제를 선택하는 방법을 설명합니다.
---

# 최대 한계 관련성(MMR)으로 예제 선택하는 방법

`MaxMarginalRelevanceExampleSelector`는 입력과 가장 유사한 예제를 기반으로 예제를 선택하면서 다양성을 최적화합니다. 이는 입력과의 코사인 유사성이 가장 높은 임베딩을 가진 예제를 찾아내고, 이미 선택된 예제와의 근접성에 대해 패널티를 부여하면서 반복적으로 추가하는 방식으로 이루어집니다.

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to select examples by maximal marginal relevance (MMR)"}, {"imported": "MaxMarginalRelevanceExampleSelector", "source": "langchain_core.example_selectors", "docs": "https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.semantic_similarity.MaxMarginalRelevanceExampleSelector.html", "title": "How to select examples by maximal marginal relevance (MMR)"}, {"imported": "SemanticSimilarityExampleSelector", "source": "langchain_core.example_selectors", "docs": "https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.semantic_similarity.SemanticSimilarityExampleSelector.html", "title": "How to select examples by maximal marginal relevance (MMR)"}, {"imported": "FewShotPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotPromptTemplate.html", "title": "How to select examples by maximal marginal relevance (MMR)"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to select examples by maximal marginal relevance (MMR)"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to select examples by maximal marginal relevance (MMR)"}]-->
from langchain_community.vectorstores import FAISS
from langchain_core.example_selectors import (
    MaxMarginalRelevanceExampleSelector,
    SemanticSimilarityExampleSelector,
)
from langchain_core.prompts import FewShotPromptTemplate, PromptTemplate
from langchain_openai import OpenAIEmbeddings

example_prompt = PromptTemplate(
    input_variables=["input", "output"],
    template="Input: {input}\nOutput: {output}",
)

# Examples of a pretend task of creating antonyms.
examples = [
    {"input": "happy", "output": "sad"},
    {"input": "tall", "output": "short"},
    {"input": "energetic", "output": "lethargic"},
    {"input": "sunny", "output": "gloomy"},
    {"input": "windy", "output": "calm"},
]
```


```python
example_selector = MaxMarginalRelevanceExampleSelector.from_examples(
    # The list of examples available to select from.
    examples,
    # The embedding class used to produce embeddings which are used to measure semantic similarity.
    OpenAIEmbeddings(),
    # The VectorStore class that is used to store the embeddings and do a similarity search over.
    FAISS,
    # The number of examples to produce.
    k=2,
)
mmr_prompt = FewShotPromptTemplate(
    # We provide an ExampleSelector instead of examples.
    example_selector=example_selector,
    example_prompt=example_prompt,
    prefix="Give the antonym of every input",
    suffix="Input: {adjective}\nOutput:",
    input_variables=["adjective"],
)
```


```python
# Input is a feeling, so should select the happy/sad example as the first one
print(mmr_prompt.format(adjective="worried"))
```

```output
Give the antonym of every input

Input: happy
Output: sad

Input: windy
Output: calm

Input: worried
Output:
```


```python
# Let's compare this to what we would just get if we went solely off of similarity,
# by using SemanticSimilarityExampleSelector instead of MaxMarginalRelevanceExampleSelector.
example_selector = SemanticSimilarityExampleSelector.from_examples(
    # The list of examples available to select from.
    examples,
    # The embedding class used to produce embeddings which are used to measure semantic similarity.
    OpenAIEmbeddings(),
    # The VectorStore class that is used to store the embeddings and do a similarity search over.
    FAISS,
    # The number of examples to produce.
    k=2,
)
similar_prompt = FewShotPromptTemplate(
    # We provide an ExampleSelector instead of examples.
    example_selector=example_selector,
    example_prompt=example_prompt,
    prefix="Give the antonym of every input",
    suffix="Input: {adjective}\nOutput:",
    input_variables=["adjective"],
)
print(similar_prompt.format(adjective="worried"))
```

```output
Give the antonym of every input

Input: happy
Output: sad

Input: sunny
Output: gloomy

Input: worried
Output:
```