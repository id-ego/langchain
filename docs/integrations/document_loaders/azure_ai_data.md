---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/azure_ai_data.ipynb
description: Azure AI Studio를 통해 클라우드 스토리지에 데이터 자산을 업로드하고 등록하는 방법을 다루는 문서입니다.
---

# Azure AI 데이터

> [Azure AI Studio](https://ai.azure.com/)는 클라우드 스토리지에 데이터 자산을 업로드하고 다음 소스에서 기존 데이터 자산을 등록할 수 있는 기능을 제공합니다:
> 
> - `Microsoft OneLake`
> - `Azure Blob Storage`
> - `Azure Data Lake gen 2`

이 접근 방식의 장점은 `AzureBlobStorageContainerLoader` 및 `AzureBlobStorageFileLoader`에 비해 인증이 클라우드 스토리지에 원활하게 처리된다는 것입니다. 데이터에 대한 *아이덴티티 기반* 데이터 접근 제어 또는 *자격 증명 기반* (예: SAS 토큰, 계정 키)을 사용할 수 있습니다. 자격 증명 기반 데이터 접근의 경우 코드에 비밀을 지정하거나 키 볼트를 설정할 필요가 없습니다 - 시스템이 이를 대신 처리합니다.

이 노트북은 AI Studio에서 데이터 자산의 문서 객체를 로드하는 방법을 다룹니다.

```python
%pip install --upgrade --quiet  azureml-fsspec, azure-ai-generative
```


```python
<!--IMPORTS:[{"imported": "AzureAIDataLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.azure_ai_data.AzureAIDataLoader.html", "title": "Azure AI Data"}]-->
from azure.ai.resources.client import AIClient
from azure.identity import DefaultAzureCredential
from langchain_community.document_loaders import AzureAIDataLoader
```


```python
# Create a connection to your project
client = AIClient(
    credential=DefaultAzureCredential(),
    subscription_id="<subscription_id>",
    resource_group_name="<resource_group_name>",
    project_name="<project_name>",
)
```


```python
# get the latest version of your data asset
data_asset = client.data.get(name="<data_asset_name>", label="latest")
```


```python
# load the data asset
loader = AzureAIDataLoader(url=data_asset.path)
```


```python
loader.load()
```


```output
[Document(page_content='Lorem ipsum dolor sit amet.', lookup_str='', metadata={'source': '/var/folders/y6/8_bzdg295ld6s1_97_12m4lr0000gn/T/tmpaa9xl6ch/fake.docx'}, lookup_index=0)]
```


## 글로브 패턴 지정
더 세밀한 파일 로드 제어를 위해 글로브 패턴을 지정할 수도 있습니다. 아래 예제에서는 `pdf` 확장자를 가진 파일만 로드됩니다.

```python
loader = AzureAIDataLoader(url=data_asset.path, glob="*.pdf")
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