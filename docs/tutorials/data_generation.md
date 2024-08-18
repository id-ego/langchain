---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/tutorials/data_generation.ipynb
description: 합성 데이터는 개인 정보를 보호하면서 실제 데이터를 시뮬레이션할 수 있는 인공적으로 생성된 데이터입니다.
sidebar_class_name: hidden
---

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/langchain-ai/langchain/blob/master/docs/docs/use_cases/data_generation.ipynb)

# 합성 데이터 생성

합성 데이터는 실제 사건에서 수집된 데이터가 아닌 인위적으로 생성된 데이터입니다. 이는 개인 정보 보호를 침해하거나 실제 세계의 한계에 직면하지 않고 실제 데이터를 시뮬레이션하는 데 사용됩니다.

합성 데이터의 이점:

1. **개인 정보 보호 및 보안**: 유출 위험이 있는 실제 개인 데이터가 없음.
2. **데이터 증강**: 머신러닝을 위한 데이터셋 확장.
3. **유연성**: 특정 또는 드문 시나리오 생성.
4. **비용 효율적**: 실제 데이터 수집보다 종종 저렴함.
5. **규제 준수**: 엄격한 데이터 보호 법률을 탐색하는 데 도움.
6. **모델 강건성**: 더 나은 일반화 AI 모델로 이어질 수 있음.
7. **신속한 프로토타이핑**: 실제 데이터 없이 빠른 테스트 가능.
8. **제어된 실험**: 특정 조건을 시뮬레이션.
9. **데이터 접근**: 실제 데이터가 없을 때의 대안.

참고: 이점에도 불구하고 합성 데이터는 실제 세계의 복잡성을 항상 포착하지 못할 수 있으므로 주의해서 사용해야 합니다.

## 빠른 시작

이 노트북에서는 langchain 라이브러리를 사용하여 합성 의료 청구 기록을 생성하는 방법을 깊이 있게 다룰 것입니다. 이 도구는 개인 정보 보호 문제나 데이터 가용성 문제로 인해 실제 환자 데이터를 사용하고 싶지 않을 때 알고리즘을 개발하거나 테스트하는 데 특히 유용합니다.

### 설정
먼저, langchain 라이브러리와 그 종속성을 설치해야 합니다. OpenAI 생성기 체인을 사용하고 있으므로 그것도 설치하겠습니다. 실험적인 라이브러리이므로 `langchain_experimental`을 설치에 포함해야 합니다. 그런 다음 필요한 모듈을 가져옵니다.

```python
<!--IMPORTS:[{"imported": "FewShotPromptTemplate", "source": "langchain.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.few_shot.FewShotPromptTemplate.html", "title": "Generate Synthetic Data"}, {"imported": "PromptTemplate", "source": "langchain.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Generate Synthetic Data"}, {"imported": "OPENAI_TEMPLATE", "source": "langchain_experimental.tabular_synthetic_data.openai", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.OPENAI_TEMPLATE.html", "title": "Generate Synthetic Data"}, {"imported": "create_openai_data_generator", "source": "langchain_experimental.tabular_synthetic_data.openai", "docs": "https://api.python.langchain.com/en/latest/tabular_synthetic_data/langchain_experimental.tabular_synthetic_data.openai.create_openai_data_generator.html", "title": "Generate Synthetic Data"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Generate Synthetic Data"}]-->
%pip install --upgrade --quiet  langchain langchain_experimental langchain-openai
# Set env var OPENAI_API_KEY or load from a .env file:
# import dotenv
# dotenv.load_dotenv()

from langchain.prompts import FewShotPromptTemplate, PromptTemplate
from langchain_core.pydantic_v1 import BaseModel
from langchain_experimental.tabular_synthetic_data.openai import (
    OPENAI_TEMPLATE,
    create_openai_data_generator,
)
from langchain_experimental.tabular_synthetic_data.prompts import (
    SYNTHETIC_FEW_SHOT_PREFIX,
    SYNTHETIC_FEW_SHOT_SUFFIX,
)
from langchain_openai import ChatOpenAI
```


## 1. 데이터 모델 정의
모든 데이터셋은 구조 또는 "스키마"를 가지고 있습니다. 아래의 MedicalBilling 클래스는 합성 데이터의 스키마 역할을 합니다. 이를 정의함으로써 합성 데이터 생성기에 우리가 기대하는 데이터의 형태와 특성에 대해 알리고 있습니다.

