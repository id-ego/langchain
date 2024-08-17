---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/databricks/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/databricks.ipynb
---

# Databricks Unity Catalog (UC)

This notebook shows how to use UC functions as LangChain tools.

See Databricks documentation ([AWS](https://docs.databricks.com/en/sql/language-manual/sql-ref-syntax-ddl-create-sql-function.html)|[Azure](https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/sql-ref-syntax-ddl-create-sql-function)|[GCP](https://docs.gcp.databricks.com/en/sql/language-manual/sql-ref-syntax-ddl-create-sql-function.html)) to learn how to create SQL or Python functions in UC. Do not skip function and parameter comments, which are critical for LLMs to call functions properly.

In this example notebook, we create a simple Python function that executes arbitrary code and use it as a LangChain tool:

```sql
CREATE FUNCTION main.tools.python_exec (
  code STRING COMMENT 'Python code to execute. Remember to print the final result to stdout.'
)
RETURNS STRING
LANGUAGE PYTHON
COMMENT 'Executes Python code and returns its stdout.'
AS $$
  import sys
  from io import StringIO
  stdout = StringIO()
  sys.stdout = stdout
  exec(code)
  return stdout.getvalue()
$$
```

It runs in a secure and isolated environment within a Databricks SQL warehouse.


```python
%pip install --upgrade --quiet databricks-sdk langchain-community mlflow
```


```python
<!--IMPORTS:[{"imported": "ChatDatabricks", "source": "langchain_community.chat_models.databricks", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.databricks.ChatDatabricks.html", "title": "Databricks Unity Catalog (UC)"}]-->
from langchain_community.chat_models.databricks import ChatDatabricks

llm = ChatDatabricks(endpoint="databricks-meta-llama-3-70b-instruct")
```


```python
<!--IMPORTS:[{"imported": "UCFunctionToolkit", "source": "langchain_community.tools.databricks", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.databricks.tool.UCFunctionToolkit.html", "title": "Databricks Unity Catalog (UC)"}]-->
from langchain_community.tools.databricks import UCFunctionToolkit

tools = (
    UCFunctionToolkit(
        # You can find the SQL warehouse ID in its UI after creation.
        warehouse_id="xxxx123456789"
    )
    .include(
        # Include functions as tools using their qualified names.
        # You can use "{catalog_name}.{schema_name}.*" to get all functions in a schema.
        "main.tools.python_exec",
    )
    .get_tools()
)
```


```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Databricks Unity Catalog (UC)"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "Databricks Unity Catalog (UC)"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Databricks Unity Catalog (UC)"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            "You are a helpful assistant. Make sure to use tool for information.",
        ),
        ("placeholder", "{chat_history}"),
        ("human", "{input}"),
        ("placeholder", "{agent_scratchpad}"),
    ]
)

agent = create_tool_calling_agent(llm, tools, prompt)
```


```python
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
agent_executor.invoke({"input": "36939 * 8922.4"})
```
```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `main__tools__python_exec` with `{'code': 'print(36939 * 8922.4)'}`


[0m[36;1m[1;3m{"format": "SCALAR", "value": "329584533.59999996\n", "truncated": false}[0m[32;1m[1;3mThe result of the multiplication 36939 * 8922.4 is 329,584,533.60.[0m

[1m> Finished chain.[0m
```


```output
{'input': '36939 * 8922.4',
 'output': 'The result of the multiplication 36939 * 8922.4 is 329,584,533.60.'}
```



## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)