---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/unstructured_markdown.ipynb
description: UnstructuredMarkdownLoader를 사용하여 비구조화된 Markdown 문서를 쉽게 로드하고 처리하는 방법에
  대한 간단한 개요를 제공합니다.
---

# 비구조화된MarkdownLoader

이 노트북은 비구조화된Markdown [문서 로더](https://python.langchain.com/v0.2/docs/concepts/#document-loaders)를 시작하는 데 필요한 간단한 개요를 제공합니다. 모든 __ModuleName__Loader 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html)로 이동하세요.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | [JS 지원](https://js.langchain.com/v0.2/docs/integrations/document_loaders/file_loaders/unstructured/)|
| :--- | :--- | :---: | :---: |  :---: |
| [UnstructuredMarkdownLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ❌ | ❌ | ✅ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원
| :---: | :---: | :---: |
| UnstructuredMarkdownLoader | ✅ | ❌ | 

## 설정

UnstructuredMarkdownLoader 문서 로더에 접근하려면 `langchain-community` 통합 패키지와 `unstructured` 파이썬 패키지를 설치해야 합니다.

### 자격 증명

이 로더를 사용하기 위해서는 자격 증명이 필요하지 않습니다.

모델 호출에 대한 자동화된 최상의 추적을 원하시면 아래의 [LangSmith](https://docs.smith.langchain.com/) API 키를 주석 해제하여 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

**langchain_community** 및 **unstructured** 설치

```python
%pip install -qU langchain_community unstructured
```


## 초기화

이제 모델 객체를 인스턴스화하고 문서를 로드할 수 있습니다.

로더는 "single" 모드와 "elements" 모드 중 하나로 실행할 수 있습니다. "single" 모드를 사용하면 문서가 단일 `Document` 객체로 반환됩니다. "elements" 모드를 사용하면 비구조화 라이브러리가 문서를 `Title` 및 `NarrativeText`와 같은 요소로 분할합니다. 모드 뒤에 추가 `unstructured` kwargs를 전달하여 다양한 `unstructured` 설정을 적용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "UnstructuredMarkdownLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html", "title": "UnstructuredMarkdownLoader"}]-->
from langchain_community.document_loaders import UnstructuredMarkdownLoader

loader = UnstructuredMarkdownLoader(
    "./example_data/example.md",
    mode="single",
    strategy="fast",
)
```


## 로드

```python
docs = loader.load()
docs[0]
```


```output
Document(metadata={'source': './example_data/example.md'}, page_content='Sample Markdown Document\n\nIntroduction\n\nWelcome to this sample Markdown document. Markdown is a lightweight markup language used for formatting text. It\'s widely used for documentation, readme files, and more.\n\nFeatures\n\nHeaders\n\nMarkdown supports multiple levels of headers:\n\nHeader 1: # Header 1\n\nHeader 2: ## Header 2\n\nHeader 3: ### Header 3\n\nLists\n\nUnordered List\n\nItem 1\n\nItem 2\n\nSubitem 2.1\n\nSubitem 2.2\n\nOrdered List\n\nFirst item\n\nSecond item\n\nThird item\n\nLinks\n\nOpenAI is an AI research organization.\n\nImages\n\nHere\'s an example image:\n\nCode\n\nInline Code\n\nUse code for inline code snippets.\n\nCode Block\n\n```python def greet(name): return f"Hello, {name}!"\n\nprint(greet("World")) ```')
```


```python
print(docs[0].metadata)
```

```output
{'source': './example_data/example.md'}
```

## 지연 로드

```python
page = []
for doc in loader.lazy_load():
    page.append(doc)
    if len(page) >= 10:
        # do some paged operation, e.g.
        # index.upsert(page)

        page = []
page[0]
```


```output
Document(metadata={'source': './example_data/example.md', 'link_texts': ['OpenAI'], 'link_urls': ['https://www.openai.com'], 'last_modified': '2024-08-14T15:04:18', 'languages': ['eng'], 'parent_id': 'de1f74bf226224377ab4d8b54f215bb9', 'filetype': 'text/markdown', 'file_directory': './example_data', 'filename': 'example.md', 'category': 'NarrativeText', 'element_id': '898a542a261f7dc65e0072d1e847d535'}, page_content='OpenAI is an AI research organization.')
```


## 요소 로드

이 예제에서는 `elements` 모드로 로드하여 마크다운 문서의 다양한 요소 목록을 반환합니다:

```python
<!--IMPORTS:[{"imported": "UnstructuredMarkdownLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html", "title": "UnstructuredMarkdownLoader"}]-->
from langchain_community.document_loaders import UnstructuredMarkdownLoader

loader = UnstructuredMarkdownLoader(
    "./example_data/example.md",
    mode="elements",
    strategy="fast",
)

docs = loader.load()
len(docs)
```


```output
29
```


보시다시피 `example.md` 파일에서 29개의 요소가 추출되었습니다. 첫 번째 요소는 예상대로 문서의 제목입니다:

```python
docs[0].page_content
```


```output
'Sample Markdown Document'
```


## API 참조

모든 UnstructuredMarkdownLoader 기능 및 구성에 대한 자세한 문서는 API 참조를 참조하세요: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.markdown.UnstructuredMarkdownLoader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)