---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/nuclia.ipynb
description: Nuclia는 비정형 데이터를 자동으로 색인화하여 최적화된 검색 결과와 생성적 답변을 제공합니다. 다양한 콘텐츠를 처리합니다.
---

# Nuclia

> [Nuclia](https://nuclia.com)는 내부 및 외부 출처의 비구조화된 데이터를 자동으로 인덱싱하여 최적화된 검색 결과와 생성적 답변을 제공합니다. 비디오 및 오디오 전사, 이미지 콘텐츠 추출 및 문서 파싱을 처리할 수 있습니다.

> `Nuclia Understanding API`는 텍스트, 웹 페이지, 문서 및 오디오/비디오 콘텐츠를 포함한 비구조화된 데이터의 처리를 지원합니다. 필요한 경우 음성 인식 또는 OCR을 사용하여 모든 텍스트를 추출하고, 메타데이터, 내장 파일(예: PDF의 이미지) 및 웹 링크도 추출합니다. 머신러닝이 활성화되면 엔티티를 식별하고, 콘텐츠의 요약을 제공하며, 모든 문장에 대한 임베딩을 생성합니다.

## 설정

`Nuclia Understanding API`를 사용하려면 Nuclia 계정이 필요합니다. [https://nuclia.cloud](https://nuclia.cloud)에서 무료로 계정을 생성한 후, [NUA 키를 생성](https://docs.nuclia.dev/docs/docs/using/understanding/intro)해야 합니다.

```python
%pip install --upgrade --quiet  protobuf
%pip install --upgrade --quiet  nucliadb-protos
```


```python
import os

os.environ["NUCLIA_ZONE"] = "<YOUR_ZONE>"  # e.g. europe-1
os.environ["NUCLIA_NUA_KEY"] = "<YOUR_API_KEY>"
```


## 예시

Nuclia 문서 로더를 사용하려면 `NucliaUnderstandingAPI` 도구를 인스턴스화해야 합니다:

```python
<!--IMPORTS:[{"imported": "NucliaUnderstandingAPI", "source": "langchain_community.tools.nuclia", "docs": "https://api.python.langchain.com/en/latest/tools/langchain_community.tools.nuclia.tool.NucliaUnderstandingAPI.html", "title": "Nuclia"}]-->
from langchain_community.tools.nuclia import NucliaUnderstandingAPI

nua = NucliaUnderstandingAPI(enable_ml=False)
```


```python
<!--IMPORTS:[{"imported": "NucliaLoader", "source": "langchain_community.document_loaders.nuclia", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.nuclia.NucliaLoader.html", "title": "Nuclia"}]-->
from langchain_community.document_loaders.nuclia import NucliaLoader

loader = NucliaLoader("./interview.mp4", nua)
```


이제 문서를 가져올 때까지 `load`를 호출할 수 있습니다.

```python
import time

pending = True
while pending:
    time.sleep(15)
    docs = loader.load()
    if len(docs) > 0:
        print(docs[0].page_content)
        print(docs[0].metadata)
        pending = False
    else:
        print("waiting...")
```


## 검색된 정보

Nuclia는 다음 정보를 반환합니다:

- 파일 메타데이터
- 추출된 텍스트
- 중첩 텍스트(내장 이미지의 텍스트와 같은)
- 문단 및 문장 분할(첫 번째 및 마지막 문자 위치, 비디오 또는 오디오 파일의 시작 및 종료 시간으로 정의됨)
- 링크
- 썸네일
- 내장 파일

참고:

생성된 파일(썸네일, 추출된 내장 파일 등)은 토큰으로 제공됩니다. [`/processing/download` 엔드포인트](https://docs.nuclia.dev/docs/api#operation/Download_binary_file_processing_download_get)를 사용하여 다운로드할 수 있습니다.

또한 모든 수준에서 속성이 특정 크기를 초과하면 다운로드 가능한 파일로 이동되며, 문서에서는 파일 포인터로 대체됩니다. 이는 `{"file": {"uri": "JWT_TOKEN"}}` 형태로 구성됩니다. 규칙은 메시지의 크기가 1,000,000자를 초과하는 경우 가장 큰 부분이 다운로드 가능한 파일로 이동된다는 것입니다. 먼저 압축 프로세스는 벡터를 대상으로 합니다. 그것이 충분하지 않으면 큰 필드 메타데이터를 대상으로 하고, 마지막으로 추출된 텍스트를 대상으로 합니다.

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)