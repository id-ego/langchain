---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/azure_blob_storage_file.ipynb
description: Azure Files를 사용하여 클라우드에서 문서 객체를 로드하는 방법을 설명합니다. SMB, NFS, REST API를 통해
  접근 가능합니다.
---

# Azure Blob Storage 파일

> [Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-introduction)는 업계 표준 서버 메시지 블록(`SMB`) 프로토콜, 네트워크 파일 시스템(`NFS`) 프로토콜 및 `Azure Files REST API`를 통해 접근할 수 있는 완전 관리형 파일 공유를 클라우드에서 제공합니다.

이 문서는 Azure Files에서 문서 객체를 로드하는 방법을 다룹니다.

```python
%pip install --upgrade --quiet  azure-storage-blob
```


```python
<!--IMPORTS:[{"imported": "AzureBlobStorageFileLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.azure_blob_storage_file.AzureBlobStorageFileLoader.html", "title": "Azure Blob Storage File"}]-->
from langchain_community.document_loaders import AzureBlobStorageFileLoader
```


```python
loader = AzureBlobStorageFileLoader(
    conn_str="<connection string>",
    container="<container name>",
    blob_name="<blob name>",
)
```


```python
loader.load()
```


```output
[Document(page_content='Lorem ipsum dolor sit amet.', lookup_str='', metadata={'source': '/var/folders/y6/8_bzdg295ld6s1_97_12m4lr0000gn/T/tmpxvave6wl/fake.docx'}, lookup_index=0)]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)