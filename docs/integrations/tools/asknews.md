---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/asknews.ipynb
description: AskNews는 최신 글로벌 뉴스와 역사적 뉴스를 LLM에 통합하여 자연어 쿼리로 정보를 제공합니다. 300k 기사 이상을
  매일 처리합니다.
---

# AskNews

> [AskNews](https://asknews.app)는 단일 자연어 쿼리를 사용하여 최신 글로벌 뉴스(또는 역사적 뉴스)를 모든 LLM에 주입합니다. 특히, AskNews는 300,000개 이상의 기사를 매일 번역, 요약, 개체 추출 및 핫 및 콜드 벡터 데이터베이스에 인덱싱하여 풍부하게 하고 있습니다. AskNews는 이러한 벡터 데이터베이스를 저지연 엔드포인트에 배치합니다. AskNews에 쿼리를 보내면, 가장 관련성 높은 풍부한 정보(예: 개체, 분류, 번역, 요약)를 포함하는 프롬프트 최적화 문자열을 반환받습니다. 이는 여러분이 자체 뉴스 RAG를 관리할 필요가 없으며, LLM에 뉴스 정보를 간결하게 전달하는 방법에 대해 걱정할 필요가 없음을 의미합니다. AskNews는 또한 투명성에 전념하고 있으며, 이는 우리의 보도가 수백 개 국가, 13개 언어 및 50,000개 출처에 걸쳐 모니터링되고 다양화되기 때문입니다. 출처 범위를 추적하고 싶다면, [투명성 대시보드](https://asknews.app/en/transparency)를 방문할 수 있습니다.

## 설정

통합은 `langchain-community` 패키지에 있습니다. 우리는 또한 `asknews` 패키지 자체를 설치해야 합니다.

```bash
pip install -U langchain-community asknews
```


AskNews API 자격 증명도 설정해야 하며, 이는 [AskNews 콘솔](https://my.asknews.app)에서 얻을 수 있습니다.

```python
import getpass
import os

os.environ["ASKNEWS_CLIENT_ID"] = getpass.getpass()
os.environ["ASKNEWS_CLIENT_SECRET"] = getpass.getpass()
```


## 사용법

여기서는 도구를 개별적으로 사용하는 방법을 보여줍니다.

```python
<!--IMPORTS:[{"imported": "AskNewsSearch", "source": "langchain_community.tools.asknews", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.asknews.tool.AskNewsSearch.html", "title": "AskNews"}]-->
from langchain_community.tools.asknews import AskNewsSearch

tool = AskNewsSearch(max_results=2)
tool.invoke({"query": "Effect of fed policy on tech sector"})
```


```output
"\n<doc>\n[1]:\ntitle: Market Awaits Comments From Key Fed Official\nsummary: The market is awaiting comments from Fed Governor Christopher Waller, but it's not expected to move markets significantly. The recent Consumer Price Index (CPI) report showed slimming inflation figures, leading to a conclusion that inflation is being curbed. This has led to a 'soft landing' narrative, causing bullish sentiment in the stock market, with the Dow, S&P 500, Nasdaq, and Russell 2000 indices near all-time highs. NVIDIA is set to report earnings next week, and despite its 95% year-to-date growth, it remains a Zacks Rank #1 (Strong Buy) stock. The article also mentions upcoming economic data releases, including New and Existing Home Sales, S&P flash PMI Services and Manufacturing, Durable Goods, and Weekly Jobless Claims.\nsource: Yahoo\npublished: May 17 2024 14:53\nOrganization: Nasdaq, Fed, NVIDIA, Zacks\nPerson: Christopher Waller\nEvent: Weekly Jobless Claims\nclassification: Business\nsentiment: 0\n</doc>\n\n<doc>\n[2]:\ntitle: US futures flat as Fed comments cool rate cut optimism\nsummary: US stock index futures remained flat on Thursday evening, following a weak finish on Wall Street, as Federal Reserve officials warned that bets on interest rate cuts were potentially premature. The Fed officials, including Atlanta Fed President Raphael Bostic, New York Fed President John Williams, and Cleveland Fed President Loretta Mester, stated that the central bank still needed more confidence to cut interest rates, and that the timing of the move remained uncertain. As a result, investors slightly trimmed their expectations for a September rate cut, and the S&P 500 and Nasdaq 100 indexes fell 0.2% and 0.3%, respectively. Meanwhile, Reddit surged 11% after announcing a partnership with OpenAI, while Take-Two Interactive and DXC Technology fell after issuing disappointing earnings guidance.\nsource: Yahoo\npublished: May 16 2024 20:08\nLocation: US, Wall Street\nDate: September, Thursday\nOrganization: Atlanta Fed, Cleveland Fed, New York Fed, Fed, Reddit, Take-Two Interactive, DXC Technology, OpenAI, Federal Reserve\nTitle: President\nPerson: Loretta Mester, Raphael Bostic, John Williams\nclassification: Business\nsentiment: 0\n</doc>\n"
```


## 체인

여기서는 에이전트의 일부로 사용하는 방법을 보여줍니다. 우리는 OpenAI Functions Agent를 사용하므로, 이를 위해 필요한 종속성을 설정하고 설치해야 합니다. 또한 프롬프트를 가져오기 위해 [LangSmith Hub](https://smith.langchain.com/hub)를 사용할 것이므로, 이를 설치해야 합니다.

```bash
pip install -U langchain-openai langchainhub
```


```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass()
```


```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "AskNews"}, {"imported": "create_openai_functions_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.openai_functions_agent.base.create_openai_functions_agent.html", "title": "AskNews"}, {"imported": "AskNewsSearch", "source": "langchain_community.tools.asknews", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.asknews.tool.AskNewsSearch.html", "title": "AskNews"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "AskNews"}]-->
from langchain import hub
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_community.tools.asknews import AskNewsSearch
from langchain_openai import ChatOpenAI

prompt = hub.pull("hwchase17/openai-functions-agent")
llm = ChatOpenAI(temperature=0)
asknews_tool = AskNewsSearch()
tools = [asknews_tool]
agent = create_openai_functions_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)
agent_executor.invoke({"input": "How is the tech sector being affected by fed policy?"})
```


```output
{'input': 'How is the tech sector being affected by fed policy?',
 'output': 'The tech sector is being affected by federal policy in various ways, particularly in relation to artificial intelligence (AI) regulation and investment. Here are some recent news articles related to the tech sector and federal policy:\n\n1. The US Senate has released a bipartisan AI policy roadmap, addressing areas of consensus and disagreement on AI use and development. The roadmap includes recommendations for intellectual property reforms, funding for AI research, sector-specific rules, and transparency requirements. It also emphasizes the need for increased funding for AI innovation and investments in national defense. [Source: The National Law Review]\n\n2. A bipartisan group of US senators, led by Senate Majority Leader Chuck Schumer, has proposed allocating at least $32 billion over the next three years to develop AI and establish safeguards around it. The proposal aims to regulate and promote AI development to maintain US competitiveness and improve quality of life. [Source: Cointelegraph]\n\n3. The US administration is planning to restrict the export of advanced AI models to prevent China and Russia from accessing the technology. This move is part of efforts to protect national security and prevent the misuse of AI by foreign powers. [Source: O Cafezinho]\n\n4. The US and China have discussed the risks of AI technologies, with the US taking the lead in the AI arms race. The US has proposed a $32 billion increase in federal spending on AI to maintain its lead, despite concerns about stifling innovation. [Source: AOL]\n\nThese articles highlight the ongoing discussions and actions related to AI regulation, investment, and export restrictions that are impacting the tech sector in response to federal policy decisions.'}
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)