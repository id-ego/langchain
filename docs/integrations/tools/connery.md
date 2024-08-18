---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/connery.ipynb
description: Connery 툴킷을 사용하여 LangChain 에이전트에 Connery 액션을 통합하는 방법과 설치 및 설정 절차를 안내합니다.
---

# Connery Toolkit 및 도구

Connery 툴킷 및 도구를 사용하여 Connery Actions를 LangChain 에이전트에 통합할 수 있습니다.

## Connery란 무엇인가요?

Connery는 AI를 위한 오픈 소스 플러그인 인프라입니다.

Connery를 사용하면 일련의 액션으로 사용자 정의 플러그인을 쉽게 만들고 이를 LangChain 에이전트에 원활하게 통합할 수 있습니다. Connery는 런타임, 인증, 비밀 관리, 접근 관리, 감사 로그 및 기타 중요한 기능과 같은 중요한 측면을 처리합니다.

또한, 커뮤니티의 지원을 받는 Connery는 추가 편의를 위해 사용 가능한 다양한 오픈 소스 플러그인 컬렉션을 제공합니다.

Connery에 대해 더 알아보세요:

- GitHub: https://github.com/connery-io/connery
- 문서: https://docs.connery.io

## 설정

### 설치

Connery 도구를 사용하려면 `langchain_community` 패키지를 설치해야 합니다.

```python
%pip install -qU langchain-community
```


### 자격 증명

LangChain 에이전트에서 Connery Actions를 사용하려면 몇 가지 준비가 필요합니다:

