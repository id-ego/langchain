---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/callbacks/labelstudio.ipynb
description: Label Studio는 대규모 언어 모델을 위한 데이터 라벨링 플랫폼으로, LangChain과 연결하여 데이터 수집 및 평가를
  지원합니다.
---

# Label Studio

> [Label Studio](https://labelstud.io/guide/get_started)는 대규모 언어 모델(LLM)의 미세 조정을 위한 데이터 레이블링에 있어 LangChain에 유연성을 제공하는 오픈 소스 데이터 레이블링 플랫폼입니다. 또한 사용자 정의 훈련 데이터 준비 및 인간 피드백을 통한 응답 수집 및 평가를 가능하게 합니다.

이 가이드에서는 LangChain 파이프라인을 `Label Studio`에 연결하는 방법을 배웁니다:

- 모든 입력 프롬프트, 대화 및 응답을 단일 `Label Studio` 프로젝트에 집계합니다. 이를 통해 모든 데이터를 한 곳에 통합하여 레이블링 및 분석을 용이하게 합니다.
- 프롬프트와 응답을 다듬어 감독된 미세 조정(SFT) 및 인간 피드백을 통한 강화 학습(RLHF) 시나리오를 위한 데이터 세트를 만듭니다. 레이블이 지정된 데이터는 LLM의 성능을 향상시키기 위해 추가 훈련에 사용될 수 있습니다.
- 인간 피드백을 통해 모델 응답을 평가합니다. `Label Studio`는 인간이 모델 응답을 검토하고 피드백을 제공할 수 있는 인터페이스를 제공하여 평가 및 반복을 가능하게 합니다.

## 설치 및 설정

먼저 Label Studio와 Label Studio API 클라이언트의 최신 버전을 설치합니다:

```python
%pip install --upgrade --quiet langchain label-studio label-studio-sdk langchain-openai langchain-community
```


다음으로, 명령줄에서 `label-studio`를 실행하여 `http://localhost:8080`에서 로컬 LabelStudio 인스턴스를 시작합니다. 더 많은 옵션은 [Label Studio 설치 가이드](https://labelstud.io/guide/install)를 참조하세요.

API 호출을 하려면 토큰이 필요합니다.

브라우저에서 LabelStudio 인스턴스를 열고 `Account & Settings > Access Token`으로 이동하여 키를 복사합니다.

LabelStudio URL, API 키 및 OpenAI API 키로 환경 변수를 설정합니다:

```python
import os

os.environ["LABEL_STUDIO_URL"] = "<YOUR-LABEL-STUDIO-URL>"  # e.g. http://localhost:8080
os.environ["LABEL_STUDIO_API_KEY"] = "<YOUR-LABEL-STUDIO-API-KEY>"
os.environ["OPENAI_API_KEY"] = "<YOUR-OPENAI-API-KEY>"
```


## LLM 프롬프트 및 응답 수집

레이블링에 사용되는 데이터는 Label Studio 내의 프로젝트에 저장됩니다. 각 프로젝트는 입력 및 출력 데이터에 대한 사양을 자세히 설명하는 XML 구성으로 식별됩니다.

인간 입력을 텍스트 형식으로 받고 텍스트 영역에서 편집 가능한 LLM 응답을 출력하는 프로젝트를 생성합니다:

```xml
<View>
<Style>
    .prompt-box {
        background-color: white;
        border-radius: 10px;
        box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
        padding: 20px;
    }
</Style>
<View className="root">
    <View className="prompt-box">
        <Text name="prompt" value="$prompt"/>
    </View>
    <TextArea name="response" toName="prompt"
              maxSubmissions="1" editable="true"
              required="true"/>
</View>
<Header value="Rate the response:"/>
<Rating name="rating" toName="prompt"/>
</View>
```


1. Label Studio에서 "Create" 버튼을 클릭하여 프로젝트를 생성합니다.
2. "Project Name" 필드에 `My Project`와 같은 프로젝트 이름을 입력합니다.
3. `Labeling Setup > Custom Template`로 이동하여 위에 제공된 XML 구성을 붙여넣습니다.

`LabelStudioCallbackHandler`를 통해 LabelStudio 프로젝트에서 입력 LLM 프롬프트와 출력 응답을 수집할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "LabelStudioCallbackHandler", "source": "langchain_community.callbacks.labelstudio_callback", "docs": "https://api.python.langchain.com/en/latest/callbacks/langchain_community.callbacks.labelstudio_callback.LabelStudioCallbackHandler.html", "title": "Label Studio"}]-->
from langchain_community.callbacks.labelstudio_callback import (
    LabelStudioCallbackHandler,
)
```


```python
<!--IMPORTS:[{"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Label Studio"}]-->
from langchain_openai import OpenAI

