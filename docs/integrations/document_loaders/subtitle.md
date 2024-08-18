---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/subtitle.ipynb
description: 이 문서는 SubRip 파일 형식(.srt)에 대한 설명과 자막 파일에서 데이터를 로드하는 방법을 안내합니다.
---

# 자막

> [SubRip 파일 형식](https://en.wikipedia.org/wiki/SubRip#SubRip_file_format)은 `Matroska` 멀티미디어 컨테이너 형식 웹사이트에서 "모든 자막 형식 중 가장 기본적인 형식일 수 있다"고 설명됩니다. `SubRip (SubRip Text)` 파일은 `.srt` 확장자로 명명되며, 공백 줄로 구분된 그룹의 형식이 지정된 일반 텍스트 줄을 포함합니다. 자막은 1부터 시작하여 순차적으로 번호가 매겨집니다. 사용되는 타임코드 형식은 시간:분:초,밀리초이며, 시간 단위는 두 자리로 0으로 채워지고 분수는 세 자리로 0으로 채워집니다 (00:00:00,000). 사용되는 분수 구분자는 쉼표이며, 프로그램이 프랑스에서 작성되었기 때문입니다.

자막(`.srt`) 파일에서 데이터 로드하는 방법

여기에서 [예제 .srt 파일을 다운로드하세요](https://www.opensubtitles.org/en/subtitles/5575150/star-wars-the-clone-wars-crisis-at-the-heart-en).

```python
%pip install --upgrade --quiet  pysrt
```


```python
<!--IMPORTS:[{"imported": "SRTLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.srt.SRTLoader.html", "title": "Subtitle"}]-->
from langchain_community.document_loaders import SRTLoader
```


```python
loader = SRTLoader(
    "example_data/Star_Wars_The_Clone_Wars_S06E07_Crisis_at_the_Heart.srt"
)
```


```python
docs = loader.load()
```


```python
docs[0].page_content[:100]
```


```output
'<i>Corruption discovered\nat the core of the Banking Clan!</i> <i>Reunited, Rush Clovis\nand Senator A'
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)