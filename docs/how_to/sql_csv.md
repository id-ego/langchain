---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/sql_csv.ipynb
description: CSV 파일을 활용한 질문 응답 시스템 구축 방법을 소개합니다. SQL 데이터베이스와 Pandas 라이브러리 사용 두 가지
  접근 방식을 다룹니다.
---

# CSV에서 질문 응답하는 방법

LLM은 다양한 유형의 데이터 소스에 대한 질문 응답 시스템을 구축하는 데 매우 유용합니다. 이 섹션에서는 CSV 파일에 저장된 데이터에 대한 Q&A 시스템을 구축하는 방법을 다룰 것입니다. SQL 데이터베이스 작업과 마찬가지로, CSV 파일 작업의 핵심은 LLM에 데이터 쿼리 및 상호작용을 위한 도구에 대한 접근을 제공하는 것입니다. 이를 수행하는 두 가지 주요 방법은 다음과 같습니다:

* **추천**: CSV 파일을 SQL 데이터베이스에 로드하고, [SQL 튜토리얼](/docs/tutorials/sql_qa)에서 설명된 접근 방식을 사용합니다.
* LLM이 Pandas와 같은 라이브러리를 사용하여 데이터와 상호작용할 수 있는 Python 환경에 접근할 수 있도록 합니다.

이 가이드에서는 두 가지 접근 방식을 모두 다룰 것입니다.

## ⚠️ 보안 주의 ⚠️

위에서 언급한 두 가지 접근 방식은 상당한 위험을 동반합니다. SQL을 사용하면 모델이 생성한 SQL 쿼리를 실행해야 합니다. Pandas와 같은 라이브러리를 사용하면 모델이 Python 코드를 실행하도록 허용해야 합니다. SQL 연결 권한을 엄격하게 제한하고 SQL 쿼리를 정화하는 것이 Python 환경을 샌드박스하는 것보다 쉽기 때문에, **CSV 데이터와 상호작용할 때 SQL을 사용하는 것을 강력히 권장합니다.** 일반적인 보안 모범 사례에 대한 자세한 내용은 [여기](/docs/security)를 참조하십시오.

## 설정
이 가이드를 위한 종속성:

```python
%pip install -qU langchain langchain-openai langchain-community langchain-experimental pandas
```


필요한 환경 변수를 설정합니다:

```python
# Using LangSmith is recommended but not required. Uncomment below lines to use.
# import os
# os.environ["LANGCHAIN_TRACING_V2"] = "true"
# os.environ["LANGCHAIN_API_KEY"] = getpass.getpass()
```


