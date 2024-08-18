---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/google_cloud_storage_file.ipynb
description: Google Cloud Storage(GCS) 파일 객체에서 문서 객체를 로드하는 방법을 설명합니다. 대체 로더 사용에 대한
  정보도 포함되어 있습니다.
---

# 구글 클라우드 스토리지 파일

> [구글 클라우드 스토리지](https://en.wikipedia.org/wiki/Google_Cloud_Storage)는 비구조화 데이터를 저장하기 위한 관리형 서비스입니다.

이 문서는 `구글 클라우드 스토리지 (GCS) 파일 객체 (blob)`에서 문서 객체를 로드하는 방법을 다룹니다.

```python
%pip install --upgrade --quiet  langchain-google-community[gcs]
```


```python
from langchain_google_community import GCSFileLoader
```


```python
loader = GCSFileLoader(project_name="aist", bucket="testing-hwc", blob="fake.docx")
```


```python
loader.load()
```

```output
/Users/harrisonchase/workplace/langchain/.venv/lib/python3.10/site-packages/google/auth/_default.py:83: UserWarning: Your application has authenticated using end user credentials from Google Cloud SDK without a quota project. You might receive a "quota exceeded" or "API not enabled" error. We recommend you rerun `gcloud auth application-default login` and make sure a quota project is added. Or you can use service accounts instead. For more information about service accounts, see https://cloud.google.com/docs/authentication/
  warnings.warn(_CLOUD_SDK_CREDENTIALS_WARNING)
```


```output
[Document(page_content='Lorem ipsum dolor sit amet.', lookup_str='', metadata={'source': '/var/folders/y6/8_bzdg295ld6s1_97_12m4lr0000gn/T/tmp3srlf8n8/fake.docx'}, lookup_index=0)]
```


대체 로더를 사용하려면 사용자 정의 함수를 제공할 수 있습니다. 예를 들어:

```python
<!--IMPORTS:[{"imported": "PyPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html", "title": "Google Cloud Storage File"}]-->
from langchain_community.document_loaders import PyPDFLoader


def load_pdf(file_path):
    return PyPDFLoader(file_path)


loader = GCSFileLoader(
    project_name="aist", bucket="testing-hwc", blob="fake.pdf", loader_func=load_pdf
)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)