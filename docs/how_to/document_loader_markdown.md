---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/document_loader_markdown.ipynb
description: Markdown 문서를 LangChain의 Document 객체로 로드하는 방법과 제목, 목록 항목, 텍스트 등의 요소로 파싱하는
  방법을 설명합니다.
---

# Markdown 로드하는 방법

[Markdown](https://en.wikipedia.org/wiki/Markdown)은 일반 텍스트 편집기를 사용하여 형식이 지정된 텍스트를 생성하기 위한 경량 마크업 언어입니다.

여기에서는 `Markdown` 문서를 LangChain [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html#langchain_core.documents.base.Document) 객체로 로드하는 방법을 다룹니다. 이 객체는 이후에 사용할 수 있습니다.

우리는 다음을 다룰 것입니다:

- 기본 사용법;
- 제목, 목록 항목 및 텍스트와 같은 요소로 Markdown 구문 분석.

LangChain은 [UnstructuredMarkdownLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html) 객체를 구현하며, 이는 [Unstructured](https://unstructured-io.github.io/unstructured/) 패키지를 필요로 합니다. 먼저 이를 설치합니다:

```python
%pip install "unstructured[md]"
```


기본 사용법은 Markdown 파일을 단일 문서로 가져옵니다. 여기에서는 LangChain의 readme를 시연합니다:

```python
<!--IMPORTS:[{"imported": "UnstructuredMarkdownLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html", "title": "How to load Markdown"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "How to load Markdown"}]-->
from langchain_community.document_loaders import UnstructuredMarkdownLoader
from langchain_core.documents import Document

markdown_path = "../../../README.md"
loader = UnstructuredMarkdownLoader(markdown_path)

data = loader.load()
assert len(data) == 1
assert isinstance(data[0], Document)
readme_content = data[0].page_content
print(readme_content[:250])
```

```output
🦜️🔗 LangChain

⚡ Build context-aware reasoning applications ⚡

Looking for the JS/TS library? Check out LangChain.js.

To help you ship LangChain apps to production faster, check out LangSmith. 
LangSmith is a unified developer platform for building,
```

## 요소 유지

언더 후드에서는 Unstructured가 서로 다른 텍스트 덩어리에 대해 서로 다른 "요소"를 생성합니다. 기본적으로 우리는 그것들을 결합하지만, `mode="elements"`를 지정하여 쉽게 그 분리를 유지할 수 있습니다.

```python
loader = UnstructuredMarkdownLoader(markdown_path, mode="elements")

data = loader.load()
print(f"Number of documents: {len(data)}\n")

for document in data[:2]:
    print(f"{document}\n")
```

```output
Number of documents: 66

page_content='🦜️🔗 LangChain' metadata={'source': '../../../README.md', 'category_depth': 0, 'last_modified': '2024-06-28T15:20:01', 'languages': ['eng'], 'filetype': 'text/markdown', 'file_directory': '../../..', 'filename': 'README.md', 'category': 'Title'}

page_content='⚡ Build context-aware reasoning applications ⚡' metadata={'source': '../../../README.md', 'last_modified': '2024-06-28T15:20:01', 'languages': ['eng'], 'parent_id': '200b8a7d0dd03f66e4f13456566d2b3a', 'filetype': 'text/markdown', 'file_directory': '../../..', 'filename': 'README.md', 'category': 'NarrativeText'}
```

이 경우 우리는 세 가지 뚜렷한 요소 유형을 복구한다는 점에 유의하십시오:

```python
print(set(document.metadata["category"] for document in data))
```

```output
{'ListItem', 'NarrativeText', 'Title'}
```