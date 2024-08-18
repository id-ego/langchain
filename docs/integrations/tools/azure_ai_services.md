---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/azure_ai_services.ipynb
description: Azure AI 서비스 API와 상호작용하여 이미지 분석, 문서 인식, 음성 변환 등 다양한 멀티모달 기능을 제공하는 툴킷입니다.
---

# Azure AI Services Toolkit

이 툴킷은 `Azure AI Services API`와 상호작용하여 몇 가지 다중 모드 기능을 달성하는 데 사용됩니다.

현재 이 툴킷에는 다섯 가지 도구가 포함되어 있습니다:
- **AzureAiServicesImageAnalysisTool**: 이미지에서 캡션, 객체, 태그 및 텍스트를 추출하는 데 사용됩니다.
- **AzureAiServicesDocumentIntelligenceTool**: 문서에서 텍스트, 표 및 키-값 쌍을 추출하는 데 사용됩니다.
- **AzureAiServicesSpeechToTextTool**: 음성을 텍스트로 전사하는 데 사용됩니다.
- **AzureAiServicesTextToSpeechTool**: 텍스트를 음성으로 합성하는 데 사용됩니다.
- **AzureAiServicesTextAnalyticsForHealthTool**: 의료 관련 엔티티를 추출하는 데 사용됩니다.