```python
class MedicalBilling(BaseModel):
    patient_id: int
    patient_name: str
    diagnosis_code: str
    procedure_code: str
    total_charge: float
    insurance_claim_amount: float
```


예를 들어, 모든 기록은 정수형인 `patient_id`와 문자열인 `patient_name` 등을 가집니다.

## 2. 샘플 데이터
합성 데이터 생성기를 안내하기 위해 몇 가지 실제와 유사한 예제를 제공하는 것이 유용합니다. 이러한 예제는 "씨앗" 역할을 하며, 원하는 데이터 유형을 대표하고 생성기는 이를 사용하여 유사한 데이터를 생성합니다.

다음은 허구의 의료 청구 기록입니다:

```python
examples = [
    {
        "example": """Patient ID: 123456, Patient Name: John Doe, Diagnosis Code: 
        J20.9, Procedure Code: 99203, Total Charge: $500, Insurance Claim Amount: $350"""
    },
    {
        "example": """Patient ID: 789012, Patient Name: Johnson Smith, Diagnosis 
        Code: M54.5, Procedure Code: 99213, Total Charge: $150, Insurance Claim Amount: $120"""
    },
    {
        "example": """Patient ID: 345678, Patient Name: Emily Stone, Diagnosis Code: 
        E11.9, Procedure Code: 99214, Total Charge: $300, Insurance Claim Amount: $250"""
    },
]
```


## 3. 프롬프트 템플릿 작성
생성기는 우리의 데이터를 어떻게 생성할지 마법처럼 알지 못합니다. 우리는 이를 안내해야 합니다. 이를 위해 프롬프트 템플릿을 생성합니다. 이 템플릿은 합성 데이터를 원하는 형식으로 생성하도록 기본 언어 모델에 지시하는 데 도움이 됩니다.

```python
OPENAI_TEMPLATE = PromptTemplate(input_variables=["example"], template="{example}")

prompt_template = FewShotPromptTemplate(
    prefix=SYNTHETIC_FEW_SHOT_PREFIX,
    examples=examples,
    suffix=SYNTHETIC_FEW_SHOT_SUFFIX,
    input_variables=["subject", "extra"],
    example_prompt=OPENAI_TEMPLATE,
)
```


`FewShotPromptTemplate`에는 다음이 포함됩니다:

- `prefix` 및 `suffix`: 이러한 부분은 안내하는 맥락이나 지침을 포함할 가능성이 높습니다.
- `examples`: 우리가 이전에 정의한 샘플 데이터.
- `input_variables`: 이러한 변수("subject", "extra")는 나중에 동적으로 채울 수 있는 자리 표시자입니다. 예를 들어, "subject"는 모델을 더 안내하기 위해 "medical_billing"으로 채워질 수 있습니다.
- `example_prompt`: 이 프롬프트 템플릿은 프롬프트에서 각 예제 행이 가져야 할 형식입니다.

## 4. 데이터 생성기 생성
스키마와 프롬프트가 준비되면 다음 단계는 데이터 생성기를 만드는 것입니다. 이 객체는 합성 데이터를 얻기 위해 기본 언어 모델과 통신하는 방법을 알고 있습니다.

```python
synthetic_data_generator = create_openai_data_generator(
    output_schema=MedicalBilling,
    llm=ChatOpenAI(
        temperature=1
    ),  # You'll need to replace with your actual Language Model instance
    prompt=prompt_template,
)
```


## 5. 합성 데이터 생성
마지막으로, 합성 데이터를 얻어봅시다!

```python
synthetic_results = synthetic_data_generator.generate(
    subject="medical_billing",
    extra="the name must be chosen at random. Make it something you wouldn't normally choose.",
    runs=10,
)
```


이 명령은 생성기에게 10개의 합성 의료 청구 기록을 생성하도록 요청합니다. 결과는 `synthetic_results`에 저장됩니다. 출력은 MedicalBilling pydantic 모델의 목록이 될 것입니다.

### 다른 구현

