---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/character_text_splitter.ipynb
description: 이 문서는 특정 문자로 텍스트를 분할하는 방법과 LangChain 문서 객체를 생성하는 방법에 대해 설명합니다.
keywords:
- charactertextsplitter
---

# 문자로 나누는 방법

가장 간단한 방법입니다. 이는 주어진 문자 시퀀스를 기준으로 나누며, 기본값은 `"\n\n"`입니다. 청크 길이는 문자 수로 측정됩니다.

1. 텍스트가 나누어지는 방법: 단일 문자 구분 기호로.
2. 청크 크기가 측정되는 방법: 문자 수로.

문자열 내용을 직접 얻으려면 `.split_text`를 사용하세요.

LangChain [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) 객체를 생성하려면 (예: 하위 작업에서 사용하기 위해) `.create_documents`를 사용하세요.

```python
%pip install -qU langchain-text-splitters
```


```python
<!--IMPORTS:[{"imported": "CharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.CharacterTextSplitter.html", "title": "How to split by character"}]-->
from langchain_text_splitters import CharacterTextSplitter

# Load an example document
with open("state_of_the_union.txt") as f:
    state_of_the_union = f.read()

text_splitter = CharacterTextSplitter(
    separator="\n\n",
    chunk_size=1000,
    chunk_overlap=200,
    length_function=len,
    is_separator_regex=False,
)
texts = text_splitter.create_documents([state_of_the_union])
print(texts[0])
```

```output
page_content='Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  \n\nLast year COVID-19 kept us apart. This year we are finally together again. \n\nTonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. \n\nWith a duty to one another to the American people to the Constitution. \n\nAnd with an unwavering resolve that freedom will always triumph over tyranny. \n\nSix days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. \n\nHe thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. \n\nHe met the Ukrainian people. \n\nFrom President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world.'
```

각 문서와 관련된 메타데이터를 출력 청크로 전파하려면 `.create_documents`를 사용하세요:

```python
metadatas = [{"document": 1}, {"document": 2}]
documents = text_splitter.create_documents(
    [state_of_the_union, state_of_the_union], metadatas=metadatas
)
print(documents[0])
```

```output
page_content='Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  \n\nLast year COVID-19 kept us apart. This year we are finally together again. \n\nTonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. \n\nWith a duty to one another to the American people to the Constitution. \n\nAnd with an unwavering resolve that freedom will always triumph over tyranny. \n\nSix days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. \n\nHe thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. \n\nHe met the Ukrainian people. \n\nFrom President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world.' metadata={'document': 1}
```

문자열 내용을 직접 얻으려면 `.split_text`를 사용하세요:

```python
text_splitter.split_text(state_of_the_union)[0]
```


```output
'Madam Speaker, Madam Vice President, our First Lady and Second Gentleman. Members of Congress and the Cabinet. Justices of the Supreme Court. My fellow Americans.  \n\nLast year COVID-19 kept us apart. This year we are finally together again. \n\nTonight, we meet as Democrats Republicans and Independents. But most importantly as Americans. \n\nWith a duty to one another to the American people to the Constitution. \n\nAnd with an unwavering resolve that freedom will always triumph over tyranny. \n\nSix days ago, Russia’s Vladimir Putin sought to shake the foundations of the free world thinking he could make it bend to his menacing ways. But he badly miscalculated. \n\nHe thought he could roll into Ukraine and the world would roll over. Instead he met a wall of strength he never imagined. \n\nHe met the Ukrainian people. \n\nFrom President Zelenskyy to every Ukrainian, their fearlessness, their courage, their determination, inspires the world.'
```