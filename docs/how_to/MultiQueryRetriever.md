---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/MultiQueryRetriever.ipynb
description: MultiQueryRetriever는 LLM을 사용하여 사용자 쿼리에서 다양한 관점을 생성하고, 관련 문서의 집합을 검색하여
  결과를 개선합니다.
---

# 멀티쿼리 검색기 사용 방법

거리 기반 벡터 데이터베이스 검색은 쿼리를 고차원 공간에 임베드(표현)하고 거리 메트릭을 기반으로 유사한 임베드 문서를 찾습니다. 그러나 검색은 쿼리 문구의 미세한 변화나 임베딩이 데이터의 의미를 잘 포착하지 못할 경우 다른 결과를 생성할 수 있습니다. 이러한 문제를 수동으로 해결하기 위해 프롬프트 엔지니어링/튜닝이 가끔 수행되지만, 이는 번거로울 수 있습니다.

[MultiQueryRetriever](https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_query.MultiQueryRetriever.html)는 주어진 사용자 입력 쿼리에 대해 다양한 관점에서 여러 쿼리를 생성하기 위해 LLM을 사용하여 프롬프트 튜닝 프로세스를 자동화합니다. 각 쿼리에 대해 관련 문서 집합을 검색하고 모든 쿼리에서 고유한 합집합을 취하여 잠재적으로 관련 있는 문서의 더 큰 집합을 얻습니다. 동일한 질문에 대한 여러 관점을 생성함으로써 `MultiQueryRetriever`는 거리 기반 검색의 일부 한계를 완화하고 더 풍부한 결과 집합을 얻을 수 있습니다.

[Lilian Weng의 블로그 포스트](https://lilianweng.github.io/posts/2023-06-23-agent/)를 사용하여 벡터 저장소를 구축해 봅시다. 이 블로그 포스트는 [RAG 튜토리얼](/docs/tutorials/rag)에서 가져온 것입니다:

```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to use the MultiQueryRetriever"}, {"imported": "WebBaseLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.web_base.WebBaseLoader.html", "title": "How to use the MultiQueryRetriever"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to use the MultiQueryRetriever"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to use the MultiQueryRetriever"}]-->
# Build a sample vectorDB
from langchain_chroma import Chroma
from langchain_community.document_loaders import WebBaseLoader
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Load blog post
loader = WebBaseLoader("https://lilianweng.github.io/posts/2023-06-23-agent/")
data = loader.load()

# Split
text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0)
splits = text_splitter.split_documents(data)

# VectorDB
embedding = OpenAIEmbeddings()
vectordb = Chroma.from_documents(documents=splits, embedding=embedding)
```


#### 간단한 사용법

쿼리 생성을 위해 사용할 LLM을 지정하면, 검색기가 나머지를 처리합니다.

```python
<!--IMPORTS:[{"imported": "MultiQueryRetriever", "source": "langchain.retrievers.multi_query", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.multi_query.MultiQueryRetriever.html", "title": "How to use the MultiQueryRetriever"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to use the MultiQueryRetriever"}]-->
from langchain.retrievers.multi_query import MultiQueryRetriever
from langchain_openai import ChatOpenAI

question = "What are the approaches to Task Decomposition?"
llm = ChatOpenAI(temperature=0)
retriever_from_llm = MultiQueryRetriever.from_llm(
    retriever=vectordb.as_retriever(), llm=llm
)
```


```python
# Set logging for the queries
import logging

logging.basicConfig()
logging.getLogger("langchain.retrievers.multi_query").setLevel(logging.INFO)
```


```python
unique_docs = retriever_from_llm.invoke(question)
len(unique_docs)
```

```output
INFO:langchain.retrievers.multi_query:Generated queries: ['1. How can Task Decomposition be achieved through different methods?', '2. What strategies are commonly used for Task Decomposition?', '3. What are the various techniques for breaking down tasks in Task Decomposition?']
```


```output
5
```


검색기가 생성한 기본 쿼리는 `INFO` 수준에서 기록됩니다.

#### 사용자 정의 프롬프트 제공

내부적으로 `MultiQueryRetriever`는 특정 [프롬프트](https://api.python.langchain.com/en/latest/_modules/langchain/retrievers/multi_query.html#MultiQueryRetriever)를 사용하여 쿼리를 생성합니다. 이 프롬프트를 사용자 정의하려면:

1. 질문에 대한 입력 변수를 가진 [PromptTemplate](https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html)를 만듭니다;
2. 아래와 같은 [출력 파서](/docs/concepts#output-parsers)를 구현하여 결과를 쿼리 목록으로 분할합니다.

프롬프트와 출력 파서는 함께 쿼리 목록 생성을 지원해야 합니다.

```python
<!--IMPORTS:[{"imported": "BaseOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.base.BaseOutputParser.html", "title": "How to use the MultiQueryRetriever"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "How to use the MultiQueryRetriever"}]-->
from typing import List

from langchain_core.output_parsers import BaseOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.pydantic_v1 import BaseModel, Field


# Output parser will split the LLM result into a list of queries
class LineListOutputParser(BaseOutputParser[List[str]]):
    """Output parser for a list of lines."""

    def parse(self, text: str) -> List[str]:
        lines = text.strip().split("\n")
        return list(filter(None, lines))  # Remove empty lines


output_parser = LineListOutputParser()

QUERY_PROMPT = PromptTemplate(
    input_variables=["question"],
    template="""You are an AI language model assistant. Your task is to generate five 
    different versions of the given user question to retrieve relevant documents from a vector 
    database. By generating multiple perspectives on the user question, your goal is to help
    the user overcome some of the limitations of the distance-based similarity search. 
    Provide these alternative questions separated by newlines.
    Original question: {question}""",
)
llm = ChatOpenAI(temperature=0)

# Chain
llm_chain = QUERY_PROMPT | llm | output_parser

# Other inputs
question = "What are the approaches to Task Decomposition?"
```


```python
# Run
retriever = MultiQueryRetriever(
    retriever=vectordb.as_retriever(), llm_chain=llm_chain, parser_key="lines"
)  # "lines" is the key (attribute name) of the parsed output

# Results
unique_docs = retriever.invoke("What does the course say about regression?")
len(unique_docs)
```

```output
INFO:langchain.retrievers.multi_query:Generated queries: ['1. Can you provide insights on regression from the course material?', '2. How is regression discussed in the course content?', '3. What information does the course offer about regression?', '4. In what way is regression covered in the course?', '5. What are the teachings of the course regarding regression?']
```


```output
9
```