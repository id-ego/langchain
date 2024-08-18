---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/eleven_labs_tts.ipynb
description: 이 문서는 ElevenLabs API를 사용하여 텍스트를 음성으로 변환하는 방법을 설명합니다. 사용법 및 에이전트 내에서의
  활용법을 포함합니다.
---

# Eleven Labs Text2Speech

이 노트북은 `ElevenLabs API`와 상호작용하여 텍스트-음성 변환 기능을 구현하는 방법을 보여줍니다.

먼저, ElevenLabs 계정을 설정해야 합니다. [여기](https://docs.elevenlabs.io/welcome/introduction)에서 지침을 따를 수 있습니다.

```python
%pip install --upgrade --quiet  elevenlabs langchain-community
```


```python
import os

os.environ["ELEVEN_API_KEY"] = ""
```


## 사용법

```python
<!--IMPORTS:[{"imported": "ElevenLabsText2SpeechTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.eleven_labs.text2speech.ElevenLabsText2SpeechTool.html", "title": "Eleven Labs Text2Speech"}]-->
from langchain_community.tools import ElevenLabsText2SpeechTool

text_to_speak = "Hello world! I am the real slim shady"

tts = ElevenLabsText2SpeechTool()
tts.name
```


```output
'eleven_labs_text2speech'
```


우리는 오디오를 생성하고, 임시 파일에 저장한 다음 재생할 수 있습니다.

```python
speech_file = tts.run(text_to_speak)
tts.play(speech_file)
```


또는 오디오를 직접 스트리밍할 수 있습니다.

```python
tts.stream_speech(text_to_speak)
```


## 에이전트 내에서 사용

```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Eleven Labs Text2Speech"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Eleven Labs Text2Speech"}, {"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "Eleven Labs Text2Speech"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Eleven Labs Text2Speech"}]-->
from langchain.agents import AgentType, initialize_agent, load_tools
from langchain_openai import OpenAI
```


```python
llm = OpenAI(temperature=0)
tools = load_tools(["eleven_labs_text2speech"])
agent = initialize_agent(
    tools=tools,
    llm=llm,
    agent=AgentType.STRUCTURED_CHAT_ZERO_SHOT_REACT_DESCRIPTION,
    verbose=True,
)
```


```python
audio_file = agent.run("Tell me a joke and read it out for me.")
```

```output


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3mAction:
```

{
"action": "eleven_labs_text2speech",
"action_input": {
"query": "왜 닭이 놀이터를 건넜나요? 다른 슬라이드에 가기 위해서요!"
}
}
```

[0m
Observation: [36;1m[1;3m/tmp/tmpsfg783f1.wav[0m
Thought:[32;1m[1;3m I have the audio file ready to be sent to the human
Action:
```

{
"action": "Final Answer",
"action_input": "/tmp/tmpsfg783f1.wav"
}
```

[0m

[1m> Finished chain.[0m
```


```python
tts.play(audio_file)
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)