아직 다운로드하지 않았다면 [타이타닉 데이터셋](https://www.kaggle.com/datasets/yasserh/titanic-dataset)을 다운로드합니다:

```python
!wget https://web.stanford.edu/class/archive/cs/cs109/cs109.1166/stuff/titanic.csv -O titanic.csv
```


```python
import pandas as pd

df = pd.read_csv("titanic.csv")
print(df.shape)
print(df.columns.tolist())
```

```output
(887, 8)
['Survived', 'Pclass', 'Name', 'Sex', 'Age', 'Siblings/Spouses Aboard', 'Parents/Children Aboard', 'Fare']
```

## SQL

CSV 데이터와 상호작용하기 위해 SQL을 사용하는 것은 권장되는 접근 방식입니다. 이는 임의의 Python보다 권한을 제한하고 쿼리를 정화하는 것이 더 쉽기 때문입니다.

대부분의 SQL 데이터베이스는 CSV 파일을 테이블로 쉽게 로드할 수 있습니다 ([DuckDB](https://duckdb.org/docs/data/csv/overview.html), [SQLite](https://www.sqlite.org/csv.html) 등). 이렇게 하면 [SQL 튜토리얼](/docs/tutorials/sql_qa)에서 설명된 모든 체인 및 에이전트 생성 기술을 사용할 수 있습니다. SQLite를 사용하여 이를 수행하는 방법에 대한 간단한 예는 다음과 같습니다:

```python
<!--IMPORTS:[{"imported": "SQLDatabase", "source": "langchain_community.utilities", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.sql_database.SQLDatabase.html", "title": "How to do question answering over CSVs"}]-->
from langchain_community.utilities import SQLDatabase
from sqlalchemy import create_engine

engine = create_engine("sqlite:///titanic.db")
df.to_sql("titanic", engine, index=False)
```


```output
887
```


```python
db = SQLDatabase(engine=engine)
print(db.dialect)
print(db.get_usable_table_names())
print(db.run("SELECT * FROM titanic WHERE Age < 2;"))
```

```output
sqlite
['titanic']
[(1, 2, 'Master. Alden Gates Caldwell', 'male', 0.83, 0, 2, 29.0), (0, 3, 'Master. Eino Viljami Panula', 'male', 1.0, 4, 1, 39.6875), (1, 3, 'Miss. Eleanor Ileen Johnson', 'female', 1.0, 1, 1, 11.1333), (1, 2, 'Master. Richard F Becker', 'male', 1.0, 2, 1, 39.0), (1, 1, 'Master. Hudson Trevor Allison', 'male', 0.92, 1, 2, 151.55), (1, 3, 'Miss. Maria Nakid', 'female', 1.0, 0, 2, 15.7417), (0, 3, 'Master. Sidney Leonard Goodwin', 'male', 1.0, 5, 2, 46.9), (1, 3, 'Miss. Helene Barbara Baclini', 'female', 0.75, 2, 1, 19.2583), (1, 3, 'Miss. Eugenie Baclini', 'female', 0.75, 2, 1, 19.2583), (1, 2, 'Master. Viljo Hamalainen', 'male', 0.67, 1, 1, 14.5), (1, 3, 'Master. Bertram Vere Dean', 'male', 1.0, 1, 2, 20.575), (1, 3, 'Master. Assad Alexander Thomas', 'male', 0.42, 0, 1, 8.5167), (1, 2, 'Master. Andre Mallet', 'male', 1.0, 0, 2, 37.0042), (1, 2, 'Master. George Sibley Richards', 'male', 0.83, 1, 1, 18.75)]
```

그리고 이를 상호작용하기 위한 [SQL 에이전트](/docs/tutorials/sql_qa)를 생성합니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

```python
<!--IMPORTS:[{"imported": "create_sql_agent", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.sql.base.create_sql_agent.html", "title": "How to do question answering over CSVs"}]-->
from langchain_community.agent_toolkits import create_sql_agent

agent_executor = create_sql_agent(llm, db=db, agent_type="openai-tools", verbose=True)
```


```python
agent_executor.invoke({"input": "what's the average age of survivors"})
```

```output


[1m> Entering new SQL Agent Executor chain...[0m
[32;1m[1;3m
Invoking: `sql_db_list_tables` with `{}`


[0m[38;5;200m[1;3mtitanic[0m[32;1m[1;3m
Invoking: `sql_db_schema` with `{'table_names': 'titanic'}`


[0m[33;1m[1;3m
CREATE TABLE titanic (
	"Survived" BIGINT, 
	"Pclass" BIGINT, 
	"Name" TEXT, 
	"Sex" TEXT, 
	"Age" FLOAT, 
	"Siblings/Spouses Aboard" BIGINT, 
	"Parents/Children Aboard" BIGINT, 
	"Fare" FLOAT
)

/*
3 rows from titanic table:
Survived	Pclass	Name	Sex	Age	Siblings/Spouses Aboard	Parents/Children Aboard	Fare
0	3	Mr. Owen Harris Braund	male	22.0	1	0	7.25
1	1	Mrs. John Bradley (Florence Briggs Thayer) Cumings	female	38.0	1	0	71.2833
1	3	Miss. Laina Heikkinen	female	26.0	0	0	7.925
*/[0m[32;1m[1;3m
Invoking: `sql_db_query` with `{'query': 'SELECT AVG(Age) AS Average_Age FROM titanic WHERE Survived = 1'}`


[0m[36;1m[1;3m[(28.408391812865496,)][0m[32;1m[1;3mThe average age of survivors in the Titanic dataset is approximately 28.41 years.[0m

[1m> Finished chain.[0m
```


```output
{'input': "what's the average age of survivors",
 'output': 'The average age of survivors in the Titanic dataset is approximately 28.41 years.'}
```


이 접근 방식은 각 CSV를 자체 테이블로 데이터베이스에 로드할 수 있으므로 여러 CSV에 쉽게 일반화됩니다. 아래의 [여러 CSV](/docs/how_to/sql_csv#multiple-csvs) 섹션을 참조하십시오.

## Pandas

SQL 대신 Pandas와 같은 데이터 분석 라이브러리와 LLM의 코드 생성 능력을 사용하여 CSV 데이터와 상호작용할 수도 있습니다. 다시 말하지만, **이 접근 방식은 광범위한 안전 장치가 없는 한 생산 사용 사례에 적합하지 않습니다**. 이러한 이유로, 우리의 코드 실행 유틸리티 및 생성자는 `langchain-experimental` 패키지에 포함되어 있습니다.

### 체인

대부분의 LLM은 충분한 Pandas Python 코드로 훈련되어 있어 요청만으로 이를 생성할 수 있습니다:

```python
ai_msg = llm.invoke(
    "I have a pandas DataFrame 'df' with columns 'Age' and 'Fare'. Write code to compute the correlation between the two columns. Return Markdown for a Python code snippet and nothing else."
)
print(ai_msg.content)
```

```output
```python
correlation = df['Age'].corr(df['Fare'])
correlation
```

```
We can combine this ability with a Python-executing tool to create a simple data analysis chain. We'll first want to load our CSV table as a dataframe, and give the tool access to this dataframe:


```python
<!--IMPORTS:[{"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "How to do question answering over CSVs"}, {"imported": "PythonAstREPLTool", "source": "langchain_experimental.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_experimental.tools.python.tool.PythonAstREPLTool.html", "title": "How to do question answering over CSVs"}]-->
import pandas as pd
from langchain_core.prompts import ChatPromptTemplate
from langchain_experimental.tools import PythonAstREPLTool

df = pd.read_csv("titanic.csv")
tool = PythonAstREPLTool(locals={"df": df})
tool.invoke("df['Fare'].mean()")
```


```output
32.30542018038331
```


Python 도구의 적절한 사용을 보장하기 위해, 우리는 [도구 호출](/docs/how_to/tool_calling)을 사용할 것입니다:

```python
llm_with_tools = llm.bind_tools([tool], tool_choice=tool.name)
response = llm_with_tools.invoke(
    "I have a dataframe 'df' and want to know the correlation between the 'Age' and 'Fare' columns"
)
response
```


```output
AIMessage(content='', additional_kwargs={'tool_calls': [{'id': 'call_SBrK246yUbdnJemXFC8Iod05', 'function': {'arguments': '{"query":"df.corr()[\'Age\'][\'Fare\']"}', 'name': 'python_repl_ast'}, 'type': 'function'}]}, response_metadata={'token_usage': {'completion_tokens': 13, 'prompt_tokens': 125, 'total_tokens': 138}, 'model_name': 'gpt-3.5-turbo', 'system_fingerprint': 'fp_3b956da36b', 'finish_reason': 'stop', 'logprobs': None}, id='run-1fd332ba-fa72-4351-8182-d464e7368311-0', tool_calls=[{'name': 'python_repl_ast', 'args': {'query': "df.corr()['Age']['Fare']"}, 'id': 'call_SBrK246yUbdnJemXFC8Iod05'}])
```


```python
response.tool_calls
```


```output
[{'name': 'python_repl_ast',
  'args': {'query': "df.corr()['Age']['Fare']"},
  'id': 'call_SBrK246yUbdnJemXFC8Iod05'}]
```


함수 호출을 dict로 추출하기 위해 도구 출력 파서를 추가합니다:

```python
<!--IMPORTS:[{"imported": "JsonOutputKeyToolsParser", "source": "langchain_core.output_parsers.openai_tools", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.openai_tools.JsonOutputKeyToolsParser.html", "title": "How to do question answering over CSVs"}]-->
from langchain_core.output_parsers.openai_tools import JsonOutputKeyToolsParser

parser = JsonOutputKeyToolsParser(key_name=tool.name, first_tool_only=True)
(llm_with_tools | parser).invoke(
    "I have a dataframe 'df' and want to know the correlation between the 'Age' and 'Fare' columns"
)
```


```output
{'query': "df[['Age', 'Fare']].corr()"}
```


매번 호출할 때 데이터프레임 정보를 지정할 필요 없이 질문만 지정할 수 있도록 프롬프트와 결합합니다:

```python
system = f"""You have access to a pandas dataframe `df`. \
Here is the output of `df.head().to_markdown()`:

```

{df.head().to_markdown()}
```

Given a user question, write the Python code to answer it. \
Return ONLY the valid Python code and nothing else. \
Don't assume you have access to any libraries other than built-in Python ones and pandas."""
prompt = ChatPromptTemplate.from_messages([("system", system), ("human", "{question}")])
code_chain = prompt | llm_with_tools | parser
code_chain.invoke({"question": "What's the correlation between age and fare"})
```


```output
{'query': "df[['Age', 'Fare']].corr()"}
```


마지막으로 생성된 코드가 실제로 실행되도록 Python 도구를 추가합니다:

```python
chain = prompt | llm_with_tools | parser | tool
chain.invoke({"question": "What's the correlation between age and fare"})
```


```output
0.11232863699941621
```


이렇게 간단하게 데이터 분석 체인을 만들 수 있습니다. LangSmith 추적을 통해 중간 단계를 살펴볼 수 있습니다: https://smith.langchain.com/public/b1309290-7212-49b7-bde2-75b39a32b49a/r

대화형 응답을 생성하기 위해 마지막에 추가 LLM 호출을 추가할 수 있습니다. 이렇게 하면 도구 출력만으로 응답하지 않게 됩니다. 이를 위해 프롬프트에 채팅 기록 `MessagesPlaceholder`를 추가하고자 합니다:

```python
<!--IMPORTS:[{"imported": "ToolMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.tool.ToolMessage.html", "title": "How to do question answering over CSVs"}, {"imported": "StrOutputParser", "source": "langchain_core.output_parsers", "docs": "https://api.python.langchain.com/en/latest/output_parsers/langchain_core.output_parsers.string.StrOutputParser.html", "title": "How to do question answering over CSVs"}, {"imported": "MessagesPlaceholder", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.MessagesPlaceholder.html", "title": "How to do question answering over CSVs"}, {"imported": "RunnablePassthrough", "source": "langchain_core.runnables", "docs": "https://api.python.langchain.com/en/latest/runnables/langchain_core.runnables.passthrough.RunnablePassthrough.html", "title": "How to do question answering over CSVs"}]-->
from operator import itemgetter

from langchain_core.messages import ToolMessage
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import MessagesPlaceholder
from langchain_core.runnables import RunnablePassthrough

system = f"""You have access to a pandas dataframe `df`. \
Here is the output of `df.head().to_markdown()`:

```

{df.head().to_markdown()}
```

Given a user question, write the Python code to answer it. \
Don't assume you have access to any libraries other than built-in Python ones and pandas.
Respond directly to the question once you have enough information to answer it."""
prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            system,
        ),
        ("human", "{question}"),
        # This MessagesPlaceholder allows us to optionally append an arbitrary number of messages
        # at the end of the prompt using the 'chat_history' arg.
        MessagesPlaceholder("chat_history", optional=True),
    ]
)


def _get_chat_history(x: dict) -> list:
    """Parse the chain output up to this point into a list of chat history messages to insert in the prompt."""
    ai_msg = x["ai_msg"]
    tool_call_id = x["ai_msg"].additional_kwargs["tool_calls"][0]["id"]
    tool_msg = ToolMessage(tool_call_id=tool_call_id, content=str(x["tool_output"]))
    return [ai_msg, tool_msg]


chain = (
    RunnablePassthrough.assign(ai_msg=prompt | llm_with_tools)
    .assign(tool_output=itemgetter("ai_msg") | parser | tool)
    .assign(chat_history=_get_chat_history)
    .assign(response=prompt | llm | StrOutputParser())
    .pick(["tool_output", "response"])
)
```


```python
chain.invoke({"question": "What's the correlation between age and fare"})
```


```output
{'tool_output': 0.11232863699941616,
 'response': 'The correlation between age and fare is approximately 0.1123.'}
```


이번 실행에 대한 LangSmith 추적은 다음과 같습니다: https://smith.langchain.com/public/14e38d70-45b1-4b81-8477-9fd2b7c07ea6/r

### 에이전트

복잡한 질문의 경우 LLM이 이전 실행의 입력 및 출력을 유지하면서 코드를 반복적으로 실행할 수 있는 것이 유용할 수 있습니다. 여기서 에이전트가 등장합니다. 에이전트는 LLM이 도구를 호출해야 하는 횟수를 결정하고 지금까지 수행한 실행을 추적할 수 있게 해줍니다. [create_pandas_dataframe_agent](https://api.python.langchain.com/en/latest/agents/langchain_experimental.agents.agent_toolkits.pandas.base.create_pandas_dataframe_agent.html)는 데이터프레임 작업을 쉽게 해주는 내장 에이전트입니다:

```python
<!--IMPORTS:[{"imported": "create_pandas_dataframe_agent", "source": "langchain_experimental.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain_experimental.agents.agent_toolkits.pandas.base.create_pandas_dataframe_agent.html", "title": "How to do question answering over CSVs"}]-->
from langchain_experimental.agents import create_pandas_dataframe_agent

agent = create_pandas_dataframe_agent(llm, df, agent_type="openai-tools", verbose=True)
agent.invoke(
    {
        "input": "What's the correlation between age and fare? is that greater than the correlation between fare and survival?"
    }
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `python_repl_ast` with `{'query': "df[['Age', 'Fare']].corr().iloc[0,1]"}`


[0m[36;1m[1;3m0.11232863699941621[0m[32;1m[1;3m
Invoking: `python_repl_ast` with `{'query': "df[['Fare', 'Survived']].corr().iloc[0,1]"}`


[0m[36;1m[1;3m0.2561785496289603[0m[32;1m[1;3mThe correlation between Age and Fare is approximately 0.112, and the correlation between Fare and Survival is approximately 0.256.

Therefore, the correlation between Fare and Survival (0.256) is greater than the correlation between Age and Fare (0.112).[0m

[1m> Finished chain.[0m
```


```output
{'input': "What's the correlation between age and fare? is that greater than the correlation between fare and survival?",
 'output': 'The correlation between Age and Fare is approximately 0.112, and the correlation between Fare and Survival is approximately 0.256.\n\nTherefore, the correlation between Fare and Survival (0.256) is greater than the correlation between Age and Fare (0.112).'}
```


이번 실행에 대한 LangSmith 추적은 다음과 같습니다: https://smith.langchain.com/public/6a86aee2-4f22-474a-9264-bd4c7283e665/r

### 여러 CSV {#multiple-csvs}

여러 CSV(또는 데이터프레임)를 처리하려면 Python 도구에 여러 데이터프레임을 전달하면 됩니다. 우리의 `create_pandas_dataframe_agent` 생성자는 기본적으로 이를 지원하며, 하나 대신 데이터프레임 목록을 전달할 수 있습니다. 체인을 직접 구성하는 경우 다음과 같은 작업을 수행할 수 있습니다:

```python
df_1 = df[["Age", "Fare"]]
df_2 = df[["Fare", "Survived"]]

tool = PythonAstREPLTool(locals={"df_1": df_1, "df_2": df_2})
llm_with_tool = llm.bind_tools(tools=[tool], tool_choice=tool.name)
df_template = """```python
{df_name}.head().to_markdown()
>>> {df_head}
```"""
df_context = "\n\n".join(
    df_template.format(df_head=_df.head().to_markdown(), df_name=df_name)
    for _df, df_name in [(df_1, "df_1"), (df_2, "df_2")]
)

system = f"""You have access to a number of pandas dataframes. \
Here is a sample of rows from each dataframe and the python code that was used to generate the sample:

{df_context}

Given a user question about the dataframes, write the Python code to answer it. \
Don't assume you have access to any libraries other than built-in Python ones and pandas. \
Make sure to refer only to the variables mentioned above."""
prompt = ChatPromptTemplate.from_messages([("system", system), ("human", "{question}")])

chain = prompt | llm_with_tool | parser | tool
chain.invoke(
    {
        "question": "return the difference in the correlation between age and fare and the correlation between fare and survival"
    }
)
```


```output
0.14384991262954416
```


이번 실행에 대한 LangSmith 추적은 다음과 같습니다: https://smith.langchain.com/public/cc2a7d7f-7c5a-4e77-a10c-7b5420fcd07f/r

### 샌드박스 코드 실행

[E2B](/docs/integrations/tools/e2b_data_analysis) 및 [Bearly](/docs/integrations/tools/bearly)와 같은 여러 도구는 Python 코드 실행을 위한 샌드박스 환경을 제공하여 더 안전한 코드 실행 체인 및 에이전트를 허용합니다.

## 다음 단계

보다 고급 데이터 분석 애플리케이션을 위해 다음을 확인하는 것이 좋습니다:

* [SQL 튜토리얼](/docs/tutorials/sql_qa): SQL 데이터베이스 및 CSV 작업의 많은 문제는 모든 구조화된 데이터 유형에 일반적이므로, CSV 데이터 분석에 Pandas를 사용하더라도 SQL 기술을 읽는 것이 유용합니다.
* [도구 사용](/docs/how_to/tool_calling): 도구를 호출하는 체인 및 에이전트 작업 시 일반적인 모범 사례에 대한 가이드
* [에이전트](/docs/tutorials/agents): LLM 에이전트 구축의 기본 사항 이해하기.
* 통합: [E2B](/docs/integrations/tools/e2b_data_analysis) 및 [Bearly](/docs/integrations/tools/bearly)와 같은 샌드박스 환경, [SQLDatabase](https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.sql_database.SQLDatabase.html#langchain_community.utilities.sql_database.SQLDatabase)와 같은 유틸리티, [Spark DataFrame agent](/docs/integrations/tools/spark_sql)와 같은 관련 에이전트.