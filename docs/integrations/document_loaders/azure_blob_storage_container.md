---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/azure_blob_storage_container/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/azure_blob_storage_container.ipynb
---

# Azure Blob Storage Container

>[Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) is Microsoft's object storage solution for the cloud. Blob Storage is optimized for storing massive amounts of unstructured data. Unstructured data is data that doesn't adhere to a particular data model or definition, such as text or binary data.

`Azure Blob Storage` is designed for:
- Serving images or documents directly to a browser.
- Storing files for distributed access.
- Streaming video and audio.
- Writing to log files.
- Storing data for backup and restore, disaster recovery, and archiving.
- Storing data for analysis by an on-premises or Azure-hosted service.

This notebook covers how to load document objects from a container on `Azure Blob Storage`.


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


## Specifying a prefix
You can also specify a prefix for more finegrained control over what files to load.


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



## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)