```python
<!--IMPORTS:[{"imported": "DatasetGenerator", "source": "langchain_experimental.synthetic_data", "docs": "https://api.python.langchain.com/en/latest/synthetic_data/langchain_experimental.synthetic_data.DatasetGenerator.html", "title": "Generate Synthetic Data"}, {"imported": "create_data_generation_chain", "source": "langchain_experimental.synthetic_data", "docs": "https://api.python.langchain.com/en/latest/synthetic_data/langchain_experimental.synthetic_data.create_data_generation_chain.html", "title": "Generate Synthetic Data"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Generate Synthetic Data"}]-->
from langchain_experimental.synthetic_data import (
    DatasetGenerator,
    create_data_generation_chain,
)
from langchain_openai import ChatOpenAI
```


```python
# LLM
model = ChatOpenAI(model="gpt-3.5-turbo", temperature=0.7)
chain = create_data_generation_chain(model)
```


```python
chain({"fields": ["blue", "yellow"], "preferences": {}})
```


```output
{'fields': ['blue', 'yellow'],
 'preferences': {},
 'text': 'The vibrant blue sky contrasted beautifully with the bright yellow sun, creating a stunning display of colors that instantly lifted the spirits of all who gazed upon it.'}
```


```python
chain(
    {
        "fields": {"colors": ["blue", "yellow"]},
        "preferences": {"style": "Make it in a style of a weather forecast."},
    }
)
```


```output
{'fields': {'colors': ['blue', 'yellow']},
 'preferences': {'style': 'Make it in a style of a weather forecast.'},
 'text': "Good morning! Today's weather forecast brings a beautiful combination of colors to the sky, with hues of blue and yellow gently blending together like a mesmerizing painting."}
```


```python
chain(
    {
        "fields": {"actor": "Tom Hanks", "movies": ["Forrest Gump", "Green Mile"]},
        "preferences": None,
    }
)
```


```output
{'fields': {'actor': 'Tom Hanks', 'movies': ['Forrest Gump', 'Green Mile']},
 'preferences': None,
 'text': 'Tom Hanks, the renowned actor known for his incredible versatility and charm, has graced the silver screen in unforgettable movies such as "Forrest Gump" and "Green Mile".'}
```


```python
chain(
    {
        "fields": [
            {"actor": "Tom Hanks", "movies": ["Forrest Gump", "Green Mile"]},
            {"actor": "Mads Mikkelsen", "movies": ["Hannibal", "Another round"]},
        ],
        "preferences": {"minimum_length": 200, "style": "gossip"},
    }
)
```


```output
{'fields': [{'actor': 'Tom Hanks', 'movies': ['Forrest Gump', 'Green Mile']},
  {'actor': 'Mads Mikkelsen', 'movies': ['Hannibal', 'Another round']}],
 'preferences': {'minimum_length': 200, 'style': 'gossip'},
 'text': 'Did you know that Tom Hanks, the beloved Hollywood actor known for his roles in "Forrest Gump" and "Green Mile", has shared the screen with the talented Mads Mikkelsen, who gained international acclaim for his performances in "Hannibal" and "Another round"? These two incredible actors have brought their exceptional skills and captivating charisma to the big screen, delivering unforgettable performances that have enthralled audiences around the world. Whether it\'s Hanks\' endearing portrayal of Forrest Gump or Mikkelsen\'s chilling depiction of Hannibal Lecter, these movies have solidified their places in cinematic history, leaving a lasting impact on viewers and cementing their status as true icons of the silver screen.'}
```


생성된 예제가 다양하고 우리가 원하는 정보를 가지고 있는 것을 볼 수 있습니다. 또한, 그들의 스타일은 주어진 선호도를 잘 반영합니다.

## 추출 벤치마킹 목적을 위한 모범 데이터셋 생성

```python
inp = [
    {
        "Actor": "Tom Hanks",
        "Film": [
            "Forrest Gump",
            "Saving Private Ryan",
            "The Green Mile",
            "Toy Story",
            "Catch Me If You Can",
        ],
    },
    {
        "Actor": "Tom Hardy",
        "Film": [
            "Inception",
            "The Dark Knight Rises",
            "Mad Max: Fury Road",
            "The Revenant",
            "Dunkirk",
        ],
    },
]

generator = DatasetGenerator(model, {"style": "informal", "minimal length": 500})
dataset = generator(inp)
```


```python
dataset
```


