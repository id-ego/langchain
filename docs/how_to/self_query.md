---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/self_query.ipynb
description: 자기 쿼리 검색기는 자연어 쿼리를 구조화된 쿼리로 변환하여 벡터 저장소에 적용하는 기능을 제공합니다.
---

# "자기 쿼리" 검색 방법

:::info

자기 쿼리를 지원하는 벡터 저장소에 대한 문서는 [통합](/docs/integrations/retrievers/self_query)에서 확인하세요.

:::

자기 쿼리 검색기는 이름에서 알 수 있듯이 스스로 쿼리할 수 있는 능력을 가진 검색기입니다. 구체적으로, 자연어 쿼리를 주면 검색기는 쿼리 구성 LLM 체인을 사용하여 구조화된 쿼리를 작성하고, 그 구조화된 쿼리를 기본 벡터 저장소에 적용합니다. 이를 통해 검색기는 사용자 입력 쿼리를 저장된 문서의 내용과 의미적 유사성 비교에 사용할 뿐만 아니라, 저장된 문서의 메타데이터에 대한 사용자 쿼리에서 필터를 추출하고 그 필터를 실행할 수 있습니다.

![](../../static/img/self_querying.jpg)

## 시작하기
시연을 위해 `Chroma` 벡터 저장소를 사용할 것입니다. 영화 요약이 포함된 작은 데모 문서 세트를 만들었습니다.

**참고:** 자기 쿼리 검색기를 사용하려면 `lark` 패키지가 설치되어 있어야 합니다.

```python
%pip install --upgrade --quiet  lark langchain-chroma
```


```python
<!--IMPORTS:[{"imported": "Chroma", "source": "langchain_chroma", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_chroma.vectorstores.Chroma.html", "title": "How to do \"self-querying\" retrieval"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to do \"self-querying\" retrieval"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to do \"self-querying\" retrieval"}]-->
from langchain_chroma import Chroma
from langchain_core.documents import Document
from langchain_openai import OpenAIEmbeddings

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
            "director": "Andrei Tarkovsky",
            "genre": "thriller",
            "rating": 9.9,
        },
    ),
]
vectorstore = Chroma.from_documents(docs, OpenAIEmbeddings())
```


### 자기 쿼리 검색기 만들기

이제 검색기를 인스턴스화할 수 있습니다. 이를 위해 문서가 지원하는 메타데이터 필드에 대한 정보를 미리 제공하고 문서 내용에 대한 간단한 설명이 필요합니다.

```python
<!--IMPORTS:[{"imported": "AttributeInfo", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.schema.AttributeInfo.html", "title": "How to do \"self-querying\" retrieval"}, {"imported": "SelfQueryRetriever", "source": "langchain.retrievers.self_query.base", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.self_query.base.SelfQueryRetriever.html", "title": "How to do \"self-querying\" retrieval"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to do \"self-querying\" retrieval"}]-->
from langchain.chains.query_constructor.base import AttributeInfo
from langchain.retrievers.self_query.base import SelfQueryRetriever
from langchain_openai import ChatOpenAI

metadata_field_info = [
    AttributeInfo(
        name="genre",
        description="The genre of the movie. One of ['science fiction', 'comedy', 'drama', 'thriller', 'romance', 'action', 'animated']",
        type="string",
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
llm = ChatOpenAI(temperature=0)
retriever = SelfQueryRetriever.from_llm(
    llm,
    vectorstore,
    document_content_description,
    metadata_field_info,
)
```


### 테스트해보기

이제 실제로 검색기를 사용해 볼 수 있습니다!

```python
# This example only specifies a filter
retriever.invoke("I want to watch a movie rated higher than 8.5")
```


```output
[Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'director': 'Andrei Tarkovsky', 'genre': 'thriller', 'rating': 9.9, 'year': 1979}),
 Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'director': 'Satoshi Kon', 'rating': 8.6, 'year': 2006})]
```


```python
# This example specifies a query and a filter
retriever.invoke("Has Greta Gerwig directed any movies about women")
```


```output
[Document(page_content='A bunch of normal-sized women are supremely wholesome and some men pine after them', metadata={'director': 'Greta Gerwig', 'rating': 8.3, 'year': 2019})]
```


```python
# This example specifies a composite filter
retriever.invoke("What's a highly rated (above 8.5) science fiction film?")
```


```output
[Document(page_content='A psychologist / detective gets lost in a series of dreams within dreams within dreams and Inception reused the idea', metadata={'director': 'Satoshi Kon', 'rating': 8.6, 'year': 2006}),
 Document(page_content='Three men walk into the Zone, three men walk out of the Zone', metadata={'director': 'Andrei Tarkovsky', 'genre': 'thriller', 'rating': 9.9, 'year': 1979})]
```