1. [빠른 시작](https://docs.connery.io/docs/runner/quick-start/) 가이드를 사용하여 Connery 러너를 설정합니다.
2. 에이전트에서 사용하려는 액션이 포함된 모든 플러그인을 설치합니다.
3. 툴킷이 Connery 러너와 통신할 수 있도록 환경 변수 `CONNERY_RUNNER_URL` 및 `CONNERY_RUNNER_API_KEY`를 설정합니다.

```python
import getpass
import os

for key in ["CONNERY_RUNNER_URL", "CONNERY_RUNNER_API_KEY"]:
    if key not in os.environ:
        os.environ[key] = getpass.getpass(f"Please enter the value for {key}: ")
```


## 툴킷

아래 예제에서는 두 개의 Connery Actions를 사용하여 공개 웹페이지를 요약하고 요약을 이메일로 전송하는 에이전트를 생성합니다:

1. [요약](https://github.com/connery-io/summarization-plugin) 플러그인의 **공개 웹페이지 요약** 액션.
2. [Gmail](https://github.com/connery-io/gmail) 플러그인의 **이메일 전송** 액션.

이 예제의 LangSmith 추적을 [여기](https://smith.langchain.com/public/4af5385a-afe9-46f6-8a53-57fe2d63c5bc/r)에서 확인할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Connery Toolkit and Tools"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Connery Toolkit and Tools"}, {"imported": "ConneryToolkit", "source": "langchain_community.agent_toolkits.connery", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.connery.toolkit.ConneryToolkit.html", "title": "Connery Toolkit and Tools"}, {"imported": "ConneryService", "source": "langchain_community.tools.connery", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.connery.service.ConneryService.html", "title": "Connery Toolkit and Tools"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Connery Toolkit and Tools"}]-->
import os

from langchain.agents import AgentType, initialize_agent
from langchain_community.agent_toolkits.connery import ConneryToolkit
from langchain_community.tools.connery import ConneryService
from langchain_openai import ChatOpenAI

# Specify your Connery Runner credentials.
os.environ["CONNERY_RUNNER_URL"] = ""
os.environ["CONNERY_RUNNER_API_KEY"] = ""

# Specify OpenAI API key.
os.environ["OPENAI_API_KEY"] = ""

# Specify your email address to receive the email with the summary from example below.
recepient_email = "test@example.com"

# Create a Connery Toolkit with all the available actions from the Connery Runner.
connery_service = ConneryService()
connery_toolkit = ConneryToolkit.create_instance(connery_service)

# Use OpenAI Functions agent to execute the prompt using actions from the Connery Toolkit.
llm = ChatOpenAI(temperature=0)
agent = initialize_agent(
    connery_toolkit.get_tools(), llm, AgentType.OPENAI_FUNCTIONS, verbose=True
)
result = agent.run(
    f"""Make a short summary of the webpage http://www.paulgraham.com/vb.html in three sentences
and send it to {recepient_email}. Include the link to the webpage into the body of the email."""
)
print(result)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `CA72DFB0AB4DF6C830B43E14B0782F70` with `{'publicWebpageUrl': 'http://www.paulgraham.com/vb.html'}`


[0m[33;1m[1;3m{'summary': 'The author reflects on the concept of life being short and how having children made them realize the true brevity of life. They discuss how time can be converted into discrete quantities and how limited certain experiences are. The author emphasizes the importance of prioritizing and eliminating unnecessary things in life, as well as actively pursuing meaningful experiences. They also discuss the negative impact of getting caught up in online arguments and the need to be aware of how time is being spent. The author suggests pruning unnecessary activities, not waiting to do things that matter, and savoring the time one has.'}[0m[32;1m[1;3m
Invoking: `CABC80BB79C15067CA983495324AE709` with `{'recipient': 'test@example.com', 'subject': 'Summary of the webpage', 'body': 'Here is a short summary of the webpage http://www.paulgraham.com/vb.html:\n\nThe author reflects on the concept of life being short and how having children made them realize the true brevity of life. They discuss how time can be converted into discrete quantities and how limited certain experiences are. The author emphasizes the importance of prioritizing and eliminating unnecessary things in life, as well as actively pursuing meaningful experiences. They also discuss the negative impact of getting caught up in online arguments and the need to be aware of how time is being spent. The author suggests pruning unnecessary activities, not waiting to do things that matter, and savoring the time one has.\n\nYou can find the full webpage [here](http://www.paulgraham.com/vb.html).'}`


[0m[33;1m[1;3m{'messageId': '<2f04b00e-122d-c7de-c91e-e78e0c3276d6@gmail.com>'}[0m[32;1m[1;3mI have sent the email with the summary of the webpage to test@example.com. Please check your inbox.[0m

[1m> Finished chain.[0m
I have sent the email with the summary of the webpage to test@example.com. Please check your inbox.
```

참고: Connery Action은 구조화된 도구이므로 구조화된 도구를 지원하는 에이전트에서만 사용할 수 있습니다.

## 도구

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Connery Toolkit and Tools"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Connery Toolkit and Tools"}, {"imported": "ConneryService", "source": "langchain_community.tools.connery", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.connery.service.ConneryService.html", "title": "Connery Toolkit and Tools"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Connery Toolkit and Tools"}]-->
import os

from langchain.agents import AgentType, initialize_agent
from langchain_community.tools.connery import ConneryService
from langchain_openai import ChatOpenAI

# Specify your Connery Runner credentials.
os.environ["CONNERY_RUNNER_URL"] = ""
os.environ["CONNERY_RUNNER_API_KEY"] = ""

# Specify OpenAI API key.
os.environ["OPENAI_API_KEY"] = ""

# Specify your email address to receive the emails from examples below.
recepient_email = "test@example.com"

# Get the SendEmail action from the Connery Runner by ID.
connery_service = ConneryService()
send_email_action = connery_service.get_action("CABC80BB79C15067CA983495324AE709")
```


액션을 수동으로 실행합니다.

```python
manual_run_result = send_email_action.run(
    {
        "recipient": recepient_email,
        "subject": "Test email",
        "body": "This is a test email sent from Connery.",
    }
)
print(manual_run_result)
```


OpenAI Functions 에이전트를 사용하여 액션을 실행합니다.

이 예제의 LangSmith 추적을 [여기](https://smith.langchain.com/public/a37d216f-c121-46da-a428-0e09dc19b1dc/r)에서 확인할 수 있습니다.

```python
llm = ChatOpenAI(temperature=0)
agent = initialize_agent(
    [send_email_action], llm, AgentType.OPENAI_FUNCTIONS, verbose=True
)
agent_run_result = agent.run(
    f"Send an email to the {recepient_email} and say that I will be late for the meeting."
)
print(agent_run_result)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Invoking: `CABC80BB79C15067CA983495324AE709` with `{'recipient': 'test@example.com', 'subject': 'Late for Meeting', 'body': 'Dear Team,\n\nI wanted to inform you that I will be late for the meeting today. I apologize for any inconvenience caused. Please proceed with the meeting without me and I will join as soon as I can.\n\nBest regards,\n[Your Name]'}`


[0m[36;1m[1;3m{'messageId': '<d34a694d-50e0-3988-25da-e86b4c51d7a7@gmail.com>'}[0m[32;1m[1;3mI have sent an email to test@example.com informing them that you will be late for the meeting.[0m

[1m> Finished chain.[0m
I have sent an email to test@example.com informing them that you will be late for the meeting.
```

참고: Connery Action은 구조화된 도구이므로 구조화된 도구를 지원하는 에이전트에서만 사용할 수 있습니다.

## API 참조

모든 Connery 기능 및 구성에 대한 자세한 문서는 API 참조를 확인하세요:

- 툴킷: https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.connery.toolkit.ConneryToolkit.html
- 도구: https://api.python.langchain.com/en/latest/tools/langchain_community.tools.connery.service.ConneryService.html

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)