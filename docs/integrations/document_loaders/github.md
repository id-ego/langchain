---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/github.ipynb
description: 이 문서는 LangChain Python 저장소를 예로 들어 GitHub API를 사용하여 이슈 및 PR을 로드하는 방법을
  보여줍니다.
---

# GitHub

이 노트북은 주어진 리포지토리에서 [GitHub](https://github.com/)의 이슈와 풀 리퀘스트(PR)를 로드하는 방법을 보여줍니다. 또한 주어진 리포지토리에서 GitHub 파일을 로드하는 방법도 보여줍니다. 우리는 LangChain Python 리포지토리를 예제로 사용할 것입니다.

## 액세스 토큰 설정

GitHub API에 접근하려면 개인 액세스 토큰이 필요합니다 - 여기에서 설정할 수 있습니다: https://github.com/settings/tokens?type=beta. 이 토큰을 환경 변수 `GITHUB_PERSONAL_ACCESS_TOKEN`으로 설정하면 자동으로 가져오거나, 초기화 시 `access_token`이라는 이름의 매개변수로 직접 전달할 수 있습니다.

```python
# If you haven't set your access token as an environment variable, pass it in here.
from getpass import getpass

ACCESS_TOKEN = getpass()
```


## 이슈 및 PR 로드

```python
<!--IMPORTS:[{"imported": "GitHubIssuesLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.github.GitHubIssuesLoader.html", "title": "GitHub"}]-->
from langchain_community.document_loaders import GitHubIssuesLoader
```


```python
loader = GitHubIssuesLoader(
    repo="langchain-ai/langchain",
    access_token=ACCESS_TOKEN,  # delete/comment out this argument if you've set the access token as an env var.
    creator="UmerHA",
)
```


"UmerHA"가 생성한 모든 이슈와 PR을 로드해 보겠습니다.

사용할 수 있는 모든 필터 목록입니다:
- include_prs
- milestone
- state
- assignee
- creator
- mentioned
- labels
- sort
- direction
- since

자세한 정보는 https://docs.github.com/en/rest/issues/issues?apiVersion=2022-11-28#list-repository-issues를 참조하세요.

```python
docs = loader.load()
```


```python
print(docs[0].page_content)
print(docs[0].metadata)
```


## 이슈만 로드

기본적으로 GitHub API는 풀 리퀘스트를 이슈로 간주합니다. '순수한' 이슈(즉, 풀 리퀘스트 없음)만 가져오려면 `include_prs=False`를 사용하세요.

```python
loader = GitHubIssuesLoader(
    repo="langchain-ai/langchain",
    access_token=ACCESS_TOKEN,  # delete/comment out this argument if you've set the access token as an env var.
    creator="UmerHA",
    include_prs=False,
)
docs = loader.load()
```


```python
print(docs[0].page_content)
print(docs[0].metadata)
```


## GitHub 파일 내용 로드

아래 코드는 `langchain-ai/langchain` 리포지토리의 모든 마크다운 파일을 로드합니다.

```python
<!--IMPORTS:[{"imported": "GithubFileLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.github.GithubFileLoader.html", "title": "GitHub"}]-->
from langchain_community.document_loaders import GithubFileLoader
```


```python
loader = GithubFileLoader(
    repo="langchain-ai/langchain",  # the repo name
    access_token=ACCESS_TOKEN,
    github_api_url="https://api.github.com",
    file_filter=lambda file_path: file_path.endswith(
        ".md"
    ),  # load all markdowns files.
)
documents = loader.load()
```


문서 중 하나의 예시 출력:

```json
documents.metadata: 
    {
      "path": "README.md",
      "sha": "82f1c4ea88ecf8d2dfsfx06a700e84be4",
      "source": "https://github.com/langchain-ai/langchain/blob/master/README.md"
    }
documents.content:
    mock content
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)