```python
# This example specifies a query and composite filter
retriever.invoke(
    "What's a movie after 1990 but before 2005 that's all about toys, and preferably is animated"
)
```


```output
[Document(page_content='Toys come alive and have a blast doing so', metadata={'genre': 'animated', 'year': 1995})]
```


### k 필터

자기 쿼리 검색기를 사용하여 `k`: 가져올 문서 수를 지정할 수도 있습니다.

이를 위해 생성자에 `enable_limit=True`를 전달하면 됩니다.

```python
retriever = SelfQueryRetriever.from_llm(
    llm,
    vectorstore,
    document_content_description,
    metadata_field_info,
    enable_limit=True,
)

# This example only specifies a relevant query
retriever.invoke("What are two movies about dinosaurs")
```


```output
[Document(page_content='A bunch of scientists bring back dinosaurs and mayhem breaks loose', metadata={'genre': 'science fiction', 'rating': 7.7, 'year': 1993}),
 Document(page_content='Toys come alive and have a blast doing so', metadata={'genre': 'animated', 'year': 1995})]
```


## LCEL로 처음부터 구성하기

무엇이 내부에서 일어나고 있는지 확인하고 더 많은 사용자 정의 제어를 위해 검색기를 처음부터 재구성할 수 있습니다.

먼저, 쿼리 구성 체인을 만들어야 합니다. 이 체인은 사용자 쿼리를 받아 사용자에 의해 지정된 필터를 캡처하는 `StructuredQuery` 객체를 생성합니다. 프롬프트 및 출력 파서를 생성하기 위한 몇 가지 도우미 함수를 제공합니다. 이들은 단순성을 위해 여기서는 무시할 수 있는 조정 가능한 매개변수를 가지고 있습니다.

```python
<!--IMPORTS:[{"imported": "StructuredQueryOutputParser", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.base.StructuredQueryOutputParser.html", "title": "How to do \"self-querying\" retrieval"}, {"imported": "get_query_constructor_prompt", "source": "langchain.chains.query_constructor.base", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.query_constructor.base.get_query_constructor_prompt.html", "title": "How to do \"self-querying\" retrieval"}]-->
from langchain.chains.query_constructor.base import (
    StructuredQueryOutputParser,
    get_query_constructor_prompt,
)

prompt = get_query_constructor_prompt(
    document_content_description,
    metadata_field_info,
)
output_parser = StructuredQueryOutputParser.from_components()
query_constructor = prompt | llm | output_parser
```


프롬프트를 살펴보겠습니다:

```python
print(prompt.format(query="dummy question"))
```

