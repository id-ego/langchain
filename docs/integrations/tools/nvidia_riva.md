---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/nvidia_riva.ipynb
description: NVIDIA Riva는 실시간 대화형 AI 파이프라인 구축을 위한 GPU 가속 다국어 음성 및 번역 AI SDK입니다. ASR,
  TTS 및 NMT를 지원합니다.
---

# NVIDIA Riva: ASR 및 TTS

## NVIDIA Riva
[NVIDIA Riva](https://www.nvidia.com/en-us/ai-data-science/products/riva/)는 자동 음성 인식(ASR), 텍스트 음성 변환(TTS) 및 신경 기계 번역(NMT) 애플리케이션을 포함한 완전히 사용자 정의 가능한 실시간 대화형 AI 파이프라인을 구축하기 위한 GPU 가속 다국어 음성 및 번역 AI 소프트웨어 개발 키트입니다. 클라우드, 데이터 센터, 엣지 또는 임베디드 장치에 배포할 수 있습니다.

Riva Speech API 서버는 음성 인식, 음성 합성 및 다양한 자연어 처리 추론을 수행하기 위한 간단한 API를 노출하며, ASR 및 TTS를 위해 LangChain에 통합되어 있습니다. 아래에서 [Riva Speech API](#3-setup) 서버 설정 방법에 대한 지침을 참조하십시오.

## NVIDIA Riva를 LangChain 체인에 통합하기
`NVIDIARivaASR`, `NVIDIARivaTTS` 유틸리티 실행 가능 항목은 자동 음성 인식(ASR) 및 텍스트 음성 변환(TTS)을 위해 [NVIDIA Riva](https://www.nvidia.com/en-us/ai-data-science/products/riva/)를 LCEL 체인에 통합하는 LangChain 실행 가능 항목입니다.

이 예제에서는 이러한 LangChain 실행 가능 항목을 사용하여:
1. 스트리밍 오디오 수신,
2. 오디오를 텍스트로 변환,
3. 텍스트를 LLM에 전송,
4. 텍스트 LLM 응답을 스트리밍,
5. 응답을 스트리밍 인간 음성으로 변환하는 방법을 설명합니다.

## 1. NVIDIA Riva 실행 가능 항목
Riva 실행 가능 항목은 2개입니다:

a. **RivaASR**: NVIDIA Riva를 사용하여 오디오 바이트를 LLM용 텍스트로 변환합니다.

b. **RivaTTS**: NVIDIA Riva를 사용하여 텍스트를 오디오 바이트로 변환합니다.

### a. RivaASR
[**RivaASR**](https://github.com/langchain-ai/langchain/blob/master/libs/community/langchain_community/utilities/nvidia_riva.py#L404) 실행 가능 항목은 NVIDIA Riva를 사용하여 오디오 바이트를 LLM용 문자열로 변환합니다.

이는 오디오 스트림(스트리밍 오디오를 포함하는 메시지)을 체인으로 전송하고, 해당 오디오를 문자열로 변환하여 LLM 프롬프트를 생성하는 데 유용합니다.

```
ASRInputType = AudioStream # the AudioStream type is a custom type for a message queue containing streaming audio
ASROutputType = str

class RivaASR(
    RivaAuthMixin,
    RivaCommonConfigMixin,
    RunnableSerializable[ASRInputType, ASROutputType],
):
    """A runnable that performs Automatic Speech Recognition (ASR) using NVIDIA Riva."""

    name: str = "nvidia_riva_asr"
    description: str = (
        "A Runnable for converting audio bytes to a string."
        "This is useful for feeding an audio stream into a chain and"
        "preprocessing that audio to create an LLM prompt."
    )

    # riva options
    audio_channel_count: int = Field(
        1, description="The number of audio channels in the input audio stream."
    )
    profanity_filter: bool = Field(
        True,
        description=(
            "Controls whether or not Riva should attempt to filter "
            "profanity out of the transcribed text."
        ),
    )
    enable_automatic_punctuation: bool = Field(
        True,
        description=(
            "Controls whether Riva should attempt to correct "
            "senetence puncuation in the transcribed text."
        ),
    )
```


이 실행 가능 항목이 입력에 호출되면, 입력 오디오 스트림을 큐로 사용하고, 반환된 청크에 따라 전사를 연결합니다. 응답이 완전히 생성된 후 문자열이 반환됩니다. 
* LLM이 전체 쿼리를 요구하므로 ASR은 연결되고 토큰별로 스트리밍되지 않음을 유의하십시오.

### b. RivaTTS
[**RivaTTS**](https://github.com/langchain-ai/langchain/blob/master/libs/community/langchain_community/utilities/nvidia_riva.py#L511) 실행 가능 항목은 텍스트 출력을 오디오 바이트로 변환합니다.

이는 LLM에서 스트리밍된 텍스트 응답을 처리하여 텍스트를 오디오 바이트로 변환하는 데 유용합니다. 이러한 오디오 바이트는 사용자에게 재생될 자연스러운 인간 음성과 같습니다.

```
TTSInputType = Union[str, AnyMessage, PromptValue]
TTSOutputType = byte

class RivaTTS(
    RivaAuthMixin,
    RivaCommonConfigMixin,
    RunnableSerializable[TTSInputType, TTSOutputType],
):
    """A runnable that performs Text-to-Speech (TTS) with NVIDIA Riva."""

    name: str = "nvidia_riva_tts"
    description: str = (
        "A tool for converting text to speech."
        "This is useful for converting LLM output into audio bytes."
    )

    # riva options
    voice_name: str = Field(
        "English-US.Female-1",
        description=(
            "The voice model in Riva to use for speech. "
            "Pre-trained models are documented in "
            "[the Riva documentation]"
            "(https://docs.nvidia.com/deeplearning/riva/user-guide/docs/tts/tts-overview.html)."
        ),
    )
    output_directory: Optional[str] = Field(
        None,
        description=(
            "The directory where all audio files should be saved. "
            "A null value indicates that wave files should not be saved. "
            "This is useful for debugging purposes."
        ),
```


이 실행 가능 항목이 입력에 호출되면, 반복 가능한 텍스트 청크를 받아 출력 오디오 바이트로 스트리밍하여 `.wav` 파일에 기록되거나 소리 내어 재생됩니다.

## 2. 설치

NVIDIA Riva 클라이언트 라이브러리를 설치해야 합니다.

```python
%pip install --upgrade --quiet nvidia-riva-client
```

```output
Note: you may need to restart the kernel to use updated packages.
```

## 3. 설정

**NVIDIA Riva를 시작하려면:**

1. [빠른 시작 스크립트를 사용한 로컬 배포](https://docs.nvidia.com/deeplearning/riva/user-guide/docs/quick-start-guide.html#local-deployment-using-quick-start-scripts)에 대한 Riva 빠른 시작 설정 지침을 따르십시오.

## 4. 실행 가능 항목 가져오기 및 검사
RivaASR 및 RivaTTS 실행 가능 항목을 가져오고 해당 스키마를 검사하여 필드를 이해합니다.

```python
<!--IMPORTS:[{"imported": "RivaASR", "source": "langchain_community.utilities.nvidia_riva", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.nvidia_riva.RivaASR.html", "title": "NVIDIA Riva: ASR and TTS"}, {"imported": "RivaTTS", "source": "langchain_community.utilities.nvidia_riva", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.nvidia_riva.RivaTTS.html", "title": "NVIDIA Riva: ASR and TTS"}]-->
import json

from langchain_community.utilities.nvidia_riva import (
    RivaASR,
    RivaTTS,
)
```


스키마를 봅시다.

```python
print(json.dumps(RivaASR.schema(), indent=2))
print(json.dumps(RivaTTS.schema(), indent=2))
```

```output
{
  "title": "RivaASR",
  "description": "A runnable that performs Automatic Speech Recognition (ASR) using NVIDIA Riva.",
  "type": "object",
  "properties": {
    "name": {
      "title": "Name",
      "default": "nvidia_riva_asr",
      "type": "string"
    },
    "encoding": {
      "description": "The encoding on the audio stream.",
      "default": "LINEAR_PCM",
      "allOf": [
        {
          "$ref": "#/definitions/RivaAudioEncoding"
        }
      ]
    },
    "sample_rate_hertz": {
      "title": "Sample Rate Hertz",
      "description": "The sample rate frequency of audio stream.",
      "default": 8000,
      "type": "integer"
    },
    "language_code": {
      "title": "Language Code",
      "description": "The [BCP-47 language code](https://www.rfc-editor.org/rfc/bcp/bcp47.txt) for the target language.",
      "default": "en-US",
      "type": "string"
    },
    "url": {
      "title": "Url",
      "description": "The full URL where the Riva service can be found.",
      "default": "http://localhost:50051",
      "examples": [
        "http://localhost:50051",
        "https://user@pass:riva.example.com"
      ],
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 65536,
          "format": "uri"
        },
        {
          "type": "string"
        }
      ]
    },
    "ssl_cert": {
      "title": "Ssl Cert",
      "description": "A full path to the file where Riva's public ssl key can be read.",
      "type": "string"
    },
    "description": {
      "title": "Description",
      "default": "A Runnable for converting audio bytes to a string.This is useful for feeding an audio stream into a chain andpreprocessing that audio to create an LLM prompt.",
      "type": "string"
    },
    "audio_channel_count": {
      "title": "Audio Channel Count",
      "description": "The number of audio channels in the input audio stream.",
      "default": 1,
      "type": "integer"
    },
    "profanity_filter": {
      "title": "Profanity Filter",
      "description": "Controls whether or not Riva should attempt to filter profanity out of the transcribed text.",
      "default": true,
      "type": "boolean"
    },
    "enable_automatic_punctuation": {
      "title": "Enable Automatic Punctuation",
      "description": "Controls whether Riva should attempt to correct senetence puncuation in the transcribed text.",
      "default": true,
      "type": "boolean"
    }
  },
  "definitions": {
    "RivaAudioEncoding": {
      "title": "RivaAudioEncoding",
      "description": "An enum of the possible choices for Riva audio encoding.\n\nThe list of types exposed by the Riva GRPC Protobuf files can be found\nwith the following commands:\n```python\nimport riva.client\nprint(riva.client.AudioEncoding.keys())  # noqa: T201\n```",
      "enum": [
        "ALAW",
        "ENCODING_UNSPECIFIED",
        "FLAC",
        "LINEAR_PCM",
        "MULAW",
        "OGGOPUS"
      ],
      "type": "string"
    }
  }
}
{
  "title": "RivaTTS",
  "description": "A runnable that performs Text-to-Speech (TTS) with NVIDIA Riva.",
  "type": "object",
  "properties": {
    "name": {
      "title": "Name",
      "default": "nvidia_riva_tts",
      "type": "string"
    },
    "encoding": {
      "description": "The encoding on the audio stream.",
      "default": "LINEAR_PCM",
      "allOf": [
        {
          "$ref": "#/definitions/RivaAudioEncoding"
        }
      ]
    },
    "sample_rate_hertz": {
      "title": "Sample Rate Hertz",
      "description": "The sample rate frequency of audio stream.",
      "default": 8000,
      "type": "integer"
    },
    "language_code": {
      "title": "Language Code",
      "description": "The [BCP-47 language code](https://www.rfc-editor.org/rfc/bcp/bcp47.txt) for the target language.",
      "default": "en-US",
      "type": "string"
    },
    "url": {
      "title": "Url",
      "description": "The full URL where the Riva service can be found.",
      "default": "http://localhost:50051",
      "examples": [
        "http://localhost:50051",
        "https://user@pass:riva.example.com"
      ],
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 65536,
          "format": "uri"
        },
        {
          "type": "string"
        }
      ]
    },
    "ssl_cert": {
      "title": "Ssl Cert",
      "description": "A full path to the file where Riva's public ssl key can be read.",
      "type": "string"
    },
    "description": {
      "title": "Description",
      "default": "A tool for converting text to speech.This is useful for converting LLM output into audio bytes.",
      "type": "string"
    },
    "voice_name": {
      "title": "Voice Name",
      "description": "The voice model in Riva to use for speech. Pre-trained models are documented in [the Riva documentation](https://docs.nvidia.com/deeplearning/riva/user-guide/docs/tts/tts-overview.html).",
      "default": "English-US.Female-1",
      "type": "string"
    },
    "output_directory": {
      "title": "Output Directory",
      "description": "The directory where all audio files should be saved. A null value indicates that wave files should not be saved. This is useful for debugging purposes.",
      "type": "string"
    }
  },
  "definitions": {
    "RivaAudioEncoding": {
      "title": "RivaAudioEncoding",
      "description": "An enum of the possible choices for Riva audio encoding.\n\nThe list of types exposed by the Riva GRPC Protobuf files can be found\nwith the following commands:\n```python\nimport riva.client\nprint(riva.client.AudioEncoding.keys())  # noqa: T201\n```",
      "enum": [
        "ALAW",
        "ENCODING_UNSPECIFIED",
        "FLAC",
        "LINEAR_PCM",
        "MULAW",
        "OGGOPUS"
      ],
      "type": "string"
    }
  }
}
```

## 5. Riva ASR 및 Riva TTS 실행 가능 항목 선언

이 예제에서는 단일 채널 오디오 파일(멀라우 형식, 즉 `.wav`)을 사용합니다.

Riva 음성 서버 설정이 필요하므로 Riva 음성 서버가 없는 경우 [설정](#3-setup)으로 이동하십시오.

### a. 오디오 매개변수 설정
오디오의 일부 매개변수는 멀라우 파일에서 유추할 수 있지만, 다른 매개변수는 명시적으로 설정됩니다.

`audio_file`을 오디오 파일의 경로로 교체하십시오.

```python
<!--IMPORTS:[{"imported": "RivaAudioEncoding", "source": "langchain_community.utilities.nvidia_riva", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.nvidia_riva.RivaAudioEncoding.html", "title": "NVIDIA Riva: ASR and TTS"}]-->
import pywav  # pywav is used instead of built-in wave because of mulaw support
from langchain_community.utilities.nvidia_riva import RivaAudioEncoding

audio_file = "./audio_files/en-US_sample2.wav"
wav_file = pywav.WavRead(audio_file)
audio_data = wav_file.getdata()
audio_encoding = RivaAudioEncoding.from_wave_format_code(wav_file.getaudioformat())
sample_rate = wav_file.getsamplerate()
delay_time = 1 / 4
chunk_size = int(sample_rate * delay_time)
delay_time = 1 / 8
num_channels = wav_file.getnumofchannels()
```


```python
import IPython

IPython.display.Audio(audio_file)
```


```html

<audio  controls="controls" >
    <source src="data:audio/x-wav;base64,UklGRiQHAgBXQVZFZm10...AAAAAAAAA=" type="audio/x-wav" />
    Your browser does not support the audio element.
</audio>
 
```


### b. 음성 서버 설정 및 Riva LangChain 실행 가능 항목 선언

`RIVA_SPEECH_URL`을 Riva 음성 서버의 URI로 설정해야 합니다.

실행 가능 항목은 음성 서버의 클라이언트 역할을 합니다. 이 예제에서 설정된 많은 필드는 샘플 오디오 데이터를 기반으로 구성됩니다.

```python
RIVA_SPEECH_URL = "http://localhost:50051/"

riva_asr = RivaASR(
    url=RIVA_SPEECH_URL,  # the location of the Riva ASR server
    encoding=audio_encoding,
    audio_channel_count=num_channels,
    sample_rate_hertz=sample_rate,
    profanity_filter=True,
    enable_automatic_punctuation=True,
    language_code="en-US",
)

riva_tts = RivaTTS(
    url=RIVA_SPEECH_URL,  # the location of the Riva TTS server
    output_directory="./scratch",  # location of the output .wav files
    language_code="en-US",
    voice_name="English-US.Female-1",
)
```


## 6. 추가 체인 구성 요소 생성
일반적으로 체인의 다른 부분을 선언합니다. 이 경우 프롬프트 템플릿과 LLM만 있습니다.

체인에서 사용할 수 있는 [LangChain 호환 LLM](https://python.langchain.com/v0.1/docs/integrations/llms/)을 사용할 수 있습니다. 이 예제에서는 [NVIDIA의 Mixtral8x7b NIM](https://python.langchain.com/v0.2/docs/integrations/chat/nvidia_ai_endpoints/)을 사용합니다. NVIDIA NIM은 `langchain-nvidia-ai-endpoints` 패키지를 통해 LangChain에서 지원되므로 최고의 처리량과 대기 시간을 가진 애플리케이션을 쉽게 구축할 수 있습니다.

[NVIDIA AI Foundation Endpoints](https://www.nvidia.com/en-us/ai-data-science/foundation-models/)의 LangChain 호환 NVIDIA LLM도 이러한 [지침](https://python.langchain.com/docs/integrations/chat/nvidia_ai_endpoints)을 따라 사용할 수 있습니다.

```python
%pip install --upgrade --quiet langchain-nvidia-ai-endpoints
```


[NVIDIA NIM을 사용하여 음성 지원 LangChain 애플리케이션을 만드는 방법에 대한 지침](https://python.langchain.com/v0.2/docs/integrations/chat/nvidia_ai_endpoints/)을 따르십시오.

NIM이 호스팅되는 NVIDIA API 카탈로그의 키를 설정하십시오.

```python
import getpass
import os

nvapi_key = getpass.getpass("NVAPI Key (starts with nvapi-): ")
assert nvapi_key.startswith("nvapi-"), f"{nvapi_key[:5]}... is not a valid key"
os.environ["NVIDIA_API_KEY"] = nvapi_key
```


LLM을 인스턴스화합니다.

```python
<!--IMPORTS:[{"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "NVIDIA Riva: ASR and TTS"}, {"imported": "ChatNVIDIA", "source": "langchain_nvidia_ai_endpoints", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_nvidia_ai_endpoints.chat_models.ChatNVIDIA.html", "title": "NVIDIA Riva: ASR and TTS"}]-->
from langchain_core.prompts import PromptTemplate
from langchain_nvidia_ai_endpoints import ChatNVIDIA

prompt = PromptTemplate.from_template("{user_input}")

llm = ChatNVIDIA(model="mistralai/mixtral-8x7b-instruct-v0.1")
```


이제 RivaASR 및 RivaTTS를 포함하여 체인의 모든 부분을 연결합니다.

```python
chain = {"user_input": riva_asr} | prompt | llm | riva_tts
```


## 7. 스트리밍 입력 및 출력으로 체인 실행

### a. 오디오 스트리밍 모방
스트리밍을 모방하기 위해, 먼저 처리된 오디오 데이터를 반복 가능한 청크의 오디오 바이트로 변환합니다.

두 개의 함수 `producer`와 `consumer`는 각각 체인에 오디오 데이터를 비동기적으로 전달하고 체인에서 오디오 데이터를 소비하는 역할을 합니다.

```python
<!--IMPORTS:[{"imported": "AudioStream", "source": "langchain_community.utilities.nvidia_riva", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.nvidia_riva.AudioStream.html", "title": "NVIDIA Riva: ASR and TTS"}]-->
import asyncio

from langchain_community.utilities.nvidia_riva import AudioStream

audio_chunks = [
    audio_data[0 + i : chunk_size + i] for i in range(0, len(audio_data), chunk_size)
]


async def producer(input_stream) -> None:
    """Produces audio chunk bytes into an AudioStream as streaming audio input."""
    for chunk in audio_chunks:
        await input_stream.aput(chunk)
    input_stream.close()


async def consumer(input_stream, output_stream) -> None:
    """
    Consumes audio chunks from input stream and passes them along the chain
    constructed comprised of ASR -> text based prompt for an LLM -> TTS chunks
    with synthesized voice of LLM response put in an output stream.
    """
    while not input_stream.complete:
        async for chunk in chain.astream(input_stream):
            await output_stream.put(
                chunk
            )  # for production code don't forget to add a timeout


input_stream = AudioStream(maxsize=1000)
output_stream = asyncio.Queue()

# send data into the chain
producer_task = asyncio.create_task(producer(input_stream))
# get data out of the chain
consumer_task = asyncio.create_task(consumer(input_stream, output_stream))

while not consumer_task.done():
    try:
        generated_audio = await asyncio.wait_for(
            output_stream.get(), timeout=2
        )  # for production code don't forget to add a timeout
    except asyncio.TimeoutError:
        continue

await producer_task
await consumer_task
```


## 8. 음성 응답 듣기

오디오 응답은 `./scratch`에 기록되며, 입력 오디오에 대한 응답인 오디오 클립을 포함해야 합니다.

```python
import glob
import os

output_path = os.path.join(os.getcwd(), "scratch")
file_type = "*.wav"
files_path = os.path.join(output_path, file_type)
files = glob.glob(files_path)

IPython.display.Audio(files[0])
```


```html

<audio  controls="controls" >
    <source src="data:audio/x-wav;base64,UklGRoLnCQBXQVZFZm10...X/9f/3//f/" type="audio/x-wav" />
    Your browser does not support the audio element.
</audio>
 
```


## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)