llm = OpenAI(
    temperature=0, callbacks=[LabelStudioCallbackHandler(project_name="My Project")]
)
print(llm.invoke("Tell me a joke"))
```


Label Studio에서 `My Project`를 열면 프롬프트, 응답 및 모델 이름과 같은 메타데이터를 볼 수 있습니다.

## 채팅 모델 대화 수집

LabelStudio에서 전체 채팅 대화를 추적하고 표시할 수 있으며, 마지막 응답을 평가하고 수정할 수 있습니다:

1. Label Studio를 열고 "Create" 버튼을 클릭합니다.
2. "Project Name" 필드에 `New Project with Chat`와 같은 프로젝트 이름을 입력합니다.
3. Labeling Setup > Custom Template로 이동하여 다음 XML 구성을 붙여넣습니다:

```xml
<View>
<View className="root">
     <Paragraphs name="dialogue"
               value="$prompt"
               layout="dialogue"
               textKey="content"
               nameKey="role"
               granularity="sentence"/>
  <Header value="Final response:"/>
    <TextArea name="response" toName="dialogue"
              maxSubmissions="1" editable="true"
              required="true"/>
</View>
<Header value="Rate the response:"/>
<Rating name="rating" toName="dialogue"/>
</View>
```


```python
<!--IMPORTS:[{"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "Label Studio"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "Label Studio"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Label Studio"}]-->
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI

chat_llm = ChatOpenAI(
    callbacks=[
        LabelStudioCallbackHandler(
            mode="chat",
            project_name="New Project with Chat",
        )
    ]
)
llm_results = chat_llm.invoke(
    [
        SystemMessage(content="Always use a lot of emojis"),
        HumanMessage(content="Tell me a joke"),
    ]
)
```


Label Studio에서 "New Project with Chat"을 열고 생성된 작업을 클릭하여 대화 기록을 보고 응답을 편집/주석 달 수 있습니다.

## 사용자 정의 레이블링 구성

LabelStudio의 기본 레이블링 구성을 수정하여 응답 감정, 관련성 및 기타 [유형의 주석자 피드백](https://labelstud.io/tags/)과 같은 더 많은 대상 레이블을 추가할 수 있습니다.

새 레이블링 구성은 UI에서 추가할 수 있습니다: `Settings > Labeling Interface`로 이동하여 `Choices`와 같은 추가 태그를 사용하여 사용자 정의 구성을 설정합니다. 감정을 위해 또는 관련성을 위해 `Rating`을 사용할 수 있습니다. LLM 응답을 표시하기 위해서는 모든 구성에 [`TextArea` 태그](https://labelstud.io/tags/textarea)가 포함되어야 합니다.

또는 프로젝트 생성 전에 초기 호출에서 레이블링 구성을 지정할 수 있습니다:

```python
ls = LabelStudioCallbackHandler(
    project_config="""
<View>
<Text name="prompt" value="$prompt"/>
<TextArea name="response" toName="prompt"/>
<TextArea name="user_feedback" toName="prompt"/>
<Rating name="rating" toName="prompt"/>
<Choices name="sentiment" toName="prompt">
    <Choice value="Positive"/>
    <Choice value="Negative"/>
</Choices>
</View>
"""
)
```


프로젝트가 존재하지 않으면 지정된 레이블링 구성으로 생성됩니다.

## 기타 매개변수

`LabelStudioCallbackHandler`는 여러 선택적 매개변수를 수용합니다:

- **api_key** - Label Studio API 키. 환경 변수 `LABEL_STUDIO_API_KEY`를 덮어씁니다.
- **url** - Label Studio URL. `LABEL_STUDIO_URL`을 덮어쓰며 기본값은 `http://localhost:8080`입니다.
- **project_id** - 기존 Label Studio 프로젝트 ID. `LABEL_STUDIO_PROJECT_ID`를 덮어씁니다. 이 프로젝트에 데이터를 저장합니다.
- **project_name** - 프로젝트 ID가 지정되지 않은 경우 프로젝트 이름. 새 프로젝트를 생성합니다. 기본값은 현재 날짜로 형식화된 `"LangChain-%Y-%m-%d"`입니다.
- **project_config** - [사용자 정의 레이블링 구성](#custom-labeling-configuration)
- **mode**: 이 단축키를 사용하여 대상 구성을 처음부터 생성합니다:
  - `"prompt"` - 단일 프롬프트, 단일 응답. 기본값.
  - `"chat"` - 다중 턴 채팅 모드.