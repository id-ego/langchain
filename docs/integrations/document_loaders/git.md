---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/git.ipynb
description: 이 문서는 Git 저장소에서 텍스트 파일을 로드하는 방법을 설명합니다. 로컬 저장소 및 URL에서 클론하는 방법을 다룹니다.
---

# Git

> [Git](https://en.wikipedia.org/wiki/Git)는 소프트웨어 개발 중에 소스 코드를 공동으로 개발하는 프로그래머들 간의 작업 조정을 위해 일반적으로 사용되는 컴퓨터 파일 집합의 변경 사항을 추적하는 분산 버전 관리 시스템입니다.

이 노트북은 `Git` 저장소에서 텍스트 파일을 로드하는 방법을 보여줍니다.

## 디스크에서 기존 저장소 로드

```python
%pip install --upgrade --quiet  GitPython
```


```python
from git import Repo

repo = Repo.clone_from(
    "https://github.com/langchain-ai/langchain", to_path="./example_data/test_repo1"
)
branch = repo.head.reference
```


```python
<!--IMPORTS:[{"imported": "GitLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.git.GitLoader.html", "title": "Git"}]-->
from langchain_community.document_loaders import GitLoader
```


```python
loader = GitLoader(repo_path="./example_data/test_repo1/", branch=branch)
```


```python
data = loader.load()
```


```python
len(data)
```


```python
print(data[0])
```

```output
page_content='.venv\n.github\n.git\n.mypy_cache\n.pytest_cache\nDockerfile' metadata={'file_path': '.dockerignore', 'file_name': '.dockerignore', 'file_type': ''}
```

## URL에서 저장소 복제

```python
<!--IMPORTS:[{"imported": "GitLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.git.GitLoader.html", "title": "Git"}]-->
from langchain_community.document_loaders import GitLoader
```


```python
loader = GitLoader(
    clone_url="https://github.com/langchain-ai/langchain",
    repo_path="./example_data/test_repo2/",
    branch="master",
)
```


```python
data = loader.load()
```


```python
len(data)
```


```output
1074
```


## 로드할 파일 필터링

```python
<!--IMPORTS:[{"imported": "GitLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.git.GitLoader.html", "title": "Git"}]-->
from langchain_community.document_loaders import GitLoader

# e.g. loading only python files
loader = GitLoader(
    repo_path="./example_data/test_repo1/",
    file_filter=lambda file_path: file_path.endswith(".py"),
)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)