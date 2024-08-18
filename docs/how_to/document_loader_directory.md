---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/document_loader_directory.ipynb
description: LangChain의 DirectoryLoader를 사용하여 디렉토리에서 문서를 로드하는 방법을 설명합니다. 파일 시스템, 멀티스레딩,
  사용자 정의 로더 및 오류 처리 방법을 다룹니다.
---

# 디렉토리에서 문서 로드하는 방법

LangChain의 [DirectoryLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.directory.DirectoryLoader.html)는 디스크에서 LangChain [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html#langchain_core.documents.base.Document) 객체로 파일을 읽는 기능을 구현합니다. 여기에서는 다음을 보여줍니다:

- 와일드카드 패턴을 포함하여 파일 시스템에서 로드하는 방법;
- 파일 I/O를 위한 멀티스레딩 사용 방법;
- 특정 파일 형식(예: 코드)을 구문 분석하기 위한 사용자 정의 로더 클래스 사용 방법;
- 디코딩으로 인한 오류 처리 방법.

```python
<!--IMPORTS:[{"imported": "DirectoryLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.directory.DirectoryLoader.html", "title": "How to load documents from a directory"}]-->
from langchain_community.document_loaders import DirectoryLoader
```


`DirectoryLoader`는 기본값이 [UnstructuredLoader](/docs/integrations/document_loaders/unstructured_file)인 `loader_cls` kwarg를 수용합니다. [Unstructured](https://unstructured-io.github.io/unstructured/)는 PDF 및 HTML과 같은 여러 형식의 구문 분석을 지원합니다. 여기에서는 이를 사용하여 마크다운(.md) 파일을 읽습니다.

`glob` 매개변수를 사용하여 로드할 파일을 제어할 수 있습니다. 여기서는 `.rst` 파일이나 `.html` 파일을 로드하지 않는다는 점에 유의하십시오.

```python
loader = DirectoryLoader("../", glob="**/*.md")
docs = loader.load()
len(docs)
```


```output
20
```


```python
print(docs[0].page_content[:100])
```

```output
Security

LangChain has a large ecosystem of integrations with various external resources like local
```


## 진행률 표시줄 표시

기본적으로 진행률 표시줄은 표시되지 않습니다. 진행률 표시줄을 표시하려면 `tqdm` 라이브러리를 설치하고(e.g. `pip install tqdm`), `show_progress` 매개변수를 `True`로 설정합니다.

```python
loader = DirectoryLoader("../", glob="**/*.md", show_progress=True)
docs = loader.load()
```

```output
100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 20/20 [00:00<00:00, 54.56it/s]
```


## 멀티스레딩 사용

기본적으로 로드는 하나의 스레드에서 발생합니다. 여러 스레드를 활용하려면 `use_multithreading` 플래그를 true로 설정하십시오.

```python
loader = DirectoryLoader("../", glob="**/*.md", use_multithreading=True)
docs = loader.load()
```


## 로더 클래스 변경
기본적으로 `UnstructuredLoader` 클래스를 사용합니다. 로더를 사용자 정의하려면 `loader_cls` kwarg에서 로더 클래스를 지정하십시오. 아래에서는 [TextLoader](https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html)를 사용하는 예를 보여줍니다:

```python
<!--IMPORTS:[{"imported": "TextLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.text.TextLoader.html", "title": "How to load documents from a directory"}]-->
from langchain_community.document_loaders import TextLoader

loader = DirectoryLoader("../", glob="**/*.md", loader_cls=TextLoader)
docs = loader.load()
```


```python
print(docs[0].page_content[:100])
```

```output
# Security

LangChain has a large ecosystem of integrations with various external resources like loc
```


`UnstructuredLoader`가 마크다운 헤더를 구문 분석하는 반면, `TextLoader`는 그렇지 않다는 점에 유의하십시오.

Python 소스 코드 파일을 로드해야 하는 경우 `PythonLoader`를 사용하십시오:

```python
<!--IMPORTS:[{"imported": "PythonLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.python.PythonLoader.html", "title": "How to load documents from a directory"}]-->
from langchain_community.document_loaders import PythonLoader

loader = DirectoryLoader("../../../../../", glob="**/*.py", loader_cls=PythonLoader)
```


## TextLoader로 파일 인코딩 자동 감지

`DirectoryLoader`는 파일 인코딩의 변동으로 인한 오류를 관리하는 데 도움을 줄 수 있습니다. 아래에서는 비-UTF8 인코딩을 포함하는 파일 모음을 로드하려고 시도합니다.

```python
path = "../../../../libs/langchain/tests/unit_tests/examples/"

loader = DirectoryLoader(path, glob="**/*.txt", loader_cls=TextLoader)
```


### A. 기본 동작

기본적으로 오류를 발생시킵니다:

```python
loader.load()
```

```output
Error loading file ../../../../libs/langchain/tests/unit_tests/examples/example-non-utf8.txt
```

```output
---------------------------------------------------------------------------
``````output
UnicodeDecodeError                        Traceback (most recent call last)
``````output
File ~/repos/langchain/libs/community/langchain_community/document_loaders/text.py:43, in TextLoader.lazy_load(self)
     42     with open(self.file_path, encoding=self.encoding) as f:
---> 43         text = f.read()
     44 except UnicodeDecodeError as e:
``````output
File ~/.pyenv/versions/3.10.4/lib/python3.10/codecs.py:322, in BufferedIncrementalDecoder.decode(self, input, final)
    321 data = self.buffer + input
--> 322 (result, consumed) = self._buffer_decode(data, self.errors, final)
    323 # keep undecoded input until the next call
``````output
UnicodeDecodeError: 'utf-8' codec can't decode byte 0xca in position 0: invalid continuation byte
``````output

The above exception was the direct cause of the following exception:
``````output
RuntimeError                              Traceback (most recent call last)
``````output
Cell In[10], line 1
----> 1 loader.load()
``````output
File ~/repos/langchain/libs/community/langchain_community/document_loaders/directory.py:117, in DirectoryLoader.load(self)
    115 def load(self) -> List[Document]:
    116     """Load documents."""
--> 117     return list(self.lazy_load())
``````output
File ~/repos/langchain/libs/community/langchain_community/document_loaders/directory.py:182, in DirectoryLoader.lazy_load(self)
    180 else:
    181     for i in items:
--> 182         yield from self._lazy_load_file(i, p, pbar)
    184 if pbar:
    185     pbar.close()
``````output
File ~/repos/langchain/libs/community/langchain_community/document_loaders/directory.py:220, in DirectoryLoader._lazy_load_file(self, item, path, pbar)
    218     else:
    219         logger.error(f"Error loading file {str(item)}")
--> 220         raise e
    221 finally:
    222     if pbar:
``````output
File ~/repos/langchain/libs/community/langchain_community/document_loaders/directory.py:210, in DirectoryLoader._lazy_load_file(self, item, path, pbar)
    208 loader = self.loader_cls(str(item), **self.loader_kwargs)
    209 try:
--> 210     for subdoc in loader.lazy_load():
    211         yield subdoc
    212 except NotImplementedError:
``````output
File ~/repos/langchain/libs/community/langchain_community/document_loaders/text.py:56, in TextLoader.lazy_load(self)
     54                 continue
     55     else:
---> 56         raise RuntimeError(f"Error loading {self.file_path}") from e
     57 except Exception as e:
     58     raise RuntimeError(f"Error loading {self.file_path}") from e
``````output
RuntimeError: Error loading ../../../../libs/langchain/tests/unit_tests/examples/example-non-utf8.txt
```


파일 `example-non-utf8.txt`는 다른 인코딩을 사용하므로 `load()` 함수는 어떤 파일이 디코딩에 실패했는지를 나타내는 유용한 메시지와 함께 실패합니다.

`TextLoader`의 기본 동작에서는 문서 중 하나라도 로드에 실패하면 전체 로드 프로세스가 실패하고 문서가 로드되지 않습니다.

### B. 무음 실패

로드할 수 없는 파일을 건너뛰고 로드 프로세스를 계속하려면 `DirectoryLoader`에 `silent_errors` 매개변수를 전달할 수 있습니다.

```python
loader = DirectoryLoader(
    path, glob="**/*.txt", loader_cls=TextLoader, silent_errors=True
)
docs = loader.load()
```

```output
Error loading file ../../../../libs/langchain/tests/unit_tests/examples/example-non-utf8.txt: Error loading ../../../../libs/langchain/tests/unit_tests/examples/example-non-utf8.txt
```


```python
doc_sources = [doc.metadata["source"] for doc in docs]
doc_sources
```


```output
['../../../../libs/langchain/tests/unit_tests/examples/example-utf8.txt']
```


### C. 인코딩 자동 감지

`TextLoader`에 실패하기 전에 파일 인코딩을 자동 감지하도록 요청할 수도 있습니다. 로더 클래스에 `autodetect_encoding`을 전달하여 가능합니다.

```python
text_loader_kwargs = {"autodetect_encoding": True}
loader = DirectoryLoader(
    path, glob="**/*.txt", loader_cls=TextLoader, loader_kwargs=text_loader_kwargs
)
docs = loader.load()
```


```python
doc_sources = [doc.metadata["source"] for doc in docs]
doc_sources
```


```output
['../../../../libs/langchain/tests/unit_tests/examples/example-utf8.txt',
 '../../../../libs/langchain/tests/unit_tests/examples/example-non-utf8.txt']
```