---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/markdown_header_metadata_splitter.ipynb
description: 마크다운 문서를 헤더별로 분할하는 방법을 설명하며, 문서 구조를 유지하면서 효율적으로 텍스트를 청크화하는 전략을 소개합니다.
---

# 헤더로 마크다운 나누는 방법

### 동기

많은 채팅 또는 Q+A 애플리케이션은 임베딩 및 벡터 저장 전에 입력 문서를 청크로 나누는 작업을 포함합니다.

[Pinecone의 이 노트](https://www.pinecone.io/learn/chunking-strategies/)는 유용한 팁을 제공합니다:

```
When a full paragraph or document is embedded, the embedding process considers both the overall context and the relationships between the sentences and phrases within the text. This can result in a more comprehensive vector representation that captures the broader meaning and themes of the text.
```


언급했듯이, 청크 나누기는 종종 공통 컨텍스트가 있는 텍스트를 함께 유지하는 것을 목표로 합니다. 이를 염두에 두고, 문서 자체의 구조를 존중하는 것이 좋습니다. 예를 들어, 마크다운 파일은 헤더로 구성됩니다. 특정 헤더 그룹 내에서 청크를 만드는 것은 직관적인 아이디어입니다. 이 문제를 해결하기 위해 [MarkdownHeaderTextSplitter](https://api.python.langchain.com/en/latest/markdown/langchain_text_splitters.markdown.MarkdownHeaderTextSplitter.html)를 사용할 수 있습니다. 이는 지정된 헤더 세트에 따라 마크다운 파일을 나눕니다.

예를 들어, 이 마크다운을 나누고 싶다면:
```
md = '# Foo\n\n ## Bar\n\nHi this is Jim  \nHi this is Joe\n\n ## Baz\n\n Hi this is Molly' 
```


나눌 헤더를 지정할 수 있습니다:
```
[("#", "Header 1"),("##", "Header 2")]
```


그리고 내용은 공통 헤더에 따라 그룹화되거나 나뉩니다:
```
{'content': 'Hi this is Jim  \nHi this is Joe', 'metadata': {'Header 1': 'Foo', 'Header 2': 'Bar'}}
{'content': 'Hi this is Molly', 'metadata': {'Header 1': 'Foo', 'Header 2': 'Baz'}}
```


아래 몇 가지 예를 살펴보겠습니다.

### 기본 사용법:

```python
%pip install -qU langchain-text-splitters
```


```python
<!--IMPORTS:[{"imported": "MarkdownHeaderTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/markdown/langchain_text_splitters.markdown.MarkdownHeaderTextSplitter.html", "title": "How to split Markdown by Headers"}]-->
from langchain_text_splitters import MarkdownHeaderTextSplitter
```


```python
markdown_document = "# Foo\n\n    ## Bar\n\nHi this is Jim\n\nHi this is Joe\n\n ### Boo \n\n Hi this is Lance \n\n ## Baz\n\n Hi this is Molly"

headers_to_split_on = [
    ("#", "Header 1"),
    ("##", "Header 2"),
    ("###", "Header 3"),
]

markdown_splitter = MarkdownHeaderTextSplitter(headers_to_split_on)
md_header_splits = markdown_splitter.split_text(markdown_document)
md_header_splits
```


```output
[Document(page_content='Hi this is Jim  \nHi this is Joe', metadata={'Header 1': 'Foo', 'Header 2': 'Bar'}),
 Document(page_content='Hi this is Lance', metadata={'Header 1': 'Foo', 'Header 2': 'Bar', 'Header 3': 'Boo'}),
 Document(page_content='Hi this is Molly', metadata={'Header 1': 'Foo', 'Header 2': 'Baz'})]
```


```python
type(md_header_splits[0])
```


```output
langchain_core.documents.base.Document
```


기본적으로, `MarkdownHeaderTextSplitter`는 출력 청크의 내용에서 나누는 헤더를 제거합니다. 이는 `strip_headers = False`로 설정하여 비활성화할 수 있습니다.

```python
markdown_splitter = MarkdownHeaderTextSplitter(headers_to_split_on, strip_headers=False)
md_header_splits = markdown_splitter.split_text(markdown_document)
md_header_splits
```


```output
[Document(page_content='# Foo  \n## Bar  \nHi this is Jim  \nHi this is Joe', metadata={'Header 1': 'Foo', 'Header 2': 'Bar'}),
 Document(page_content='### Boo  \nHi this is Lance', metadata={'Header 1': 'Foo', 'Header 2': 'Bar', 'Header 3': 'Boo'}),
 Document(page_content='## Baz  \nHi this is Molly', metadata={'Header 1': 'Foo', 'Header 2': 'Baz'})]
```


### 마크다운 줄을 별도의 문서로 반환하는 방법

기본적으로, `MarkdownHeaderTextSplitter`는 `headers_to_split_on`에 지정된 헤더를 기준으로 줄을 집계합니다. `return_each_line`을 지정하여 이를 비활성화할 수 있습니다:

```python
markdown_splitter = MarkdownHeaderTextSplitter(
    headers_to_split_on,
    return_each_line=True,
)
md_header_splits = markdown_splitter.split_text(markdown_document)
md_header_splits
```


```output
[Document(page_content='Hi this is Jim', metadata={'Header 1': 'Foo', 'Header 2': 'Bar'}),
 Document(page_content='Hi this is Joe', metadata={'Header 1': 'Foo', 'Header 2': 'Bar'}),
 Document(page_content='Hi this is Lance', metadata={'Header 1': 'Foo', 'Header 2': 'Bar', 'Header 3': 'Boo'}),
 Document(page_content='Hi this is Molly', metadata={'Header 1': 'Foo', 'Header 2': 'Baz'})]
```


여기서 헤더 정보는 각 문서의 `metadata`에 보존됩니다.

### 청크 크기를 제한하는 방법:

각 마크다운 그룹 내에서 `RecursiveCharacterTextSplitter`와 같은 원하는 텍스트 분할기를 적용할 수 있으며, 이는 청크 크기를 더 세밀하게 제어할 수 있게 해줍니다.

```python
<!--IMPORTS:[{"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to split Markdown by Headers"}]-->
markdown_document = "# Intro \n\n    ## History \n\n Markdown[9] is a lightweight markup language for creating formatted text using a plain-text editor. John Gruber created Markdown in 2004 as a markup language that is appealing to human readers in its source code form.[9] \n\n Markdown is widely used in blogging, instant messaging, online forums, collaborative software, documentation pages, and readme files. \n\n ## Rise and divergence \n\n As Markdown popularity grew rapidly, many Markdown implementations appeared, driven mostly by the need for \n\n additional features such as tables, footnotes, definition lists,[note 1] and Markdown inside HTML blocks. \n\n #### Standardization \n\n From 2012, a group of people, including Jeff Atwood and John MacFarlane, launched what Atwood characterised as a standardisation effort. \n\n ## Implementations \n\n Implementations of Markdown are available for over a dozen programming languages."

headers_to_split_on = [
    ("#", "Header 1"),
    ("##", "Header 2"),
]

# MD splits
markdown_splitter = MarkdownHeaderTextSplitter(
    headers_to_split_on=headers_to_split_on, strip_headers=False
)
md_header_splits = markdown_splitter.split_text(markdown_document)

# Char-level splits
from langchain_text_splitters import RecursiveCharacterTextSplitter

chunk_size = 250
chunk_overlap = 30
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=chunk_size, chunk_overlap=chunk_overlap
)

# Split
splits = text_splitter.split_documents(md_header_splits)
splits
```


```output
[Document(page_content='# Intro  \n## History  \nMarkdown[9] is a lightweight markup language for creating formatted text using a plain-text editor. John Gruber created Markdown in 2004 as a markup language that is appealing to human readers in its source code form.[9]', metadata={'Header 1': 'Intro', 'Header 2': 'History'}),
 Document(page_content='Markdown is widely used in blogging, instant messaging, online forums, collaborative software, documentation pages, and readme files.', metadata={'Header 1': 'Intro', 'Header 2': 'History'}),
 Document(page_content='## Rise and divergence  \nAs Markdown popularity grew rapidly, many Markdown implementations appeared, driven mostly by the need for  \nadditional features such as tables, footnotes, definition lists,[note 1] and Markdown inside HTML blocks.', metadata={'Header 1': 'Intro', 'Header 2': 'Rise and divergence'}),
 Document(page_content='#### Standardization  \nFrom 2012, a group of people, including Jeff Atwood and John MacFarlane, launched what Atwood characterised as a standardisation effort.', metadata={'Header 1': 'Intro', 'Header 2': 'Rise and divergence'}),
 Document(page_content='## Implementations  \nImplementations of Markdown are available for over a dozen programming languages.', metadata={'Header 1': 'Intro', 'Header 2': 'Implementations'})]
```