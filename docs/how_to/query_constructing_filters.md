---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/query_constructing_filters.ipynb
description: 쿼리 분석을 위한 필터 구성 방법과 LangChain의 변환기를 사용하여 Pydantic 모델을 필터로 변환하는 방법을 설명합니다.
sidebar_position: 6
---

# 쿼리 분석을 위한 필터 구성 방법

쿼리 분석을 통해 리트리버에 전달할 필터를 추출하고자 할 수 있습니다. LLM에게 이러한 필터를 Pydantic 모델로 표현하도록 요청하는 한 가지 방법이 있습니다. 그 다음에는 해당 Pydantic 모델을 리트리버에 전달할 수 있는 필터로 변환하는 문제가 있습니다.

이는 수동으로 수행할 수 있지만, LangChain은 공통 구문에서 각 리트리버에 특정한 필터로 변환할 수 있는 "변환기"를 제공합니다. 여기에서는 이러한 변환기를 사용하는 방법을 다룰 것입니다.

```python
<!--IMPORTS:[{"imported": "Comparator", "source": "langchain.chains.query_constructor.ir", "docs": "https://api.python.langchain.com/en/latest/structured_query/langchain_core.structured_query.Comparator.html", "title": "How to construct filters for query analysis"}, {"imported": "Comparison", "source": "langchain.chains.query_constructor.ir", "docs": "https://api.python.langchain.com/en/latest/structured_query/langchain_core.structured_query.Comparison.html", "title": "How to construct filters for query analysis"}, {"imported": "Operation", "source": "langchain.chains.query_constructor.ir", "docs": "https://api.python.langchain.com/en/latest/structured_query/langchain_core.structured_query.Operation.html", "title": "How to construct filters for query analysis"}, {"imported": "Operator", "source": "langchain.chains.query_constructor.ir", "docs": "https://api.python.langchain.com/en/latest/structured_query/langchain_core.structured_query.Operator.html", "title": "How to construct filters for query analysis"}, {"imported": "StructuredQuery", "source": "langchain.chains.query_constructor.ir", "docs": "https://api.python.langchain.com/en/latest/structured_query/langchain_core.structured_query.StructuredQuery.html", "title": "How to construct filters for query analysis"}, {"imported": "ChromaTranslator", "source": "langchain_community.query_constructors.chroma", "docs": "https://api.python.langchain.com/en/latest/query_constructors/langchain_community.query_constructors.chroma.ChromaTranslator.html", "title": "How to construct filters for query analysis"}, {"imported": "ElasticsearchTranslator", "source": "langchain_community.query_constructors.elasticsearch", "docs": "https://api.python.langchain.com/en/latest/query_constructors/langchain_community.query_constructors.elasticsearch.ElasticsearchTranslator.html", "title": "How to construct filters for query analysis"}]-->
from typing import Optional

from langchain.chains.query_constructor.ir import (
    Comparator,
    Comparison,
    Operation,
    Operator,
    StructuredQuery,
)
from langchain_community.query_constructors.chroma import ChromaTranslator
from langchain_community.query_constructors.elasticsearch import ElasticsearchTranslator
from langchain_core.pydantic_v1 import BaseModel
```


이 예제에서 `year`와 `author`는 모두 필터링할 속성입니다.

```python
class Search(BaseModel):
    query: str
    start_year: Optional[int]
    author: Optional[str]
```


```python
search_query = Search(query="RAG", start_year=2022, author="LangChain")
```


```python
def construct_comparisons(query: Search):
    comparisons = []
    if query.start_year is not None:
        comparisons.append(
            Comparison(
                comparator=Comparator.GT,
                attribute="start_year",
                value=query.start_year,
            )
        )
    if query.author is not None:
        comparisons.append(
            Comparison(
                comparator=Comparator.EQ,
                attribute="author",
                value=query.author,
            )
        )
    return comparisons
```


```python
comparisons = construct_comparisons(search_query)
```


```python
_filter = Operation(operator=Operator.AND, arguments=comparisons)
```


```python
ElasticsearchTranslator().visit_operation(_filter)
```


```output
{'bool': {'must': [{'range': {'metadata.start_year': {'gt': 2022}}},
   {'term': {'metadata.author.keyword': 'LangChain'}}]}}
```


```python
ChromaTranslator().visit_operation(_filter)
```


```output
{'$and': [{'start_year': {'$gt': 2022}}, {'author': {'$eq': 'LangChain'}}]}
```