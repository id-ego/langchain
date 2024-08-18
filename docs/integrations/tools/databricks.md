---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/databricks.ipynb
description: 이 문서는 LangChain 도구로서 Databricks Unity Catalog의 기능을 사용하는 방법을 보여줍니다. SQL
  및 Python 함수 생성에 대한 안내를 포함합니다.
---

# Databricks Unity Catalog (UC)

이 노트북은 UC 기능을 LangChain 도구로 사용하는 방법을 보여줍니다.

SQL 또는 Python 함수를 UC에서 생성하는 방법을 배우려면 Databricks 문서([AWS](https://docs.databricks.com/en/sql/language-manual/sql-ref-syntax-ddl-create-sql-function.html)|[Azure](https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/sql-ref-syntax-ddl-create-sql-function)|[GCP](https://docs.gcp.databricks.com/en/sql/language-manual/sql-ref-syntax-ddl-create-sql-function.html))를 참조하세요. LLM이 함수를 올바르게 호출하기 위해서는 함수 및 매개변수 주석을 건너뛰지 마세요.

이 예제 노트북에서는 임의의 코드를 실행하는 간단한 Python 함수를 생성하고 이를 LangChain 도구로 사용합니다:

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


이 코드는 Databricks SQL 웨어하우스 내의 안전하고 격리된 환경에서 실행됩니다.

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


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)