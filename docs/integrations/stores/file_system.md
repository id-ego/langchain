---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/stores/file_system.ipynb
description: '`LocalFileStore`는 선택한 폴더에 데이터를 저장하는 지속적인 `ByteStore` 구현체로, 단일 머신에서 사용하기에
  적합합니다.'
sidebar_label: Local Filesystem
---

# LocalFileStore

이 문서는 로컬 파일 시스템 [키-값 저장소](/docs/concepts/#key-value-stores)를 시작하는 데 도움이 됩니다. 모든 LocalFileStore 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/storage/langchain.storage.file_system.LocalFileStore.html)에서 확인하세요.

## 개요

`LocalFileStore`는 선택한 폴더에 모든 것을 저장하는 `ByteStore`의 지속적인 구현입니다. 단일 머신을 사용하고 파일이 추가되거나 삭제되는 것에 관대하다면 유용합니다.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/stores/file_system) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [LocalFileStore](https://api.python.langchain.com/en/latest/storage/langchain.storage.file_system.LocalFileStore.html) | [langchain](https://api.python.langchain.com/en/latest/langchain_api_reference.html) | ✅ | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain?style=flat-square&label=%20) |

### 설치

LangChain `LocalFileStore` 통합은 `langchain` 패키지에 있습니다:

```python
%pip install -qU langchain
```


## 인스턴스화

이제 우리의 바이트 저장소를 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "LocalFileStore", "source": "langchain.storage", "docs": "https://api.python.langchain.com/en/latest/storage/langchain.storage.file_system.LocalFileStore.html", "title": "LocalFileStore"}]-->
from pathlib import Path

from langchain.storage import LocalFileStore

root_path = Path.cwd() / "data"  # can also be a path set by a string

kv_store = LocalFileStore(root_path)
```


## 사용법

`mset` 메서드를 사용하여 다음과 같이 키 아래에 데이터를 설정할 수 있습니다:

```python
kv_store.mset(
    [
        ["key1", b"value1"],
        ["key2", b"value2"],
    ]
)

kv_store.mget(
    [
        "key1",
        "key2",
    ]
)
```


```output
[b'value1', b'value2']
```


생성된 파일은 `data` 폴더에서 확인할 수 있습니다:

```python
!ls {root_path}
```

```output
key1 key2
```

그리고 `mdelete` 메서드를 사용하여 데이터를 삭제할 수 있습니다:

```python
kv_store.mdelete(
    [
        "key1",
        "key2",
    ]
)

kv_store.mget(
    [
        "key1",
        "key2",
    ]
)
```


```output
[None, None]
```


## API 참조

모든 `LocalFileStore` 기능 및 구성에 대한 자세한 문서는 API 참조를 확인하세요: https://api.python.langchain.com/en/latest/storage/langchain.storage.file_system.LocalFileStore.html

## 관련

- [키-값 저장소 개념 가이드](/docs/concepts/#key-value-stores)