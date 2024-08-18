---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/extraction_long_text.ipynb
description: 긴 텍스트 추출 시 LLM의 컨텍스트 창을 초과하는 문제를 해결하는 전략을 설명하는 가이드입니다.
---

# 긴 텍스트를 추출할 때 처리하는 방법

PDF와 같은 파일을 작업할 때, 언어 모델의 컨텍스트 창을 초과하는 텍스트를 만날 가능성이 높습니다. 이 텍스트를 처리하기 위해 다음과 같은 전략을 고려해 보세요:

1. **LLM 변경** 더 큰 컨텍스트 창을 지원하는 다른 LLM을 선택합니다.
2. **무차별 대입** 문서를 청크로 나누고 각 청크에서 내용을 추출합니다.
3. **RAG** 문서를 청크로 나누고, 청크를 인덱싱한 후 "관련"으로 보이는 청크의 하위 집합에서만 내용을 추출합니다.

이러한 전략은 각각의 장단점이 있으며, 최상의 전략은 설계 중인 애플리케이션에 따라 다를 수 있습니다!

이 가이드는 전략 2와 3을 구현하는 방법을 보여줍니다.

## 설정

예제 데이터가 필요합니다! [위키피디아의 자동차에 대한 기사](https://en.wikipedia.org/wiki/Car)를 다운로드하고 LangChain [문서](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html)로 로드해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "BSHTMLLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.html_bs.BSHTMLLoader.html", "title": "How to handle long text when doing extraction"}]-->
import re

import requests
from langchain_community.document_loaders import BSHTMLLoader

# Download the content
response = requests.get("https://en.wikipedia.org/wiki/Car")
# Write it to a file
with open("car.html", "w", encoding="utf-8") as f:
    f.write(response.text)
# Load it with an HTML parser
loader = BSHTMLLoader("car.html")
document = loader.load()[0]
# Clean up code
# Replace consecutive new lines with a single new line
document.page_content = re.sub("\n\n+", "\n", document.page_content)
```


```python
print(len(document.page_content))
```

```output
79174
```


## 스키마 정의

[추출 튜토리얼](/docs/tutorials/extraction)을 따라, 추출하고자 하는 정보의 스키마를 정의하기 위해 Pydantic을 사용할 것입니다. 이 경우, 연도와 설명을 포함하는 "주요 개발" 목록(예: 중요한 역사적 사건)을 추출할 것입니다.

또한 `evidence` 키를 포함하고 모델에게 기사에서 관련 문장을 그대로 제공하도록 지시합니다. 이를 통해 추출 결과를 원본 문서의 텍스트(모델의 재구성)와 비교할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to handle long text when doing extraction"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to handle long text when doing extraction"}]-->
from typing import List, Optional

from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.pydantic_v1 import BaseModel, Field


class KeyDevelopment(BaseModel):
    """Information about a development in the history of cars."""

    year: int = Field(
        ..., description="The year when there was an important historic development."
    )
    description: str = Field(
        ..., description="What happened in this year? What was the development?"
    )
    evidence: str = Field(
        ...,
        description="Repeat in verbatim the sentence(s) from which the year and description information were extracted",
    )


class ExtractionData(BaseModel):
    """Extracted information about key developments in the history of cars."""

    key_developments: List[KeyDevelopment]


# Define a custom prompt to provide instructions and any additional context.
# 1) You can add examples into the prompt template to improve extraction quality
# 2) Introduce additional parameters to take context into account (e.g., include metadata
#    about the document from which the text was extracted.)
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are an expert at identifying key historic development in text. "
            "Only extract important historic developments. Extract nothing if no important information can be found in the text.",
        ),
        ("human", "{text}"),
    ]
)
```


## 추출기 생성

LLM을 선택해 보겠습니다. 도구 호출을 사용하고 있기 때문에 도구 호출 기능을 지원하는 모델이 필요합니다. 사용 가능한 LLM에 대한 [이 표](/docs/integrations/chat)를 참조하세요.

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs
customVarName="llm"
openaiParams={`model="gpt-4-0125-preview", temperature=0`}
/>

```python
extractor = prompt | llm.with_structured_output(
    schema=ExtractionData,
    include_raw=False,
)
```


## 무차별 대입 접근법

문서를 청크로 나누어 각 청크가 LLM의 컨텍스트 창에 맞도록 합니다.

```python
<!--IMPORTS:[{"imported": "TokenTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/base/langchain_text_splitters.base.TokenTextSplitter.html", "title": "How to handle long text when doing extraction"}]-->
from langchain_text_splitters import TokenTextSplitter

text_splitter = TokenTextSplitter(
    # Controls the size of each chunk
    chunk_size=2000,
    # Controls overlap between chunks
    chunk_overlap=20,
)

texts = text_splitter.split_text(document.page_content)
```


[배치](https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.Runnable.html) 기능을 사용하여 각 청크에서 추출을 **병렬로** 실행하세요!

:::tip
종종 .batch()를 사용하여 추출을 병렬화할 수 있습니다! `.batch`는 내부적으로 스레드 풀을 사용하여 작업을 병렬화하는 데 도움을 줍니다.

모델이 API를 통해 노출되어 있다면, 추출 흐름이 빨라질 것입니다!
:::

```python
# Limit just to the first 3 chunks
# so the code can be re-run quickly
first_few = texts[:3]

extractions = extractor.batch(
    [{"text": text} for text in first_few],
    {"max_concurrency": 5},  # limit the concurrency by passing max concurrency!
)
```


### 결과 병합

청크에서 데이터를 추출한 후, 추출 결과를 병합하고자 합니다.

```python
key_developments = []

for extraction in extractions:
    key_developments.extend(extraction.key_developments)

key_developments[:10]
```


```output
[KeyDevelopment(year=1966, description='The Toyota Corolla began production, becoming the best-selling series of automobile in history.', evidence='The Toyota Corolla, which has been in production since 1966, is the best-selling series of automobile in history.'),
 KeyDevelopment(year=1769, description='Nicolas-Joseph Cugnot built the first steam-powered road vehicle.', evidence='The French inventor Nicolas-Joseph Cugnot built the first steam-powered road vehicle in 1769.'),
 KeyDevelopment(year=1808, description='François Isaac de Rivaz designed and constructed the first internal combustion-powered automobile.', evidence='the Swiss inventor François Isaac de Rivaz designed and constructed the first internal combustion-powered automobile in 1808.'),
 KeyDevelopment(year=1886, description='Carl Benz patented his Benz Patent-Motorwagen, inventing the modern car.', evidence='The modern car—a practical, marketable automobile for everyday use—was invented in 1886, when the German inventor Carl Benz patented his Benz Patent-Motorwagen.'),
 KeyDevelopment(year=1908, description='Ford Model T, one of the first cars affordable by the masses, began production.', evidence='One of the first cars affordable by the masses was the Ford Model T, begun in 1908, an American car manufactured by the Ford Motor Company.'),
 KeyDevelopment(year=1888, description="Bertha Benz undertook the first road trip by car to prove the road-worthiness of her husband's invention.", evidence="In August 1888, Bertha Benz, the wife of Carl Benz, undertook the first road trip by car, to prove the road-worthiness of her husband's invention."),
 KeyDevelopment(year=1896, description='Benz designed and patented the first internal-combustion flat engine, called boxermotor.', evidence='In 1896, Benz designed and patented the first internal-combustion flat engine, called boxermotor.'),
 KeyDevelopment(year=1897, description='Nesselsdorfer Wagenbau produced the Präsident automobil, one of the first factory-made cars in the world.', evidence='The first motor car in central Europe and one of the first factory-made cars in the world, was produced by Czech company Nesselsdorfer Wagenbau (later renamed to Tatra) in 1897, the Präsident automobil.'),
 KeyDevelopment(year=1890, description='Daimler Motoren Gesellschaft (DMG) was founded by Daimler and Maybach in Cannstatt.', evidence='Daimler and Maybach founded Daimler Motoren Gesellschaft (DMG) in Cannstatt in 1890.'),
 KeyDevelopment(year=1891, description='Auguste Doriot and Louis Rigoulot completed the longest trip by a petrol-driven vehicle with a Daimler powered Peugeot Type 3.', evidence='In 1891, Auguste Doriot and his Peugeot colleague Louis Rigoulot completed the longest trip by a petrol-driven vehicle when their self-designed and built Daimler powered Peugeot Type 3 completed 2,100 kilometres (1,300 mi) from Valentigney to Paris and Brest and back again.')]
```


## RAG 기반 접근법

또 다른 간단한 아이디어는 텍스트를 청크로 나누는 것이지만, 모든 청크에서 정보를 추출하는 대신 가장 관련성이 높은 청크에만 집중하는 것입니다.

:::caution
어떤 청크가 관련이 있는지 식별하기 어려울 수 있습니다.

예를 들어, 여기서 사용하는 `car` 기사에서는 대부분의 기사가 주요 개발 정보로 구성되어 있습니다. 따라서 **RAG**를 사용하면 많은 관련 정보를 버릴 가능성이 높습니다.

사용 사례를 실험해 보고 이 접근법이 작동하는지 여부를 판단하는 것을 권장합니다.
:::

RAG 기반 접근법을 구현하려면:

1. 문서를 청크로 나누고 인덱싱합니다(예: 벡터 저장소에);
2. 벡터 저장소를 사용하여 검색 단계를 추가하여 `extractor` 체인을 전처리합니다.

다음은 `FAISS` 벡터 저장소에 의존하는 간단한 예입니다.

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to handle long text when doing extraction"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to handle long text when doing extraction"}, {"imported": "RunnableLambda", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableLambda.html", "title": "How to handle long text when doing extraction"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to handle long text when doing extraction"}, {"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "How to handle long text when doing extraction"}]-->
from langchain_community.vectorstores import FAISS
from langchain_core.documents import Document
from langchain_core.runnables import RunnableLambda
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import CharacterTextSplitter

texts = text_splitter.split_text(document.page_content)
vectorstore = FAISS.from_texts(texts, embedding=OpenAIEmbeddings())

retriever = vectorstore.as_retriever(
    search_kwargs={"k": 1}
)  # Only extract from first document
```


이 경우 RAG 추출기는 상위 문서만 살펴보고 있습니다.

```python
rag_extractor = {
    "text": retriever | (lambda docs: docs[0].page_content)  # fetch content of top doc
} | extractor
```


```python
results = rag_extractor.invoke("Key developments associated with cars")
```


```python
for key_development in results.key_developments:
    print(key_development)
```

```output
year=1869 description='Mary Ward became one of the first documented car fatalities in Parsonstown, Ireland.' evidence='Mary Ward became one of the first documented car fatalities in 1869 in Parsonstown, Ireland,'
year=1899 description="Henry Bliss one of the US's first pedestrian car casualties in New York City." evidence="Henry Bliss one of the US's first pedestrian car casualties in 1899 in New York City."
year=2030 description='All fossil fuel vehicles will be banned in Amsterdam.' evidence='all fossil fuel vehicles will be banned in Amsterdam from 2030.'
```


## 일반적인 문제

다양한 방법은 비용, 속도 및 정확성과 관련하여 각각 장단점이 있습니다.

다음 문제에 주의하세요:

* 콘텐츠를 청크로 나누면 정보가 여러 청크에 분산되어 LLM이 정보를 추출하지 못할 수 있습니다.
* 큰 청크 중복은 동일한 정보가 두 번 추출될 수 있으므로 중복 제거를 준비하세요!
* LLM은 데이터를 만들어낼 수 있습니다. 큰 텍스트에서 단일 사실을 찾고 무차별 대입 접근법을 사용할 경우, 더 많은 허위 데이터를 얻을 수 있습니다.