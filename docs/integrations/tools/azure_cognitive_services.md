---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/azure_cognitive_services.ipynb
description: Azure Cognitive Services Toolkit은 다양한 멀티모달 기능을 제공하는 API와 상호작용하는 도구 모음입니다.
---

# Azure Cognitive Services Toolkit

이 툴킷은 `Azure Cognitive Services API`와 상호작용하여 일부 다중 모드 기능을 달성하는 데 사용됩니다.

현재 이 툴킷에는 네 가지 도구가 포함되어 있습니다:
- AzureCogsImageAnalysisTool: 이미지에서 캡션, 객체, 태그 및 텍스트를 추출하는 데 사용됩니다. (참고: 이 도구는 `azure-ai-vision` 패키지에 대한 의존성으로 인해 현재 Mac OS에서는 사용할 수 없습니다. 이 패키지는 현재 Windows 및 Linux에서만 지원됩니다.)
- AzureCogsFormRecognizerTool: 문서에서 텍스트, 표 및 키-값 쌍을 추출하는 데 사용됩니다.
- AzureCogsSpeech2TextTool: 음성을 텍스트로 전사하는 데 사용됩니다.
- AzureCogsText2SpeechTool: 텍스트를 음성으로 합성하는 데 사용됩니다.
- AzureCogsTextAnalyticsHealthTool: 의료 엔티티를 추출하는 데 사용됩니다.

