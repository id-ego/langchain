---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/github/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/github.ipynb
---

# Github Toolkit

The `Github` toolkit contains tools that enable an LLM agent to interact with a github repository.
The tool is a wrapper for the [PyGitHub](https://github.com/PyGithub/PyGithub) library. 

For detailed documentation of all GithubToolkit features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.github.toolkit.GitHubToolkit.html).

## Setup

At a high-level, we will:

1. Install the pygithub library
2. Create a Github app
3. Set your environmental variables
4. Pass the tools to your agent with `toolkit.get_tools()`

If you want to get automated tracing from runs of individual tools, you can also set your [LangSmith](https://docs.smith.langchain.com/) API key by uncommenting below:

```python
# os.environ["LANGSMITH_API_KEY"] = getpass.getpass("Enter your LangSmith API key: ")
# os.environ["LANGSMITH_TRACING"] = "true"
```

### Installation

#### 1. Install dependencies

This integration is implemented in `langchain-community`. We will also need the `pygithub` dependency:

```python
%pip install --upgrade --quiet  pygithub langchain-community
```

#### 2. Create a Github App

[Follow the instructions here](https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app) to create and register a Github app. Make sure your app has the following [repository permissions:](https://docs.github.com/en/rest/overview/permissions-required-for-github-apps?apiVersion=2022-11-28)

* Commit statuses (read only)
* Contents (read and write)
* Issues (read and write)
* Metadata (read only)
* Pull requests (read and write)

Once the app has been registered, you must give your app permission to access each of the repositories you whish it to act upon. Use the App settings on [github.com here](https://github.com/settings/installations).

#### 3. Set Environment Variables

Before initializing your agent, the following environment variables need to be set:

* **GITHUB_APP_ID**- A six digit number found in your app's general settings
* **GITHUB_APP_PRIVATE_KEY**- The location of your app's private key .pem file, or the full text of that file as a string.
* **GITHUB_REPOSITORY**- The name of the Github repository you want your bot to act upon. Must follow the format {username}/{repo-name}. *Make sure the app has been added to this repository first!*
* Optional: **GITHUB_BRANCH**- The branch where the bot will make its commits. Defaults to `repo.default_branch`.
* Optional: **GITHUB_BASE_BRANCH**- The base branch of your repo upon which PRs will based from. Defaults to `repo.default_branch`.

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

## Instantiation

Now we can instantiate our toolkit:

```python
<!--IMPORTS:[{"imported": "GitHubToolkit", "source": "langchain_community.agent_toolkits.github.toolkit", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.github.toolkit.GitHubToolkit.html", "title": "Github Toolkit"}, {"imported": "GitHubAPIWrapper", "source": "langchain_community.utilities.github", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.github.GitHubAPIWrapper.html", "title": "Github Toolkit"}]-->
from langchain_community.agent_toolkits.github.toolkit import GitHubToolkit
from langchain_community.utilities.github import GitHubAPIWrapper

github = GitHubAPIWrapper()
toolkit = GitHubToolkit.from_github_api_wrapper(github)
```

## Tools

View available tools:

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
The purpose of these tools is as follows:

Each of these steps will be explained in great detail below.

1. **Get Issues**- fetches issues from the repository.
2. **Get Issue**- fetches details about a specific issue.
3. **Comment on Issue**- posts a comment on a specific issue.
4. **Create Pull Request**- creates a pull request from the bot's working branch to the base branch.
5. **Create File**- creates a new file in the repository.
6. **Read File**- reads a file from the repository.
7. **Update File**- updates a file in the repository.
8. **Delete File**- deletes a file from the repository.

## Use within an agent

We will need a LLM or chat model:

import ChatModelTabs from "@theme/ChatModelTabs";

<ChatModelTabs customVarName="llm" />


Initialize the agent with a subset of tools:

```python
from langgraph.prebuilt import create_react_agent

tools = [tool for tool in toolkit.get_tools() if tool.name == "Get Issue"]
assert len(tools) == 1
tools[0].name = "get_issue"

agent_executor = create_react_agent(llm, tools)
```

And issue it a query:

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
## API reference

For detailed documentation of all `GithubToolkit` features and configurations head to the [API reference](https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.github.toolkit.GitHubToolkit.html).

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)