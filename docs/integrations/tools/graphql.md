---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/graphql/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/graphql.ipynb
---

# GraphQL

> [GraphQL](https://graphql.org/) is a query language for APIs and a runtime for executing those queries against your data. `GraphQL` provides a complete and understandable description of the data in your API, gives clients the power to ask for exactly what they need and nothing more, makes it easier to evolve APIs over time, and enables powerful developer tools.

By including a `BaseGraphQLTool` in the list of tools provided to an Agent, you can grant your Agent the ability to query data from GraphQL APIs for any purposes you need.

This Jupyter Notebook demonstrates how to use the `GraphQLAPIWrapper` component with an Agent.

In this example, we'll be using the public `Star Wars GraphQL API` available at the following endpoint: https://swapi-graphql.netlify.app/.netlify/functions/index.

First, you need to install `httpx` and `gql` Python packages.

```python
pip install httpx gql > /dev/null
```

```python
%pip install --upgrade --quiet  langchain-community
```

Now, let's create a BaseGraphQLTool instance with the specified Star Wars API endpoint and initialize an Agent with the tool.

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

Now, we can use the Agent to run queries against the Star Wars GraphQL API. Let's ask the Agent to list all the Star Wars films and their release dates.

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

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)