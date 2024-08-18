---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/conll-u.ipynb
description: CoNLL-U 형식은 단어 주석을 포함한 텍스트 파일로, 문장 경계를 표시하는 빈 줄과 주석이 포함됩니다.
---

# CoNLL-U

> [CoNLL-U](https://universaldependencies.org/format.html)는 CoNLL-X 형식의 수정된 버전입니다. 주석은 세 가지 유형의 줄이 포함된 일반 텍스트 파일(UTF-8, NFC로 정규화, 줄 바꿈에 LF 문자만 사용, 파일 끝에 LF 문자 포함)로 인코딩됩니다:
> - 단어 줄은 단일 탭 문자로 구분된 10개의 필드에 단어/토큰의 주석을 포함합니다; 아래를 참조하십시오.
> - 문장 경계를 표시하는 빈 줄.
> - 해시(#)로 시작하는 주석 줄.

이것은 [CoNLL-U](https://universaldependencies.org/format.html) 형식의 파일을 로드하는 방법의 예입니다. 전체 파일은 하나의 문서로 처리됩니다. 예제 데이터(`conllu.conllu`)는 표준 UD/CoNLL-U 예제 중 하나를 기반으로 합니다.

```python
<!--IMPORTS:[{"imported": "CoNLLULoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.conllu.CoNLLULoader.html", "title": "CoNLL-U"}]-->
from langchain_community.document_loaders import CoNLLULoader
```


```python
loader = CoNLLULoader("example_data/conllu.conllu")
```


```python
document = loader.load()
```


```python
document
```


```output
[Document(page_content='They buy and sell books.', metadata={'source': 'example_data/conllu.conllu'})]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)