---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/bshtml.ipynb
description: BSHTMLLoader는 BeautifulSoup4를 사용하여 HTML 문서를 로드하는 방법을 소개하는 노트북입니다. 빠른
  시작을 위한 개요를 제공합니다.
---

# BSHTMLLoader

이 노트북은 BeautifulSoup4 [문서 로더](https://python.langchain.com/v0.2/docs/concepts/#document-loaders)를 시작하는 데 필요한 간단한 개요를 제공합니다. 모든 __ModuleName__Loader 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.html_bs.BSHTMLLoader.html)에서 확인할 수 있습니다.

## 개요
### 통합 세부정보

| 클래스 | 패키지 | 로컬 | 직렬화 가능 | JS 지원 |
| :--- | :--- | :---: | :---: |  :---: |
| [BSHTMLLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.html_bs.BSHTMLLoader.html) | [langchain_community](https://api.python.langchain.com/en/latest/community_api_reference.html) | ✅ | ❌ | ❌ | 
### 로더 기능
| 소스 | 문서 지연 로딩 | 네이티브 비동기 지원 |
| :---: | :---: | :---: |
| BSHTMLLoader | ✅ | ❌ | 

## 설정

BSHTMLLoader 문서 로더에 접근하려면 `langchain-community` 통합 패키지와 `bs4` 파이썬 패키지를 설치해야 합니다.

### 자격 증명

`BSHTMLLoader` 클래스를 사용하기 위해 필요한 자격 증명은 없습니다.

모델 호출에 대한 자동 최적 추적을 원하시면 아래의 주석을 제거하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

**langchain_community**와 **bs4**를 설치합니다.

```python
%pip install -qU langchain_community bs4
```


## 초기화

이제 모델 객체를 인스턴스화하고 문서를 로드할 수 있습니다:

- TODO: 관련 매개변수로 모델 인스턴스화를 업데이트합니다.

```python
<!--IMPORTS:[{"imported": "BSHTMLLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.html_bs.BSHTMLLoader.html", "title": "BSHTMLLoader"}]-->
from langchain_community.document_loaders import BSHTMLLoader

loader = BSHTMLLoader(
    file_path="./example_data/fake-content.html",
)
```


## 로드

```python
docs = loader.load()
docs[0]
```


```output
Document(metadata={'source': './example_data/fake-content.html', 'title': 'Test Title'}, page_content='\nTest Title\n\n\nMy First Heading\nMy first paragraph.\n\n\n')
```


```python
print(docs[0].metadata)
```

```output
{'source': './example_data/fake-content.html', 'title': 'Test Title'}
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
Document(metadata={'source': './example_data/fake-content.html', 'title': 'Test Title'}, page_content='\nTest Title\n\n\nMy First Heading\nMy first paragraph.\n\n\n')
```


## BS4에 구분자 추가

수프에서 get_text를 호출할 때 사용할 구분자를 전달할 수도 있습니다.

```python
loader = BSHTMLLoader(
    file_path="./example_data/fake-content.html", get_text_separator=", "
)

docs = loader.load()
print(docs[0])
```

```output
page_content='
, Test Title, 
, 
, 
, My First Heading, 
, My first paragraph., 
, 
, 
' metadata={'source': './example_data/fake-content.html', 'title': 'Test Title'}
```

## API 참조

모든 BSHTMLLoader 기능 및 구성에 대한 자세한 문서는 API 참조에서 확인할 수 있습니다: https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.html_bs.BSHTMLLoader.html

## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)