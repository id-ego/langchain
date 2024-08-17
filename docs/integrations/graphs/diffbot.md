---
canonical: https://python.langchain.com/v0.2/docs/integrations/graphs/diffbot/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/diffbot.ipynb
---

# Diffbot

> [Diffbot](https://docs.diffbot.com/docs/getting-started-with-diffbot) is a suite of ML-based products that make it easy to structure web data.
> 
> Diffbot's [Natural Language Processing API](https://www.diffbot.com/products/natural-language/) allows for the extraction of entities, relationships, and semantic meaning from unstructured text data.
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/langchain-ai/langchain/blob/master/docs/docs/integrations/graphs/diffbot.ipynb)

## Use case

Text data often contain rich relationships and insights used for various analytics, recommendation engines, or knowledge management applications.

By coupling `Diffbot's NLP API` with `Neo4j`, a graph database, you can create powerful, dynamic graph structures based on the information extracted from text. These graph structures are fully queryable and can be integrated into various applications.

This combination allows for use cases such as:

* Building knowledge graphs (like [Diffbot's Knowledge Graph](https://www.diffbot.com/products/knowledge-graph/)) from textual documents, websites, or social media feeds.
* Generating recommendations based on semantic relationships in the data.
* Creating advanced search features that understand the relationships between entities.
* Building analytics dashboards that allow users to explore the hidden relationships in data.

## Overview

LangChain provides tools to interact with Graph Databases:

1. `Construct knowledge graphs from text` using graph transformer and store integrations 
2. `Query a graph database` using chains for query creation and execution
3. `Interact with a graph database` using agents for robust and flexible querying 

## Setting up

First, get required packages and set environment variables:

```python
%pip install --upgrade --quiet  langchain langchain-experimental langchain-openai neo4j wikipedia
```

### Diffbot NLP API

`Diffbot's NLP API` is a tool for extracting entities, relationships, and semantic context from unstructured text data.
This extracted information can be used to construct a knowledge graph.
To use the API, you'll need to obtain a [free API token from Diffbot](https://app.diffbot.com/get-started/).

```python
<!--IMPORTS:[{"imported": "DiffbotGraphTransformer", "source": "langchain_experimental.graph_transformers.diffbot", "docs": "https://api.python.langchain.com/en/latest/graph_transformers/langchain_experimental.graph_transformers.diffbot.DiffbotGraphTransformer.html", "title": "Diffbot"}]-->
from langchain_experimental.graph_transformers.diffbot import DiffbotGraphTransformer

diffbot_api_key = "DIFFBOT_KEY"
diffbot_nlp = DiffbotGraphTransformer(diffbot_api_key=diffbot_api_key)
```

This code fetches Wikipedia articles about "Warren Buffett" and then uses `DiffbotGraphTransformer` to extract entities and relationships.
The `DiffbotGraphTransformer` outputs a structured data `GraphDocument`, which can be used to populate a graph database.
Note that text chunking is avoided due to Diffbot's [character limit per API request](https://docs.diffbot.com/reference/introduction-to-natural-language-api).

```python
<!--IMPORTS:[{"imported": "WikipediaLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.wikipedia.WikipediaLoader.html", "title": "Diffbot"}]-->
from langchain_community.document_loaders import WikipediaLoader

query = "Warren Buffett"
raw_documents = WikipediaLoader(query=query).load()
graph_documents = diffbot_nlp.convert_to_graph_documents(raw_documents)
```

## Loading the data into a knowledge graph

You will need to have a running Neo4j instance. One option is to create a [free Neo4j database instance in their Aura cloud service](https://neo4j.com/cloud/platform/aura-graph-database/). You can also run the database locally using the [Neo4j Desktop application](https://neo4j.com/download/), or running a docker container. You can run a local docker container by running the executing the following script:
```
docker run \
    --name neo4j \
    -p 7474:7474 -p 7687:7687 \
    -d \
    -e NEO4J_AUTH=neo4j/password \
    -e NEO4J_PLUGINS=\[\"apoc\"\]  \
    neo4j:latest
```
If you are using the docker container, you need to wait a couple of second for the database to start.

```python
<!--IMPORTS:[{"imported": "Neo4jGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neo4j_graph.Neo4jGraph.html", "title": "Diffbot"}]-->
from langchain_community.graphs import Neo4jGraph

url = "bolt://localhost:7687"
username = "neo4j"
password = "password"

graph = Neo4jGraph(url=url, username=username, password=password)
```

The `GraphDocuments` can be loaded into a knowledge graph using the `add_graph_documents` method.

```python
graph.add_graph_documents(graph_documents)
```

## Refresh graph schema information
If the schema of database changes, you can refresh the schema information needed to generate Cypher statements

```python
graph.refresh_schema()
```

## Querying the graph
We can now use the graph cypher QA chain to ask question of the graph. It is advisable to use **gpt-4** to construct Cypher queries to get the best experience.

```python
<!--IMPORTS:[{"imported": "GraphCypherQAChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.cypher.GraphCypherQAChain.html", "title": "Diffbot"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Diffbot"}]-->
from langchain.chains import GraphCypherQAChain
from langchain_openai import ChatOpenAI

chain = GraphCypherQAChain.from_llm(
    cypher_llm=ChatOpenAI(temperature=0, model_name="gpt-4"),
    qa_llm=ChatOpenAI(temperature=0, model_name="gpt-3.5-turbo"),
    graph=graph,
    verbose=True,
)
```

```python
chain.run("Which university did Warren Buffett attend?")
```
```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (p:Person {name: "Warren Buffett"})-[:EDUCATED_AT]->(o:Organization)
RETURN o.name[0m
Full Context:
[32;1m[1;3m[{'o.name': 'New York Institute of Finance'}, {'o.name': 'Alice Deal Junior High School'}, {'o.name': 'Woodrow Wilson High School'}, {'o.name': 'University of Nebraska'}][0m

[1m> Finished chain.[0m
```

```output
'Warren Buffett attended the University of Nebraska.'
```

```python
chain.run("Who is or was working at Berkshire Hathaway?")
```
```output


[1m> Entering new GraphCypherQAChain chain...[0m
Generated Cypher:
[32;1m[1;3mMATCH (p:Person)-[r:EMPLOYEE_OR_MEMBER_OF]->(o:Organization) WHERE o.name = 'Berkshire Hathaway' RETURN p.name[0m
Full Context:
[32;1m[1;3m[{'p.name': 'Charlie Munger'}, {'p.name': 'Oliver Chace'}, {'p.name': 'Howard Buffett'}, {'p.name': 'Howard'}, {'p.name': 'Susan Buffett'}, {'p.name': 'Warren Buffett'}][0m

[1m> Finished chain.[0m
```

```output
'Charlie Munger, Oliver Chace, Howard Buffett, Susan Buffett, and Warren Buffett are or were working at Berkshire Hathaway.'
```