```output
Your goal is to structure the user's query to match the request schema provided below.

<< Structured Request Schema >>
When responding use a markdown code snippet with a JSON object formatted in the following schema:

```json
{
    "query": string \ text string to compare to document contents
    "filter": string \ logical condition statement for filtering documents
}
```


쿼리 문자열은 문서의 내용과 일치할 것으로 예상되는 텍스트만 포함해야 합니다. 필터의 조건은 쿼리에서 언급되지 않아야 합니다.

논리 조건 문장은 하나 이상의 비교 및 논리 연산 문장으로 구성됩니다.

비교 문장은 다음 형식을 취합니다: `comp(attr, val)`:
- `comp` (eq | ne | gt | gte | lt | lte | contain | like | in | nin): 비교자
- `attr` (string): 비교를 적용할 속성의 이름
- `val` (string): 비교 값

논리 연산 문장은 `op(statement1, statement2, ...)` 형식을 취합니다:
- `op` (and | or | not): 논리 연산자
- `statement1`, `statement2`, ... (비교 문장 또는 논리 연산 문장): 연산을 적용할 하나 이상의 문장

위에 나열된 비교자와 논리 연산자만 사용해야 하며 다른 것은 사용하지 마십시오.
필터는 데이터 소스에 존재하는 속성만 참조해야 합니다.
필터는 적용된 함수가 있는 경우 속성 이름과 함수 이름만 사용해야 합니다.
필터는 날짜 데이터 형식 값을 처리할 때 `YYYY-MM-DD` 형식만 사용해야 합니다.
필터는 속성 설명을 고려하고 저장된 데이터 유형에 따라 실행 가능한 비교만 수행해야 합니다.
필터는 필요한 경우에만 사용해야 합니다. 적용할 필터가 없으면 필터 값으로 "NO_FILTER"를 반환해야 합니다.

<< 예시 1. >>
데이터 소스:
```json
{
    "content": "Lyrics of a song",
    "attributes": {
        "artist": {
            "type": "string",
            "description": "Name of the song artist"
        },
        "length": {
            "type": "integer",
            "description": "Length of the song in seconds"
        },
        "genre": {
            "type": "string",
            "description": "The song genre, one of "pop", "rock" or "rap""
        }
    }
}
```


사용자 쿼리:
3분 이하의 댄스 팝 장르에서 테일러 스위프트 또는 케이티 페리의 청소년 로맨스에 관한 노래는 무엇인가요?

구조화된 요청:
```json
{
    "query": "teenager love",
    "filter": "and(or(eq(\"artist\", \"Taylor Swift\"), eq(\"artist\", \"Katy Perry\")), lt(\"length\", 180), eq(\"genre\", \"pop\"))"
}
```


<< 예시 2. >>
데이터 소스:
```json
{
    "content": "Lyrics of a song",
    "attributes": {
        "artist": {
            "type": "string",
            "description": "Name of the song artist"
        },
        "length": {
            "type": "integer",
            "description": "Length of the song in seconds"
        },
        "genre": {
            "type": "string",
            "description": "The song genre, one of "pop", "rock" or "rap""
        }
    }
}
```


사용자 쿼리:
스포티파이에 게시되지 않은 노래는 무엇인가요?

구조화된 요청:
```json
{
    "query": "",
    "filter": "NO_FILTER"
}
```


<< 예시 3. >>
데이터 소스:
```json
{
    "content": "Brief summary of a movie",
    "attributes": {
    "genre": {
        "description": "The genre of the movie. One of ['science fiction', 'comedy', 'drama', 'thriller', 'romance', 'action', 'animated']",
        "type": "string"
    },
    "year": {
        "description": "The year the movie was released",
        "type": "integer"
    },
    "director": {
        "description": "The name of the movie director",
        "type": "string"
    },
    "rating": {
        "description": "A 1-10 rating for the movie",
        "type": "float"
    }
}
}
```


사용자 쿼리:
더미 질문

구조화된 요청:
```
And what our full chain produces:


```python
query_constructor.invoke(
    {
        "query": "What are some sci-fi movies from the 90's directed by Luc Besson about taxi drivers"
    }
)
```


```output
StructuredQuery(query='taxi driver', filter=Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='genre', value='science fiction'), Operation(operator=<Operator.AND: 'and'>, arguments=[Comparison(comparator=<Comparator.GTE: 'gte'>, attribute='year', value=1990), Comparison(comparator=<Comparator.LT: 'lt'>, attribute='year', value=2000)]), Comparison(comparator=<Comparator.EQ: 'eq'>, attribute='director', value='Luc Besson')]), limit=None)
```


쿼리 생성기는 자기 쿼리 검색기의 핵심 요소입니다. 훌륭한 검색 시스템을 만들기 위해서는 쿼리 생성기가 잘 작동하는지 확인해야 합니다. 종종 이를 위해 프롬프트, 프롬프트 내의 예제, 속성 설명 등을 조정해야 합니다. 호텔 인벤토리 데이터에서 쿼리 생성기를 개선하는 과정을 설명하는 예제를 보려면 [이 요리책](https://github.com/langchain-ai/langchain/blob/master/cookbook/self_query_hotel_search.ipynb)을 확인하세요.

다음 핵심 요소는 구조화된 쿼리 변환기입니다. 이는 일반 `StructuredQuery` 객체를 사용 중인 벡터 저장소의 구문으로 메타데이터 필터로 변환하는 책임이 있는 객체입니다. LangChain은 여러 개의 내장 변환기를 제공합니다. 모든 변환기를 보려면 [통합 섹션](/docs/integrations/retrievers/self_query)으로 이동하세요.

```python
<!--IMPORTS:[{"imported": "ChromaTranslator", "source": "langchain_community.query_constructors.chroma", "docs": "https://api.python.langchain.com/en/latest/query_constructors/langchain_community.query_constructors.chroma.ChromaTranslator.html", "title": "How to do \"self-querying\" retrieval"}]-->
from langchain_community.query_constructors.chroma import ChromaTranslator

retriever = SelfQueryRetriever(
    query_constructor=query_constructor,
    vectorstore=vectorstore,
    structured_query_translator=ChromaTranslator(),
)
```


```python
retriever.invoke(
    "What's a movie after 1990 but before 2005 that's all about toys, and preferably is animated"
)
```


```output
[Document(page_content='Toys come alive and have a blast doing so', metadata={'genre': 'animated', 'year': 1995})]
```