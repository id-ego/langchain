---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/HTML_header_metadata_splitter.ipynb
description: HTMLHeaderTextSplitter는 HTML 요소 수준에서 텍스트를 분할하고 관련 메타데이터를 추가하여 문서 구조를
  유지합니다.
---

# HTML 헤더로 나누는 방법
## 설명 및 동기

[HTMLHeaderTextSplitter](https://api.python.langchain.com/en/latest/html/langchain_text_splitters.html.HTMLHeaderTextSplitter.html)는 HTML 요소 수준에서 텍스트를 나누고 각 헤더와 관련된 메타데이터를 추가하는 "구조 인식" 청크입니다. 관련 텍스트를 (대체로) 의미적으로 그룹화하고 문서 구조에 인코딩된 맥락이 풍부한 정보를 보존하는 것을 목표로 하여, 요소별로 청크를 반환하거나 동일한 메타데이터를 가진 요소들을 결합할 수 있습니다. 이는 청크 파이프라인의 일환으로 다른 텍스트 분할기와 함께 사용할 수 있습니다.

이는 마크다운 파일을 위한 [MarkdownHeaderTextSplitter](/docs/how_to/markdown_header_metadata_splitter)와 유사합니다.

어떤 헤더로 나눌지를 지정하려면, 아래와 같이 `HTMLHeaderTextSplitter`를 인스턴스화할 때 `headers_to_split_on`을 지정하십시오.

## 사용 예시
### 1) HTML 문자열 나누는 방법:

```python
%pip install -qU langchain-text-splitters
```


```python
<!--IMPORTS:[{"imported": "HTMLHeaderTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/html/langchain_text_splitters.html.HTMLHeaderTextSplitter.html", "title": "How to split by HTML header "}]-->
from langchain_text_splitters import HTMLHeaderTextSplitter

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
]

html_splitter = HTMLHeaderTextSplitter(headers_to_split_on)
html_header_splits = html_splitter.split_text(html_string)
html_header_splits
```


```output
[Document(page_content='Foo'),
 Document(page_content='Some intro text about Foo.  \nBar main section Bar subsection 1 Bar subsection 2', metadata={'Header 1': 'Foo'}),
 Document(page_content='Some intro text about Bar.', metadata={'Header 1': 'Foo', 'Header 2': 'Bar main section'}),
 Document(page_content='Some text about the first subtopic of Bar.', metadata={'Header 1': 'Foo', 'Header 2': 'Bar main section', 'Header 3': 'Bar subsection 1'}),
 Document(page_content='Some text about the second subtopic of Bar.', metadata={'Header 1': 'Foo', 'Header 2': 'Bar main section', 'Header 3': 'Bar subsection 2'}),
 Document(page_content='Baz', metadata={'Header 1': 'Foo'}),
 Document(page_content='Some text about Baz', metadata={'Header 1': 'Foo', 'Header 2': 'Baz'}),
 Document(page_content='Some concluding text about Foo', metadata={'Header 1': 'Foo'})]
```


각 요소와 그에 관련된 헤더를 함께 반환하려면, `HTMLHeaderTextSplitter`를 인스턴스화할 때 `return_each_element=True`를 지정하십시오:

```python
html_splitter = HTMLHeaderTextSplitter(
    headers_to_split_on,
    return_each_element=True,
)
html_header_splits_elements = html_splitter.split_text(html_string)
```


위와 비교하여, 요소들이 헤더에 의해 집계되는 경우:

```python
for element in html_header_splits[:2]:
    print(element)
```

```output
page_content='Foo'
page_content='Some intro text about Foo.  \nBar main section Bar subsection 1 Bar subsection 2' metadata={'Header 1': 'Foo'}
```

이제 각 요소는 별개의 `Document`로 반환됩니다:

```python
for element in html_header_splits_elements[:3]:
    print(element)
```

```output
page_content='Foo'
page_content='Some intro text about Foo.' metadata={'Header 1': 'Foo'}
page_content='Bar main section Bar subsection 1 Bar subsection 2' metadata={'Header 1': 'Foo'}
```

#### 2) URL 또는 HTML 파일에서 나누는 방법:

URL에서 직접 읽으려면, URL 문자열을 `split_text_from_url` 메서드에 전달하십시오.

유사하게, 로컬 HTML 파일은 `split_text_from_file` 메서드에 전달할 수 있습니다.

```python
url = "https://plato.stanford.edu/entries/goedel/"

headers_to_split_on = [
    ("h1", "Header 1"),
    ("h2", "Header 2"),
    ("h3", "Header 3"),
    ("h4", "Header 4"),
]

html_splitter = HTMLHeaderTextSplitter(headers_to_split_on)

# for local file use html_splitter.split_text_from_file(<path_to_file>)
html_header_splits = html_splitter.split_text_from_url(url)
```


### 2) 청크 크기 제한하는 방법:

HTML 헤더를 기반으로 나누는 `HTMLHeaderTextSplitter`는 문자 길이를 기준으로 나누는 다른 분할기와 결합할 수 있습니다, 예를 들어 `RecursiveCharacterTextSplitter`와 같은 것입니다.

이는 두 번째 분할기의 `.split_documents` 메서드를 사용하여 수행할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "How to split by HTML header "}]-->
from langchain_text_splitters import RecursiveCharacterTextSplitter

