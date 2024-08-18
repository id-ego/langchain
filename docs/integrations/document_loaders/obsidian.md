---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/obsidian.ipynb
description: Obsidian은 로컬 텍스트 파일 폴더 위에서 작동하는 강력한 지식 기반으로, 문서 로딩 방법을 다룹니다.
---

# Obsidian

> [Obsidian](https://obsidian.md/)는 로컬 텍스트 파일 폴더 위에서 작동하는 강력하고 확장 가능한 지식 기반입니다.

이 노트북은 `Obsidian` 데이터베이스에서 문서를 로드하는 방법을 다룹니다.

`Obsidian`은 단순히 마크다운 파일의 폴더로 디스크에 저장되므로, 로더는 이 디렉토리에 대한 경로를 가져옵니다.

`Obsidian` 파일은 때때로 파일 상단에 있는 YAML 블록인 [메타데이터](https://help.obsidian.md/Editing+and+formatting/Metadata)를 포함하기도 합니다. 이러한 값은 문서의 메타데이터에 추가됩니다. (`ObsidianLoader`에 `collect_metadata=False` 인수를 전달하여 이 동작을 비활성화할 수도 있습니다.)

```python
<!--IMPORTS:[{"imported": "ObsidianLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.obsidian.ObsidianLoader.html", "title": "Obsidian"}]-->
from langchain_community.document_loaders import ObsidianLoader
```


```python
loader = ObsidianLoader("<path-to-obsidian>")
```


```python
docs = loader.load()
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)