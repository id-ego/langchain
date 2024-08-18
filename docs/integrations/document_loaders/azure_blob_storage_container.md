---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/azure_blob_storage_container.ipynb
description: Azure Blob Storage는 대량의 비정형 데이터를 저장하고 관리하는 Microsoft의 클라우드 객체 저장 솔루션입니다.
---

# Azure Blob Storage Container

> [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) 는 Microsoft의 클라우드 객체 저장 솔루션입니다. Blob Storage는 대량의 비구조화 데이터를 저장하는 데 최적화되어 있습니다. 비구조화 데이터는 텍스트나 이진 데이터와 같이 특정 데이터 모델이나 정의를 따르지 않는 데이터입니다.

`Azure Blob Storage`는 다음을 위해 설계되었습니다:
- 이미지를 브라우저에 직접 제공하기.
- 분산 액세스를 위한 파일 저장.
- 비디오 및 오디오 스트리밍.
- 로그 파일에 쓰기.
- 백업 및 복원, 재해 복구 및 아카이빙을 위한 데이터 저장.
- 온프레미스 또는 Azure 호스팅 서비스에 의한 분석을 위한 데이터 저장.

이 노트북에서는 `Azure Blob Storage`의 컨테이너에서 문서 객체를 로드하는 방법을 다룹니다.

```python
%pip install --upgrade --quiet  azure-storage-blob
```


```python
<!--IMPORTS:[{"imported": "AzureBlobStorageContainerLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.azure_blob_storage_container.AzureBlobStorageContainerLoader.html", "title": "Azure Blob Storage Container"}]-->
from langchain_community.document_loaders import AzureBlobStorageContainerLoader
```


```python
loader = AzureBlobStorageContainerLoader(conn_str="<conn_str>", container="<container>")
```


```python
loader.load()
```


```output
[Document(page_content='Lorem ipsum dolor sit amet.', lookup_str='', metadata={'source': '/var/folders/y6/8_bzdg295ld6s1_97_12m4lr0000gn/T/tmpaa9xl6ch/fake.docx'}, lookup_index=0)]
```


## 접두사 지정
로드할 파일에 대한 보다 세밀한 제어를 위해 접두사를 지정할 수도 있습니다.

```python
loader = AzureBlobStorageContainerLoader(
    conn_str="<conn_str>", container="<container>", prefix="<prefix>"
)
```


```python
loader.load()
```


```output
[Document(page_content='Lorem ipsum dolor sit amet.', lookup_str='', metadata={'source': '/var/folders/y6/8_bzdg295ld6s1_97_12m4lr0000gn/T/tmpujbkzf_l/fake.docx'}, lookup_index=0)]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)