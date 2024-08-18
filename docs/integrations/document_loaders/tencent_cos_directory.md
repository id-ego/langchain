---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/tencent_cos_directory.ipynb
description: Tencent COS는 HTTP/HTTPS 프로토콜을 통해 데이터를 저장할 수 있는 분산 스토리지 서비스로, 다양한 사용 사례에
  적합합니다.
---

# Tencent COS 디렉토리

> [Tencent Cloud Object Storage (COS)](https://www.tencentcloud.com/products/cos)는 HTTP/HTTPS 프로토콜을 통해 어디서나 데이터를 저장할 수 있는 분산 저장 서비스입니다. `COS`는 데이터 구조나 형식에 대한 제한이 없습니다. 또한 버킷 크기 제한과 파티션 관리가 없어 데이터 전달, 데이터 처리, 데이터 레이크와 같은 거의 모든 사용 사례에 적합합니다. `COS`는 웹 기반 콘솔, 다국어 SDK 및 API, 명령줄 도구, 그래픽 도구를 제공합니다. Amazon S3 API와 잘 작동하여 커뮤니티 도구 및 플러그인에 빠르게 접근할 수 있습니다.

이 문서는 `Tencent COS 디렉토리`에서 문서 객체를 로드하는 방법을 다룹니다.

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


## 접두사 지정
더 세밀한 제어를 위해 로드할 파일의 접두사를 지정할 수도 있습니다.

```python
loader = TencentCOSDirectoryLoader(conf=conf, bucket="you_cos_bucket", prefix="fake")
```


```python
loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)