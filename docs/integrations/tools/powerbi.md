---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/powerbi.ipynb
description: 이 문서는 Power BI 데이터셋과 상호작용하는 에이전트를 소개하며, 일반 질문에 대한 답변과 오류 복구 기능을 보여줍니다.
---

# PowerBI 툴킷

이 노트북은 `Power BI 데이터셋`과 상호작용하는 에이전트를 보여줍니다. 에이전트는 데이터셋에 대한 보다 일반적인 질문에 답변하며, 오류에서 복구합니다.

이 에이전트는 현재 개발 중이므로 모든 답변이 정확하지 않을 수 있습니다. 삭제를 허용하지 않는 [executequery 엔드포인트](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-queries)에서 실행됩니다.

### 노트:
- azure.identity 패키지로 인증을 의존하며, `pip install azure-identity`로 설치할 수 있습니다. 또는 자격 증명을 제공하지 않고 문자열로 토큰을 사용하여 powerbi 데이터셋을 생성할 수 있습니다.
- RLS가 활성화된 데이터셋과 함께 사용하기 위해 가장할 사용자 이름을 제공할 수도 있습니다.
- 툴킷은 질문에서 쿼리를 생성하기 위해 LLM을 사용하며, 에이전트는 전체 실행을 위해 LLM을 사용합니다.
- 테스트는 주로 `gpt-3.5-turbo-instruct` 모델로 수행되었으며, codex 모델은 성능이 좋지 않은 것으로 보였습니다.

## 초기화

```python
<!--IMPORTS:[{"imported": "PowerBIToolkit", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.powerbi.toolkit.PowerBIToolkit.html", "title": "PowerBI Toolkit"}, {"imported": "create_pbi_agent", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.powerbi.base.create_pbi_agent.html", "title": "PowerBI Toolkit"}, {"imported": "PowerBIDataset", "source": "langchain_community.utilities.powerbi", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.powerbi.PowerBIDataset.html", "title": "PowerBI Toolkit"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "PowerBI Toolkit"}]-->
from azure.identity import DefaultAzureCredential
from langchain_community.agent_toolkits import PowerBIToolkit, create_pbi_agent
from langchain_community.utilities.powerbi import PowerBIDataset
from langchain_openai import ChatOpenAI
```


```python
fast_llm = ChatOpenAI(
    temperature=0.5, max_tokens=1000, model_name="gpt-3.5-turbo", verbose=True
)
smart_llm = ChatOpenAI(temperature=0, max_tokens=100, model_name="gpt-4", verbose=True)

toolkit = PowerBIToolkit(
    powerbi=PowerBIDataset(
        dataset_id="<dataset_id>",
        table_names=["table1", "table2"],
        credential=DefaultAzureCredential(),
    ),
    llm=smart_llm,
)

agent_executor = create_pbi_agent(
    llm=fast_llm,
    toolkit=toolkit,
    verbose=True,
)
```


## 예제: 테이블 설명하기

```python
agent_executor.run("Describe table1")
```


## 예제: 테이블에 대한 간단한 쿼리
이 예제에서 에이전트는 실제로 테이블의 행 수를 가져오기 위한 올바른 쿼리를 찾아냅니다.

```python
agent_executor.run("How many records are in table1?")
```


## 예제: 쿼리 실행하기

```python
agent_executor.run("How many records are there by dimension1 in table2?")
```


```python
agent_executor.run("What unique values are there for dimensions2 in table2")
```


## 예제: 자신의 몇 가지 샷 프롬프트 추가하기

```python
# fictional example
few_shots = """
Question: How many rows are in the table revenue?
DAX: EVALUATE ROW("Number of rows", COUNTROWS(revenue_details))
----
Question: How many rows are in the table revenue where year is not empty?
DAX: EVALUATE ROW("Number of rows", COUNTROWS(FILTER(revenue_details, revenue_details[year] <> "")))
----
Question: What was the average of value in revenue in dollars?
DAX: EVALUATE ROW("Average", AVERAGE(revenue_details[dollar_value]))
----
"""
toolkit = PowerBIToolkit(
    powerbi=PowerBIDataset(
        dataset_id="<dataset_id>",
        table_names=["table1", "table2"],
        credential=DefaultAzureCredential(),
    ),
    llm=smart_llm,
    examples=few_shots,
)
agent_executor = create_pbi_agent(
    llm=fast_llm,
    toolkit=toolkit,
    verbose=True,
)
```


```python
agent_executor.run("What was the maximum of value in revenue in dollars in 2022?")
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)