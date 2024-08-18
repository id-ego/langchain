---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/passio_nutrition_ai.ipynb
description: NutritionAI를 활용하여 음식 영양 정보를 찾는 에이전트를 구축하는 방법을 안내하는 문서입니다.
---

# Passio NutritionAI

NutritionAI가 귀하의 에이전트에게 슈퍼 음식 영양력을 부여하는 방법을 가장 잘 이해하기 위해, Passio NutritionAI를 통해 해당 정보를 찾을 수 있는 에이전트를 구축해 보겠습니다.

## 도구 정의

먼저 [Passio NutritionAI 도구](/docs/integrations/tools/passio_nutrition_ai)를 생성해야 합니다.

### [Passio Nutrition AI](/docs/integrations/tools/passio_nutrition_ai)

우리는 LangChain에 내장된 도구를 사용하여 Passio NutritionAI를 쉽게 사용하여 음식 영양 정보를 찾을 수 있습니다. 이 작업에는 API 키가 필요합니다 - 무료 요금제가 있습니다.

API 키를 생성한 후, 다음과 같이 내보내야 합니다:

```bash
export NUTRITIONAI_SUBSCRIPTION_KEY="..."
```


... 또는 `dotenv` 패키지와 같은 다른 방법을 통해 Python 환경에 제공해야 합니다. 생성자 호출을 통해 키를 명시적으로 제어할 수도 있습니다.

```python
<!--IMPORTS:[{"imported": "get_from_env", "source": "langchain_core.utils", "docs": "https://api.python.langchain.com/en/latest/utils/langchain_core.utils.env.get_from_env.html", "title": "Passio NutritionAI"}]-->
from dotenv import load_dotenv
from langchain_core.utils import get_from_env

load_dotenv()

nutritionai_subscription_key = get_from_env(
    "nutritionai_subscription_key", "NUTRITIONAI_SUBSCRIPTION_KEY"
)
```


```python
<!--IMPORTS:[{"imported": "NutritionAI", "source": "langchain_community.tools.passio_nutrition_ai", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.passio_nutrition_ai.tool.NutritionAI.html", "title": "Passio NutritionAI"}, {"imported": "NutritionAIAPI", "source": "langchain_community.utilities.passio_nutrition_ai", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.passio_nutrition_ai.NutritionAIAPI.html", "title": "Passio NutritionAI"}]-->
from langchain_community.tools.passio_nutrition_ai import NutritionAI
from langchain_community.utilities.passio_nutrition_ai import NutritionAIAPI
```


```python
nutritionai_search = NutritionAI(api_wrapper=NutritionAIAPI())
```


```python
nutritionai_search.invoke("chicken tikka masala")
```


```python
nutritionai_search.invoke("Schnuck Markets sliced pepper jack cheese")
```


### 도구

이제 도구를 확보했으므로, 하류에서 사용할 도구 목록을 생성할 수 있습니다.

```python
tools = [nutritionai_search]
```


## 에이전트 생성

도구를 정의했으므로 이제 에이전트를 생성할 수 있습니다. OpenAI Functions 에이전트를 사용할 것입니다 - 이 유형의 에이전트 및 기타 옵션에 대한 자세한 내용은 [이 가이드](/docs/concepts#agents)를 참조하십시오.

먼저, 에이전트를 안내할 LLM을 선택합니다.

```python
<!--IMPORTS:[{"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Passio NutritionAI"}]-->
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
```


다음으로, 에이전트를 안내할 프롬프트를 선택합니다.

```python
from langchain import hub

# Get the prompt to use - you can modify this!
prompt = hub.pull("hwchase17/openai-functions-agent")
prompt.messages
```


```output
[SystemMessagePromptTemplate(prompt=PromptTemplate(input_variables=[], template='You are a helpful assistant')),
 MessagesPlaceholder(variable_name='chat_history', optional=True),
 HumanMessagePromptTemplate(prompt=PromptTemplate(input_variables=['input'], template='{input}')),
 MessagesPlaceholder(variable_name='agent_scratchpad')]
```


이제 LLM, 프롬프트 및 도구로 에이전트를 초기화할 수 있습니다. 에이전트는 입력을 받아들이고 어떤 작업을 수행할지 결정하는 책임이 있습니다. 중요한 점은 에이전트가 이러한 작업을 실행하지 않는다는 것입니다 - 이는 AgentExecutor(다음 단계)가 수행합니다. 이러한 구성 요소에 대해 생각하는 방법에 대한 자세한 내용은 [개념 가이드](/docs/concepts#agents)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "create_openai_functions_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.openai_functions_agent.base.create_openai_functions_agent.html", "title": "Passio NutritionAI"}]-->
from langchain.agents import create_openai_functions_agent

agent = create_openai_functions_agent(llm, tools, prompt)
```


마지막으로, 에이전트(두뇌)와 도구를 AgentExecutor 내에서 결합합니다(이는 에이전트를 반복적으로 호출하고 도구를 실행합니다). 이러한 구성 요소에 대해 생각하는 방법에 대한 자세한 내용은 [개념 가이드](/docs/concepts#agents)를 참조하십시오.

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Passio NutritionAI"}]-->
from langchain.agents import AgentExecutor

agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
```


## 에이전트 실행

이제 몇 가지 쿼리에 대해 에이전트를 실행할 수 있습니다! 현재로서는 모두 **무상태** 쿼리입니다(이전 상호작용을 기억하지 않습니다).

```python
agent_executor.invoke({"input": "hi!"})
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mHello! How can I assist you today?[0m

[1m> Finished chain.[0m
```


```output
{'input': 'hi!', 'output': 'Hello! How can I assist you today?'}
```


```python
agent_executor.invoke({"input": "how many calories are in a slice pepperoni pizza?"})
```


이 메시지를 자동으로 추적하려면, 이를 RunnableWithMessageHistory로 감쌀 수 있습니다. 이를 사용하는 방법에 대한 자세한 내용은 [이 가이드](/docs/how_to/message_history)를 참조하십시오.

```python
agent_executor.invoke(
    {"input": "I had bacon and eggs for breakfast.  How many calories is that?"}
)
```


```python
agent_executor.invoke(
    {
        "input": "I had sliced pepper jack cheese for a snack.  How much protein did I have?"
    }
)
```


```python
agent_executor.invoke(
    {
        "input": "I had sliced colby cheese for a snack. Give me calories for this Schnuck Markets product."
    }
)
```


```python
agent_executor.invoke(
    {
        "input": "I had chicken tikka masala for dinner.  how much calories, protein, and fat did I have with default quantity?"
    }
)
```


## 결론

이제 마무리되었습니다! 이 빠른 시작에서는 음식 영양 정보를 답변에 통합할 수 있는 간단한 에이전트를 만드는 방법을 다루었습니다. 에이전트는 복잡한 주제이며, 배울 것이 많습니다!

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)