먼저, Azure 계정을 설정하고 Cognitive Services 리소스를 생성해야 합니다. 리소스를 생성하는 방법에 대한 지침은 [여기](https://docs.microsoft.com/en-us/azure/cognitive-services/cognitive-services-apis-create-account?tabs=multiservice%2Cwindows)를 참조하세요.

그런 다음, 리소스의 엔드포인트, 키 및 지역을 가져와 환경 변수로 설정해야 합니다. 이 정보는 리소스의 "키 및 엔드포인트" 페이지에서 찾을 수 있습니다.

```python
%pip install --upgrade --quiet  azure-ai-formrecognizer > /dev/null
%pip install --upgrade --quiet  azure-cognitiveservices-speech > /dev/null
%pip install --upgrade --quiet  azure-ai-textanalytics > /dev/null

# For Windows/Linux
%pip install --upgrade --quiet  azure-ai-vision > /dev/null
```


```python
%pip install -qU langchain-community
```


```python
import os

os.environ["OPENAI_API_KEY"] = "sk-"
os.environ["AZURE_COGS_KEY"] = ""
os.environ["AZURE_COGS_ENDPOINT"] = ""
os.environ["AZURE_COGS_REGION"] = ""
```


## 툴킷 생성

```python
<!--IMPORTS:[{"imported": "AzureCognitiveServicesToolkit", "source": "langchain_community.agent_toolkits", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.azure_cognitive_services.AzureCognitiveServicesToolkit.html", "title": "Azure Cognitive Services Toolkit"}]-->
from langchain_community.agent_toolkits import AzureCognitiveServicesToolkit

toolkit = AzureCognitiveServicesToolkit()
```


```python
[tool.name for tool in toolkit.get_tools()]
```


```output
['Azure Cognitive Services Image Analysis',
 'Azure Cognitive Services Form Recognizer',
 'Azure Cognitive Services Speech2Text',
 'Azure Cognitive Services Text2Speech']
```


## 에이전트 내에서 사용

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Azure Cognitive Services Toolkit"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Azure Cognitive Services Toolkit"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Azure Cognitive Services Toolkit"}]-->
from langchain.agents import AgentType, initialize_agent
from langchain_openai import OpenAI
```


```python
llm = OpenAI(temperature=0)
agent = initialize_agent(
    tools=toolkit.get_tools(),
    llm=llm,
    agent=AgentType.STRUCTURED_CHAT_ZERO_SHOT_REACT_DESCRIPTION,
    verbose=True,
)
```


```python
agent.run(
    "What can I make with these ingredients?"
    "https://images.openai.com/blob/9ad5a2ab-041f-475f-ad6a-b51899c50182/ingredients.png"
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Action:
```

{
"action": "Azure Cognitive Services Image Analysis",
"action_input": "https://images.openai.com/blob/9ad5a2ab-041f-475f-ad6a-b51899c50182/ingredients.png"
}
```

[0m
Observation: [36;1m[1;3mCaption: a group of eggs and flour in bowls
Objects: Egg, Egg, Food
Tags: dairy, ingredient, indoor, thickening agent, food, mixing bowl, powder, flour, egg, bowl[0m
Thought:[32;1m[1;3m I can use the objects and tags to suggest recipes
Action:
```

{
"action": "Final Answer",
"action_input": "이 재료로 팬케이크, 오믈렛 또는 키시를 만들 수 있습니다!"
}
```[0m

[1m> Finished chain.[0m
```


```output
'You can make pancakes, omelettes, or quiches with these ingredients!'
```


```python
audio_file = agent.run("Tell me a joke and read it out for me.")
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mAction:
```

{
"action": "Azure Cognitive Services Text2Speech",
"action_input": "왜 닭이 놀이터를 건넜나요? 다른 슬라이드에 가기 위해서요!"
}
```

[0m
Observation: [31;1m[1;3m/tmp/tmpa3uu_j6b.wav[0m
Thought:[32;1m[1;3m I have the audio file of the joke
Action:
```

{
"action": "Final Answer",
"action_input": "/tmp/tmpa3uu_j6b.wav"
}
```[0m

[1m> Finished chain.[0m
```


```output
'/tmp/tmpa3uu_j6b.wav'
```


```python
from IPython import display

audio = display.Audio(audio_file)
display.display(audio)
```


```python
agent.run(
    """The patient is a 54-year-old gentleman with a history of progressive angina over the past several months.
The patient had a cardiac catheterization in July of this year revealing total occlusion of the RCA and 50% left main disease ,
with a strong family history of coronary artery disease with a brother dying at the age of 52 from a myocardial infarction and
another brother who is status post coronary artery bypass grafting. The patient had a stress echocardiogram done on July , 2001 ,
which showed no wall motion abnormalities , but this was a difficult study due to body habitus. The patient went for six minutes with
minimal ST depressions in the anterior lateral leads , thought due to fatigue and wrist pain , his anginal equivalent. Due to the patient's
increased symptoms and family history and history left main disease with total occasional of his RCA was referred for revascularization with open heart surgery.

List all the diagnoses.
"""
)
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mAction:
```

{
"action": "azure_cognitive_services_text_analyics_health",
"action_input": "환자는 지난 몇 달 동안 진행성 협심증 병력이 있는 54세 남성입니다. 환자는 올해 7월에 심장 카테터 삽입술을 받았으며, RCA의 완전 폐쇄와 50% 좌측 주관상 동맥 질환이 발견되었습니다. 환자의 형이 52세에 심근경색으로 사망한 강한 가족력이 있으며, 다른 형은 관상동맥 우회 수술을 받았습니다. 환자는 2001년 7월에 스트레스 심초음파 검사를 받았으며, 벽 운동 이상은 없었지만 체형으로 인해 어려운 검사였습니다. 환자는 최소한의 ST 하강을 보이며 6분 동안 운동했으며, 이는 피로와 손목 통증으로 인한 협심증의 동등한 증상으로 생각됩니다. 환자의 증상 악화와 가족력, RCA의 완전 폐쇄로 인해 개심 수술을 통한 재관류를 위해 의뢰되었습니다."
}
```
[0m
Observation: [36;1m[1;3mThe text conatins the following healthcare entities: 54-year-old is a healthcare entity of type Age, gentleman is a healthcare entity of type Gender, progressive angina is a healthcare entity of type Diagnosis, past several months is a healthcare entity of type Time, cardiac catheterization is a healthcare entity of type ExaminationName, July of this year is a healthcare entity of type Time, total is a healthcare entity of type ConditionQualifier, occlusion is a healthcare entity of type SymptomOrSign, RCA is a healthcare entity of type BodyStructure, 50 is a healthcare entity of type MeasurementValue, % is a healthcare entity of type MeasurementUnit, left main is a healthcare entity of type BodyStructure, disease is a healthcare entity of type Diagnosis, family is a healthcare entity of type FamilyRelation, coronary artery disease is a healthcare entity of type Diagnosis, brother is a healthcare entity of type FamilyRelation, dying is a healthcare entity of type Diagnosis, 52 is a healthcare entity of type Age, myocardial infarction is a healthcare entity of type Diagnosis, brother is a healthcare entity of type FamilyRelation, coronary artery bypass grafting is a healthcare entity of type TreatmentName, stress echocardiogram is a healthcare entity of type ExaminationName, July, 2001 is a healthcare entity of type Time, wall motion abnormalities is a healthcare entity of type SymptomOrSign, body habitus is a healthcare entity of type SymptomOrSign, six minutes is a healthcare entity of type Time, minimal is a healthcare entity of type ConditionQualifier, ST depressions in the anterior lateral leads is a healthcare entity of type SymptomOrSign, fatigue is a healthcare entity of type SymptomOrSign, wrist pain is a healthcare entity of type SymptomOrSign, anginal equivalent is a healthcare entity of type SymptomOrSign, increased is a healthcare entity of type Course, symptoms is a healthcare entity of type SymptomOrSign, family is a healthcare entity of type FamilyRelation, left is a healthcare entity of type Direction, main is a healthcare entity of type BodyStructure, disease is a healthcare entity of type Diagnosis, occasional is a healthcare entity of type Course, RCA is a healthcare entity of type BodyStructure, revascularization is a healthcare entity of type TreatmentName, open heart surgery is a healthcare entity of type TreatmentName[0m
Thought:[32;1m[1;3m I know what to respond
Action:
```

{
"action": "Final Answer",
"action_input": "텍스트에는 다음과 같은 진단이 포함되어 있습니다: 진행성 협심증, 관상동맥 질환, 심근경색 및 관상동맥 우회 수술."
}
```[0m

[1m> Finished chain.[0m
```


```output
'The text contains the following diagnoses: progressive angina, coronary artery disease, myocardial infarction, and coronary artery bypass grafting.'
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)