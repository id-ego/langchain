---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/qa_citations.ipynb
description: 이 가이드는 RAG 애플리케이션에서 응답 생성 시 출처 문서의 인용 방법을 다룹니다. 다섯 가지 방법을 소개합니다.
---

# RAG 애플리케이션에 인용 추가하는 방법

이 가이드는 모델이 응답을 생성할 때 참조한 소스 문서의 어떤 부분을 인용하는지에 대한 방법을 검토합니다.

다섯 가지 방법을 다룰 것입니다:

1. 도구 호출을 사용하여 문서 ID 인용하기;
2. 도구 호출을 사용하여 문서 ID와 텍스트 스니펫 인용하기;
3. 직접 프롬프트하기;
4. 검색 후 처리(즉, 검색된 맥락을 압축하여 더 관련성 있게 만들기);
5. 생성 후 처리(즉, 생성된 답변에 인용을 추가하기 위해 두 번째 LLM 호출하기).

일반적으로 귀하의 사용 사례에 맞는 첫 번째 항목을 사용하는 것을 권장합니다. 즉, 모델이 도구 호출을 지원하는 경우 방법 1 또는 2를 시도하고, 그렇지 않거나 실패할 경우 목록을 따라 진행하십시오.

먼저 간단한 RAG 체인을 만들어 보겠습니다. 시작하기 위해 [WikipediaRetriever](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.wikipedia.WikipediaRetriever.html)를 사용하여 위키피디아에서 검색할 것입니다.

## 설정

먼저 사용할 모델에 대한 종속성을 설치하고 환경 변수를 설정해야 합니다.

```python
%pip install -qU langchain langchain-openai langchain-anthropic langchain-community wikipedia
```


