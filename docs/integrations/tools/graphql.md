---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/graphql.ipynb
description: GraphQL은 API를 위한 쿼리 언어로, 데이터를 효율적으로 요청하고 처리할 수 있는 강력한 도구입니다.
---

# GraphQL

> [GraphQL](https://graphql.org/)는 API를 위한 쿼리 언어이자 데이터에 대한 쿼리를 실행하기 위한 런타임입니다. `GraphQL`은 API의 데이터에 대한 완전하고 이해하기 쉬운 설명을 제공하며, 클라이언트가 필요한 것만 정확히 요청할 수 있는 권한을 부여하고, 시간이 지남에 따라 API를 발전시키기 쉽게 하며, 강력한 개발자 도구를 가능하게 합니다.

Agent에 제공되는 도구 목록에 `BaseGraphQLTool`을 포함시키면, Agent가 필요에 따라 GraphQL API에서 데이터를 쿼리할 수 있는 능력을 부여할 수 있습니다.

이 Jupyter Notebook은 Agent와 함께 `GraphQLAPIWrapper` 구성 요소를 사용하는 방법을 보여줍니다.

이 예제에서는 다음 엔드포인트에서 사용할 수 있는 공개 `Star Wars GraphQL API`를 사용할 것입니다: https://swapi-graphql.netlify.app/.netlify/functions/index.

먼저, `httpx`와 `gql` Python 패키지를 설치해야 합니다.

```python
pip install httpx gql > /dev/null
```


```python
%pip install --upgrade --quiet  langchain-community
```


이제 지정된 Star Wars API 엔드포인트로 BaseGraphQLTool 인스턴스를 생성하고 도구로 Agent를 초기화합시다.

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "GraphQL"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "GraphQL"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "GraphQL"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "GraphQL"}]-->
from langchain.agents import AgentType, initialize_agent, load_tools
from langchain_openai import OpenAI

llm = OpenAI(temperature=0)

tools = load_tools(
    ["graphql"],
    graphql_endpoint="https://swapi-graphql.netlify.app/.netlify/functions/index",
)

agent = initialize_agent(
    tools, llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)
```


이제 Agent를 사용하여 Star Wars GraphQL API에 대한 쿼리를 실행할 수 있습니다. Agent에게 모든 Star Wars 영화와 그 개봉일을 나열해 달라고 요청해 봅시다.

```python
graphql_fields = """allFilms {
    films {
      title
      director
      releaseDate
      speciesConnection {
        species {
          name
          classification
          homeworld {
            name
          }
        }
      }
    }
  }

"""

suffix = "Search for the titles of all the stawars films stored in the graphql database that has this schema "


agent.run(suffix + graphql_fields)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m I need to query the graphql database to get the titles of all the star wars films
Action: query_graphql
Action Input: query { allFilms { films { title } } }[0m
Observation: [36;1m[1;3m"{\n  \"allFilms\": {\n    \"films\": [\n      {\n        \"title\": \"A New Hope\"\n      },\n      {\n        \"title\": \"The Empire Strikes Back\"\n      },\n      {\n        \"title\": \"Return of the Jedi\"\n      },\n      {\n        \"title\": \"The Phantom Menace\"\n      },\n      {\n        \"title\": \"Attack of the Clones\"\n      },\n      {\n        \"title\": \"Revenge of the Sith\"\n      }\n    ]\n  }\n}"[0m
Thought:[32;1m[1;3m I now know the titles of all the star wars films
Final Answer: The titles of all the star wars films are: A New Hope, The Empire Strikes Back, Return of the Jedi, The Phantom Menace, Attack of the Clones, and Revenge of the Sith.[0m

[1m> Finished chain.[0m
```


```output
'The titles of all the star wars films are: A New Hope, The Empire Strikes Back, Return of the Jedi, The Phantom Menace, Attack of the Clones, and Revenge of the Sith.'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)