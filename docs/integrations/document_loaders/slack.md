---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/slack/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/slack.ipynb
---

# Slack

> [Slack](https://slack.com/) is an instant messaging program.

This notebook covers how to load documents from a Zipfile generated from a `Slack` export.

In order to get this `Slack` export, follow these instructions:

## 🧑 Instructions for ingesting your own dataset

Export your Slack data. You can do this by going to your Workspace Management page and clicking the Import/Export option ({your_slack_domain}.slack.com/services/export). Then, choose the right date range and click `Start export`. Slack will send you an email and a DM when the export is ready.

The download will produce a `.zip` file in your Downloads folder (or wherever your downloads can be found, depending on your OS configuration).

Copy the path to the `.zip` file, and assign it as `LOCAL_ZIPFILE` below.

```python
<!--IMPORTS:[{"imported": "SlackDirectoryLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.slack_directory.SlackDirectoryLoader.html", "title": "Slack"}]-->
from langchain_community.document_loaders import SlackDirectoryLoader
```

```python
# Optionally set your Slack URL. This will give you proper URLs in the docs sources.
SLACK_WORKSPACE_URL = "https://xxx.slack.com"
LOCAL_ZIPFILE = ""  # Paste the local paty to your Slack zip file here.

loader = SlackDirectoryLoader(LOCAL_ZIPFILE, SLACK_WORKSPACE_URL)
```

```python
docs = loader.load()
docs
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)