```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()
os.environ["ANTHROPIC_API_KEY"] = getpass.getpass()

# Uncomment if you want to log to LangSmith
# os.environ["LANGCHAIN_TRACING_V2"] = "true
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


먼저 LLM을 선택합시다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

```python
<!--IMPORTS:[{"imported": "WikipediaRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.wikipedia.WikipediaRetriever.html", "title": "How to get a RAG application to add citations"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to get a RAG application to add citations"}]-->
from langchain_community.retrievers import WikipediaRetriever
from langchain_core.prompts import ChatPromptTemplate

system_prompt = (
    "You're a helpful AI assistant. Given a user question "
    "and some Wikipedia article snippets, answer the user "
    "question. If none of the articles answer the question, "
    "just say you don't know."
    "\n\nHere are the Wikipedia articles: "
    "{context}"
)

retriever = WikipediaRetriever(top_k_results=6, doc_content_chars_max=2000)
prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        ("human", "{input}"),
    ]
)
prompt.pretty_print()
```

```output
================================[1m System Message [0m================================

You're a helpful AI assistant. Given a user question and some Wikipedia article snippets, answer the user question. If none of the articles answer the question, just say you don't know.

Here are the Wikipedia articles: [33;1m[1;3m{context}[0m

================================[1m Human Message [0m=================================

[33;1m[1;3m{input}[0m
```

모델, 검색기 및 프롬프트를 준비했으니 이제 이들을 모두 연결해 보겠습니다. 검색된 문서를 프롬프트에 전달할 수 있는 문자열로 포맷하는 논리를 추가해야 합니다. [인용 추가하기](/docs/how_to/qa_citations)에 대한 가이드를 따라 체인이 답변과 검색된 문서를 모두 반환하도록 만들겠습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to get a RAG application to add citations"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to get a RAG application to add citations"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to get a RAG application to add citations"}]-->
from typing import List

from langchain_core.documents import Document
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough


def format_docs(docs: List[Document]):
    return "\n\n".join(doc.page_content for doc in docs)


rag_chain_from_docs = (
    RunnablePassthrough.assign(context=(lambda x: format_docs(x["context"])))
    | prompt
    | llm
    | StrOutputParser()
)

retrieve_docs = (lambda x: x["input"]) | retriever

chain = RunnablePassthrough.assign(context=retrieve_docs).assign(
    answer=rag_chain_from_docs
)
```


```python
result = chain.invoke({"input": "How fast are cheetahs?"})
```


```python
print(result.keys())
```

```output
dict_keys(['input', 'context', 'answer'])
```


```python
print(result["context"][0])
```

```output
page_content='The cheetah (Acinonyx jubatus) is a large cat and the fastest land animal. It has a tawny to creamy white or pale buff fur that is marked with evenly spaced, solid black spots. The head is small and rounded, with a short snout and black tear-like facial streaks. It reaches 67–94 cm (26–37 in) at the shoulder, and the head-and-body length is between 1.1 and 1.5 m (3 ft 7 in and 4 ft 11 in). Adults weigh between 21 and 72 kg (46 and 159 lb). The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail.\nThe cheetah was first described in the late 18th century. Four subspecies are recognised today that are native to Africa and central Iran. An African subspecies was introduced to India in 2022. It is now distributed mainly in small, fragmented populations in northwestern, eastern and southern Africa and central Iran. It lives in a variety of habitats such as savannahs in the Serengeti, arid mountain ranges in the Sahara, and hilly desert terrain.\nThe cheetah lives in three main social groups: females and their cubs, male "coalitions", and solitary males. While females lead a nomadic life searching for prey in large home ranges, males are more sedentary and instead establish much smaller territories in areas with plentiful prey and access to females. The cheetah is active during the day, with peaks during dawn and dusk. It feeds on small- to medium-sized prey, mostly weighing under 40 kg (88 lb), and prefers medium-sized ungulates such as impala, springbok and Thomson\'s gazelles. The cheetah typically stalks its prey within 60–100 m (200–330 ft) before charging towards it, trips it during the chase and bites its throat to suffocate it to death. It breeds throughout the year. After a gestation of nearly three months, females give birth to a litter of three or four cubs. Cheetah cubs are highly vulnerable to predation by other large carnivores. They are weaned a' metadata={'title': 'Cheetah', 'summary': 'The cheetah (Acinonyx jubatus) is a large cat and the fastest land animal. It has a tawny to creamy white or pale buff fur that is marked with evenly spaced, solid black spots. The head is small and rounded, with a short snout and black tear-like facial streaks. It reaches 67–94 cm (26–37 in) at the shoulder, and the head-and-body length is between 1.1 and 1.5 m (3 ft 7 in and 4 ft 11 in). Adults weigh between 21 and 72 kg (46 and 159 lb). The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail.\nThe cheetah was first described in the late 18th century. Four subspecies are recognised today that are native to Africa and central Iran. An African subspecies was introduced to India in 2022. It is now distributed mainly in small, fragmented populations in northwestern, eastern and southern Africa and central Iran. It lives in a variety of habitats such as savannahs in the Serengeti, arid mountain ranges in the Sahara, and hilly desert terrain.\nThe cheetah lives in three main social groups: females and their cubs, male "coalitions", and solitary males. While females lead a nomadic life searching for prey in large home ranges, males are more sedentary and instead establish much smaller territories in areas with plentiful prey and access to females. The cheetah is active during the day, with peaks during dawn and dusk. It feeds on small- to medium-sized prey, mostly weighing under 40 kg (88 lb), and prefers medium-sized ungulates such as impala, springbok and Thomson\'s gazelles. The cheetah typically stalks its prey within 60–100 m (200–330 ft) before charging towards it, trips it during the chase and bites its throat to suffocate it to death. It breeds throughout the year. After a gestation of nearly three months, females give birth to a litter of three or four cubs. Cheetah cubs are highly vulnerable to predation by other large carnivores. They are weaned at around four months and are independent by around 20 months of age.\nThe cheetah is threatened by habitat loss, conflict with humans, poaching and high susceptibility to diseases. In 2016, the global cheetah population was estimated at 7,100 individuals in the wild; it is listed as Vulnerable on the IUCN Red List. It has been widely depicted in art, literature, advertising, and animation. It was tamed in ancient Egypt and trained for hunting ungulates in the Arabian Peninsula and India. It has been kept in zoos since the early 19th century.', 'source': 'https://en.wikipedia.org/wiki/Cheetah'}
```


```python
print(result["answer"])
```

```output
Cheetahs are capable of running at speeds of 93 to 104 km/h (58 to 65 mph). They have evolved specialized adaptations for speed, including a light build, long thin legs, and a long tail.
```

LangSmith 추적: https://smith.langchain.com/public/0472c5d1-49dc-4c1c-8100-61910067d7ed/r

## 함수 호출

선택한 LLM이 [도구 호출](/docs/concepts#functiontool-calling) 기능을 구현하는 경우, 모델이 응답을 생성할 때 참조하는 제공된 문서 중 어떤 것을 명시하도록 사용할 수 있습니다. LangChain 도구 호출 모델은 원하는 스키마를 준수하도록 생성을 강제하는 `.with_structured_output` 메서드를 구현합니다(예를 들어 [여기](https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html#langchain_openai.chat_models.base.ChatOpenAI.with_structured_output)를 참조하십시오).

### 문서 인용하기

식별자를 사용하여 문서를 인용하려면, 식별자를 프롬프트에 포맷한 다음, `.with_structured_output`을 사용하여 LLM이 출력에서 이러한 식별자를 참조하도록 강제합니다.

먼저 출력에 대한 스키마를 정의합니다. `.with_structured_output`은 JSON 스키마 및 Pydantic을 포함한 여러 형식을 지원합니다. 여기서는 Pydantic을 사용할 것입니다:

```python
from langchain_core.pydantic_v1 import BaseModel, Field


class CitedAnswer(BaseModel):
    """Answer the user question based only on the given sources, and cite the sources used."""

    answer: str = Field(
        ...,
        description="The answer to the user question, which is based only on the given sources.",
    )
    citations: List[int] = Field(
        ...,
        description="The integer IDs of the SPECIFIC sources which justify the answer.",
    )
```


사용자 입력과 함께 함수와 함께 전달할 때 모델 출력이 어떤지 살펴보겠습니다:

```python
structured_llm = llm.with_structured_output(CitedAnswer)

example_q = """What Brian's height?

Source: 1
Information: Suzy is 6'2"

Source: 2
Information: Jeremiah is blonde

Source: 3
Information: Brian is 3 inches shorter than Suzy"""
result = structured_llm.invoke(example_q)

result
```


```output
CitedAnswer(answer='Brian\'s height is 5\'11".', citations=[1, 3])
```


또는 사전 형식으로:

```python
result.dict()
```


```output
{'answer': 'Brian\'s height is 5\'11".', 'citations': [1, 3]}
```


이제 소스 식별자를 프롬프트에 구조화하여 체인과 함께 복제합니다. 세 가지 변경을 하겠습니다:

1. 프롬프트를 소스 식별자를 포함하도록 업데이트합니다;
2. `structured_llm`을 사용합니다(즉, `llm.with_structured_output(CitedAnswer)`);
3. `StrOutputParser`를 제거하여 출력에서 Pydantic 객체를 유지합니다.

```python
def format_docs_with_id(docs: List[Document]) -> str:
    formatted = [
        f"Source ID: {i}\nArticle Title: {doc.metadata['title']}\nArticle Snippet: {doc.page_content}"
        for i, doc in enumerate(docs)
    ]
    return "\n\n" + "\n\n".join(formatted)


rag_chain_from_docs = (
    RunnablePassthrough.assign(context=(lambda x: format_docs_with_id(x["context"])))
    | prompt
    | structured_llm
)

retrieve_docs = (lambda x: x["input"]) | retriever

chain = RunnablePassthrough.assign(context=retrieve_docs).assign(
    answer=rag_chain_from_docs
)
```


```python
result = chain.invoke({"input": "How fast are cheetahs?"})
```


```python
print(result["answer"])
```

```output
answer='Cheetahs can run at speeds of 93 to 104 km/h (58 to 65 mph). They are known as the fastest land animals.' citations=[0]
```

모델이 인용한 문서의 인덱스 0을 검사할 수 있습니다:

```python
print(result["context"][0])
```

```output
page_content='The cheetah (Acinonyx jubatus) is a large cat and the fastest land animal. It has a tawny to creamy white or pale buff fur that is marked with evenly spaced, solid black spots. The head is small and rounded, with a short snout and black tear-like facial streaks. It reaches 67–94 cm (26–37 in) at the shoulder, and the head-and-body length is between 1.1 and 1.5 m (3 ft 7 in and 4 ft 11 in). Adults weigh between 21 and 72 kg (46 and 159 lb). The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail.\nThe cheetah was first described in the late 18th century. Four subspecies are recognised today that are native to Africa and central Iran. An African subspecies was introduced to India in 2022. It is now distributed mainly in small, fragmented populations in northwestern, eastern and southern Africa and central Iran. It lives in a variety of habitats such as savannahs in the Serengeti, arid mountain ranges in the Sahara, and hilly desert terrain.\nThe cheetah lives in three main social groups: females and their cubs, male "coalitions", and solitary males. While females lead a nomadic life searching for prey in large home ranges, males are more sedentary and instead establish much smaller territories in areas with plentiful prey and access to females. The cheetah is active during the day, with peaks during dawn and dusk. It feeds on small- to medium-sized prey, mostly weighing under 40 kg (88 lb), and prefers medium-sized ungulates such as impala, springbok and Thomson\'s gazelles. The cheetah typically stalks its prey within 60–100 m (200–330 ft) before charging towards it, trips it during the chase and bites its throat to suffocate it to death. It breeds throughout the year. After a gestation of nearly three months, females give birth to a litter of three or four cubs. Cheetah cubs are highly vulnerable to predation by other large carnivores. They are weaned a' metadata={'title': 'Cheetah', 'summary': 'The cheetah (Acinonyx jubatus) is a large cat and the fastest land animal. It has a tawny to creamy white or pale buff fur that is marked with evenly spaced, solid black spots. The head is small and rounded, with a short snout and black tear-like facial streaks. It reaches 67–94 cm (26–37 in) at the shoulder, and the head-and-body length is between 1.1 and 1.5 m (3 ft 7 in and 4 ft 11 in). Adults weigh between 21 and 72 kg (46 and 159 lb). The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail.\nThe cheetah was first described in the late 18th century. Four subspecies are recognised today that are native to Africa and central Iran. An African subspecies was introduced to India in 2022. It is now distributed mainly in small, fragmented populations in northwestern, eastern and southern Africa and central Iran. It lives in a variety of habitats such as savannahs in the Serengeti, arid mountain ranges in the Sahara, and hilly desert terrain.\nThe cheetah lives in three main social groups: females and their cubs, male "coalitions", and solitary males. While females lead a nomadic life searching for prey in large home ranges, males are more sedentary and instead establish much smaller territories in areas with plentiful prey and access to females. The cheetah is active during the day, with peaks during dawn and dusk. It feeds on small- to medium-sized prey, mostly weighing under 40 kg (88 lb), and prefers medium-sized ungulates such as impala, springbok and Thomson\'s gazelles. The cheetah typically stalks its prey within 60–100 m (200–330 ft) before charging towards it, trips it during the chase and bites its throat to suffocate it to death. It breeds throughout the year. After a gestation of nearly three months, females give birth to a litter of three or four cubs. Cheetah cubs are highly vulnerable to predation by other large carnivores. They are weaned at around four months and are independent by around 20 months of age.\nThe cheetah is threatened by habitat loss, conflict with humans, poaching and high susceptibility to diseases. In 2016, the global cheetah population was estimated at 7,100 individuals in the wild; it is listed as Vulnerable on the IUCN Red List. It has been widely depicted in art, literature, advertising, and animation. It was tamed in ancient Egypt and trained for hunting ungulates in the Arabian Peninsula and India. It has been kept in zoos since the early 19th century.', 'source': 'https://en.wikipedia.org/wiki/Cheetah'}
```

LangSmith 추적: https://smith.langchain.com/public/aff39dc7-3e09-4d64-8083-87026d975534/r

### 스니펫 인용하기

텍스트 범위를 반환하려면(아마도 소스 식별자와 함께), 동일한 접근 방식을 사용할 수 있습니다. 유일한 변경 사항은 소스 식별자와 함께 "인용"을 포함하는 더 복잡한 출력 스키마를 Pydantic을 사용하여 구축하는 것입니다.

*참고: 문서를 문장이나 두 개로 나누어 긴 문서 몇 개 대신 많은 문서가 있는 경우, 문서를 인용하는 것은 대략적으로 스니펫을 인용하는 것과 동등해지며, 모델이 실제 텍스트 대신 각 스니펫에 대한 식별자만 반환하면 되므로 모델에게 더 쉬울 수 있습니다. 두 가지 접근 방식을 모두 시도하고 평가할 가치가 있습니다.*

```python
class Citation(BaseModel):
    source_id: int = Field(
        ...,
        description="The integer ID of a SPECIFIC source which justifies the answer.",
    )
    quote: str = Field(
        ...,
        description="The VERBATIM quote from the specified source that justifies the answer.",
    )


class QuotedAnswer(BaseModel):
    """Answer the user question based only on the given sources, and cite the sources used."""

    answer: str = Field(
        ...,
        description="The answer to the user question, which is based only on the given sources.",
    )
    citations: List[Citation] = Field(
        ..., description="Citations from the given sources that justify the answer."
    )
```


```python
rag_chain_from_docs = (
    RunnablePassthrough.assign(context=(lambda x: format_docs_with_id(x["context"])))
    | prompt
    | llm.with_structured_output(QuotedAnswer)
)

retrieve_docs = (lambda x: x["input"]) | retriever

chain = RunnablePassthrough.assign(context=retrieve_docs).assign(
    answer=rag_chain_from_docs
)
```


```python
result = chain.invoke({"input": "How fast are cheetahs?"})
```


여기에서 모델이 소스 0에서 관련 스니펫을 추출한 것을 볼 수 있습니다:

```python
result["answer"]
```


```output
QuotedAnswer(answer='Cheetahs can run at speeds of 93 to 104 km/h (58 to 65 mph).', citations=[Citation(source_id=0, quote='The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail.')])
```


LangSmith 추적: https://smith.langchain.com/public/0f638cc9-8409-4a53-9010-86ac28144129/r

## 직접 프롬프트하기

많은 모델이 함수 호출을 지원하지 않습니다. 직접 프롬프트를 통해 유사한 결과를 얻을 수 있습니다. 모델에게 출력에 대한 구조화된 XML을 생성하도록 지시해 보겠습니다:

```python
xml_system = """You're a helpful AI assistant. Given a user question and some Wikipedia article snippets, \
answer the user question and provide citations. If none of the articles answer the question, just say you don't know.

Remember, you must return both an answer and citations. A citation consists of a VERBATIM quote that \
justifies the answer and the ID of the quote article. Return a citation for every quote across all articles \
that justify the answer. Use the following format for your final output:

<cited_answer>
    <answer></answer>
    <citations>
        <citation><source_id></source_id><quote></quote></citation>
        <citation><source_id></source_id><quote></quote></citation>
        ...
    </citations>
</cited_answer>

Here are the Wikipedia articles:{context}"""
xml_prompt = ChatPromptTemplate.from_messages(
    [("system", xml_system), ("human", "{input}")]
)
```


이제 체인에 대해 유사한 작은 업데이트를 합니다:

1. 검색된 맥락을 XML 태그로 감싸도록 포맷팅 함수를 업데이트합니다;
2. 모델에 대해 `.with_structured_output`을 사용하지 않습니다(예: 모델에 존재하지 않기 때문에);
3. `StrOutputParser` 대신 [XMLOutputParser](https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.xml.XMLOutputParser.html)를 사용하여 답변을 사전으로 구문 분석합니다.

```python
<!--IMPORTS:[{"imported": "XMLOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.xml.XMLOutputParser.html", "title": "How to get a RAG application to add citations"}]-->
from langchain_core.output_parsers import XMLOutputParser


def format_docs_xml(docs: List[Document]) -> str:
    formatted = []
    for i, doc in enumerate(docs):
        doc_str = f"""\
    <source id=\"{i}\">
        <title>{doc.metadata['title']}</title>
        <article_snippet>{doc.page_content}</article_snippet>
    </source>"""
        formatted.append(doc_str)
    return "\n\n<sources>" + "\n".join(formatted) + "</sources>"


rag_chain_from_docs = (
    RunnablePassthrough.assign(context=(lambda x: format_docs_xml(x["context"])))
    | xml_prompt
    | llm
    | XMLOutputParser()
)

retrieve_docs = (lambda x: x["input"]) | retriever

chain = RunnablePassthrough.assign(context=retrieve_docs).assign(
    answer=rag_chain_from_docs
)
```


```python
result = chain.invoke({"input": "How fast are cheetahs?"})
```


인용이 다시 답변에 구조화되어 있다는 점에 유의하십시오:

```python
result["answer"]
```


```output
{'cited_answer': [{'answer': 'Cheetahs are capable of running at 93 to 104 km/h (58 to 65 mph).'},
  {'citations': [{'citation': [{'source_id': '0'},
      {'quote': 'The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail.'}]}]}]}
```


LangSmith 추적: https://smith.langchain.com/public/a3636c70-39c6-4c8f-bc83-1c7a174c237e/r

## 검색 후 처리

또 다른 접근 방식은 검색된 문서를 후처리하여 내용을 압축하여 소스 내용이 이미 최소화되어 모델이 특정 소스나 범위를 인용할 필요가 없도록 하는 것입니다. 예를 들어, 각 문서를 한두 문장으로 나누고 이를 임베드하여 가장 관련성이 높은 것만 유지할 수 있습니다. LangChain에는 이를 위한 몇 가지 내장 구성 요소가 있습니다. 여기서는 구분자 하위 문자열을 기준으로 지정된 크기로 청크를 생성하는 [RecursiveCharacterTextSplitter](https://api.python.langchain.com/en/latest/text_splitter/langchain_text_splitters.RecursiveCharacterTextSplitter.html#langchain_text_splitters.RecursiveCharacterTextSplitter)와 가장 관련성이 높은 임베딩만 유지하는 [EmbeddingsFilter](https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.document_compressors.embeddings_filter.EmbeddingsFilter.html#langchain.retrievers.document_compressors.embeddings_filter.EmbeddingsFilter)를 사용할 것입니다.

이 접근 방식은 원래 검색기를 업데이트된 것으로 교체하여 문서를 압축합니다. 시작하기 위해 검색기를 구축합니다:

```python
<!--IMPORTS:[{"imported": "EmbeddingsFilter", "source": "langchain.retrievers.document_compressors", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.document_compressors.embeddings_filter.EmbeddingsFilter.html", "title": "How to get a RAG application to add citations"}, {"imported": "RunnableParallel", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.base.RunnableParallel.html", "title": "How to get a RAG application to add citations"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to get a RAG application to add citations"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to get a RAG application to add citations"}]-->
from langchain.retrievers.document_compressors import EmbeddingsFilter
from langchain_core.runnables import RunnableParallel
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

splitter = RecursiveCharacterTextSplitter(
    chunk_size=400,
    chunk_overlap=0,
    separators=["\n\n", "\n", ".", " "],
    keep_separator=False,
)
compressor = EmbeddingsFilter(embeddings=OpenAIEmbeddings(), k=10)


def split_and_filter(input) -> List[Document]:
    docs = input["docs"]
    question = input["question"]
    split_docs = splitter.split_documents(docs)
    stateful_docs = compressor.compress_documents(split_docs, question)
    return [stateful_doc for stateful_doc in stateful_docs]


new_retriever = (
    RunnableParallel(question=RunnablePassthrough(), docs=retriever) | split_and_filter
)
docs = new_retriever.invoke("How fast are cheetahs?")
for doc in docs:
    print(doc.page_content)
    print("\n\n")
```

```output
Adults weigh between 21 and 72 kg (46 and 159 lb). The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail



The cheetah (Acinonyx jubatus) is a large cat and the fastest land animal. It has a tawny to creamy white or pale buff fur that is marked with evenly spaced, solid black spots. The head is small and rounded, with a short snout and black tear-like facial streaks. It reaches 67–94 cm (26–37 in) at the shoulder, and the head-and-body length is between 1.1 and 1.5 m (3 ft 7 in and 4 ft 11 in)



2 mph), or 171 body lengths per second. The cheetah, the fastest land mammal, scores at only 16 body lengths per second, while Anna's hummingbird has the highest known length-specific velocity attained by any vertebrate



It feeds on small- to medium-sized prey, mostly weighing under 40 kg (88 lb), and prefers medium-sized ungulates such as impala, springbok and Thomson's gazelles. The cheetah typically stalks its prey within 60–100 m (200–330 ft) before charging towards it, trips it during the chase and bites its throat to suffocate it to death. It breeds throughout the year



The cheetah was first described in the late 18th century. Four subspecies are recognised today that are native to Africa and central Iran. An African subspecies was introduced to India in 2022. It is now distributed mainly in small, fragmented populations in northwestern, eastern and southern Africa and central Iran



The cheetah lives in three main social groups: females and their cubs, male "coalitions", and solitary males. While females lead a nomadic life searching for prey in large home ranges, males are more sedentary and instead establish much smaller territories in areas with plentiful prey and access to females. The cheetah is active during the day, with peaks during dawn and dusk



The Southeast African cheetah (Acinonyx jubatus jubatus) is the nominate cheetah subspecies native to East and Southern Africa. The Southern African cheetah lives mainly in the lowland areas and deserts of the Kalahari, the savannahs of Okavango Delta, and the grasslands of the Transvaal region in South Africa. In Namibia, cheetahs are mostly found in farmlands



Subpopulations have been called "South African cheetah" and "Namibian cheetah."



In India, four cheetahs of the subspecies are living in Kuno National Park in Madhya Pradesh after having been introduced there



Acinonyx jubatus velox proposed in 1913 by Edmund Heller on basis of a cheetah that was shot by Kermit Roosevelt in June 1909 in the Kenyan highlands.
Acinonyx rex proposed in 1927 by Reginald Innes Pocock on basis of a specimen from the Umvukwe Range in Rhodesia.
```

다음으로 이전과 같이 체인에 조립합니다:

```python
rag_chain_from_docs = (
    RunnablePassthrough.assign(context=(lambda x: format_docs(x["context"])))
    | prompt
    | llm
    | StrOutputParser()
)

chain = RunnablePassthrough.assign(
    context=(lambda x: x["input"]) | new_retriever
).assign(answer=rag_chain_from_docs)
```


```python
result = chain.invoke({"input": "How fast are cheetahs?"})

print(result["answer"])
```

```output
Cheetahs are capable of running at speeds between 93 to 104 km/h (58 to 65 mph), making them the fastest land animals.
```

문서 내용이 이제 압축되었지만, 문서 객체는 메타데이터의 "요약" 키에 원래 내용을 유지한다는 점에 유의하십시오. 이러한 요약은 모델에 전달되지 않으며, 오직 압축된 내용만 전달됩니다.

```python
result["context"][0].page_content  # passed to model
```


```output
'Adults weigh between 21 and 72 kg (46 and 159 lb). The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail'
```


```python
result["context"][0].metadata["summary"]  # original document
```


```output
'The cheetah (Acinonyx jubatus) is a large cat and the fastest land animal. It has a tawny to creamy white or pale buff fur that is marked with evenly spaced, solid black spots. The head is small and rounded, with a short snout and black tear-like facial streaks. It reaches 67–94 cm (26–37 in) at the shoulder, and the head-and-body length is between 1.1 and 1.5 m (3 ft 7 in and 4 ft 11 in). Adults weigh between 21 and 72 kg (46 and 159 lb). The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail.\nThe cheetah was first described in the late 18th century. Four subspecies are recognised today that are native to Africa and central Iran. An African subspecies was introduced to India in 2022. It is now distributed mainly in small, fragmented populations in northwestern, eastern and southern Africa and central Iran. It lives in a variety of habitats such as savannahs in the Serengeti, arid mountain ranges in the Sahara, and hilly desert terrain.\nThe cheetah lives in three main social groups: females and their cubs, male "coalitions", and solitary males. While females lead a nomadic life searching for prey in large home ranges, males are more sedentary and instead establish much smaller territories in areas with plentiful prey and access to females. The cheetah is active during the day, with peaks during dawn and dusk. It feeds on small- to medium-sized prey, mostly weighing under 40 kg (88 lb), and prefers medium-sized ungulates such as impala, springbok and Thomson\'s gazelles. The cheetah typically stalks its prey within 60–100 m (200–330 ft) before charging towards it, trips it during the chase and bites its throat to suffocate it to death. It breeds throughout the year. After a gestation of nearly three months, females give birth to a litter of three or four cubs. Cheetah cubs are highly vulnerable to predation by other large carnivores. They are weaned at around four months and are independent by around 20 months of age.\nThe cheetah is threatened by habitat loss, conflict with humans, poaching and high susceptibility to diseases. In 2016, the global cheetah population was estimated at 7,100 individuals in the wild; it is listed as Vulnerable on the IUCN Red List. It has been widely depicted in art, literature, advertising, and animation. It was tamed in ancient Egypt and trained for hunting ungulates in the Arabian Peninsula and India. It has been kept in zoos since the early 19th century.'
```


LangSmith 추적: https://smith.langchain.com/public/a61304fa-e5a5-4c64-a268-b0aef1130d53/r

## 생성 후 처리

또 다른 접근 방식은 모델 생성을 후처리하는 것입니다. 이 예제에서는 먼저 답변만 생성한 다음, 모델에게 자신의 답변에 인용을 추가하도록 요청할 것입니다. 이 접근 방식의 단점은 물론 두 개의 모델 호출이 필요하기 때문에 느리고 비용이 더 많이 든다는 것입니다.

이를 초기 체인에 적용해 보겠습니다.

```python
class Citation(BaseModel):
    source_id: int = Field(
        ...,
        description="The integer ID of a SPECIFIC source which justifies the answer.",
    )
    quote: str = Field(
        ...,
        description="The VERBATIM quote from the specified source that justifies the answer.",
    )


class AnnotatedAnswer(BaseModel):
    """Annotate the answer to the user question with quote citations that justify the answer."""

    citations: List[Citation] = Field(
        ..., description="Citations from the given sources that justify the answer."
    )


structured_llm = llm.with_structured_output(AnnotatedAnswer)
```


```python
<!--IMPORTS:[{"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to get a RAG application to add citations"}]-->
from langchain_core.prompts import MessagesPlaceholder

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        ("human", "{question}"),
        MessagesPlaceholder("chat_history", optional=True),
    ]
)
answer = prompt | llm
annotation_chain = prompt | structured_llm

chain = (
    RunnableParallel(
        question=RunnablePassthrough(), docs=(lambda x: x["input"]) | retriever
    )
    .assign(context=format)
    .assign(ai_message=answer)
    .assign(
        chat_history=(lambda x: [x["ai_message"]]),
        answer=(lambda x: x["ai_message"].content),
    )
    .assign(annotations=annotation_chain)
    .pick(["answer", "docs", "annotations"])
)
```


```python
result = chain.invoke({"input": "How fast are cheetahs?"})
```


```python
print(result["answer"])
```

```output
Cheetahs are capable of running at speeds between 93 to 104 km/h (58 to 65 mph). Their specialized adaptations for speed, such as a light build, long thin legs, and a long tail, allow them to be the fastest land animals.
```


```python
result["annotations"]
```


```output
AnnotatedAnswer(citations=[Citation(source_id=0, quote='The cheetah is capable of running at 93 to 104 km/h (58 to 65 mph); it has evolved specialized adaptations for speed, including a light build, long thin legs and a long tail.')])
```


LangSmith 추적: https://smith.langchain.com/public/bf5e8856-193b-4ff2-af8d-c0f4fbd1d9cb/r