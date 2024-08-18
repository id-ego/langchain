---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/nuclia.ipynb
description: Nuclia는 비구조적 데이터를 자동으로 색인화하여 최적화된 검색 결과와 생성적 답변을 제공합니다. 다양한 콘텐츠를 처리할
  수 있습니다.
---

# Nuclia 이해하기

> [Nuclia](https://nuclia.com)는 내부 및 외부의 모든 출처에서 비구조화된 데이터를 자동으로 인덱싱하여 최적화된 검색 결과와 생성된 답변을 제공합니다. 비디오 및 오디오 전사, 이미지 콘텐츠 추출, 문서 파싱을 처리할 수 있습니다.

`Nuclia Understanding API`는 텍스트, 웹 페이지, 문서 및 오디오/비디오 콘텐츠를 포함한 비구조화된 데이터 처리를 지원합니다. 필요한 경우 음성 인식 또는 OCR을 사용하여 모든 텍스트를 추출하고, 엔티티를 식별하며, 메타데이터, 내장 파일(예: PDF의 이미지) 및 웹 링크를 추출합니다. 또한 콘텐츠 요약을 제공합니다.

`Nuclia Understanding API`를 사용하려면 `Nuclia` 계정이 필요합니다. [https://nuclia.cloud](https://nuclia.cloud)에서 무료로 계정을 생성한 후, [NUA 키를 생성](https://docs.nuclia.dev/docs/docs/using/understanding/intro)할 수 있습니다.

```python
%pip install --upgrade --quiet  protobuf
%pip install --upgrade --quiet  nucliadb-protos
```


```python
import os

os.environ["NUCLIA_ZONE"] = "<YOUR_ZONE>"  # e.g. europe-1
os.environ["NUCLIA_NUA_KEY"] = "<YOUR_API_KEY>"
```


```python
<!--IMPORTS:[{"imported": "NucliaUnderstandingAPI", "source": "langchain_community.tools.nuclia", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.nuclia.tool.NucliaUnderstandingAPI.html", "title": "Nuclia Understanding"}]-->
from langchain_community.tools.nuclia import NucliaUnderstandingAPI

nua = NucliaUnderstandingAPI(enable_ml=False)
```


`push` 작업을 사용하여 Nuclia Understanding API에 파일을 전송할 수 있습니다. 처리는 비동기적으로 수행되므로 결과가 파일이 푸시된 순서와 다르게 반환될 수 있습니다. 따라서 결과와 해당 파일을 일치시키기 위해 `id`를 제공해야 합니다.

```python
nua.run({"action": "push", "id": "1", "path": "./report.docx"})
nua.run({"action": "push", "id": "2", "path": "./interview.mp4"})
```


이제 JSON 형식의 결과를 받을 때까지 `pull` 작업을 루프에서 호출할 수 있습니다.

```python
import time

pending = True
data = None
while pending:
    time.sleep(15)
    data = nua.run({"action": "pull", "id": "1", "path": None})
    if data:
        print(data)
        pending = False
    else:
        print("waiting...")
```


`async` 모드에서 한 번의 단계로 수행할 수도 있으며, 푸시만 하면 결과가 수신될 때까지 기다립니다:

```python
import asyncio


async def process():
    data = await nua.arun(
        {"action": "push", "id": "1", "path": "./talk.mp4", "text": None}
    )
    print(data)


asyncio.run(process())
```


## 검색된 정보

Nuclia는 다음 정보를 반환합니다:

- 파일 메타데이터
- 추출된 텍스트
- 중첩 텍스트(내장 이미지의 텍스트와 같은)
- 요약(`enable_ml`이 `True`로 설정된 경우에만)
- 문단 및 문장 분할(첫 번째 및 마지막 문자 위치에 의해 정의되며, 비디오 또는 오디오 파일의 시작 시간 및 종료 시간 포함)
- 명명된 엔티티: 사람, 날짜, 장소, 조직 등(`enable_ml`이 `True`로 설정된 경우에만)
- 링크
- 썸네일
- 내장 파일
- 텍스트의 벡터 표현(`enable_ml`이 `True`로 설정된 경우에만)

참고:

생성된 파일(썸네일, 추출된 내장 파일 등)은 토큰으로 제공됩니다. [`/processing/download` 엔드포인트](https://docs.nuclia.dev/docs/api#operation/Download_binary_file_processing_download_get)를 사용하여 다운로드할 수 있습니다.

또한 어떤 수준에서든 속성이 특정 크기를 초과하면 다운로드 가능한 파일에 넣어지고 문서에서는 파일 포인터로 대체됩니다. 이는 `{"file": {"uri": "JWT_TOKEN"}}`로 구성됩니다. 규칙은 메시지의 크기가 1000000자를 초과하면 가장 큰 부분이 다운로드 가능한 파일로 이동된다는 것입니다. 먼저 압축 프로세스는 벡터를 대상으로 합니다. 그게 충분하지 않으면 큰 필드 메타데이터를 대상으로 하고, 마지막으로 추출된 텍스트를 대상으로 합니다.

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)