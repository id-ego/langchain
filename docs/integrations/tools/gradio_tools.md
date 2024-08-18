---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/gradio_tools.ipynb
description: '`Gradio` 앱을 LLM 기반 에이전트가 활용할 수 있도록 변환하는 `gradio-tools` 라이브러리에 대한 설명과
  사용 방법을 제공합니다.'
---

# Gradio

수천 개의 `Gradio` 앱이 `Hugging Face Spaces`에 있습니다. 이 라이브러리는 LLM의 손끝에서 그것들을 사용할 수 있게 합니다 🦾

특히, `gradio-tools`는 `Gradio` 앱을 LLM 기반 에이전트가 작업을 완료하는 데 활용할 수 있는 도구로 변환하는 Python 라이브러리입니다. 예를 들어, LLM은 온라인에서 찾은 음성 녹음을 필기하고 이를 요약하기 위해 `Gradio` 도구를 사용할 수 있습니다. 또는 Google Drive의 문서에 OCR을 적용하고 이에 대한 질문에 답하기 위해 다른 `Gradio` 도구를 사용할 수 있습니다.

미리 구축된 도구 중 하나가 아닌 공간을 사용하고 싶다면 자신의 도구를 만드는 것은 매우 쉽습니다. 그렇게 하는 방법에 대한 정보는 gradio-tools 문서의 이 섹션을 참조하십시오. 모든 기여는 환영합니다!

```python
%pip install --upgrade --quiet  gradio_tools langchain-community
```


## 도구 사용하기

```python
from gradio_tools.tools import StableDiffusionTool
```


```python
local_file_path = StableDiffusionTool().langchain.run(
    "Please create a photo of a dog riding a skateboard"
)
local_file_path
```

```output
Loaded as API: https://gradio-client-demos-stable-diffusion.hf.space ✔

Job Status: Status.STARTING eta: None
```


```output
'/Users/harrisonchase/workplace/langchain/docs/modules/agents/tools/integrations/b61c1dd9-47e2-46f1-a47c-20d27640993d/tmp4ap48vnm.jpg'
```


```python
from PIL import Image
```


```python
im = Image.open(local_file_path)
```


```python
from IPython.display import display

display(im)
```


## 에이전트 내에서 사용하기

```python
<!--IMPORTS:[{"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Gradio"}, {"imported": "ConversationBufferMemory", "source": "langchain.memory", "docs": "https://api.python.langchain.com/en/latest/memory/langchain.memory.buffer.ConversationBufferMemory.html", "title": "Gradio"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Gradio"}]-->
from gradio_tools.tools import (
    ImageCaptioningTool,
    StableDiffusionPromptGeneratorTool,
    StableDiffusionTool,
    TextToVideoTool,
)
from langchain.agents import initialize_agent
from langchain.memory import ConversationBufferMemory
from langchain_openai import OpenAI

llm = OpenAI(temperature=0)
memory = ConversationBufferMemory(memory_key="chat_history")
tools = [
    StableDiffusionTool().langchain,
    ImageCaptioningTool().langchain,
    StableDiffusionPromptGeneratorTool().langchain,
    TextToVideoTool().langchain,
]


agent = initialize_agent(
    tools, llm, memory=memory, agent="conversational-react-description", verbose=True
)
output = agent.run(
    input=(
        "Please create a photo of a dog riding a skateboard "
        "but improve my prompt prior to using an image generator."
        "Please caption the generated image and create a video for it using the improved prompt."
    )
)
```

```output
Loaded as API: https://gradio-client-demos-stable-diffusion.hf.space ✔
Loaded as API: https://taesiri-blip-2.hf.space ✔
Loaded as API: https://microsoft-promptist.hf.space ✔
Loaded as API: https://damo-vilab-modelscope-text-to-video-synthesis.hf.space ✔


[1m> Entering new AgentExecutor chain...[0m
[32;1m[1;3m
Thought: Do I need to use a tool? Yes
Action: StableDiffusionPromptGenerator
Action Input: A dog riding a skateboard[0m
Job Status: Status.STARTING eta: None

Observation: [38;5;200m[1;3mA dog riding a skateboard, digital painting, artstation, concept art, smooth, sharp focus, illustration, art by artgerm and greg rutkowski and alphonse mucha[0m
Thought:[32;1m[1;3m Do I need to use a tool? Yes
Action: StableDiffusion
Action Input: A dog riding a skateboard, digital painting, artstation, concept art, smooth, sharp focus, illustration, art by artgerm and greg rutkowski and alphonse mucha[0m
Job Status: Status.STARTING eta: None

Job Status: Status.PROCESSING eta: None

Observation: [36;1m[1;3m/Users/harrisonchase/workplace/langchain/docs/modules/agents/tools/integrations/2e280ce4-4974-4420-8680-450825c31601/tmpfmiz2g1c.jpg[0m
Thought:[32;1m[1;3m Do I need to use a tool? Yes
Action: ImageCaptioner
Action Input: /Users/harrisonchase/workplace/langchain/docs/modules/agents/tools/integrations/2e280ce4-4974-4420-8680-450825c31601/tmpfmiz2g1c.jpg[0m
Job Status: Status.STARTING eta: None

Observation: [33;1m[1;3ma painting of a dog sitting on a skateboard[0m
Thought:[32;1m[1;3m Do I need to use a tool? Yes
Action: TextToVideo
Action Input: a painting of a dog sitting on a skateboard[0m
Job Status: Status.STARTING eta: None
Due to heavy traffic on this app, the prediction will take approximately 73 seconds.For faster predictions without waiting in queue, you may duplicate the space using: Client.duplicate(damo-vilab/modelscope-text-to-video-synthesis)

Job Status: Status.IN_QUEUE eta: 73.89824726581574
Due to heavy traffic on this app, the prediction will take approximately 42 seconds.For faster predictions without waiting in queue, you may duplicate the space using: Client.duplicate(damo-vilab/modelscope-text-to-video-synthesis)

Job Status: Status.IN_QUEUE eta: 42.49370198879602

Job Status: Status.IN_QUEUE eta: 21.314297944849187

Observation: [31;1m[1;3m/var/folders/bm/ylzhm36n075cslb9fvvbgq640000gn/T/tmp5snj_nmzf20_cb3m.mp4[0m
Thought:[32;1m[1;3m Do I need to use a tool? No
AI: Here is a video of a painting of a dog sitting on a skateboard.[0m

[1m> Finished chain.[0m
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)