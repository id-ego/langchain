---
canonical: https://python.langchain.com/v0.2/docs/how_to/query_constructing_filters/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/query_constructing_filters.ipynb
sidebar_position: 6
---

# How to construct filters for query analysis

We may want to do query analysis to extract filters to pass into retrievers. One way we ask the LLM to represent these filters is as a Pydantic model. There is then the issue of converting that Pydantic model into a filter that can be passed into a retriever. 

This can be done manually, but LangChain also provides some "Translators" that are able to translate from a common syntax into filters specific to each retriever. Here, we will cover how to use those translators.

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

In this example, `year` and `author` are both attributes to filter on.

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