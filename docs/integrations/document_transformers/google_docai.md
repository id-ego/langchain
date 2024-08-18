---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_transformers/google_docai.ipynb
description: Google Cloud Document AI는 비정형 데이터를 구조화된 데이터로 변환하여 이해하고 분석하기 쉽게 만드는 문서
  이해 플랫폼입니다.
---

# 구글 클라우드 문서 AI

문서 AI는 구글 클라우드의 문서 이해 플랫폼으로, 문서의 비구조화된 데이터를 구조화된 데이터로 변환하여 이해하고 분석하며 소비하기 쉽게 만듭니다.

자세히 알아보기:

- [문서 AI 개요](https://cloud.google.com/document-ai/docs/overview)
- [문서 AI 비디오 및 실습](https://cloud.google.com/document-ai/docs/videos)
- [사용해 보기!](https://cloud.google.com/document-ai/docs/drag-and-drop)

이 모듈은 구글 클라우드의 DocAI를 기반으로 한 `PDF` 파서를 포함하고 있습니다.

이 파서를 사용하려면 두 개의 라이브러리를 설치해야 합니다:

```python
%pip install --upgrade --quiet  langchain-google-community[docai]
```


먼저, 여기에서 설명한 대로 구글 클라우드 스토리지(GCS) 버킷을 설정하고 자신의 광학 문자 인식(OCR) 프로세서를 생성해야 합니다: https://cloud.google.com/document-ai/docs/create-processor

`GCS_OUTPUT_PATH`는 GCS의 폴더 경로( `gs://`로 시작)여야 하며, `PROCESSOR_NAME`은 `projects/PROJECT_NUMBER/locations/LOCATION/processors/PROCESSOR_ID` 또는 `projects/PROJECT_NUMBER/locations/LOCATION/processors/PROCESSOR_ID/processorVersions/PROCESSOR_VERSION_ID`와 같은 형식이어야 합니다. 이를 프로그래밍 방식으로 얻거나 구글 클라우드 콘솔의 `Processor details` 탭의 `Prediction endpoint` 섹션에서 복사할 수 있습니다.

```python
GCS_OUTPUT_PATH = "gs://BUCKET_NAME/FOLDER_PATH"
PROCESSOR_NAME = "projects/PROJECT_NUMBER/locations/LOCATION/processors/PROCESSOR_ID"
```


```python
<!--IMPORTS:[{"imported": "Blob", "source": "langchain_core.document_loaders.blob_loaders", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Blob.html", "title": "Google Cloud Document AI"}]-->
from langchain_core.document_loaders.blob_loaders import Blob
from langchain_google_community import DocAIParser
```


이제 `DocAIParser`를 생성합니다.

```python
parser = DocAIParser(
    location="us", processor_name=PROCESSOR_NAME, gcs_output_path=GCS_OUTPUT_PATH
)
```


이 예제에서는 공개 GCS 버킷에 업로드된 알파벳 수익 보고서를 사용할 수 있습니다.

[2022Q1_alphabet_earnings_release.pdf](https://storage.googleapis.com/cloud-samples-data/gen-app-builder/search/alphabet-investor-pdfs/2022Q1_alphabet_earnings_release.pdf)

문서를 `lazy_parse()` 메서드에 전달하여

```python
blob = Blob(
    path="gs://cloud-samples-data/gen-app-builder/search/alphabet-investor-pdfs/2022Q1_alphabet_earnings_release.pdf"
)
```


페이지당 하나의 문서를 얻을 수 있으며, 총 11개입니다:

```python
docs = list(parser.lazy_parse(blob))
print(len(docs))
```

```output
11
```

블롭의 끝에서 끝까지 파싱을 하나씩 실행할 수 있습니다. 문서가 많으면 함께 배치하여 파싱 결과 처리와 파싱을 분리하는 것이 더 나은 접근 방식일 수 있습니다.

```python
operations = parser.docai_parse([blob])
print([op.operation.name for op in operations])
```

```output
['projects/543079149601/locations/us/operations/16447136779727347991']
```

작업이 완료되었는지 확인할 수 있습니다:

```python
parser.is_running(operations)
```


```output
True
```


작업이 완료되면 결과를 파싱할 수 있습니다:

```python
parser.is_running(operations)
```


```output
False
```


```python
results = parser.get_results(operations)
print(results[0])
```

```output
DocAIParsingResults(source_path='gs://vertex-pgt/examples/goog-exhibit-99-1-q1-2023-19.pdf', parsed_path='gs://vertex-pgt/test/run1/16447136779727347991/0')
```

이제 파싱된 결과에서 문서를 생성할 수 있습니다:

```python
docs = list(parser.parse_from_results(results))
```


```python
print(len(docs))
```

```output
11
```