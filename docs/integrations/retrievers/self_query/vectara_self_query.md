---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/self_query/vectara_self_query.ipynb
description: Vectara는 데이터에 기반한 AI 어시스턴트를 빠르게 생성할 수 있는 신뢰할 수 있는 생성 AI 플랫폼입니다.
---

# 벡타라 자기 쿼리

[벡타라](https://vectara.com/)는 조직이 보유한 데이터, 문서 및 지식에 기반한 ChatGPT와 유사한 경험(인공지능 비서)을 신속하게 생성할 수 있도록 하는 신뢰할 수 있는 생성 AI 플랫폼을 제공합니다(기술적으로는 Retrieval-Augmented-Generation-as-a-service입니다).

벡타라 서버리스 RAG-as-a-service는 사용하기 쉬운 API 뒤에 RAG의 모든 구성 요소를 제공합니다. 여기에는 다음이 포함됩니다:
1. 파일(PDF, PPT, DOCX 등)에서 텍스트를 추출하는 방법
2. 최첨단 성능을 제공하는 ML 기반 청크화
3. [부메랑](https://vectara.com/how-boomerang-takes-retrieval-augmented-generation-to-the-next-level-via-grounded-generation/) 임베딩 모델
4. 텍스트 청크와 임베딩 벡터가 저장되는 자체 내부 벡터 데이터베이스
5. 쿼리를 자동으로 임베딩으로 인코딩하고 가장 관련성 높은 텍스트 세그먼트를 검색하는 쿼리 서비스(여기에는 [하이브리드 검색](https://docs.vectara.com/docs/api-reference/search-apis/lexical-matching) 및 [MMR](https://vectara.com/get-diverse-results-and-comprehensive-summaries-with-vectaras-mmr-reranker/) 지원 포함)
6. 검색된 문서(컨텍스트)를 기반으로 인용을 포함한 [생성 요약](https://docs.vectara.com/docs/learn/grounded-generation/grounded-generation-overview)을 생성하는 LLM

API 사용 방법에 대한 자세한 내용은 [벡타라 API 문서](https://docs.vectara.com/docs/)를 참조하십시오.

이 노트북은 Vectara와 함께 `SelfQueryRetriever`를 사용하는 방법을 보여줍니다.

# 시작하기

시작하려면 다음 단계를 따르십시오:
1. 아직 계정이 없다면 [가입](https://www.vectara.com/integrations/langchain)하여 무료 Vectara 계정을 만드세요. 가입을 완료하면 Vectara 고객 ID가 생성됩니다. Vectara 콘솔 창의 오른쪽 상단에서 이름을 클릭하여 고객 ID를 찾을 수 있습니다.
2. 계정 내에서 하나 이상의 코퍼스를 생성할 수 있습니다. 각 코퍼스는 입력 문서에서 수집된 텍스트 데이터를 저장하는 영역을 나타냅니다. 코퍼스를 생성하려면 **"Create Corpus"** 버튼을 사용하십시오. 그런 다음 코퍼스에 이름과 설명을 제공합니다. 선택적으로 필터링 속성을 정의하고 일부 고급 옵션을 적용할 수 있습니다. 생성한 코퍼스를 클릭하면 상단에 이름과 코퍼스 ID가 표시됩니다.
3. 다음으로 코퍼스에 접근하기 위한 API 키를 생성해야 합니다. 코퍼스 보기에서 **"Access Control"** 탭을 클릭한 다음 **"Create API Key"** 버튼을 클릭하십시오. 키에 이름을 지정하고, 쿼리 전용 또는 쿼리+인덱스를 선택하십시오. "Create"를 클릭하면 이제 활성 API 키가 생성됩니다. 이 키는 비밀로 유지하십시오.

LangChain을 Vectara와 함께 사용하려면 다음 세 가지 값: `customer ID`, `corpus ID` 및 `api_key`가 필요합니다.
이 값들을 LangChain에 제공하는 방법은 두 가지입니다:

1. 환경에 다음 세 가지 변수를 포함합니다: `VECTARA_CUSTOMER_ID`, `VECTARA_CORPUS_ID` 및 `VECTARA_API_KEY`.
   
   예를 들어, os.environ 및 getpass를 사용하여 다음과 같이 변수를 설정할 수 있습니다:

```python
import os
import getpass

os.environ["VECTARA_CUSTOMER_ID"] = getpass.getpass("Vectara Customer ID:")
os.environ["VECTARA_CORPUS_ID"] = getpass.getpass("Vectara Corpus ID:")
os.environ["VECTARA_API_KEY"] = getpass.getpass("Vectara API Key:")
```


2. `Vectara` 벡터스토어 생성자에 추가합니다:

```python
vectara = Vectara(
                vectara_customer_id=vectara_customer_id,
                vectara_corpus_id=vectara_corpus_id,
                vectara_api_key=vectara_api_key
            )
```

이 노트북에서는 환경에서 제공된 것으로 가정합니다.

**노트:** 자기 쿼리 검색기를 사용하려면 `lark`가 설치되어 있어야 합니다(`pip install lark`).

## LangChain에서 Vectara에 연결하기

이 예제에서는 계정을 만들고 코퍼스를 생성했으며, `VECTARA_CUSTOMER_ID`, `VECTARA_CORPUS_ID` 및 `VECTARA_API_KEY`(인덱싱 및 쿼리 권한이 있는 키)를 환경 변수로 추가했다고 가정합니다.

또한 코퍼스에는 필터링 가능한 메타데이터 속성으로 정의된 4개의 필드가 있다고 가정합니다: `year`, `director`, `rating`, `genre`

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Vectara self-querying "}, {"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "Vectara self-querying "}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "Vectara self-querying "}, {"imported": "Vectara", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.vectara.Vectara.html", "title": "Vectara self-querying "}, {"imported": "ChatOpenAI", "source": "langchain_openai.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Vectara self-querying "}]-->
import os

from langchain_core.documents import Document

os.environ["VECTARA_API_KEY"] = "<YOUR_VECTARA_API_KEY>"
os.environ["VECTARA_CORPUS_ID"] = "<YOUR_VECTARA_CORPUS_ID>"
os.environ["VECTARA_CUSTOMER_ID"] = "<YOUR_VECTARA_CUSTOMER_ID>"

from langchain.chains.query_constructor.base import AttributeInfo
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain_community.vectorstores import Vectara
from langchain_openai.chat_models import ChatOpenAI
```


## 데이터셋

먼저 영화의 예제 데이터셋을 정의하고 메타데이터와 함께 코퍼스에 업로드합니다:

```python
docs = [
    Document(
        page_content="A bunch of scientists bring back dinosaurs and mayhem breaks loose",
        metadata={"year": 1993, "rating": 7.7, "genre": "science fiction"},
    ),
    Document(
        page_content="Leo DiCaprio gets lost in a dream within a dream within a dream within a ...",
        metadata={"year": 2010, "director": "Christopher Nolan", "rating": 8.2},
    ),
    Document(
        page_content="A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea",
        metadata={"year": 2006, "director": "Satoshi Kon", "rating": 8.6},
    ),
    Document(
        page_content="A bunch of normal-sized women are supremely wholesome and some men pine after them",
        metadata={"year": 2019, "director": "Greta Gerwig", "rating": 8.3},
    ),
    Document(
        page_content="Toys come alive and have a blast doing so",
        metadata={"year": 1995, "genre": "animated"},
    ),
    Document(
        page_content="Three men walk into the Zone, three men walk out of the Zone",
        metadata={
            "year": 1979,
            "rating": 9.9,
            "director": "Andrei Tarkovsky",
            "genre": "science fiction",
        },
    ),
]

vectara = Vectara()
for doc in docs:
    vectara.add_texts([doc.page_content], doc_metadata=doc.metadata)
```


## 자기 쿼리 검색기 생성
이제 검색기를 인스턴스화할 수 있습니다. 이를 위해 문서가 지원하는 메타데이터 필드에 대한 정보를 미리 제공하고 문서 내용에 대한 간단한 설명을 제공합니다.

그런 다음 llm(이 경우 OpenAI)과 `vectara` 벡터스토어를 인수로 제공합니다:

```python
metadata_field_info = [
    AttributeInfo(
        name="genre",
        description="The genre of the movie",
        type="string or list[string]",
    ),
    AttributeInfo(
        name="year",
        description="The year the movie was released",
        type="integer",
    ),
    AttributeInfo(
        name="director",
        description="The name of the movie director",
        type="string",
    ),
    AttributeInfo(
        name="rating", description="A 1-10 rating for the movie", type="float"
    ),
]
document_content_description = "Brief summary of a movie"
llm = ChatOpenAI(temperature=0, model="gpt-4o", max_tokens=4069)
retriever = SelfQueryRetriever.from_llm(
    llm, vectara, document_content_description, metadata_field_info, verbose=True
)
```


## 자기 검색 쿼리
이제 실제로 검색기를 사용해 볼 수 있습니다!

```python
# This example only specifies a relevant query
retriever.invoke("What are movies about scientists")
```


```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'lang': 'eng', 'offset': '0', 'len': '66', 'year': '1993', 'rating': '7.7', 'genre': 'science fiction', 'source': 'langchain'}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'lang': 'eng', 'offset': '0', 'len': '116', 'year': '2006', 'director': 'Satoshi Kon', 'rating': '8.6', 'source': 'langchain'}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'lang': 'eng', 'offset': '0', 'len': '41', 'year': '1995', 'genre': 'animated', 'source': 'langchain'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'lang': 'eng', 'offset': '0', 'len': '60', 'year': '1979', 'rating': '9.9', 'director': 'Andrei Tarkovsky', 'genre': 'science fiction', 'source': 'langchain'}),
 Document(page_content='A bunch of normal-sized women are supremely wholesome and some men pine after them', metadata={'lang': 'eng', 'offset': '0', 'len': '82', 'year': '2019', 'director': 'Greta Gerwig', 'rating': '8.3', 'source': 'langchain'}),
 Document(page_content='Leo DiCaprio gets lost in a dream within a dream within a dream within a ...', metadata={'lang': 'eng', 'offset': '0', 'len': '76', 'year': '2010', 'director': 'Christopher Nolan', 'rating': '8.2', 'source': 'langchain'})]
```


```python
# This example only specifies a filter
retriever.invoke("I want to watch a movie rated higher than 8.5")
```


```output
[Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'lang': 'eng', 'offset': '0', 'len': '116', 'year': '2006', 'director': 'Satoshi Kon', 'rating': '8.6', 'source': 'langchain'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'lang': 'eng', 'offset': '0', 'len': '60', 'year': '1979', 'rating': '9.9', 'director': 'Andrei Tarkovsky', 'genre': 'science fiction', 'source': 'langchain'})]
```


```python
# This example specifies a query and a filter
retriever.invoke("Has Greta Gerwig directed any movies about women")
```


```output
[Document(page_content='A bunch of normal-sized women are supremely wholesome and some men pine after them', metadata={'lang': 'eng', 'offset': '0', 'len': '82', 'year': '2019', 'director': 'Greta Gerwig', 'rating': '8.3', 'source': 'langchain'})]
```


```python
# This example specifies a composite filter
retriever.invoke("What's a highly rated (above 8.5) science fiction film?")
```


```output
[Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'lang': 'eng', 'offset': '0', 'len': '116', 'year': '2006', 'director': 'Satoshi Kon', 'rating': '8.6', 'source': 'langchain'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'lang': 'eng', 'offset': '0', 'len': '60', 'year': '1979', 'rating': '9.9', 'director': 'Andrei Tarkovsky', 'genre': 'science fiction', 'source': 'langchain'})]
```


```python
# This example specifies a query and composite filter
retriever.invoke(
    "What's a movie after 1990 but before 2005 that's all about toys, and preferably is animated"
)
```


```output
[Document(page_content='Toys come alive and have a blast doing so', metadata={'lang': 'eng', 'offset': '0', 'len': '41', 'year': '1995', 'genre': 'animated', 'source': 'langchain'}),
 Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'lang': 'eng', 'offset': '0', 'len': '66', 'year': '1993', 'rating': '7.7', 'genre': 'science fiction', 'source': 'langchain'})]
```


## 필터 k

자기 쿼리 검색기를 사용하여 `k`: 가져올 문서 수를 지정할 수도 있습니다.

생성자에 `enable_limit=True`를 전달하여 이를 수행할 수 있습니다.

```python
retriever = SelfQueryRetriever.from_llm(
    llm,
    vectara,
    document_content_description,
    metadata_field_info,
    enable_limit=True,
    verbose=True,
)
```


이것은 멋집니다. 쿼리에서 보고 싶은 결과 수를 포함할 수 있으며, 자기 검색기는 이를 올바르게 이해할 것입니다. 예를 들어, 다음을 찾아보겠습니다:

```python
# This example only specifies a relevant query
retriever.invoke("what are two movies with a rating above 8.5")
```


```output
[Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'lang': 'eng', 'offset': '0', 'len': '116', 'year': '2006', 'director': 'Satoshi Kon', 'rating': '8.6', 'source': 'langchain'}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'lang': 'eng', 'offset': '0', 'len': '60', 'year': '1979', 'rating': '9.9', 'director': 'Andrei Tarkovsky', 'genre': 'science fiction', 'source': 'langchain'})]
```