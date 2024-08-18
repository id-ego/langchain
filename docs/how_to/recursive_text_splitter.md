---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/recursive_text_splitter.ipynb
description: 텍스트를 문자로 재귀적으로 분할하는 방법에 대한 설명으로, 기본 문자 목록과 사용 예제를 제공합니다.
keywords:
- recursivecharactertextsplitter
---

# 문자를 기준으로 텍스트를 재귀적으로 분할하는 방법

이 텍스트 분할기는 일반 텍스트에 권장되는 것입니다. 문자 목록으로 매개변수화되어 있습니다. 이 목록의 문자들로 순차적으로 분할을 시도하여 조각이 충분히 작아질 때까지 진행합니다. 기본 목록은 `["\n\n", "\n", " ", ""]`입니다. 이는 모든 단락(그리고 문장, 그리고 단어)을 가능한 한 오랫동안 함께 유지하려고 시도하는 효과가 있으며, 일반적으로 의미적으로 가장 관련성이 높은 텍스트 조각으로 보입니다.

1. 텍스트가 분할되는 방법: 문자 목록에 의해.
2. 청크 크기가 측정되는 방법: 문자 수에 의해.

아래에 예제 사용법을 보여줍니다.

문자열 내용을 직접 얻으려면 `.split_text`를 사용하십시오.

LangChain [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 객체를 생성하려면 (예: 다운스트림 작업에 사용하기 위해) `.create_documents`를 사용하십시오.

```python
%pip install -qU langchain-text-splitters
```


```python
<!--IMPORTS:[{"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to recursively split text by characters"}]-->
from langchain_text_splitters import RecursiveCharacterTextSplitter

# Load example document
with open("state_of_the_union.txt") as f:
    state_of_the_union = f.read()

text_splitter = RecursiveCharacterTextSplitter(
    # Set a really small chunk size, just to show.
    chunk_size=100,
    chunk_overlap=20,
    length_function=len,
    is_separator_regex=False,
)
texts = text_splitter.create_documents([state_of_the_union])
print(texts[0])
print(texts[1])
```

```output
page_content='Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and'
page_content='of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.'
```


```python
text_splitter.split_text(state_of_the_union)[:2]
```


```output
['Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and',
 'of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.']
```


`RecursiveCharacterTextSplitter`에 대해 설정된 매개변수를 살펴보겠습니다:
- `chunk_size`: 청크의 최대 크기, 크기는 `length_function`에 의해 결정됩니다.
- `chunk_overlap`: 청크 간의 목표 중첩. 중첩된 청크는 컨텍스트가 청크 간에 나뉘었을 때 정보 손실을 완화하는 데 도움이 됩니다.
- `length_function`: 청크 크기를 결정하는 함수.
- `is_separator_regex`: 구분자 목록(기본값 `["\n\n", "\n", " ", ""]`)을 정규 표현식으로 해석해야 하는지 여부.

## 단어 경계가 없는 언어에서 텍스트 분할하기

일부 문자 체계는 [단어 경계](https://en.wikipedia.org/wiki/Category:Writing_systems_without_word_boundaries)가 없습니다. 예를 들어, 중국어, 일본어, 태국어가 있습니다. 기본 구분자 목록인 `["\n\n", "\n", " ", ""]`로 텍스트를 분할하면 단어가 청크 사이에서 나뉘어질 수 있습니다. 단어를 함께 유지하려면 구분자 목록을 추가 구두점을 포함하도록 재정의할 수 있습니다:

* ASCII 마침표 "`.`", [유니코드 전폭](https://en.wikipedia.org/wiki/Halfwidth_and_Fullwidth_Forms_(Unicode_block)) 마침표 "`．`" (중국어 텍스트에서 사용됨), 및 [표의 마침표](https://en.wikipedia.org/wiki/CJK_Symbols_and_Punctuation) "`。`" (일본어 및 중국어에서 사용됨) 추가
* 태국어, 미얀마어, 크메르어 및 일본어에서 사용되는 [제로 너비 공백](https://en.wikipedia.org/wiki/Zero-width_space) 추가
* ASCII 쉼표 "`,`", 유니코드 전폭 쉼표 "`，`", 및 유니코드 표의 쉼표 "`、`" 추가

```python
text_splitter = RecursiveCharacterTextSplitter(
    separators=[
        "\n\n",
        "\n",
        " ",
        ".",
        ",",
        "\u200b",  # Zero-width space
        "\uff0c",  # Fullwidth comma
        "\u3001",  # Ideographic comma
        "\uff0e",  # Fullwidth full stop
        "\u3002",  # Ideographic full stop
        "",
    ],
    # Existing args
)
```