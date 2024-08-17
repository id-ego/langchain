---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/tencent_cos_directory/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/tencent_cos_directory.ipynb
---

# Tencent COS Directory

>[Tencent Cloud Object Storage (COS)](https://www.tencentcloud.com/products/cos) is a distributed 
> storage service that enables you to store any amount of data from anywhere via HTTP/HTTPS protocols. 
> `COS` has no restrictions on data structure or format. It also has no bucket size limit and 
> partition management, making it suitable for virtually any use case, such as data delivery, 
> data processing, and data lakes. `COS` provides a web-based console, multi-language SDKs and APIs, 
> command line tool, and graphical tools. It works well with Amazon S3 APIs, allowing you to quickly 
> access community tools and plugins.


This covers how to load document objects from a `Tencent COS Directory`.


```python
%pip install --upgrade --quiet  cos-python-sdk-v5
```


```python
<!--IMPORTS:[{"imported": "TencentCOSDirectoryLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.tencent_cos_directory.TencentCOSDirectoryLoader.html", "title": "Tencent COS Directory"}]-->
from langchain_community.document_loaders import TencentCOSDirectoryLoader
from qcloud_cos import CosConfig
```


```python
conf = CosConfig(
    Region="your cos region",
    SecretId="your cos secret_id",
    SecretKey="your cos secret_key",
)
loader = TencentCOSDirectoryLoader(conf=conf, bucket="you_cos_bucket")
```


```python
loader.load()
```

## Specifying a prefix
You can also specify a prefix for more finegrained control over what files to load.


```python
loader = TencentCOSDirectoryLoader(conf=conf, bucket="you_cos_bucket", prefix="fake")
```


```python
loader.load()
```


## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)