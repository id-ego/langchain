---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/awslambda.ipynb
description: AWS Lambda는 서버 관리 없이 애플리케이션을 구축하고 실행할 수 있는 서버리스 컴퓨팅 서비스입니다. 코드 작성에 집중하세요.
---

# AWS Lambda

> [`Amazon AWS Lambda`](https://aws.amazon.com/pm/lambda/)는 `Amazon Web Services`(`AWS`)에서 제공하는 서버리스 컴퓨팅 서비스입니다. 이는 개발자가 서버를 프로비저닝하거나 관리하지 않고도 애플리케이션과 서비스를 구축하고 실행할 수 있도록 도와줍니다. 이 서버리스 아키텍처는 코드 작성 및 배포에 집중할 수 있게 해주며, AWS는 애플리케이션을 실행하는 데 필요한 인프라의 확장, 패치 및 관리를 자동으로 처리합니다.

이 노트북은 `AWS Lambda` 도구를 사용하는 방법에 대해 설명합니다.

에이전트에 제공된 도구 목록에 `AWS Lambda`를 포함하면, 필요에 따라 AWS 클라우드에서 실행 중인 코드를 호출할 수 있는 능력을 에이전트에 부여할 수 있습니다.

에이전트가 `AWS Lambda` 도구를 사용할 때, 문자열 유형의 인수를 제공하며, 이는 이벤트 매개변수를 통해 Lambda 함수로 전달됩니다.

먼저 `boto3` 파이썬 패키지를 설치해야 합니다.

```python
%pip install --upgrade --quiet  boto3 > /dev/null
%pip install --upgrade --quiet langchain-community
```


에이전트가 도구를 사용하려면, Lambda 함수의 논리와 일치하는 이름과 설명을 제공해야 합니다.

또한 함수의 이름도 제공해야 합니다.

이 도구는 사실상 boto3 라이브러리를 감싸는 래퍼에 불과하므로, 도구를 사용하기 위해서는 `aws configure`를 실행해야 합니다. 자세한 내용은 [여기](https://docs.aws.amazon.com/cli/index.html)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "AWS Lambda"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "AWS Lambda"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "AWS Lambda"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "AWS Lambda"}]-->
from langchain.agents import AgentType, initialize_agent, load_tools
from langchain_openai import OpenAI

llm = OpenAI(temperature=0)

tools = load_tools(
    ["awslambda"],
    awslambda_tool_name="email-sender",
    awslambda_tool_description="sends an email with the specified content to test@testing123.com",
    function_name="testFunction1",
)

agent = initialize_agent(
    tools, llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True
)

agent.run("Send an email to test@testing123.com saying hello world.")
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)