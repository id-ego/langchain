---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/github.ipynb
description: 이 문서는 LLM 에이전트가 GitHub 리포지토리와 상호작용할 수 있도록 돕는 GitHub 툴킷의 설정 및 사용법을 설명합니다.
---

# Github 툴킷

`Github` 툴킷은 LLM 에이전트가 github 리포지토리와 상호작용할 수 있도록 하는 도구를 포함합니다. 이 도구는 [PyGitHub](https://github.com/PyGithub/PyGithub) 라이브러리에 대한 래퍼입니다.

모든 GithubToolkit 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.github.toolkit.GitHubToolkit.html)에서 확인할 수 있습니다.

## 설정

전반적으로 우리는 다음을 수행할 것입니다:

1. pygithub 라이브러리 설치
2. Github 앱 생성
3. 환경 변수 설정
4. `toolkit.get_tools()`로 도구를 에이전트에 전달

개별 도구 실행에서 자동 추적을 받고 싶다면 아래 주석을 해제하여 [LangSmith](https://docs.smith.langchain.com/) API 키를 설정할 수 있습니다:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```


### 설치

#### 1. 종속성 설치

이 통합은 `langchain-community`에서 구현됩니다. `pygithub` 종속성도 필요합니다:

```python
%pip install --upgrade --quiet  pygithub langchain-community
```


#### 2. Github 앱 생성

[여기에서 지침을 따르세요](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app) Github 앱을 생성하고 등록합니다. 앱에 다음 [리포지토리 권한이 있는지 확인하세요:](https://docs.github.com/en/rest/overview/permissions-required-for-github-apps?apiVersion=2022-11-28)

* 커밋 상태 (읽기 전용)
* 콘텐츠 (읽기 및 쓰기)
* 이슈 (읽기 및 쓰기)
* 메타데이터 (읽기 전용)
* 풀 요청 (읽기 및 쓰기)

앱이 등록되면, 앱이 작동할 각 리포지토리에 대한 접근 권한을 부여해야 합니다. [github.com의 앱 설정](https://github.com/settings/installations)에서 사용하세요.

#### 3. 환경 변수 설정

에이전트를 초기화하기 전에 다음 환경 변수를 설정해야 합니다:

* **GITHUB_APP_ID** - 앱의 일반 설정에서 찾을 수 있는 6자리 숫자
* **GITHUB_APP_PRIVATE_KEY** - 앱의 개인 키 .pem 파일의 위치 또는 해당 파일의 전체 텍스트를 문자열로
* **GITHUB_REPOSITORY** - 봇이 작동할 Github 리포지토리의 이름. {username}/{repo-name} 형식을 따라야 합니다. *먼저 이 리포지토리에 앱이 추가되었는지 확인하세요!*
* 선택 사항: **GITHUB_BRANCH** - 봇이 커밋을 할 브랜치. 기본값은 `repo.default_branch`입니다.
* 선택 사항: **GITHUB_BASE_BRANCH** - PR이 기반할 리포지토리의 기본 브랜치. 기본값은 `repo.default_branch`입니다.

```python
import getpass
import os

for env_var in [
    "GITHUB_APP_ID",
    "GITHUB_APP_PRIVATE_KEY",
    "GITHUB_REPOSITORY",
]:
    if not os.getenv(env_var):
        os.environ[env_var] = getpass.getpass()
```


## 인스턴스화

이제 툴킷을 인스턴스화할 수 있습니다:

```python
<!--IMPORTS:[{"imported": "GitHubToolkit", "source": "langchain_community.agent_toolkits.github.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.github.toolkit.GitHubToolkit.html", "title": "Github Toolkit"}, {"imported": "GitHubAPIWrapper", "source": "langchain_community.utilities.github", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.github.GitHubAPIWrapper.html", "title": "Github Toolkit"}]-->
from langchain_community.agent_toolkits.github.toolkit import GitHubToolkit
from langchain_community.utilities.github import GitHubAPIWrapper

github = GitHubAPIWrapper()
toolkit = GitHubToolkit.from_github_api_wrapper(github)
```


## 도구

사용 가능한 도구 보기:

```python
tools = toolkit.get_tools()

for tool in tools:
    print(tool.name)
```

```output
Get Issues
Get Issue
Comment on Issue
List open pull requests (PRs)
Get Pull Request
Overview of files included in PR
Create Pull Request
List Pull Requests' Files
Create File
Read File
Update File
Delete File
Overview of existing files in Main branch
Overview of files in current working branch
List branches in this repository
Set active branch
Create a new branch
Get files from a directory
Search issues and pull requests
Search code
Create review request
```

이 도구들의 목적은 다음과 같습니다:

각 단계는 아래에서 자세히 설명됩니다.

1. **이슈 가져오기** - 리포지토리에서 이슈를 가져옵니다.
2. **이슈 가져오기** - 특정 이슈에 대한 세부 정보를 가져옵니다.
3. **이슈에 댓글 달기** - 특정 이슈에 댓글을 게시합니다.
4. **풀 요청 생성** - 봇의 작업 브랜치에서 기본 브랜치로 풀 요청을 생성합니다.
5. **파일 생성** - 리포지토리에 새 파일을 생성합니다.
6. **파일 읽기** - 리포지토리에서 파일을 읽습니다.
7. **파일 업데이트** - 리포지토리에서 파일을 업데이트합니다.
8. **파일 삭제** - 리포지토리에서 파일을 삭제합니다.

## 에이전트 내에서 사용

LLM 또는 채팅 모델이 필요합니다:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />

도구의 하위 집합으로 에이전트를 초기화합니다:

```python
from langgraph.prebuilt import create_react_agent

tools = [tool for tool in toolkit.get_tools() if tool.name == "Get Issue"]
assert len(tools) == 1
tools[0].name = "get_issue"

agent_executor = create_react_agent(llm, tools)
```


그리고 쿼리를 발행합니다:

```python
example_query = "What is the title of issue 24888?"

events = agent_executor.stream(
    {"messages": [("user", example_query)]},
    stream_mode="values",
)
for event in events:
    event["messages"][-1].pretty_print()
```

```output
================================[1m Human Message [0m=================================

What is the title of issue 24888?
==================================[1m Ai Message [0m==================================
Tool Calls:
  get_issue (call_iSYJVaM7uchfNHOMJoVPQsOi)
 Call ID: call_iSYJVaM7uchfNHOMJoVPQsOi
  Args:
    issue_number: 24888
=================================[1m Tool Message [0m=================================
Name: get_issue

{"number": 24888, "title": "Standardize KV-Store Docs", "body": "To make our KV-store integrations as easy to use as possible we need to make sure the docs for them are thorough and standardized. There are two parts to this: updating the KV-store docstrings and updating the actual integration docs.\r\n\r\nThis needs to be done for each KV-store integration, ideally with one PR per KV-store.\r\n\r\nRelated to broader issues #21983 and #22005.\r\n\r\n## Docstrings\r\nEach KV-store class docstring should have the sections shown in the [Appendix](#appendix) below. The sections should have input and output code blocks when relevant.\r\n\r\nTo build a preview of the API docs for the package you're working on run (from root of repo):\r\n\r\n```shell\r\nmake api_docs_clean; make api_docs_quick_preview API_PKG=openai\r\n```\r\n\r\nwhere `API_PKG=` should be the parent directory that houses the edited package (e.g. community, openai, anthropic, huggingface, together, mistralai, groq, fireworks, etc.). This should be quite fast for all the partner packages.\r\n\r\n## Doc pages\r\nEach KV-store [docs page](https://python.langchain.com/v0.2/docs/integrations/stores/) should follow [this template](https://github.com/langchain-ai/langchain/blob/master/libs/cli/langchain_cli/integration_template/docs/kv_store.ipynb).\r\n\r\nHere is an example: https://python.langchain.com/v0.2/docs/integrations/stores/in_memory/\r\n\r\nYou can use the `langchain-cli` to quickly get started with a new chat model integration docs page (run from root of repo):\r\n\r\n```shell\r\npoetry run pip install -e libs/cli\r\npoetry run langchain-cli integration create-doc --name \"foo-bar\" --name-class FooBar --component-type kv_store --destination-dir ./docs/docs/integrations/stores/\r\n```\r\n\r\nwhere `--name` is the integration package name without the \"langchain-\" prefix and `--name-class` is the class name without the \"ByteStore\" suffix. This will create a template doc with some autopopulated fields at docs/docs/integrations/stores/foo_bar.ipynb.\r\n\r\nTo build a preview of the docs you can run (from root):\r\n\r\n```shell\r\nmake docs_clean\r\nmake docs_build\r\ncd docs/build/output-new\r\nyarn\r\nyarn start\r\n```\r\n\r\n## Appendix\r\nExpected sections for the KV-store class docstring.\r\n\r\n```python\r\n    \"\"\"__ModuleName__ completion KV-store integration.\r\n\r\n    # TODO: Replace with relevant packages, env vars.\r\n    Setup:\r\n        Install ``__package_name__`` and set environment variable ``__MODULE_NAME___API_KEY``.\r\n\r\n        .. code-block:: bash\r\n\r\n            pip install -U __package_name__\r\n            export __MODULE_NAME___API_KEY=\"your-api-key\"\r\n\r\n    # TODO: Populate with relevant params.\r\n    Key init args \u2014 client params:\r\n        api_key: Optional[str]\r\n            __ModuleName__ API key. If not passed in will be read from env var __MODULE_NAME___API_KEY.\r\n\r\n    See full list of supported init args and their descriptions in the params section.\r\n\r\n    # TODO: Replace with relevant init params.\r\n    Instantiate:\r\n        .. code-block:: python\r\n\r\n            from __module_name__ import __ModuleName__ByteStore\r\n\r\n            kv_store = __ModuleName__ByteStore(\r\n                # api_key=\"...\",\r\n                # other params...\r\n            )\r\n\r\n    Set keys:\r\n        .. code-block:: python\r\n\r\n            kv_pairs = [\r\n                [\"key1\", \"value1\"],\r\n                [\"key2\", \"value2\"],\r\n            ]\r\n\r\n            kv_store.mset(kv_pairs)\r\n\r\n        .. code-block:: python\r\n\r\n    Get keys:\r\n        .. code-block:: python\r\n\r\n            kv_store.mget([\"key1\", \"key2\"])\r\n\r\n        .. code-block:: python\r\n\r\n            # TODO: Example output.\r\n\r\n    Delete keys:\r\n        ..code-block:: python\r\n\r\n            kv_store.mdelete([\"key1\", \"key2\"])\r\n\r\n        ..code-block:: python\r\n    \"\"\"  # noqa: E501\r\n```", "comments": "[]", "opened_by": "jacoblee93"}
==================================[1m Ai Message [0m==================================

The title of issue 24888 is "Standardize KV-Store Docs".
```

## API 참조

모든 `GithubToolkit` 기능 및 구성에 대한 자세한 문서는 [API 참조](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.github.toolkit.GitHubToolkit.html)에서 확인할 수 있습니다.

## 관련

- 도구 [개념 가이드](/docs/concepts/#tools)
- 도구 [사용 방법 가이드](/docs/how_to/#tools)