chunk_size = 500
chunk_overlap = 30
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=chunk_size, chunk_overlap=chunk_overlap
)

# Split
splits = text_splitter.split_documents(html_header_splits)
splits[80:85]
```


```output
[Document(page_content='We see that Gödel first tried to reduce the consistency problem for analysis to that of arithmetic. This seemed to require a truth definition for arithmetic, which in turn led to paradoxes, such as the Liar paradox (“This sentence is false”) and Berry’s paradox (“The least number not defined by an expression consisting of just fourteen English words”). Gödel then noticed that such paradoxes would not necessarily arise if truth were replaced by provability. But this means that arithmetic truth', metadata={'Header 1': 'Kurt Gödel', 'Header 2': '2. Gödel’s Mathematical Work', 'Header 3': '2.2 The Incompleteness Theorems', 'Header 4': '2.2.1 The First Incompleteness Theorem'}),
 Document(page_content='means that arithmetic truth and arithmetic provability are not co-extensive — whence the First Incompleteness Theorem.', metadata={'Header 1': 'Kurt Gödel', 'Header 2': '2. Gödel’s Mathematical Work', 'Header 3': '2.2 The Incompleteness Theorems', 'Header 4': '2.2.1 The First Incompleteness Theorem'}),
 Document(page_content='This account of Gödel’s discovery was told to Hao Wang very much after the fact; but in Gödel’s contemporary correspondence with Bernays and Zermelo, essentially the same description of his path to the theorems is given. (See Gödel 2003a and Gödel 2003b respectively.) From those accounts we see that the undefinability of truth in arithmetic, a result credited to Tarski, was likely obtained in some form by Gödel by 1931. But he neither publicized nor published the result; the biases logicians', metadata={'Header 1': 'Kurt Gödel', 'Header 2': '2. Gödel’s Mathematical Work', 'Header 3': '2.2 The Incompleteness Theorems', 'Header 4': '2.2.1 The First Incompleteness Theorem'}),
 Document(page_content='result; the biases logicians had expressed at the time concerning the notion of truth, biases which came vehemently to the fore when Tarski announced his results on the undefinability of truth in formal systems 1935, may have served as a deterrent to Gödel’s publication of that theorem.', metadata={'Header 1': 'Kurt Gödel', 'Header 2': '2. Gödel’s Mathematical Work', 'Header 3': '2.2 The Incompleteness Theorems', 'Header 4': '2.2.1 The First Incompleteness Theorem'}),
 Document(page_content='We now describe the proof of the two theorems, formulating Gödel’s results in Peano arithmetic. Gödel himself used a system related to that defined in Principia Mathematica, but containing Peano arithmetic. In our presentation of the First and Second Incompleteness Theorems we refer to Peano arithmetic as P, following Gödel’s notation.', metadata={'Header 1': 'Kurt Gödel', 'Header 2': '2. Gödel’s Mathematical Work', 'Header 3': '2.2 The Incompleteness Theorems', 'Header 4': '2.2.2 The proof of the First Incompleteness Theorem'})]
```


## 한계

HTML 문서마다 구조적 변동이 상당할 수 있으며, `HTMLHeaderTextSplitter`는 주어진 청크에 모든 "관련" 헤더를 부착하려고 시도하지만, 때때로 특정 헤더를 놓칠 수 있습니다. 예를 들어, 알고리즘은 헤더가 항상 관련 텍스트의 "위"에 있는 노드에 위치하는 정보 계층 구조를 가정합니다, 즉 이전 형제, 조상 및 그 조합입니다. 다음 뉴스 기사(이 문서 작성 당시 기준)에서 문서는 최상위 헤드라인의 텍스트가 "h1"으로 태그가 붙어 있지만, 우리가 기대하는 텍스트 요소와는 *별개의* 서브트리 구조로 되어 있어, "h1" 요소와 그 관련 텍스트가 청크 메타데이터에 나타나지 않는 것을 관찰할 수 있습니다(그러나 해당되는 경우 "h2"와 그 관련 텍스트는 확인할 수 있습니다):

```python
url = "https://www.cnn.com/2023/09/25/weather/el-nino-winter-us-climate/index.html"

headers_to_split_on = [
    ("h1", "Header 1"),
    ("h2", "Header 2"),
]

html_splitter = HTMLHeaderTextSplitter(headers_to_split_on)
html_header_splits = html_splitter.split_text_from_url(url)
print(html_header_splits[1].page_content[:500])
```

```output
No two El Niño winters are the same, but many have temperature and precipitation trends in common.  
Average conditions during an El Niño winter across the continental US.  
One of the major reasons is the position of the jet stream, which often shifts south during an El Niño winter. This shift typically brings wetter and cooler weather to the South while the North becomes drier and warmer, according to NOAA.  
Because the jet stream is essentially a river of air that storms flow through, they c
```