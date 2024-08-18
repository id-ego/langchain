---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/wikipedia.ipynb
description: 위키백과에서 문서를 로드하는 방법을 보여주는 노트북으로, `wikipedia` 파이썬 패키지를 사용하여 문서 형식으로 변환합니다.
---

# 위키백과

> [위키백과](https://wikipedia.org/)는 위키피디언으로 알려진 자원봉사자 커뮤니티에 의해 작성되고 유지되는 다국어 무료 온라인 백과사전으로, 열린 협업을 통해 MediaWiki라는 위키 기반 편집 시스템을 사용합니다. `위키백과`는 역사상 가장 크고 가장 많이 읽힌 참고 자료입니다.

이 노트북은 `wikipedia.org`에서 위키 페이지를 우리가 하류에서 사용하는 문서 형식으로 로드하는 방법을 보여줍니다.

## 설치

먼저, `wikipedia` 파이썬 패키지를 설치해야 합니다.

```python
%pip install --upgrade --quiet  wikipedia
```


## 예제

`WikipediaLoader`는 다음과 같은 인수를 가집니다:
- `query`: 위키백과에서 문서를 찾는 데 사용되는 자유 텍스트
- 선택적 `lang`: 기본값="en". 특정 언어 부분의 위키백과에서 검색하는 데 사용합니다.
- 선택적 `load_max_docs`: 기본값=100. 다운로드할 문서 수를 제한하는 데 사용합니다. 100개의 문서를 모두 다운로드하는 데 시간이 걸리므로 실험을 위해 작은 수를 사용하세요. 현재 하드 리미트는 300입니다.
- 선택적 `load_all_available_meta`: 기본값=False. 기본적으로 가장 중요한 필드만 다운로드됩니다: `Published` (문서가 게시/최종 업데이트된 날짜), `title`, `Summary`. True일 경우 다른 필드도 다운로드됩니다.

```python
<!--IMPORTS:[{"imported": "WikipediaLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.wikipedia.WikipediaLoader.html", "title": "Wikipedia"}]-->
from langchain_community.document_loaders import WikipediaLoader
```


```python
docs = WikipediaLoader(query="HUNTER X HUNTER", load_max_docs=2).load()
len(docs)
```


```python
docs[0].metadata  # meta-information of the Document
```


```python
docs[0].page_content[:400]  # a content of the Document
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)