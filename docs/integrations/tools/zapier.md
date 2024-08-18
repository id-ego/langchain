---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/zapier.ipynb
description: Zapier 자연어 액션 API는 5,000개 이상의 앱과 20,000개 이상의 작업에 접근할 수 있는 자연어 인터페이스를
  제공합니다.
---

# Zapier 자연어 작업

**사용 중단 예정** 이 API는 2023-11-17에 종료됩니다: https://nla.zapier.com/start/

> [Zapier 자연어 작업](https://nla.zapier.com/start/)은 자연어 API 인터페이스를 통해 Zapier 플랫폼의 5천 개 이상의 앱과 2만 개 이상의 작업에 접근할 수 있게 해줍니다.
> 
> NLA는 `Gmail`, `Salesforce`, `Trello`, `Slack`, `Asana`, `HubSpot`, `Google Sheets`, `Microsoft Teams`와 같은 앱을 지원하며, 그 외에도 수천 개의 앱을 지원합니다: https://zapier.com/apps  
`Zapier NLA`는 모든 기본 API 인증 및 자연어 --> 기본 API 호출 --> LLM을 위한 단순화된 출력 반환을 처리합니다. 핵심 아이디어는 여러분 또는 여러분의 사용자가 oauth와 유사한 설정 창을 통해 일련의 작업을 노출하고, 이를 REST API를 통해 쿼리하고 실행할 수 있다는 것입니다.

NLA는 NLA API 요청 서명을 위한 API 키와 OAuth를 모두 제공합니다.

1. 서버 측 (API 키): 빠르게 시작하고, 테스트하며, LangChain이 개발자의 Zapier 계정에 노출된 작업만 사용할 경우의 프로덕션 시나리오에 적합합니다 (그리고 개발자의 Zapier.com 연결 계정을 사용합니다).
2. 사용자 대상 (Oauth): 최종 사용자 대상 애플리케이션을 배포하는 프로덕션 시나리오에서 LangChain이 최종 사용자의 노출된 작업 및 Zapier.com의 연결 계정에 접근해야 할 경우에 적합합니다.

이 빠른 시작 가이드는 간결함을 위해 주로 서버 측 사용 사례에 중점을 두고 있습니다. 사용자 대상 상황에 대한 Zapier 설정 방법의 짧은 예제를 보려면 [OAuth 액세스 토큰 사용 예제](#oauth)로 건너뛰십시오. 전체 사용자 대상 oauth 개발자 지원을 보려면 [전체 문서](https://nla.zapier.com/start/)를 검토하십시오.

이 예제는 `SimpleSequentialChain`과 `Agent`와 함께 Zapier 통합을 사용하는 방법을 다룹니다. 코드 아래:

```python
import os

# get from https://platform.openai.com/
os.environ["OPENAI_API_KEY"] = os.environ.get("OPENAI_API_KEY", "")

# get from https://nla.zapier.com/docs/authentication/ after logging in):
os.environ["ZAPIER_NLA_API_KEY"] = os.environ.get("ZAPIER_NLA_API_KEY", "")
```


## 에이전트와 함께하는 예제
Zapier 도구는 에이전트와 함께 사용할 수 있습니다. 아래 예제를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Zapier Natural Language Actions"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Zapier Natural Language Actions"}, {"imported": "ZapierToolkit", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.zapier.toolkit.ZapierToolkit.html", "title": "Zapier Natural Language Actions"}, {"imported": "ZapierNLAWrapper", "source": "langchain_community.utilities.zapier", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.zapier.ZapierNLAWrapper.html", "title": "Zapier Natural Language Actions"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Zapier Natural Language Actions"}]-->
from langchain.agents import AgentType, initialize_agent
from langchain_community.agent_toolkits import ZapierToolkit
from langchain_community.utilities.zapier import ZapierNLAWrapper
from langchain_openai import OpenAI
```


```python
## step 0. expose gmail 'find email' and slack 'send channel message' actions

# first go here, log in, expose (enable) the two actions: https://nla.zapier.com/demo/start -- for this example, can leave all fields "Have AI guess"
# in an oauth scenario, you'd get your own <provider> id (instead of 'demo') which you route your users through first
```


```python
llm = OpenAI(temperature=0)
zapier = ZapierNLAWrapper()
toolkit = ZapierToolkit.from_zapier_nla_wrapper(zapier)
agent = initialize_agent(
    toolkit.get_tools(), llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)
```


```python
agent.run(
    "Summarize the last email I received regarding Silicon Valley Bank. Send the summary to the #test-zapier channel in slack."
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m I need to find the email and summarize it.
Action: Gmail: Find Email
Action Input: Find the latest email from Silicon Valley Bank[0m
Observation: [31;1m[1;3m{"from__name": "Silicon Valley Bridge Bank, N.A.", "from__email": "sreply@svb.com", "body_plain": "Dear Clients, After chaotic, tumultuous & stressful days, we have clarity on path for SVB, FDIC is fully insuring all deposits & have an ask for clients & partners as we rebuild. Tim Mayopoulos <https://eml.svb.com/NjEwLUtBSy0yNjYAAAGKgoxUeBCLAyF_NxON97X4rKEaNBLG", "reply_to__email": "sreply@svb.com", "subject": "Meet the new CEO Tim Mayopoulos", "date": "Tue, 14 Mar 2023 23:42:29 -0500 (CDT)", "message_url": "https://mail.google.com/mail/u/0/#inbox/186e393b13cfdf0a", "attachment_count": "0", "to__emails": "ankush@langchain.dev", "message_id": "186e393b13cfdf0a", "labels": "IMPORTANT, CATEGORY_UPDATES, INBOX"}[0m
Thought:[32;1m[1;3m I need to summarize the email and send it to the #test-zapier channel in Slack.
Action: Slack: Send Channel Message
Action Input: Send a slack message to the #test-zapier channel with the text "Silicon Valley Bank has announced that Tim Mayopoulos is the new CEO. FDIC is fully insuring all deposits and they have an ask for clients and partners as they rebuild."[0m
Observation: [36;1m[1;3m{"message__text": "Silicon Valley Bank has announced that Tim Mayopoulos is the new CEO. FDIC is fully insuring all deposits and they have an ask for clients and partners as they rebuild.", "message__permalink": "https://langchain.slack.com/archives/C04TSGU0RA7/p1678859932375259", "channel": "C04TSGU0RA7", "message__bot_profile__name": "Zapier", "message__team": "T04F8K3FZB5", "message__bot_id": "B04TRV4R74K", "message__bot_profile__deleted": "false", "message__bot_profile__app_id": "A024R9PQM", "ts_time": "2023-03-15T05:58:52Z", "message__bot_profile__icons__image_36": "https://avatars.slack-edge.com/2022-08-02/3888649620612_f864dc1bb794cf7d82b0_36.png", "message__blocks[]block_id": "kdZZ", "message__blocks[]elements[]type": "['rich_text_section']"}[0m
Thought:[32;1m[1;3m I now know the final answer.
Final Answer: I have sent a summary of the last email from Silicon Valley Bank to the #test-zapier channel in Slack.[0m

[1m> Finished chain.[0m
```


```output
'I have sent a summary of the last email from Silicon Valley Bank to the #test-zapier channel in Slack.'
```


## SimpleSequentialChain과 함께하는 예제
더 명시적인 제어가 필요하다면, 아래와 같은 체인을 사용하십시오.

```python
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "Zapier Natural Language Actions"}, {"imported": "SimpleSequentialChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.sequential.SimpleSequentialChain.html", "title": "Zapier Natural Language Actions"}, {"imported": "TransformChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.transform.TransformChain.html", "title": "Zapier Natural Language Actions"}, {"imported": "ZapierNLARunAction", "source": "langchain_community.tools.zapier.tool", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.zapier.tool.ZapierNLARunAction.html", "title": "Zapier Natural Language Actions"}, {"imported": "ZapierNLAWrapper", "source": "langchain_community.utilities.zapier", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.zapier.ZapierNLAWrapper.html", "title": "Zapier Natural Language Actions"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "Zapier Natural Language Actions"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Zapier Natural Language Actions"}]-->
from langchain.chains import LLMChain, SimpleSequentialChain, TransformChain
from langchain_community.tools.zapier.tool import ZapierNLARunAction
from langchain_community.utilities.zapier import ZapierNLAWrapper
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI
```


```python
## step 0. expose gmail 'find email' and slack 'send direct message' actions

# first go here, log in, expose (enable) the two actions: https://nla.zapier.com/demo/start -- for this example, can leave all fields "Have AI guess"
# in an oauth scenario, you'd get your own <provider> id (instead of 'demo') which you route your users through first

actions = ZapierNLAWrapper().list()
```


```python
## step 1. gmail find email

GMAIL_SEARCH_INSTRUCTIONS = "Grab the latest email from Silicon Valley Bank"


def nla_gmail(inputs):
    action = next(
        (a for a in actions if a["description"].startswith("Gmail: Find Email")), None
    )
    return {
        "email_data": ZapierNLARunAction(
            action_id=action["id"],
            zapier_description=action["description"],
            params_schema=action["params"],
        ).run(inputs["instructions"])
    }


gmail_chain = TransformChain(
    input_variables=["instructions"],
    output_variables=["email_data"],
    transform=nla_gmail,
)
```


```python
## step 2. generate draft reply

template = """You are an assisstant who drafts replies to an incoming email. Output draft reply in plain text (not JSON).

Incoming email:
{email_data}

Draft email reply:"""

prompt_template = PromptTemplate(input_variables=["email_data"], template=template)
reply_chain = LLMChain(llm=OpenAI(temperature=0.7), prompt=prompt_template)
```


```python
## step 3. send draft reply via a slack direct message

SLACK_HANDLE = "@Ankush Gola"


def nla_slack(inputs):
    action = next(
        (
            a
            for a in actions
            if a["description"].startswith("Slack: Send Direct Message")
        ),
        None,
    )
    instructions = f'Send this to {SLACK_HANDLE} in Slack: {inputs["draft_reply"]}'
    return {
        "slack_data": ZapierNLARunAction(
            action_id=action["id"],
            zapier_description=action["description"],
            params_schema=action["params"],
        ).run(instructions)
    }


slack_chain = TransformChain(
    input_variables=["draft_reply"],
    output_variables=["slack_data"],
    transform=nla_slack,
)
```


```python
## finally, execute

overall_chain = SimpleSequentialChain(
    chains=[gmail_chain, reply_chain, slack_chain], verbose=True
)
overall_chain.run(GMAIL_SEARCH_INSTRUCTIONS)
```

```output


[1m> Entering new SimpleSequentialChain chain...[0m
[36;1m[1;3m{"from__name": "Silicon Valley Bridge Bank, N.A.", "from__email": "sreply@svb.com", "body_plain": "Dear Clients, After chaotic, tumultuous & stressful days, we have clarity on path for SVB, FDIC is fully insuring all deposits & have an ask for clients & partners as we rebuild. Tim Mayopoulos <https://eml.svb.com/NjEwLUtBSy0yNjYAAAGKgoxUeBCLAyF_NxON97X4rKEaNBLG", "reply_to__email": "sreply@svb.com", "subject": "Meet the new CEO Tim Mayopoulos", "date": "Tue, 14 Mar 2023 23:42:29 -0500 (CDT)", "message_url": "https://mail.google.com/mail/u/0/#inbox/186e393b13cfdf0a", "attachment_count": "0", "to__emails": "ankush@langchain.dev", "message_id": "186e393b13cfdf0a", "labels": "IMPORTANT, CATEGORY_UPDATES, INBOX"}[0m
[33;1m[1;3m
Dear Silicon Valley Bridge Bank, 

Thank you for your email and the update regarding your new CEO Tim Mayopoulos. We appreciate your dedication to keeping your clients and partners informed and we look forward to continuing our relationship with you. 

Best regards, 
[Your Name][0m
[38;5;200m[1;3m{"message__text": "Dear Silicon Valley Bridge Bank, \n\nThank you for your email and the update regarding your new CEO Tim Mayopoulos. We appreciate your dedication to keeping your clients and partners informed and we look forward to continuing our relationship with you. \n\nBest regards, \n[Your Name]", "message__permalink": "https://langchain.slack.com/archives/D04TKF5BBHU/p1678859968241629", "channel": "D04TKF5BBHU", "message__bot_profile__name": "Zapier", "message__team": "T04F8K3FZB5", "message__bot_id": "B04TRV4R74K", "message__bot_profile__deleted": "false", "message__bot_profile__app_id": "A024R9PQM", "ts_time": "2023-03-15T05:59:28Z", "message__blocks[]block_id": "p7i", "message__blocks[]elements[]elements[]type": "[['text']]", "message__blocks[]elements[]type": "['rich_text_section']"}[0m

[1m> Finished chain.[0m
```


```output
'{"message__text": "Dear Silicon Valley Bridge Bank, \\n\\nThank you for your email and the update regarding your new CEO Tim Mayopoulos. We appreciate your dedication to keeping your clients and partners informed and we look forward to continuing our relationship with you. \\n\\nBest regards, \\n[Your Name]", "message__permalink": "https://langchain.slack.com/archives/D04TKF5BBHU/p1678859968241629", "channel": "D04TKF5BBHU", "message__bot_profile__name": "Zapier", "message__team": "T04F8K3FZB5", "message__bot_id": "B04TRV4R74K", "message__bot_profile__deleted": "false", "message__bot_profile__app_id": "A024R9PQM", "ts_time": "2023-03-15T05:59:28Z", "message__blocks[]block_id": "p7i", "message__blocks[]elements[]elements[]type": "[[\'text\']]", "message__blocks[]elements[]type": "[\'rich_text_section\']"}'
```


## <a id="oauth">OAuth 액세스 토큰 사용 예제</a>
아래 스니펫은 조달된 OAuth 액세스 토큰으로 래퍼를 초기화하는 방법을 보여줍니다. 환경 변수를 설정하는 대신 전달되는 인수를 주목하십시오. 전체 사용자 대상 oauth 개발자 지원을 보려면 [인증 문서](https://nla.zapier.com/docs/authentication/#oauth-credentials)를 검토하십시오.

개발자는 액세스 토큰을 조달하고 갱신하기 위해 OAuth 핸드셰이킹을 처리하는 임무를 맡고 있습니다.

```python
llm = OpenAI(temperature=0)
zapier = ZapierNLAWrapper(zapier_nla_oauth_access_token="<fill in access token here>")
toolkit = ZapierToolkit.from_zapier_nla_wrapper(zapier)
agent = initialize_agent(
    toolkit.get_tools(), llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)

agent.run(
    "Summarize the last email I received regarding Silicon Valley Bank. Send the summary to the #test-zapier channel in slack."
)
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)