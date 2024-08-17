---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/azure_blob_storage_file/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/azure_blob_storage_file.ipynb
---

# Azure Blob Storage File

> [Azure Files](https://learn.microsoft.com/en-us/azure/storage/files/storage-files-introduction) offers fully managed file shares in the cloud that are accessible via the industry standard Server Message Block (`SMB`) protocol, Network File System (`NFS`) protocol, and `Azure Files REST API`.

This covers how to load document objects from a Azure Files.

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

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)