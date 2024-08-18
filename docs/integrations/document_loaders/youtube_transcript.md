---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/youtube_transcript.ipynb
description: YouTube 트랜스크립트를 로드하는 방법을 다루는 노트북으로, 비디오 정보 추가 및 언어 선호 설정 방법을 설명합니다.
---

# YouTube 전사

> [YouTube](https://www.youtube.com/)는 Google이 만든 온라인 비디오 공유 및 소셜 미디어 플랫폼입니다.

이 노트북은 `YouTube 전사`에서 문서를 로드하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "YoutubeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.youtube.YoutubeLoader.html", "title": "YouTube transcripts"}]-->
from langchain_community.document_loaders import YoutubeLoader
```


```python
%pip install --upgrade --quiet  youtube-transcript-api
```


```python
loader = YoutubeLoader.from_youtube_url(
    "https://www.youtube.com/watch?v=QsYGlZkevEg", add_video_info=False
)
```


```python
loader.load()
```


### 비디오 정보 추가

```python
%pip install --upgrade --quiet  pytube
```


```python
loader = YoutubeLoader.from_youtube_url(
    "https://www.youtube.com/watch?v=QsYGlZkevEg", add_video_info=True
)
loader.load()
```


### 언어 선호도 추가

Language param : 우선 순위가 내림차순인 언어 코드 목록입니다. 기본값은 `en`입니다.

translation param : 사용 가능한 전사를 선호하는 언어로 번역할 수 있는 번역 선호도입니다.

```python
loader = YoutubeLoader.from_youtube_url(
    "https://www.youtube.com/watch?v=QsYGlZkevEg",
    add_video_info=True,
    language=["en", "id"],
    translation="en",
)
loader.load()
```


### 타임스탬프가 있는 청크로 전사 가져오기

비디오 전사의 청크를 포함하는 하나 이상의 `Document` 객체를 가져옵니다. 청크의 길이는 초 단위로 지정할 수 있습니다. 각 청크의 메타데이터에는 특정 청크의 시작 부분에서 비디오를 시작하는 YouTube의 URL이 포함됩니다.

`transcript_format` param: `langchain_community.document_loaders.youtube.TranscriptFormat` 값 중 하나입니다. 이 경우, `TranscriptFormat.CHUNKS`입니다.

`chunk_size_seconds` param: 각 전사 데이터 청크가 나타내는 비디오 초의 정수입니다. 기본값은 120초입니다.

```python
<!--IMPORTS:[{"imported": "TranscriptFormat", "source": "langchain_community.document_loaders.youtube", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.youtube.TranscriptFormat.html", "title": "YouTube transcripts"}]-->
from langchain_community.document_loaders.youtube import TranscriptFormat

loader = YoutubeLoader.from_youtube_url(
    "https://www.youtube.com/watch?v=TKCMw0utiak",
    add_video_info=True,
    transcript_format=TranscriptFormat.CHUNKS,
    chunk_size_seconds=30,
)
print("\n\n".join(map(repr, loader.load())))
```


## Google Cloud의 YouTube 로더

### 전제 조건

1. Google Cloud 프로젝트를 생성하거나 기존 프로젝트를 사용합니다.
2. [Youtube Api](https://console.cloud.google.com/apis/enableflow?apiid=youtube.googleapis.com&project=sixth-grammar-344520)를 활성화합니다.
3. [데스크톱 앱에 대한 자격 증명 인증](https://developers.google.com/drive/api/quickstart/python#authorize_credentials_for_a_desktop_application)을 수행합니다.
4. `pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib youtube-transcript-api`를 실행합니다.

### 🧑 Google Docs 데이터 수집을 위한 지침
기본적으로 `GoogleDriveLoader`는 `credentials.json` 파일이 `~/.credentials/credentials.json`에 있다고 예상하지만, 이는 `credentials_file` 키워드 인수를 사용하여 구성할 수 있습니다. `token.json`도 마찬가지입니다. `token.json`은 로더를 처음 사용할 때 자동으로 생성됩니다.

`GoogleApiYoutubeLoader`는 Google Docs 문서 ID 목록 또는 폴더 ID에서 로드할 수 있습니다. URL에서 폴더 및 문서 ID를 얻을 수 있습니다:
설정에 따라 `service_account_path`를 설정해야 합니다. 자세한 내용은 [여기](https://developers.google.com/drive/api/v3/quickstart/python)를 참조하세요.

```python
<!--IMPORTS:[{"imported": "GoogleApiClient", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.youtube.GoogleApiClient.html", "title": "YouTube transcripts"}, {"imported": "GoogleApiYoutubeLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.youtube.GoogleApiYoutubeLoader.html", "title": "YouTube transcripts"}]-->
# Init the GoogleApiClient
from pathlib import Path

from langchain_community.document_loaders import GoogleApiClient, GoogleApiYoutubeLoader

google_api_client = GoogleApiClient(credentials_path=Path("your_path_creds.json"))


# Use a Channel
youtube_loader_channel = GoogleApiYoutubeLoader(
    google_api_client=google_api_client,
    channel_name="Reducible",
    captions_language="en",
)

# Use Youtube Ids

youtube_loader_ids = GoogleApiYoutubeLoader(
    google_api_client=google_api_client, video_ids=["TrdevFK_am4"], add_video_info=True
)

# returns a list of Documents
youtube_loader_channel.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)