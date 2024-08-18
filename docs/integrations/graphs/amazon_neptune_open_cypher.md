---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/amazon_neptune_open_cypher.ipynb
description: 아마존 넵튠과 오픈 사이퍼를 활용한 QA 체인 예제를 통해 그래프 데이터베이스 쿼리 및 인간 친화적 응답을 제공합니다.
---

# 아마존 넵튠과 사이퍼

> [아마존 넵튠](https://aws.amazon.com/neptune/)은 뛰어난 확장성과 가용성을 위한 고성능 그래프 분석 및 서버리스 데이터베이스입니다.
> 
> 이 예제는 `openCypher`를 사용하여 `Neptune` 그래프 데이터베이스를 쿼리하고 사람이 읽을 수 있는 응답을 반환하는 QA 체인을 보여줍니다.
> 
> [사이퍼](https://en.wikipedia.org/wiki/Cypher_(query_language))는 속성 그래프에서 표현력 있고 효율적인 데이터 쿼리를 허용하는 선언적 그래프 쿼리 언어입니다.
> 
> [openCypher](https://opencypher.org/)는 사이퍼의 오픈 소스 구현입니다. # 넵튠 오픈 사이퍼 QA 체인
이 QA 체인은 openCypher를 사용하여 아마존 넵튠을 쿼리하고 사람이 읽을 수 있는 응답을 반환합니다.

LangChain은 `NeptuneOpenCypherQAChain`을 사용하여 [넵튠 데이터베이스](https://docs.aws.amazon.com/neptune/latest/userguide/intro.html)와 [넵튠 분석](https://docs.aws.amazon.com/neptune-analytics/latest/userguide/what-is-neptune-analytics.html)을 모두 지원합니다.

넵튠 데이터베이스는 최적의 확장성과 가용성을 위해 설계된 서버리스 그래프 데이터베이스입니다. 초당 100,000개의 쿼리로 확장해야 하는 그래프 데이터베이스 작업 부하, 다중 AZ 고가용성 및 다중 지역 배포를 위한 솔루션을 제공합니다. 넵튠 데이터베이스는 소셜 네트워킹, 사기 경고 및 고객 360 애플리케이션에 사용할 수 있습니다.

넵튠 분석은 메모리 내에서 대량의 그래프 데이터를 신속하게 분석하여 통찰력을 얻고 트렌드를 찾을 수 있는 분석 데이터베이스 엔진입니다. 넵튠 분석은 기존 그래프 데이터베이스 또는 데이터 레이크에 저장된 그래프 데이터 세트를 신속하게 분석하기 위한 솔루션입니다. 인기 있는 그래프 분석 알고리즘과 저지연 분석 쿼리를 사용합니다.

## 넵튠 데이터베이스 사용하기

```python
<!--IMPORTS:[{"imported": "NeptuneGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neptune_graph.NeptuneGraph.html", "title": "Amazon Neptune with Cypher"}]-->
from langchain_community.graphs import NeptuneGraph

host = "<neptune-host>"
port = 8182
use_https = True

graph = NeptuneGraph(host=host, port=port, use_https=use_https)
```


### 넵튠 분석 사용하기

```python
<!--IMPORTS:[{"imported": "NeptuneAnalyticsGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neptune_graph.NeptuneAnalyticsGraph.html", "title": "Amazon Neptune with Cypher"}]-->
from langchain_community.graphs import NeptuneAnalyticsGraph

graph = NeptuneAnalyticsGraph(graph_identifier="<neptune-analytics-graph-id>")
```


## NeptuneOpenCypherQAChain 사용하기

이 QA 체인은 openCypher를 사용하여 넵튠 그래프 데이터베이스를 쿼리하고 사람이 읽을 수 있는 응답을 반환합니다.

```python
<!--IMPORTS:[{"imported": "NeptuneOpenCypherQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.neptune_cypher.NeptuneOpenCypherQAChain.html", "title": "Amazon Neptune with Cypher"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Amazon Neptune with Cypher"}]-->
from langchain.chains import NeptuneOpenCypherQAChain
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(temperature=0, model="gpt-4")

chain = NeptuneOpenCypherQAChain.from_llm(llm=llm, graph=graph)

chain.invoke("how many outgoing routes does the Austin airport have?")
```


```output
'The Austin airport has 98 outgoing routes.'
```