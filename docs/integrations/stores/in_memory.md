---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/stores/in_memory.ipynb
description: 이 가이드는 비휘발성 `InMemoryByteStore`의 사용법을 안내하며, Python 프로세스의 생애 동안 데이터를 메모리에
  저장합니다.
sidebar_label: In-memory
---

# InMemoryByteStore

이 가이드는 인메모리 [키-값 저장소](/docs/concepts/#key-value-stores)를 시작하는 데 도움이 될 것입니다. `InMemoryByteStore`의 모든 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/stores/langchain_core.stores.InMemoryByteStore.html)에서 확인할 수 있습니다.

## 개요

`InMemoryByteStore`는 모든 것을 Python 딕셔너리에 저장하는 비영속적인 `ByteStore` 구현입니다. 이는 데모 및 Python 프로세스의 수명 이상으로 지속성이 필요하지 않은 경우를 위해 설계되었습니다.

### 통합 세부정보

| 클래스 | 패키지 | 로컬 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/stores/in_memory/) | 패키지 다운로드 | 패키지 최신 |
| :--- | :--- | :---: | :---: |  :---: | :---: |
| [InMemoryByteStore](https://api.python.langchain.com/en/latest/stores/langchain_core.stores.InMemoryByteStore.html) | [langchain_core](https://api.python.langchain.com/en/latest/core_api_reference.html) | ✅ | ✅ | ![PyPI - Downloads](https://img.shields.io/pypi/dm/langchain_core?style=flat-square&label=%20) | ![PyPI - Version](https://img.shields.io/pypi/v/langchain_core?style=flat-square&label=%20) |

### 설치

LangChain `InMemoryByteStore` 통합은 `langchain_core` 패키지에 있습니다:

```python
%pip install -qU langchain_core
```


## 인스턴스화

이제 바이트 저장소를 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "InMemoryByteStore", "source": "langchain_core.stores", "docs": "https://api.python.langchain.com/en/latest/stores/langchain_core.stores.InMemoryByteStore.html", "title": "InMemoryByteStore"}]-->
from langchain_core.stores import InMemoryByteStore

kv_store = InMemoryByteStore()
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

`InMemoryByteStore`의 모든 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/stores/langchain_core.stores.InMemoryByteStore.html

## 관련

- [키-값 저장소 개념 가이드](/docs/concepts/#key-value-stores)