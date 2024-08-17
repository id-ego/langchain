---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/google_drive/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/google_drive.ipynb
---

# Google Drive

This notebook walks through connecting a LangChain to the `Google Drive API`.

## Prerequisites

1. Create a Google Cloud project or use an existing project
1. Enable the [Google Drive API](https://console.cloud.google.com/flows/enableapi?apiid=drive.googleapis.com)
1. [Authorize credentials for desktop app](https://developers.google.com/drive/api/quickstart/python#authorize_credentials_for_a_desktop_application)
1. `pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib`

## Instructions for retrieving your Google Docs data
By default, the `GoogleDriveTools` and `GoogleDriveWrapper` expects the `credentials.json` file to be `~/.credentials/credentials.json`, but this is configurable using the `GOOGLE_ACCOUNT_FILE` environment variable. 
The location of `token.json` use the same directory (or use the parameter `token_path`). Note that `token.json` will be created automatically the first time you use the tool.

`GoogleDriveSearchTool` can retrieve a selection of files with some requests. 

By default, If you use a `folder_id`, all the files inside this folder can be retrieved to `Document`, if the name match the query.



```python
%pip install --upgrade --quiet  google-api-python-client google-auth-httplib2 google-auth-oauthlib langchain-community
```

You can obtain your folder and document id from the URL:

* Folder: https://drive.google.com/drive/u/0/folders/1yucgL9WGgWZdM1TOuKkeghlPizuzMYb5 -> folder id is `"1yucgL9WGgWZdM1TOuKkeghlPizuzMYb5"`
* Document: https://docs.google.com/document/d/1bfaMQ18_i56204VaQDVeAFpqEijJTgvurupdEDiaUQw/edit -> document id is `"1bfaMQ18_i56204VaQDVeAFpqEijJTgvurupdEDiaUQw"`

The special value `root` is for your personal home.


```python
folder_id = "root"
# folder_id='1yucgL9WGgWZdM1TOuKkeghlPizuzMYb5'
```

By default, all files with these mime-type can be converted to `Document`.
- text/text
- text/plain
- text/html
- text/csv
- text/markdown
- image/png
- image/jpeg
- application/epub+zip
- application/pdf
- application/rtf
- application/vnd.google-apps.document (GDoc)
- application/vnd.google-apps.presentation (GSlide)
- application/vnd.google-apps.spreadsheet (GSheet)
- application/vnd.google.colaboratory (Notebook colab)
- application/vnd.openxmlformats-officedocument.presentationml.presentation (PPTX)
- application/vnd.openxmlformats-officedocument.wordprocessingml.document (DOCX)

It's possible to update or customize this. See the documentation of `GoogleDriveAPIWrapper`.

But, the corresponding packages must installed.


```python
%pip install --upgrade --quiet  unstructured
```


```python
from langchain_googledrive.tools.google_drive.tool import GoogleDriveSearchTool
from langchain_googledrive.utilities.google_drive import GoogleDriveAPIWrapper

# By default, search only in the filename.
tool = GoogleDriveSearchTool(
    api_wrapper=GoogleDriveAPIWrapper(
        folder_id=folder_id,
        num_results=2,
        template="gdrive-query-in-folder",  # Search in the body of documents
    )
)
```


```python
import logging

logging.basicConfig(level=logging.INFO)
```


```python
tool.run("machine learning")
```


```python
tool.description
```


```python
<!--IMPORTS:[{"imported": "load_tools", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agent_toolkits/langchain_community.agent_toolkits.load_tools.load_tools.html", "title": "Google Drive"}]-->
from langchain.agents import load_tools

tools = load_tools(
    ["google-drive-search"],
    folder_id=folder_id,
    template="gdrive-query-in-folder",
)
```

## Use within an Agent


```python
<!--IMPORTS:[{"imported": "AgentType", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.agent_types.AgentType.html", "title": "Google Drive"}, {"imported": "initialize_agent", "source": "langchain.agents", "docs": "https://api.python.langchain.com/en/latest/agents/langchain.agents.initialize.initialize_agent.html", "title": "Google Drive"}, {"imported": "OpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_openai.llms.base.OpenAI.html", "title": "Google Drive"}]-->
from langchain.agents import AgentType, initialize_agent
from langchain_openai import OpenAI

llm = OpenAI(temperature=0)
agent = initialize_agent(
    tools=tools,
    llm=llm,
    agent=AgentType.STRUCTURED_CHAT_ZERO_SHOT_REACT_DESCRIPTION,
)
```


```python
agent.run("Search in google drive, who is 'Yann LeCun' ?")
```


## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)