---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/arxiv.ipynb
description: arXiv에서 과학 기사를 검색하여 Langchain의 Document 형식으로 변환하는 방법을 보여주는 노트북입니다.
sidebar_label: Arxiv
---

# ArxivRetriever

> [arXiv](https://arxiv.org/)는 물리학, 수학, 컴퓨터 과학, 정량 생물학, 정량 금융, 통계학, 전기 공학 및 시스템 과학, 경제학 분야의 200만 개 학술 기사를 위한 오픈 액세스 아카이브입니다.

이 노트북은 Arxiv.org에서 [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 형식으로 과학 기사를 검색하는 방법을 보여줍니다.

모든 `ArxivRetriever` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.arxiv.ArxivRetriever.html)에서 확인할 수 있습니다.

### 통합 세부정보

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="external_retrievers" item="ArxivRetriever" />


## 설정

개별 쿼리에서 자동 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

이 검색기는 `langchain-community` 패키지에 포함되어 있습니다. 또한 [arxiv](https://pypi.org/project/arxiv/) 의존성도 필요합니다:

```python
%pip install -qU langchain-community arxiv
```


## 인스턴스화

`ArxivRetriever` 매개변수는 다음을 포함합니다:
- 선택적 `load_max_docs`: 기본값=100. 다운로드할 문서 수를 제한하는 데 사용합니다. 100개의 모든 문서를 다운로드하는 데 시간이 걸리므로 실험을 위해 작은 수를 사용하세요. 현재 300의 하드 제한이 있습니다.
- 선택적 `load_all_available_meta`: 기본값=False. 기본적으로 가장 중요한 필드만 다운로드됩니다: `Published` (문서가 게시/최종 업데이트된 날짜), `Title`, `Authors`, `Summary`. True인 경우 다른 필드도 다운로드됩니다.
- `get_full_documents`: 불리언, 기본값 False. 문서의 전체 텍스트를 가져올지 여부를 결정합니다.

자세한 내용은 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.arxiv.ArxivRetriever.html)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "ArxivRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.arxiv.ArxivRetriever.html", "title": "ArxivRetriever"}]-->
from langchain_community.retrievers import ArxivRetriever

retriever = ArxivRetriever(
    load_max_docs=2,
    get_ful_documents=True,
)
```


## 사용법

`ArxivRetriever`는 기사 식별자를 통한 검색을 지원합니다:

```python
docs = retriever.invoke("1605.08386")
```


```python
docs[0].metadata  # meta-information of the Document
```


```output
{'Entry ID': 'http://arxiv.org/abs/1605.08386v1',
 'Published': datetime.date(2016, 5, 26),
 'Title': 'Heat-bath random walks with Markov bases',
 'Authors': 'Caprice Stanley, Tobias Windisch'}
```


```python
docs[0].page_content[:400]  # a content of the Document
```


```output
'Graphs on lattice points are studied whose edges come from a finite set of\nallowed moves of arbitrary length. We show that the diameter of these graphs on\nfibers of a fixed integer matrix can be bounded from above by a constant. We\nthen study the mixing behaviour of heat-bath random walks on these graphs. We\nalso state explicit conditions on the set of moves so that the heat-bath random\nwalk, a ge'
```


`ArxivRetriever`는 자연어 텍스트 기반 검색도 지원합니다:

```python
docs = retriever.invoke("What is the ImageBind model?")
```


```python
docs[0].metadata
```


```output
{'Entry ID': 'http://arxiv.org/abs/2305.05665v2',
 'Published': datetime.date(2023, 5, 31),
 'Title': 'ImageBind: One Embedding Space To Bind Them All',
 'Authors': 'Rohit Girdhar, Alaaeldin El-Nouby, Zhuang Liu, Mannat Singh, Kalyan Vasudev Alwala, Armand Joulin, Ishan Misra'}
```


## 체인 내에서 사용

다른 검색기와 마찬가지로 `ArxivRetriever`는 [체인](/docs/how_to/sequence/)을 통해 LLM 애플리케이션에 통합될 수 있습니다.

LLM 또는 채팅 모델이 필요합니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "ArxivRetriever"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "ArxivRetriever"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "ArxivRetriever"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

prompt = ChatPromptTemplate.from_template(
    """Answer the question based only on the context provided.

Context: {context}

Question: {question}"""
)


def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)


chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | prompt
    | llm
    | StrOutputParser()
)
```


```python
chain.invoke("What is the ImageBind model?")
```


```output
'The ImageBind model is an approach to learn a joint embedding across six different modalities - images, text, audio, depth, thermal, and IMU data. It shows that only image-paired data is sufficient to bind the modalities together and can leverage large scale vision-language models for zero-shot capabilities and emergent applications such as cross-modal retrieval, composing modalities with arithmetic, cross-modal detection and generation.'
```


## API 참조

모든 `ArxivRetriever` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.arxiv.ArxivRetriever.html)에서 확인할 수 있습니다.

## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)