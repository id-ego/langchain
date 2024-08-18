---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/wikipedia.ipynb
description: 위키백과에서 문서를 검색하여 Langchain의 Document 형식으로 변환하는 방법을 보여주는 노트북입니다.
sidebar_label: Wikipedia
---

# WikipediaRetriever

## 개요
> [Wikipedia](https://wikipedia.org/)는 자원봉사자 커뮤니티인 위키피디언(Wikipedians)에 의해 작성되고 유지되는 다국어 무료 온라인 백과사전으로, 오픈 협업 및 MediaWiki라는 위키 기반 편집 시스템을 사용합니다. `Wikipedia`는 역사상 가장 크고 가장 많이 읽힌 참고 자료입니다.

이 노트북은 `wikipedia.org`에서 [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 형식으로 위키 페이지를 검색하는 방법을 보여줍니다.

### 통합 세부정보

import {ItemTable} from "@theme/FeatureTables";

<ItemTable category="external_retrievers" item="WikipediaRetriever" />


## 설정
개별 도구의 실행에서 자동 추적을 원하시면 아래의 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

통합은 `langchain-community` 패키지에 있습니다. 우리는 또한 `wikipedia` 파이썬 패키지를 설치해야 합니다.

```python
%pip install -qU langchain_community wikipedia
```


## 인스턴스화

이제 우리의 검색기를 인스턴스화할 수 있습니다:

`WikipediaRetriever` 매개변수는 다음을 포함합니다:
- 선택적 `lang`: 기본값="en". 특정 언어 부분의 위키피디아를 검색하는 데 사용합니다.
- 선택적 `load_max_docs`: 기본값=100. 다운로드할 문서 수를 제한하는 데 사용합니다. 100개의 모든 문서를 다운로드하는 데 시간이 걸리므로 실험을 위해 작은 수를 사용하세요. 현재 하드 제한은 300입니다.
- 선택적 `load_all_available_meta`: 기본값=False. 기본적으로 다운로드되는 가장 중요한 필드만 포함됩니다: `Published` (문서가 게시/최종 업데이트된 날짜), `title`, `Summary`. True로 설정하면 다른 필드도 다운로드됩니다.

`get_relevant_documents()`는 하나의 인수 `query`를 가지며, 이는 위키피디아에서 문서를 찾는 데 사용되는 자유 텍스트입니다.

```python
<!--IMPORTS:[{"imported": "WikipediaRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.wikipedia.WikipediaRetriever.html", "title": "WikipediaRetriever"}]-->
from langchain_community.retrievers import WikipediaRetriever

retriever = WikipediaRetriever()
```


## 사용법

```python
docs = retriever.invoke("TOKYO GHOUL")
```


```python
print(docs[0].page_content[:400])
```

```output
Tokyo Ghoul (Japanese: 東京喰種（トーキョーグール）, Hepburn: Tōkyō Gūru) is a Japanese dark fantasy manga series written and illustrated by Sui Ishida. It was serialized in Shueisha's seinen manga magazine Weekly Young Jump from September 2011 to September 2014, with its chapters collected in 14 tankōbon volumes. The story is set in an alternate version of Tokyo where humans coexist with ghouls, beings who loo
```

## 체인 내에서 사용
다른 검색기와 마찬가지로 `WikipediaRetriever`는 [체인](/docs/how_to/sequence/)을 통해 LLM 애플리케이션에 통합될 수 있습니다.

우리는 LLM 또는 채팅 모델이 필요합니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />


```python
<!--IMPORTS:[{"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "WikipediaRetriever"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "WikipediaRetriever"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "WikipediaRetriever"}]-->
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

prompt = ChatPromptTemplate.from_template(
    """
    Answer the question based only on the context provided.
    Context: {context}
    Question: {question}
    """
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
chain.invoke(
    "Who is the main character in `Tokyo Ghoul` and does he transform into a ghoul?"
)
```


```output
'The main character in Tokyo Ghoul is Ken Kaneki, who transforms into a ghoul after receiving an organ transplant from a ghoul named Rize.'
```


## API 참조

모든 `WikipediaRetriever` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.wikipedia.WikipediaRetriever.html#langchain-community-retrievers-wikipedia-wikipediaretriever)에서 확인할 수 있습니다.

## 관련

- 검색기 [개념 가이드](/docs/concepts/#retrievers)
- 검색기 [사용 방법 가이드](/docs/how_to/#retrievers)