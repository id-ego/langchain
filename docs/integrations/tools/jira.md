---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/jira.ipynb
description: 이 문서는 Jira 툴킷 사용 방법을 설명하며, 이슈 검색 및 생성 등의 작업을 수행하는 방법을 안내합니다.
---

# Jira 툴킷

이 노트북은 `Jira` 툴킷을 사용하는 방법에 대해 설명합니다.

`Jira` 툴킷은 에이전트가 주어진 Jira 인스턴스와 상호작용할 수 있도록 하며, 이슈 검색 및 이슈 생성과 같은 작업을 수행합니다. 이 도구는 atlassian-python-api 라이브러리를 래핑하고 있습니다. 자세한 내용은 다음을 참조하세요: https://atlassian-python-api.readthedocs.io/jira.html

이 도구를 사용하려면 먼저 환경 변수로 설정해야 합니다:
JIRA_API_TOKEN  
JIRA_USERNAME  
JIRA_INSTANCE_URL  
JIRA_CLOUD  

```python
%pip install --upgrade --quiet  atlassian-python-api
```


```python
%pip install -qU langchain-community
```


```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Jira Toolkit"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Jira Toolkit"}, {"imported": "JiraToolkit", "source": "langchain_community.agent_toolkits.jira.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.jira.toolkit.JiraToolkit.html", "title": "Jira Toolkit"}, {"imported": "JiraAPIWrapper", "source": "langchain_community.utilities.jira", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.jira.JiraAPIWrapper.html", "title": "Jira Toolkit"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Jira Toolkit"}]-->
import os

from langchain.agents import AgentType, initialize_agent
from langchain_community.agent_toolkits.jira.toolkit import JiraToolkit
from langchain_community.utilities.jira import JiraAPIWrapper
from langchain_openai import OpenAI
```


```python
os.environ["JIRA_API_TOKEN"] = "abc"
os.environ["JIRA_USERNAME"] = "123"
os.environ["JIRA_INSTANCE_URL"] = "https://jira.atlassian.com"
os.environ["OPENAI_API_KEY"] = "xyz"
os.environ["JIRA_CLOUD"] = "True"
```


```python
llm = OpenAI(temperature=0)
jira = JiraAPIWrapper()
toolkit = JiraToolkit.from_jira_api_wrapper(jira)
agent = initialize_agent(
    toolkit.get_tools(), llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)
```


```python
agent.run("make a new issue in project PW to remind me to make more fried rice")
```
  
```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m I need to create an issue in project PW
Action: Create Issue
Action Input: {"summary": "Make more fried rice", "description": "Reminder to make more fried rice", "issuetype": {"name": "Task"}, "priority": {"name": "Low"}, "project": {"key": "PW"}}[0m
Observation: [38;5;200m[1;3mNone[0m
Thought:[32;1m[1;3m I now know the final answer
Final Answer: A new issue has been created in project PW with the summary "Make more fried rice" and description "Reminder to make more fried rice".[0m

[1m> Finished chain.[0m
```


```output
'A new issue has been created in project PW with the summary "Make more fried rice" and description "Reminder to make more fried rice".'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)  
- 도구 [사용 방법 가이드](/docs/how_to/#tools)