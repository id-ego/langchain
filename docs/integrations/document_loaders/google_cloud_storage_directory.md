---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_cloud_storage_directory.ipynb
description: Google Cloud Storage(GCS) 디렉토리에서 문서 객체를 로드하는 방법에 대해 설명합니다. 파일 로드 및 오류
  처리 방법도 포함되어 있습니다.
---

# 구글 클라우드 스토리지 디렉토리

> [구글 클라우드 스토리지](https://en.wikipedia.org/wiki/Google_Cloud_Storage)는 비구조화 데이터를 저장하기 위한 관리형 서비스입니다.

이 문서는 `구글 클라우드 스토리지 (GCS) 디렉토리 (버킷)`에서 문서 객체를 로드하는 방법을 다룹니다.

```python
%pip install --upgrade --quiet  langchain-google-community[gcs]
```


```python
from langchain_google_community import GCSDirectoryLoader
```


```python
loader = GCSDirectoryLoader(project_name="aist", bucket="testing-hwc")
```


```python
loader.load()
```

```output
/Users/harrisonchase/workplace/langchain/.venv/lib/python3.10/site-packages/google/auth/_default.py:83: UserWarning: Your application has authenticated using end user credentials from Google Cloud SDK without a quota project. You might receive a "quota exceeded" or "API not enabled" error. We recommend you rerun `gcloud auth application-default login` and make sure a quota project is added. Or you can use service accounts instead. For more information about service accounts, see https://cloud.google.com/docs/authentication/
  warnings.warn(_CLOUD_SDK_CREDENTIALS_WARNING)
/Users/harrisonchase/workplace/langchain/.venv/lib/python3.10/site-packages/google/auth/_default.py:83: UserWarning: Your application has authenticated using end user credentials from Google Cloud SDK without a quota project. You might receive a "quota exceeded" or "API not enabled" error. We recommend you rerun `gcloud auth application-default login` and make sure a quota project is added. Or you can use service accounts instead. For more information about service accounts, see https://cloud.google.com/docs/authentication/
  warnings.warn(_CLOUD_SDK_CREDENTIALS_WARNING)
```


```output
[Document(page_content='Lorem ipsum dolor sit amet.', lookup_str='', metadata={'source': '/var/folders/y6/8_bzdg295ld6s1_97_12m4lr0000gn/T/tmpz37njh7u/fake.docx'}, lookup_index=0)]
```


## 접두사 지정
특정 폴더에서 모든 파일을 로드하는 것을 포함하여 로드할 파일에 대한 보다 세밀한 제어를 위해 접두사를 지정할 수도 있습니다.

```python
loader = GCSDirectoryLoader(project_name="aist", bucket="testing-hwc", prefix="fake")
```


```python
loader.load()
```

```output
/Users/harrisonchase/workplace/langchain/.venv/lib/python3.10/site-packages/google/auth/_default.py:83: UserWarning: Your application has authenticated using end user credentials from Google Cloud SDK without a quota project. You might receive a "quota exceeded" or "API not enabled" error. We recommend you rerun `gcloud auth application-default login` and make sure a quota project is added. Or you can use service accounts instead. For more information about service accounts, see https://cloud.google.com/docs/authentication/
  warnings.warn(_CLOUD_SDK_CREDENTIALS_WARNING)
/Users/harrisonchase/workplace/langchain/.venv/lib/python3.10/site-packages/google/auth/_default.py:83: UserWarning: Your application has authenticated using end user credentials from Google Cloud SDK without a quota project. You might receive a "quota exceeded" or "API not enabled" error. We recommend you rerun `gcloud auth application-default login` and make sure a quota project is added. Or you can use service accounts instead. For more information about service accounts, see https://cloud.google.com/docs/authentication/
  warnings.warn(_CLOUD_SDK_CREDENTIALS_WARNING)
```


```output
[Document(page_content='Lorem ipsum dolor sit amet.', lookup_str='', metadata={'source': '/var/folders/y6/8_bzdg295ld6s1_97_12m4lr0000gn/T/tmpylg6291i/fake.docx'}, lookup_index=0)]
```


## 단일 파일 로드 실패 시 계속 진행
GCS 버킷의 파일은 처리 중 오류를 발생시킬 수 있습니다. `continue_on_failure=True` 인수를 활성화하여 조용한 실패를 허용합니다. 이는 단일 파일을 처리하는 데 실패하더라도 함수가 중단되지 않으며, 대신 경고를 기록합니다.

```python
loader = GCSDirectoryLoader(
    project_name="aist", bucket="testing-hwc", continue_on_failure=True
)
```


```python
loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)