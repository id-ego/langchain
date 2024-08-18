---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/google_cloud_texttospeech.ipynb
description: 구글 클라우드 텍스트 음성 변환 API를 사용하여 자연스러운 음성을 합성하는 방법을 보여주는 노트북입니다.
---

# 구글 클라우드 텍스트 음성 변환

> [구글 클라우드 텍스트 음성 변환](https://cloud.google.com/text-to-speech)은 개발자가 100개 이상의 음성을 사용하여 자연스러운 음성을 합성할 수 있도록 하며, 여러 언어와 변형이 가능합니다. 이는 DeepMind의 획기적인 WaveNet 연구와 구글의 강력한 신경망을 적용하여 가능한 최고의 충실도를 제공합니다.

이 노트북은 `구글 클라우드 텍스트 음성 변환 API`와 상호작용하여 음성 합성 기능을 달성하는 방법을 보여줍니다.

먼저, 구글 클라우드 프로젝트를 설정해야 합니다. [여기](https://cloud.google.com/text-to-speech/docs/before-you-begin)에서 지침을 따를 수 있습니다.

```python
%pip install --upgrade --quiet  google-cloud-text-to-speech langchain-community
```


## 사용법

```python
<!--IMPORTS:[{"imported": "GoogleCloudTextToSpeechTool", "source": "langchain_community.tools", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.google_cloud.texttospeech.GoogleCloudTextToSpeechTool.html", "title": "Google Cloud Text-to-Speech"}]-->
from langchain_community.tools import GoogleCloudTextToSpeechTool

text_to_speak = "Hello world!"

tts = GoogleCloudTextToSpeechTool()
tts.name
```


우리는 오디오를 생성하고, 이를 임시 파일에 저장한 다음 재생할 수 있습니다.

```python
speech_file = tts.run(text_to_speak)
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)