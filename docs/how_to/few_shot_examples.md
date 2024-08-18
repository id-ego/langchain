---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/few_shot_examples.ipynb
description: 이 가이드는 LLM에 예시 입력 및 출력을 제공하는 몇 가지 샷 프롬프트 템플릿을 만드는 방법을 설명합니다.
sidebar_position: 3
---

# 몇 가지 샷 예제 사용 방법

:::info 전제 조건

이 가이드는 다음 개념에 대한 이해를 전제로 합니다:
- [프롬프트 템플릿](/docs/concepts/#prompt-templates)
- [예제 선택기](/docs/concepts/#example-selectors)
- [LLMs](/docs/concepts/#llms)
- [벡터 저장소](/docs/concepts/#vector-stores)

:::

이 가이드에서는 모델이 생성할 때 예제 입력 및 출력을 제공하는 간단한 프롬프트 템플릿을 만드는 방법을 배웁니다. LLM에 이러한 몇 가지 예제를 제공하는 것을 몇 샷(few-shot)이라고 하며, 생성 과정을 안내하고 경우에 따라 모델 성능을 극적으로 향상시키는 간단하면서도 강력한 방법입니다.

몇 샷 프롬프트 템플릿은 예제 집합 또는 정의된 집합에서 예제의 하위 집합을 선택하는 책임이 있는 [예제 선택기](https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.base.BaseExampleSelector.html) 클래스를 통해 구성할 수 있습니다.

이 가이드는 문자열 프롬프트 템플릿을 사용한 몇 샷에 대해 다룰 것입니다. 채팅 모델을 위한 채팅 메시지로 몇 샷을 사용하는 방법에 대한 가이드는 [여기](/docs/how_to/few_shot_examples_chat/)를 참조하세요.

## 몇 샷 예제를 위한 포매터 만들기

몇 샷 예제를 문자열로 포맷할 포매터를 구성합니다. 이 포매터는 `PromptTemplate` 객체여야 합니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to use few shot examples"}]-->
from langchain_core.prompts import PromptTemplate

example_prompt = PromptTemplate.from_template("Question: {question}\n{answer}")
```


## 예제 집합 만들기

다음으로, 몇 샷 예제의 목록을 만듭니다. 각 예제는 위에서 정의한 포매터 프롬프트에 대한 예제 입력을 나타내는 사전이어야 합니다.

```python
examples = [
    {
        "question": "Who lived longer, Muhammad Ali or Alan Turing?",
        "answer": """
Are follow up questions needed here: Yes.
Follow up: How old was Muhammad Ali when he died?
Intermediate answer: Muhammad Ali was 74 years old when he died.
Follow up: How old was Alan Turing when he died?
Intermediate answer: Alan Turing was 41 years old when he died.
So the final answer is: Muhammad Ali
""",
    },
    {
        "question": "When was the founder of craigslist born?",
        "answer": """
Are follow up questions needed here: Yes.
Follow up: Who was the founder of craigslist?
Intermediate answer: Craigslist was founded by Craig Newmark.
Follow up: When was Craig Newmark born?
Intermediate answer: Craig Newmark was born on December 6, 1952.
So the final answer is: December 6, 1952
""",
    },
    {
        "question": "Who was the maternal grandfather of George Washington?",
        "answer": """
Are follow up questions needed here: Yes.
Follow up: Who was the mother of George Washington?
Intermediate answer: The mother of George Washington was Mary Ball Washington.
Follow up: Who was the father of Mary Ball Washington?
Intermediate answer: The father of Mary Ball Washington was Joseph Ball.
So the final answer is: Joseph Ball
""",
    },
    {
        "question": "Are both the directors of Jaws and Casino Royale from the same country?",
        "answer": """
Are follow up questions needed here: Yes.
Follow up: Who is the director of Jaws?
Intermediate Answer: The director of Jaws is Steven Spielberg.
Follow up: Where is Steven Spielberg from?
Intermediate Answer: The United States.
Follow up: Who is the director of Casino Royale?
Intermediate Answer: The director of Casino Royale is Martin Campbell.
Follow up: Where is Martin Campbell from?
Intermediate Answer: New Zealand.
So the final answer is: No
""",
    },
]
```


우리의 예제 중 하나로 포매팅 프롬프트를 테스트해 봅시다:

```python
print(example_prompt.invoke(examples[0]).to_string())
```

```output
Question: Who lived longer, Muhammad Ali or Alan Turing?

Are follow up questions needed here: Yes.
Follow up: How old was Muhammad Ali when he died?
Intermediate answer: Muhammad Ali was 74 years old when he died.
Follow up: How old was Alan Turing when he died?
Intermediate answer: Alan Turing was 41 years old when he died.
So the final answer is: Muhammad Ali
```

### 예제와 포매터를 `FewShotPromptTemplate`에 전달하기

마지막으로, [`FewShotPromptTemplate`](https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotPromptTemplate.html) 객체를 만듭니다. 이 객체는 몇 샷 예제와 몇 샷 예제를 위한 포매터를 입력으로 받습니다. 이 `FewShotPromptTemplate`가 포맷될 때, 전달된 예제를 `example_prompt`를 사용하여 포맷한 다음 `suffix` 이전에 최종 프롬프트에 추가합니다:

```python
<!--IMPORTS:[{"imported": "FewShotPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotPromptTemplate.html", "title": "How to use few shot examples"}]-->
from langchain_core.prompts import FewShotPromptTemplate

prompt = FewShotPromptTemplate(
    examples=examples,
    example_prompt=example_prompt,
    suffix="Question: {input}",
    input_variables=["input"],
)

print(
    prompt.invoke({"input": "Who was the father of Mary Ball Washington?"}).to_string()
)
```

```output
Question: Who lived longer, Muhammad Ali or Alan Turing?

Are follow up questions needed here: Yes.
Follow up: How old was Muhammad Ali when he died?
Intermediate answer: Muhammad Ali was 74 years old when he died.
Follow up: How old was Alan Turing when he died?
Intermediate answer: Alan Turing was 41 years old when he died.
So the final answer is: Muhammad Ali


Question: When was the founder of craigslist born?

Are follow up questions needed here: Yes.
Follow up: Who was the founder of craigslist?
Intermediate answer: Craigslist was founded by Craig Newmark.
Follow up: When was Craig Newmark born?
Intermediate answer: Craig Newmark was born on December 6, 1952.
So the final answer is: December 6, 1952


Question: Who was the maternal grandfather of George Washington?

Are follow up questions needed here: Yes.
Follow up: Who was the mother of George Washington?
Intermediate answer: The mother of George Washington was Mary Ball Washington.
Follow up: Who was the father of Mary Ball Washington?
Intermediate answer: The father of Mary Ball Washington was Joseph Ball.
So the final answer is: Joseph Ball


Question: Are both the directors of Jaws and Casino Royale from the same country?

Are follow up questions needed here: Yes.
Follow up: Who is the director of Jaws?
Intermediate Answer: The director of Jaws is Steven Spielberg.
Follow up: Where is Steven Spielberg from?
Intermediate Answer: The United States.
Follow up: Who is the director of Casino Royale?
Intermediate Answer: The director of Casino Royale is Martin Campbell.
Follow up: Where is Martin Campbell from?
Intermediate Answer: New Zealand.
So the final answer is: No


Question: Who was the father of Mary Ball Washington?
```

이렇게 모델에 예제를 제공함으로써, 우리는 모델이 더 나은 응답을 하도록 안내할 수 있습니다.

## 예제 선택기 사용하기

우리는 이전 섹션에서 예제 집합과 포매터를 재사용할 것입니다. 그러나 예제를 `FewShotPromptTemplate` 객체에 직접 제공하는 대신, [`SemanticSimilarityExampleSelector`](https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.semantic_similarity.SemanticSimilarityExampleSelector.html)라는 `ExampleSelector`의 구현에 제공합니다. 이 클래스는 입력과의 유사성에 따라 초기 집합에서 몇 샷 예제를 선택합니다. 입력과 몇 샷 예제 간의 유사성을 계산하기 위해 임베딩 모델을 사용하고, 최근접 이웃 검색을 수행하기 위해 벡터 저장소를 사용합니다.

어떻게 생겼는지 보여주기 위해 인스턴스를 초기화하고 독립적으로 호출해 보겠습니다:

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to use few shot examples"}, {"imported": "SemanticSimilarityExampleSelector", "source": "langchain_core.example_selectors", "docs": "https://api.python.langchain.com/en/latest/example_selectors/langchain_core.example_selectors.semantic_similarity.SemanticSimilarityExampleSelector.html", "title": "How to use few shot examples"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to use few shot examples"}]-->
from langchain_chroma import Chroma
from langchain_core.example_selectors import SemanticSimilarityExampleSelector
from langchain_openai import OpenAIEmbeddings

example_selector = SemanticSimilarityExampleSelector.from_examples(
    # This is the list of examples available to select from.
    examples,
    # This is the embedding class used to produce embeddings which are used to measure semantic similarity.
    OpenAIEmbeddings(),
    # This is the VectorStore class that is used to store the embeddings and do a similarity search over.
    Chroma,
    # This is the number of examples to produce.
    k=1,
)

# Select the most similar example to the input.
question = "Who was the father of Mary Ball Washington?"
selected_examples = example_selector.select_examples({"question": question})
print(f"Examples most similar to the input: {question}")
for example in selected_examples:
    print("\n")
    for k, v in example.items():
        print(f"{k}: {v}")
```

```output
Examples most similar to the input: Who was the father of Mary Ball Washington?


answer: 
Are follow up questions needed here: Yes.
Follow up: Who was the mother of George Washington?
Intermediate answer: The mother of George Washington was Mary Ball Washington.
Follow up: Who was the father of Mary Ball Washington?
Intermediate answer: The father of Mary Ball Washington was Joseph Ball.
So the final answer is: Joseph Ball

question: Who was the maternal grandfather of George Washington?
```

이제 `FewShotPromptTemplate` 객체를 생성해 보겠습니다. 이 객체는 예제 선택기와 몇 샷 예제를 위한 포매터 프롬프트를 입력으로 받습니다.

```python
prompt = FewShotPromptTemplate(
    example_selector=example_selector,
    example_prompt=example_prompt,
    suffix="Question: {input}",
    input_variables=["input"],
)

print(
    prompt.invoke({"input": "Who was the father of Mary Ball Washington?"}).to_string()
)
```

```output
Question: Who was the maternal grandfather of George Washington?

Are follow up questions needed here: Yes.
Follow up: Who was the mother of George Washington?
Intermediate answer: The mother of George Washington was Mary Ball Washington.
Follow up: Who was the father of Mary Ball Washington?
Intermediate answer: The father of Mary Ball Washington was Joseph Ball.
So the final answer is: Joseph Ball


Question: Who was the father of Mary Ball Washington?
```

## 다음 단계

이제 프롬프트에 몇 샷 예제를 추가하는 방법을 배웠습니다.

다음으로, 이 섹션의 프롬프트 템플릿에 대한 다른 방법 가이드를 확인하거나, [채팅 모델로 몇 샷 사용하기](/docs/how_to/few_shot_examples_chat)에 대한 관련 방법 가이드 또는 다른 [예제 선택기 방법 가이드](/docs/how_to/example_selectors/)를 확인하세요.