```output
[{'fields': {'Actor': 'Tom Hanks',
   'Film': ['Forrest Gump',
    'Saving Private Ryan',
    'The Green Mile',
    'Toy Story',
    'Catch Me If You Can']},
  'preferences': {'style': 'informal', 'minimal length': 500},
  'text': 'Tom Hanks, the versatile and charismatic actor, has graced the silver screen in numerous iconic films including the heartwarming and inspirational "Forrest Gump," the intense and gripping war drama "Saving Private Ryan," the emotionally charged and thought-provoking "The Green Mile," the beloved animated classic "Toy Story," and the thrilling and captivating true story adaptation "Catch Me If You Can." With his impressive range and genuine talent, Hanks continues to captivate audiences worldwide, leaving an indelible mark on the world of cinema.'},
 {'fields': {'Actor': 'Tom Hardy',
   'Film': ['Inception',
    'The Dark Knight Rises',
    'Mad Max: Fury Road',
    'The Revenant',
    'Dunkirk']},
  'preferences': {'style': 'informal', 'minimal length': 500},
  'text': 'Tom Hardy, the versatile actor known for his intense performances, has graced the silver screen in numerous iconic films, including "Inception," "The Dark Knight Rises," "Mad Max: Fury Road," "The Revenant," and "Dunkirk." Whether he\'s delving into the depths of the subconscious mind, donning the mask of the infamous Bane, or navigating the treacherous wasteland as the enigmatic Max Rockatansky, Hardy\'s commitment to his craft is always evident. From his breathtaking portrayal of the ruthless Eames in "Inception" to his captivating transformation into the ferocious Max in "Mad Max: Fury Road," Hardy\'s dynamic range and magnetic presence captivate audiences and leave an indelible mark on the world of cinema. In his most physically demanding role to date, he endured the harsh conditions of the freezing wilderness as he portrayed the rugged frontiersman John Fitzgerald in "The Revenant," earning him critical acclaim and an Academy Award nomination. In Christopher Nolan\'s war epic "Dunkirk," Hardy\'s stoic and heroic portrayal of Royal Air Force pilot Farrier showcases his ability to convey deep emotion through nuanced performances. With his chameleon-like ability to inhabit a wide range of characters and his unwavering commitment to his craft, Tom Hardy has undoubtedly solidified his place as one of the most talented and sought-after actors of his generation.'}]
```


## 생성된 예제에서 추출
좋습니다, 이제 이 생성된 데이터에서 출력을 추출할 수 있는지, 그리고 그것이 우리의 사례와 어떻게 비교되는지 살펴봅시다!

```python
<!--IMPORTS:[{"imported": "create_extraction_chain_pydantic", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.openai_functions.extraction.create_extraction_chain_pydantic.html", "title": "Generate Synthetic Data"}, {"imported": "PydanticOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.pydantic.PydanticOutputParser.html", "title": "Generate Synthetic Data"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Generate Synthetic Data"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Generate Synthetic Data"}]-->
from typing import List

from langchain.chains import create_extraction_chain_pydantic
from langchain_core.output_parsers import PydanticOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI
from pydantic import BaseModel, Field
```


```python
class Actor(BaseModel):
    Actor: str = Field(description="name of an actor")
    Film: List[str] = Field(description="list of names of films they starred in")
```


### 파서

```python
llm = OpenAI()
parser = PydanticOutputParser(pydantic_object=Actor)

prompt = PromptTemplate(
    template="Extract fields from a given text.\n{format_instructions}\n{text}\n",
    input_variables=["text"],
    partial_variables={"format_instructions": parser.get_format_instructions()},
)

_input = prompt.format_prompt(text=dataset[0]["text"])
output = llm(_input.to_string())

parsed = parser.parse(output)
parsed
```


```output
Actor(Actor='Tom Hanks', Film=['Forrest Gump', 'Saving Private Ryan', 'The Green Mile', 'Toy Story', 'Catch Me If You Can'])
```


```python
(parsed.Actor == inp[0]["Actor"]) & (parsed.Film == inp[0]["Film"])
```


```output
True
```


### 추출기

```python
extractor = create_extraction_chain_pydantic(pydantic_schema=Actor, llm=model)
extracted = extractor.run(dataset[1]["text"])
extracted
```


```output
[Actor(Actor='Tom Hardy', Film=['Inception', 'The Dark Knight Rises', 'Mad Max: Fury Road', 'The Revenant', 'Dunkirk'])]
```


```python
(extracted[0].Actor == inp[1]["Actor"]) & (extracted[0].Film == inp[1]["Film"])
```


```output
True
```