---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/networkx.ipynb
description: 이 문서는 NetworkX를 사용하여 그래프 데이터 구조에서 질문 응답을 수행하는 방법을 설명합니다. 그래프 생성 및 쿼리
  방법을 다룹니다.
---

# NetworkX

> [NetworkX](https://networkx.org/)는 복잡한 네트워크의 구조, 동역학 및 기능을 생성, 조작 및 연구하기 위한 Python 패키지입니다.

이 노트북에서는 그래프 데이터 구조에 대한 질문 응답 방법을 다룹니다.

## 설정

Python 패키지를 설치해야 합니다.

```python
%pip install --upgrade --quiet  networkx
```


## 그래프 생성

이 섹션에서는 예제 그래프를 구성합니다. 현재로서는 작은 텍스트 조각에 가장 잘 작동합니다.

```python
<!--IMPORTS:[{"imported": "GraphIndexCreator", "source": "langchain_community.graphs.index_creator", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.index_creator.GraphIndexCreator.html", "title": "NetworkX"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "NetworkX"}]-->
from langchain_community.graphs.index_creator import GraphIndexCreator
from langchain_openai import OpenAI
```


```python
index_creator = GraphIndexCreator(llm=OpenAI(temperature=0))
```


```python
with open("../../../how_to/state_of_the_union.txt") as f:
    all_text = f.read()
```


지식 삼중항을 추출하는 것이 현재 다소 집중적이기 때문에 작은 조각만 사용할 것입니다.

```python
text = "\n".join(all_text.split("\n\n")[105:108])
```


```python
text
```


```output
'It won’t look like much, but if you stop and look closely, you’ll see a “Field of dreams,” the ground on which America’s future will be built. \nThis is where Intel, the American company that helped build Silicon Valley, is going to build its $20 billion semiconductor “mega site”. \nUp to eight state-of-the-art factories in one place. 10,000 new good-paying jobs. '
```


```python
graph = index_creator.from_text(text)
```


생성된 그래프를 검사할 수 있습니다.

```python
graph.get_triples()
```


```output
[('Intel', '$20 billion semiconductor "mega site"', 'is going to build'),
 ('Intel', 'state-of-the-art factories', 'is building'),
 ('Intel', '10,000 new good-paying jobs', 'is creating'),
 ('Intel', 'Silicon Valley', 'is helping build'),
 ('Field of dreams',
  "America's future will be built",
  'is the ground on which')]
```


## 그래프 쿼리
이제 그래프 QA 체인을 사용하여 그래프에 질문을 할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "GraphQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.base.GraphQAChain.html", "title": "NetworkX"}]-->
from langchain.chains import GraphQAChain
```


```python
chain = GraphQAChain.from_llm(OpenAI(temperature=0), graph=graph, verbose=True)
```


```python
chain.run("what is Intel going to build?")
```

```output


[1m> Entering new GraphQAChain chain...[0m
Entities Extracted:
[32;1m[1;3m Intel[0m
Full Context:
[32;1m[1;3mIntel is going to build $20 billion semiconductor "mega site"
Intel is building state-of-the-art factories
Intel is creating 10,000 new good-paying jobs
Intel is helping build Silicon Valley[0m

[1m> Finished chain.[0m
```


```output
' Intel is going to build a $20 billion semiconductor "mega site" with state-of-the-art factories, creating 10,000 new good-paying jobs and helping to build Silicon Valley.'
```


## 그래프 저장
그래프를 저장하고 불러올 수도 있습니다.

```python
graph.write_to_gml("graph.gml")
```


```python
<!--IMPORTS:[{"imported": "NetworkxEntityGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.networkx_graph.NetworkxEntityGraph.html", "title": "NetworkX"}]-->
from langchain_community.graphs import NetworkxEntityGraph
```


```python
loaded_graph = NetworkxEntityGraph.from_gml("graph.gml")
```


```python
loaded_graph.get_triples()
```


```output
[('Intel', '$20 billion semiconductor "mega site"', 'is going to build'),
 ('Intel', 'state-of-the-art factories', 'is building'),
 ('Intel', '10,000 new good-paying jobs', 'is creating'),
 ('Intel', 'Silicon Valley', 'is helping build'),
 ('Field of dreams',
  "America's future will be built",
  'is the ground on which')]
```


```python
loaded_graph.get_number_of_nodes()
```


```python
loaded_graph.add_node("NewNode")
```


```python
loaded_graph.has_node("NewNode")
```


```python
loaded_graph.remove_node("NewNode")
```


```python
loaded_graph.get_neighbors("Intel")
```


```python
loaded_graph.has_edge("Intel", "Silicon Valley")
```


```python
loaded_graph.remove_edge("Intel", "Silicon Valley")
```


```python
loaded_graph.clear_edges()
```


```python
loaded_graph.clear()
```