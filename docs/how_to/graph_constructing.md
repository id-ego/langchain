---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/graph_constructing.ipynb
description: 비구조화된 텍스트를 기반으로 지식 그래프를 구축하는 방법을 안내합니다. RAG 애플리케이션에서 활용할 수 있는 지식 기반을
  생성합니다.
sidebar_position: 4
---

# 지식 그래프 구축 방법

이 가이드에서는 비구조화된 텍스트를 기반으로 지식 그래프를 구축하는 기본 방법에 대해 설명합니다. 구축된 그래프는 RAG 애플리케이션의 지식 베이스로 사용될 수 있습니다.

## ⚠️ 보안 주의 ⚠️

지식 그래프를 구축하려면 데이터베이스에 대한 쓰기 접근 권한을 실행해야 합니다. 이 작업에는 고유한 위험이 따릅니다. 가져오기 전에 데이터를 확인하고 검증해야 합니다. 일반적인 보안 모범 사례에 대한 자세한 내용은 [여기](https://docs/security)에서 확인하세요.

## 아키텍처

지식 그래프를 텍스트에서 구축하는 단계는 다음과 같습니다:

1. **텍스트에서 구조화된 정보 추출**: 모델을 사용하여 텍스트에서 구조화된 그래프 정보를 추출합니다.
2. **그래프 데이터베이스에 저장**: 추출된 구조화된 그래프 정보를 그래프 데이터베이스에 저장하면 하위 RAG 애플리케이션에서 사용할 수 있습니다.

## 설정

먼저 필요한 패키지를 가져오고 환경 변수를 설정합니다.
이 예제에서는 Neo4j 그래프 데이터베이스를 사용할 것입니다.

```python
%pip install --upgrade --quiet  langchain langchain-community langchain-openai langchain-experimental neo4j
```

```output
Note: you may need to restart the kernel to use updated packages.
```

이 가이드에서는 OpenAI 모델을 기본으로 사용합니다.

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()

# Uncomment the below to use LangSmith. Not required.
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
```

```output
 ········
```

다음으로 Neo4j 자격 증명 및 연결을 정의해야 합니다.
Neo4j 데이터베이스를 설정하려면 [이 설치 단계](https://neo4j.com/docs/operations-manual/current/installation/)를 따르세요.

```python
<!--IMPORTS:[{"imported": "Neo4jGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neo4j_graph.Neo4jGraph.html", "title": "How to construct knowledge graphs"}]-->
import os

from langchain_community.graphs import Neo4jGraph

os.environ["NEO4J_URI"] = "bolt://localhost:7687"
os.environ["NEO4J_USERNAME"] = "neo4j"
os.environ["NEO4J_PASSWORD"] = "password"

graph = Neo4jGraph()
```


## LLM 그래프 변환기

텍스트에서 그래프 데이터를 추출하면 비구조화된 정보를 구조화된 형식으로 변환할 수 있어 복잡한 관계와 패턴을 통해 더 깊은 통찰력과 더 효율적인 탐색이 가능합니다. `LLMGraphTransformer`는 LLM을 활용하여 텍스트 문서를 구조화된 그래프 문서로 변환하여 엔티티와 그 관계를 파싱하고 분류합니다. LLM 모델의 선택은 추출된 그래프 데이터의 정확성과 뉘앙스를 결정하여 출력에 상당한 영향을 미칩니다.

```python
<!--IMPORTS:[{"imported": "LLMGraphTransformer", "source": "langchain_experimental.graph_transformers", "docs": "https://api.python.langchain.com/en/latest/graph_transformers/langchain_experimental.graph_transformers.llm.LLMGraphTransformer.html", "title": "How to construct knowledge graphs"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "How to construct knowledge graphs"}]-->
import os

from langchain_experimental.graph_transformers import LLMGraphTransformer
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(temperature=0, model_name="gpt-4-turbo")

llm_transformer = LLMGraphTransformer(llm=llm)
```


이제 예제 텍스트를 전달하고 결과를 살펴볼 수 있습니다.

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to construct knowledge graphs"}]-->
from langchain_core.documents import Document

text = """
Marie Curie, born in 1867, was a Polish and naturalised-French physicist and chemist who conducted pioneering research on radioactivity.
She was the first woman to win a Nobel Prize, the first person to win a Nobel Prize twice, and the only person to win a Nobel Prize in two scientific fields.
Her husband, Pierre Curie, was a co-winner of her first Nobel Prize, making them the first-ever married couple to win the Nobel Prize and launching the Curie family legacy of five Nobel Prizes.
She was, in 1906, the first woman to become a professor at the University of Paris.
"""
documents = [Document(page_content=text)]
graph_documents = llm_transformer.convert_to_graph_documents(documents)
print(f"Nodes:{graph_documents[0].nodes}")
print(f"Relationships:{graph_documents[0].relationships}")
```

```output
Nodes:[Node(id='Marie Curie', type='Person'), Node(id='Pierre Curie', type='Person'), Node(id='University Of Paris', type='Organization')]
Relationships:[Relationship(source=Node(id='Marie Curie', type='Person'), target=Node(id='Pierre Curie', type='Person'), type='MARRIED'), Relationship(source=Node(id='Marie Curie', type='Person'), target=Node(id='University Of Paris', type='Organization'), type='PROFESSOR')]
```

생성된 지식 그래프의 구조를 더 잘 이해하기 위해 다음 이미지를 살펴보세요.

![graph_construction1.png](../../static/img/graph_construction1.png)

LLM을 사용하고 있기 때문에 그래프 구축 과정은 비결정적이라는 점에 유의하세요. 따라서 각 실행에서 약간 다른 결과를 얻을 수 있습니다.

또한, 요구 사항에 따라 추출을 위한 특정 유형의 노드와 관계를 정의할 수 있는 유연성이 있습니다.

```python
llm_transformer_filtered = LLMGraphTransformer(
    llm=llm,
    allowed_nodes=["Person", "Country", "Organization"],
    allowed_relationships=["NATIONALITY", "LOCATED_IN", "WORKED_AT", "SPOUSE"],
)
graph_documents_filtered = llm_transformer_filtered.convert_to_graph_documents(
    documents
)
print(f"Nodes:{graph_documents_filtered[0].nodes}")
print(f"Relationships:{graph_documents_filtered[0].relationships}")
```

```output
Nodes:[Node(id='Marie Curie', type='Person'), Node(id='Pierre Curie', type='Person'), Node(id='University Of Paris', type='Organization')]
Relationships:[Relationship(source=Node(id='Marie Curie', type='Person'), target=Node(id='Pierre Curie', type='Person'), type='SPOUSE'), Relationship(source=Node(id='Marie Curie', type='Person'), target=Node(id='University Of Paris', type='Organization'), type='WORKED_AT')]
```

생성된 그래프를 더 잘 이해하기 위해 다시 시각화할 수 있습니다.

![graph_construction2.png](../../static/img/graph_construction2.png)

`node_properties` 매개변수는 노드 속성의 추출을 가능하게 하여 더 자세한 그래프를 생성할 수 있습니다.
`True`로 설정하면 LLM이 자율적으로 관련 노드 속성을 식별하고 추출합니다.
반대로, `node_properties`가 문자열 목록으로 정의되면 LLM은 텍스트에서 지정된 속성만 선택적으로 검색합니다.

```python
llm_transformer_props = LLMGraphTransformer(
    llm=llm,
    allowed_nodes=["Person", "Country", "Organization"],
    allowed_relationships=["NATIONALITY", "LOCATED_IN", "WORKED_AT", "SPOUSE"],
    node_properties=["born_year"],
)
graph_documents_props = llm_transformer_props.convert_to_graph_documents(documents)
print(f"Nodes:{graph_documents_props[0].nodes}")
print(f"Relationships:{graph_documents_props[0].relationships}")
```

```output
Nodes:[Node(id='Marie Curie', type='Person', properties={'born_year': '1867'}), Node(id='Pierre Curie', type='Person'), Node(id='University Of Paris', type='Organization')]
Relationships:[Relationship(source=Node(id='Marie Curie', type='Person'), target=Node(id='Pierre Curie', type='Person'), type='SPOUSE'), Relationship(source=Node(id='Marie Curie', type='Person'), target=Node(id='University Of Paris', type='Organization'), type='WORKED_AT')]
```

## 그래프 데이터베이스에 저장

생성된 그래프 문서는 `add_graph_documents` 메서드를 사용하여 그래프 데이터베이스에 저장할 수 있습니다.

```python
graph.add_graph_documents(graph_documents_props)
```