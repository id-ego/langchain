---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/HTML_section_aware_splitter.ipynb
description: HTMLSectionSplitter는 HTML 요소 수준에서 텍스트를 분할하고 각 헤더에 대한 메타데이터를 추가하여 관련 텍스트를
  그룹화합니다.
---

# HTML 섹션으로 나누는 방법
## 설명 및 동기
[HTMLHeaderTextSplitter](/docs/how_to/HTML_header_metadata_splitter)와 개념이 유사한 `HTMLSectionSplitter`는 요소 수준에서 텍스트를 나누고 각 헤더와 관련된 메타데이터를 추가하는 "구조 인식" 청크입니다.

이것은 요소별로 청크를 반환하거나 동일한 메타데이터를 가진 요소를 결합할 수 있으며, (a) 관련 텍스트를 의미적으로 (대략적으로) 그룹화하고 (b) 문서 구조에 인코딩된 컨텍스트가 풍부한 정보를 보존하는 것을 목표로 합니다.

`xslt_path`를 사용하여 제공된 태그를 기반으로 섹션을 감지할 수 있도록 HTML을 변환하기 위한 절대 경로를 제공합니다. 기본값은 `data_connection/document_transformers` 디렉토리에 있는 `converting_to_header.xslt` 파일을 사용하는 것입니다. 이는 HTML을 섹션을 감지하기 더 쉬운 형식/레이아웃으로 변환하기 위한 것입니다. 예를 들어, 글꼴 크기를 기반으로 한 `span`은 섹션으로 감지되도록 헤더 태그로 변환될 수 있습니다.

## 사용 예시
### 1) HTML 문자열 나누는 방법:

```python
<!--IMPORTS:[{"imported": "HTMLSectionSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/html/langchain_text_splitters.html.HTMLSectionSplitter.html", "title": "How to split by HTML sections"}]-->
from langchain_text_splitters import HTMLSectionSplitter

html_string = """
    <!DOCTYPE html>
    <html>
    <body>
        <div>
            <h1>Foo</h1>
            <p>Some intro text about Foo.</p>
            <div>
                <h2>Bar main section</h2>
                <p>Some intro text about Bar.</p>
                <h3>Bar subsection 1</h3>
                <p>Some text about the first subtopic of Bar.</p>
                <h3>Bar subsection 2</h3>
                <p>Some text about the second subtopic of Bar.</p>
            </div>
            <div>
                <h2>Baz</h2>
                <p>Some text about Baz</p>
            </div>
            <br>
            <p>Some concluding text about Foo</p>
        </div>
    </body>
    </html>
"""

headers_to_split_on = [("h1", "Header 1"), ("h2", "Header 2")]

html_splitter = HTMLSectionSplitter(headers_to_split_on)
html_header_splits = html_splitter.split_text(html_string)
html_header_splits
```


```output
[Document(page_content='Foo \n Some intro text about Foo.', metadata={'Header 1': 'Foo'}),
 Document(page_content='Bar main section \n Some intro text about Bar. \n Bar subsection 1 \n Some text about the first subtopic of Bar. \n Bar subsection 2 \n Some text about the second subtopic of Bar.', metadata={'Header 2': 'Bar main section'}),
 Document(page_content='Baz \n Some text about Baz \n \n \n Some concluding text about Foo', metadata={'Header 2': 'Baz'})]
```


### 2) 청크 크기 제한하는 방법:

`HTMLSectionSplitter`는 청크 파이프라인의 일부로 다른 텍스트 분할기와 함께 사용할 수 있습니다. 내부적으로 섹션 크기가 청크 크기보다 클 때 `RecursiveCharacterTextSplitter`를 사용합니다. 또한 텍스트의 글꼴 크기를 고려하여 결정된 글꼴 크기 임계값에 따라 섹션인지 여부를 판단합니다.

```python
<!--IMPORTS:[{"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to split by HTML sections"}]-->
from langchain_text_splitters import RecursiveCharacterTextSplitter

html_string = """
    <!DOCTYPE html>
    <html>
    <body>
        <div>
            <h1>Foo</h1>
            <p>Some intro text about Foo.</p>
            <div>
                <h2>Bar main section</h2>
                <p>Some intro text about Bar.</p>
                <h3>Bar subsection 1</h3>
                <p>Some text about the first subtopic of Bar.</p>
                <h3>Bar subsection 2</h3>
                <p>Some text about the second subtopic of Bar.</p>
            </div>
            <div>
                <h2>Baz</h2>
                <p>Some text about Baz</p>
            </div>
            <br>
            <p>Some concluding text about Foo</p>
        </div>
    </body>
    </html>
"""

headers_to_split_on = [
    ("h1", "Header 1"),
    ("h2", "Header 2"),
    ("h3", "Header 3"),
    ("h4", "Header 4"),
]

html_splitter = HTMLSectionSplitter(headers_to_split_on)

html_header_splits = html_splitter.split_text(html_string)

chunk_size = 500
chunk_overlap = 30
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=chunk_size, chunk_overlap=chunk_overlap
)

# Split
splits = text_splitter.split_documents(html_header_splits)
splits
```


```output
[Document(page_content='Foo \n Some intro text about Foo.', metadata={'Header 1': 'Foo'}),
 Document(page_content='Bar main section \n Some intro text about Bar.', metadata={'Header 2': 'Bar main section'}),
 Document(page_content='Bar subsection 1 \n Some text about the first subtopic of Bar.', metadata={'Header 3': 'Bar subsection 1'}),
 Document(page_content='Bar subsection 2 \n Some text about the second subtopic of Bar.', metadata={'Header 3': 'Bar subsection 2'}),
 Document(page_content='Baz \n Some text about Baz \n \n \n Some concluding text about Foo', metadata={'Header 2': 'Baz'})]
```