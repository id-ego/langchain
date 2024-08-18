---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/google_finance.ipynb
description: 구글 파이낸스 도구를 사용하여 구글 파이낸스 페이지에서 정보를 얻는 방법을 다루는 노트북입니다.
---

# 구글 금융

이 노트북은 구글 금융 페이지에서 정보를 얻기 위해 구글 금융 도구를 사용하는 방법을 설명합니다.

SerpApi 키를 얻으려면 다음 링크에서 가입하세요: https://serpapi.com/users/sign_up.

그런 다음 다음 명령어로 google-search-results를 설치하세요: 

pip install google-search-results

그런 다음 환경 변수 SERPAPI_API_KEY를 귀하의 SerpApi 키로 설정하세요.

또는 래퍼에 인수로 키를 전달하세요: serp_api_key="your secret key"

도구 사용하기

```python
%pip install --upgrade --quiet  google-search-results langchain-community
```


```python
<!--IMPORTS:[{"imported": "GoogleFinanceQueryRun", "source": "langchain_community.tools.google_finance", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.google_finance.tool.GoogleFinanceQueryRun.html", "title": "Google Finance"}, {"imported": "GoogleFinanceAPIWrapper", "source": "langchain_community.utilities.google_finance", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.google_finance.GoogleFinanceAPIWrapper.html", "title": "Google Finance"}]-->
import os

from langchain_community.tools.google_finance import GoogleFinanceQueryRun
from langchain_community.utilities.google_finance import GoogleFinanceAPIWrapper

os.environ["SERPAPI_API_KEY"] = ""
tool = GoogleFinanceQueryRun(api_wrapper=GoogleFinanceAPIWrapper())
```


```python
tool.run("Google")
```


Langchain과 함께 사용하기

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Google Finance"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Google Finance"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "Google Finance"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Google Finance"}]-->
import os

from langchain.agents import AgentType, initialize_agent, load_tools
from langchain_openai import OpenAI

os.environ["OPENAI_API_KEY"] = ""
os.environ["SERP_API_KEY"] = ""
llm = OpenAI()
tools = load_tools(["google-scholar", "google-finance"], llm=llm)
agent = initialize_agent(
    tools, llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)
agent.run("what is google's stock")
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)