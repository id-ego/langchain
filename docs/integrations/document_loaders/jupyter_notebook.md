---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/jupyter_notebook.ipynb
description: 이 문서는 Jupyter Notebook에서 LangChain에 적합한 형식으로 데이터를 로드하는 방법을 설명합니다.
---

# 주피터 노트북

> [주피터 노트북](https://en.wikipedia.org/wiki/Project_Jupyter#Applications) (이전의 `IPython Notebook`)은 노트북 문서를 생성하기 위한 웹 기반의 대화형 계산 환경입니다.

이 노트북은 `Jupyter notebook (.ipynb)`에서 LangChain에 적합한 형식으로 데이터를 로드하는 방법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "NotebookLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.notebook.NotebookLoader.html", "title": "Jupyter Notebook"}]-->
from langchain_community.document_loaders import NotebookLoader
```


```python
loader = NotebookLoader(
    "example_data/notebook.ipynb",
    include_outputs=True,
    max_output_length=20,
    remove_newline=True,
)
```


`NotebookLoader.load()`는 `.ipynb` 노트북 파일을 `Document` 객체로 로드합니다.

**매개변수**:

* `include_outputs` (bool): 결과 문서에 셀 출력을 포함할지 여부 (기본값은 False).
* `max_output_length` (int): 각 셀 출력에서 포함할 최대 문자 수 (기본값은 10).
* `remove_newline` (bool): 셀 소스 및 출력에서 줄 바꿈 문자를 제거할지 여부 (기본값은 False).
* `traceback` (bool): 전체 추적 정보를 포함할지 여부 (기본값은 False).

```python
loader.load()
```


```output
[Document(page_content='\'markdown\' cell: \'[\'# Notebook\', \'\', \'This notebook covers how to load data from an .html notebook into a format suitable by LangChain.\']\'\n\n \'code\' cell: \'[\'from langchain_community.document_loaders import NotebookLoader\']\'\n\n \'code\' cell: \'[\'loader = NotebookLoader("example_data/notebook.html")\']\'\n\n \'markdown\' cell: \'[\'`NotebookLoader.load()` loads the `.html` notebook file into a `Document` object.\', \'\', \'**Parameters**:\', \'\', \'* `include_outputs` (bool): whether to include cell outputs in the resulting document (default is False).\', \'* `max_output_length` (int): the maximum number of characters to include from each cell output (default is 10).\', \'* `remove_newline` (bool): whether to remove newline characters from the cell sources and outputs (default is False).\', \'* `traceback` (bool): whether to include full traceback (default is False).\']\'\n\n \'code\' cell: \'[\'loader.load(include_outputs=True, max_output_length=20, remove_newline=True)\']\'\n\n', metadata={'source': 'example_data/notebook.html'})]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)