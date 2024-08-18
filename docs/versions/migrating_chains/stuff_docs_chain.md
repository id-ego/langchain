---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/versions/migrating_chains/stuff_docs_chain.ipynb
description: 문서 결합을 위한 `StuffDocumentsChain`과 `create_stuff_documents_chain`의 기능과
  예제를 소개합니다. 질문 응답 및 요약에 효과적입니다.
title: Migrating from StuffDocumentsChain
---

[StuffDocumentsChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.StuffDocumentsChain.html)은 문서를 단일 컨텍스트 윈도우로 연결하여 결합합니다. 이는 질문 응답, 요약 및 기타 목적을 위한 문서 결합을 위한 간단하고 효과적인 전략입니다.

[create_stuff_documents_chain](https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html)은 권장되는 대안입니다. 이는 `StuffDocumentsChain`과 동일하게 작동하지만 스트리밍 및 배치 기능에 대한 지원이 더 좋습니다. [LCEL primitives](/docs/concepts/#langchain-expression-language-lcel)의 간단한 조합이기 때문에 다른 LangChain 애플리케이션에 통합하고 확장하기도 더 쉽습니다.

아래에서는 설명을 위해 간단한 예제를 통해 `StuffDocumentsChain`과 `create_stuff_documents_chain`을 살펴보겠습니다.

먼저 채팅 모델을 로드해 보겠습니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />


## 예제

문서 집합을 분석하는 예제를 살펴보겠습니다. 설명을 위해 간단한 문서를 먼저 생성합니다:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "# Example"}]-->
from langchain_core.documents import Document

documents = [
    Document(page_content="Apples are red", metadata={"title": "apple_book"}),
    Document(page_content="Blueberries are blue", metadata={"title": "blueberry_book"}),
    Document(page_content="Bananas are yelow", metadata={"title": "banana_book"}),
]
```


### 레거시

<details open>


아래에서는 `StuffDocumentsChain`을 사용한 구현을 보여줍니다. 요약 작업을 위한 프롬프트 템플릿을 정의하고 이 목적을 위해 [LLMChain](https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html) 객체를 인스턴스화합니다. 문서가 프롬프트에 어떻게 형식화되는지 정의하고 다양한 프롬프트에서 키의 일관성을 보장합니다.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "# Example"}, {"imported": "StuffDocumentsChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.StuffDocumentsChain.html", "title": "# Example"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Example"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "# Example"}]-->
from langchain.chains import LLMChain, StuffDocumentsChain
from langchain_core.prompts import ChatPromptTemplate, PromptTemplate

# This controls how each document will be formatted. Specifically,
# it will be passed to `format_document` - see that function for more
# details.
document_prompt = PromptTemplate(
    input_variables=["page_content"], template="{page_content}"
)
document_variable_name = "context"
# The prompt here should take as an input variable the
# `document_variable_name`
prompt = ChatPromptTemplate.from_template("Summarize this content: {context}")

llm_chain = LLMChain(llm=llm, prompt=prompt)
chain = StuffDocumentsChain(
    llm_chain=llm_chain,
    document_prompt=document_prompt,
    document_variable_name=document_variable_name,
)
```


이제 체인을 호출할 수 있습니다:

```python
result = chain.invoke(documents)
result["output_text"]
```


```output
'This content describes the colors of different fruits: apples are red, blueberries are blue, and bananas are yellow.'
```


```python
for chunk in chain.stream(documents):
    print(chunk)
```

```output
{'input_documents': [Document(metadata={'title': 'apple_book'}, page_content='Apples are red'), Document(metadata={'title': 'blueberry_book'}, page_content='Blueberries are blue'), Document(metadata={'title': 'banana_book'}, page_content='Bananas are yelow')], 'output_text': 'This content describes the colors of different fruits: apples are red, blueberries are blue, and bananas are yellow.'}
```

</details>


### LCEL

<details open>


아래에서는 `create_stuff_documents_chain`을 사용한 구현을 보여줍니다:

```python
<!--IMPORTS:[{"imported": "create_stuff_documents_chain", "source": "langchain.chains.combine_documents", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.combine_documents.stuff.create_stuff_documents_chain.html", "title": "# Example"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "# Example"}]-->
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_template("Summarize this content: {context}")
chain = create_stuff_documents_chain(llm, prompt)
```


체인을 호출하면 이전과 유사한 결과를 얻습니다:

```python
result = chain.invoke({"context": documents})
result
```


```output
'This content describes the colors of different fruits: apples are red, blueberries are blue, and bananas are yellow.'
```


이 구현은 출력 토큰의 스트리밍을 지원합니다:

```python
for chunk in chain.stream({"context": documents}):
    print(chunk, end=" | ")
```

```output
 | This |  content |  describes |  the |  colors |  of |  different |  fruits | : |  apples |  are |  red | , |  blue | berries |  are |  blue | , |  and |  bananas |  are |  yellow | . |  |
```

</details>


## 다음 단계

더 많은 배경 정보를 원하시면 [LCEL 개념 문서](/docs/concepts/#langchain-expression-language-lcel)를 확인하세요.

RAG와 함께하는 질문 응답 작업에 대한 더 많은 정보를 원하시면 [이 사용 방법 가이드](/docs/how_to/#qa-with-rag)를 참조하세요.

LLM 기반 요약 전략에 대한 더 많은 정보를 원하시면 [이 튜토리얼](/docs/tutorials/summarization/)을 확인하세요.