먼저, Azure 계정을 설정하고 AI Services 리소스를 생성해야 합니다. 리소스를 생성하는 방법에 대한 지침은 [여기](https://learn.microsoft.com/en-us/azure/ai-services/multi-service-resource)를 참조하십시오.

그런 다음, 리소스의 엔드포인트, 키 및 지역을 가져와 환경 변수로 설정해야 합니다. 이 정보는 리소스의 "Keys and Endpoint" 페이지에서 찾을 수 있습니다.

```python
%pip install --upgrade --quiet  azure-ai-formrecognizer > /dev/null
%pip install --upgrade --quiet  azure-cognitiveservices-speech > /dev/null
%pip install --upgrade --quiet  azure-ai-textanalytics > /dev/null
%pip install --upgrade --quiet  azure-ai-vision-imageanalysis > /dev/null
%pip install -qU langchain-community
```


```python
import os

os.environ["OPENAI_API_KEY"] = "sk-"
os.environ["AZURE_AI_SERVICES_KEY"] = ""
os.environ["AZURE_AI_SERVICES_ENDPOINT"] = ""
os.environ["AZURE_AI_SERVICES_REGION"] = ""
```


## 툴킷 생성

```python
<!--IMPORTS:[{"imported": "AzureAiServicesToolkit", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.azure_ai_services.AzureAiServicesToolkit.html", "title": "Azure AI Services Toolkit"}]-->
from langchain_community.agent_toolkits import AzureAiServicesToolkit

toolkit = AzureAiServicesToolkit()
```


```python
[tool.name for tool in toolkit.get_tools()]
```


```output
['azure_ai_services_document_intelligence',
 'azure_ai_services_image_analysis',
 'azure_ai_services_speech_to_text',
 'azure_ai_services_text_to_speech',
 'azure_ai_services_text_analytics_for_health']
```


## 에이전트 내에서 사용

```python
<!--IMPORTS:[{"imported": "AgentExecutor", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent.AgentExecutor.html", "title": "Azure AI Services Toolkit"}, {"imported": "create_structured_chat_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.structured_chat.base.create_structured_chat_agent.html", "title": "Azure AI Services Toolkit"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Azure AI Services Toolkit"}]-->
from langchain import hub
from langchain.agents import AgentExecutor, create_structured_chat_agent
from langchain_openai import OpenAI
```


```python
llm = OpenAI(temperature=0)
tools = toolkit.get_tools()
prompt = hub.pull("hwchase17/structured-chat-agent")
agent = create_structured_chat_agent(llm, tools, prompt)

agent_executor = AgentExecutor(
    agent=agent, tools=tools, verbose=True, handle_parsing_errors=True
)
```


```python
agent_executor.invoke(
    {
        "input": "What can I make with these ingredients? "
        + "https://images.openai.com/blob/9ad5a2ab-041f-475f-ad6a-b51899c50182/ingredients.png"
    }
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Thought: I need to use the azure_ai_services_image_analysis tool to analyze the image of the ingredients.
Action:
```

{
"action": "azure_ai_services_image_analysis",
"action_input": "https://images.openai.com/blob/9ad5a2ab-041f-475f-ad6a-b51899c50182/ingredients.png"
}
```
[0m[33;1m[1;3mCaption: a group of eggs and flour in bowls
Objects: Egg, Egg, Food
Tags: dairy, ingredient, indoor, thickening agent, food, mixing bowl, powder, flour, egg, bowl[0m[32;1m[1;3m
Action:
```

{
"action": "Final Answer",
"action_input": "이 재료로 케이크나 기타 구운 제품을 만들 수 있습니다."
}
```

[0m

[1m> Finished chain.[0m
```


```output
{'input': 'What can I make with these ingredients? https://images.openai.com/blob/9ad5a2ab-041f-475f-ad6a-b51899c50182/ingredients.png',
 'output': 'You can make a cake or other baked goods with these ingredients.'}
```


```python
tts_result = agent_executor.invoke({"input": "Tell me a joke and read it out for me."})
audio_file = tts_result.get("output")
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Thought: I can use the Azure AI Services Text to Speech API to convert text to speech.
Action:
```

{
"action": "azure_ai_services_text_to_speech",
"action_input": "과학자들이 원자를 믿지 않는 이유는 무엇일까요? 그들은 모든 것을 구성하기 때문입니다."
}
```
[0m[36;1m[1;3m/tmp/tmpe48vamz0.wav[0m
[32;1m[1;3m[0m

[1m> Finished chain.[0m
```


```python
from IPython import display

audio = display.Audio(data=audio_file, autoplay=True, rate=22050)
display.display(audio)
```


```python
sample_input = """
The patient is a 54-year-old gentleman with a history of progressive angina over the past several months.
The patient had a cardiac catheterization in July of this year revealing total occlusion of the RCA and 50% left main disease ,
with a strong family history of coronary artery disease with a brother dying at the age of 52 from a myocardial infarction and
another brother who is status post coronary artery bypass grafting. The patient had a stress echocardiogram done on July , 2001 ,
which showed no wall motion abnormalities , but this was a difficult study due to body habitus. The patient went for six minutes with
minimal ST depressions in the anterior lateral leads , thought due to fatigue and wrist pain , his anginal equivalent. Due to the patient's
increased symptoms and family history and history left main disease with total occasional of his RCA was referred for revascularization with open heart surgery.

List all the diagnoses.
"""

agent_executor.invoke({"input": sample_input})
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Thought: The patient has a history of progressive angina, a strong family history of coronary artery disease, and a previous cardiac catheterization revealing total occlusion of the RCA and 50% left main disease.
Action:
```

{
"action": "azure_ai_services_text_analytics_for_health",
"action_input": "환자는 지난 몇 달 동안 진행성 협심증 병력이 있는 54세 남성입니다. 환자는 올해 7월에 심장 카테터 삽입술을 받았으며, RCA의 완전 폐색과 50% 좌주간질환이 발견되었고, 52세에 심근경색으로 사망한 형과 관상동맥 우회 수술을 받은 또 다른 형이 있는 강한 가족력이 있습니다. 환자는 2001년 7월에 스트레스 심초음파 검사를 받았으며, 벽 운동 이상이 없었지만, 체형으로 인해 어려운 검사였습니다. 환자는 최소한의 ST 하강을 보이며 6분 동안 운동했으며, 이는 피로와 손목 통증으로 인한 협심증의 동등한 증상으로 생각됩니다. 환자의 증상이 증가하고 가족력 및 RCA의 완전 폐색으로 인해 개심 수술로 재관류를 위해 의뢰되었습니다."
[0m[33;1m[1;3m텍스트에는 다음과 같은 의료 관련 엔티티가 포함되어 있습니다: 54세는 나이 유형의 의료 엔티티, 남성은 성별 유형의 의료 엔티티, 진행성 협심증은 진단 유형의 의료 엔티티, 지난 몇 달은 시간 유형의 의료 엔티티, 심장 카테터 삽입술은 검사 이름 유형의 의료 엔티티, 올해 7월은 시간 유형의 의료 엔티티, 완전은 조건 한정자 유형의 의료 엔티티, 폐색은 증상 또는 징후 유형의 의료 엔티티, RCA는 신체 구조 유형의 의료 엔티티, 50은 측정 값 유형의 의료 엔티티, %는 측정 단위 유형의 의료 엔티티, 좌주간질환은 진단 유형의 의료 엔티티, 가족은 가족 관계 유형의 의료 엔티티, 관상동맥 질환은 진단 유형의 의료 엔티티, 형은 가족 관계 유형의 의료 엔티티, 사망은 진단 유형의 의료 엔티티, 52는 나이 유형의 의료 엔티티, 심근경색은 진단 유형의 의료 엔티티, 형은 가족 관계 유형의 의료 엔티티, 관상동맥 우회 수술은 치료 이름 유형의 의료 엔티티, 스트레스 심초음파 검사는 검사 이름 유형의 의료 엔티티, 2001년 7월은 시간 유형의 의료 엔티티, 벽 운동 이상은 증상 또는 징후 유형의 의료 엔티티, 체형은 증상 또는 징후 유형의 의료 엔티티, 6분은 시간 유형의 의료 엔티티, 최소한은 조건 한정자 유형의 의료 엔티티, 전측 외측 유도에서의 ST 하강은 증상 또는 징후 유형의 의료 엔티티, 피로는 증상 또는 징후 유형의 의료 엔티티, 손목 통증은 증상 또는 징후 유형의 의료 엔티티, 협심증은 증상 또는 징후 유형의 의료 엔티티, 증가된 것은 경과 유형의 의료 엔티티, 증상은 증상 또는 징후 유형의 의료 엔티티, 가족은 가족 관계 유형의 의료 엔티티, 좌주간질환은 진단 유형의 의료 엔티티, 간헐적인 것은 경과 유형의 의료 엔티티, RCA는 신체 구조 유형의 의료 엔티티, 재관류는 치료 이름 유형의 의료 엔티티, 개심 수술은 치료 이름 유형의 의료 엔티티[0m[32;1m[1;3m
Action:
```
{
  "action": "Final Answer",
  "action_input": "The patient's diagnoses include progressive angina, total occlusion of the RCA, 50% left main disease, coronary artery disease, myocardial infarction, and a family history of coronary artery disease."
}

[0m

[1m> Finished chain.[0m
```


```output
{'input': "\nThe patient is a 54-year-old gentleman with a history of progressive angina over the past several months.\nThe patient had a cardiac catheterization in July of this year revealing total occlusion of the RCA and 50% left main disease ,\nwith a strong family history of coronary artery disease with a brother dying at the age of 52 from a myocardial infarction and\nanother brother who is status post coronary artery bypass grafting. The patient had a stress echocardiogram done on July , 2001 ,\nwhich showed no wall motion abnormalities , but this was a difficult study due to body habitus. The patient went for six minutes with\nminimal ST depressions in the anterior lateral leads , thought due to fatigue and wrist pain , his anginal equivalent. Due to the patient's\nincreased symptoms and family history and history left main disease with total occasional of his RCA was referred for revascularization with open heart surgery.\n\nList all the diagnoses.\n",
 'output': "The patient's diagnoses include progressive angina, total occlusion of the RCA, 50% left main disease, coronary artery disease, myocardial infarction, and a family history of coronary artery disease."}
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)