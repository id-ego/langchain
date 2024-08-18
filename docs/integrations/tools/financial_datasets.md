---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/financial_datasets.ipynb
description: 금융 데이터셋 툴킷은 30년 이상의 데이터를 포함한 16,000개 이상의 주식 티커에 대한 REST API 엔드포인트를 제공합니다.
---

# FinancialDatasets Toolkit

[financial datasets](https://financialdatasets.ai/) 주식 시장 API는 30년 이상에 걸쳐 16,000개 이상의 티커에 대한 재무 데이터를 가져올 수 있는 REST 엔드포인트를 제공합니다.

## 설정

이 툴킷을 사용하려면 두 개의 API 키가 필요합니다:

`FINANCIAL_DATASETS_API_KEY`: [financialdatasets.ai](https://financialdatasets.ai/)에서 가져옵니다.
`OPENAI_API_KEY`: [OpenAI](https://platform.openai.com/)에서 가져옵니다.

```python
import getpass
import os

os.environ["FINANCIAL_DATASETS_API_KEY"] = getpass.getpass()
```


```python
os.environ["OPENAI_API_KEY"] = getpass.getpass()
```


### 설치

이 툴킷은 `langchain-community` 패키지에 있습니다.

```python
%pip install -qU langchain-community
```


## 인스턴스화

이제 툴킷을 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "FinancialDatasetsToolkit", "source": "langchain_community.agent_toolkits.financial_datasets.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.financial_datasets.toolkit.FinancialDatasetsToolkit.html", "title": "FinancialDatasets Toolkit"}, {"imported": "FinancialDatasetsAPIWrapper", "source": "langchain_community.utilities.financial_datasets", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.financial_datasets.FinancialDatasetsAPIWrapper.html", "title": "FinancialDatasets Toolkit"}]-->
from langchain_community.agent_toolkits.financial_datasets.toolkit import (
    FinancialDatasetsToolkit,
)
from langchain_community.utilities.financial_datasets import FinancialDatasetsAPIWrapper

api_wrapper = FinancialDatasetsAPIWrapper(
    financial_datasets_api_key=os.environ["FINANCIAL_DATASETS_API_KEY"]
)
toolkit = FinancialDatasetsToolkit(api_wrapper=api_wrapper)
```


## 도구

사용 가능한 도구 보기:

```python
tools = toolkit.get_tools()
```


## 에이전트 내에서 사용

우리의 에이전트에 FinancialDatasetsToolkit을 장착하고 재무 질문을 해봅시다.

```python
system_prompt = """
You are an advanced financial analysis AI assistant equipped with specialized tools
to access and analyze financial data. Your primary function is to help users with
financial analysis by retrieving and interpreting income statements, balance sheets,
and cash flow statements for publicly traded companies.

You have access to the following tools from the FinancialDatasetsToolkit:

1. Balance Sheets: Retrieves balance sheet data for a given ticker symbol.
2. Income Statements: Fetches income statement data for a specified company.
3. Cash Flow Statements: Accesses cash flow statement information for a particular ticker.

Your capabilities include:

1. Retrieving financial statements for any publicly traded company using its ticker symbol.
2. Analyzing financial ratios and metrics based on the data from these statements.
3. Comparing financial performance across different time periods (e.g., year-over-year or quarter-over-quarter).
4. Identifying trends in a company's financial health and performance.
5. Providing insights on a company's liquidity, solvency, profitability, and efficiency.
6. Explaining complex financial concepts in simple terms.

When responding to queries:

1. Always specify which financial statement(s) you're using for your analysis.
2. Provide context for the numbers you're referencing (e.g., fiscal year, quarter).
3. Explain your reasoning and calculations clearly.
4. If you need more information to provide a complete answer, ask for clarification.
5. When appropriate, suggest additional analyses that might be helpful.

Remember, your goal is to provide accurate, insightful financial analysis to
help users make informed decisions. Always maintain a professional and objective tone in your responses.
"""
```


LLM을 인스턴스화합니다.

```python
<!--IMPORTS:[{"imported": "tool", "source": "langchain_core.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_core.tools.convert.tool.html", "title": "FinancialDatasets Toolkit"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "FinancialDatasets Toolkit"}]-->
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI

model = ChatOpenAI(model="gpt-4o")
```


사용자 쿼리를 정의합니다.

```python
query = "What was AAPL's revenue in 2023? What about it's total debt in Q1 2024?"
```


에이전트를 생성합니다.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "FinancialDatasets Toolkit"}, {"imported": "create_tool_calling_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.tool_calling_agent.base.create_tool_calling_agent.html", "title": "FinancialDatasets Toolkit"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "FinancialDatasets Toolkit"}]-->
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate

prompt = ChatPromptTemplate.from_messages(
    [
        ("system", system_prompt),
        ("human", "{input}"),
        # Placeholders fill up a **list** of messages
        ("placeholder", "{agent_scratchpad}"),
    ]
)


agent = create_tool_calling_agent(model, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)
```


에이전트에 쿼리합니다.

```python
agent_executor.invoke({"input": query})
```


## API 참조

모든 `FinancialDatasetsToolkit` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.financial_datasets.toolkit.FinancialDatasetsToolkit.html)에서 확인하세요.

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)