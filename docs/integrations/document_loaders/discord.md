---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/discord/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/discord.ipynb
---

# Discord

> [Discord](https://discord.com/) is a VoIP and instant messaging social platform. Users have the ability to communicate with voice calls, video calls, text messaging, media and files in private chats or as part of communities called "servers". A server is a collection of persistent chat rooms and voice channels which can be accessed via invite links.

Follow these steps to download your `Discord` data:

1. Go to your **User Settings**
2. Then go to **Privacy and Safety**
3. Head over to the **Request all of my Data** and click on **Request Data** button

It might take 30 days for you to receive your data. You'll receive an email at the address which is registered with Discord. That email will have a download button using which you would be able to download your personal Discord data.

```python
import os

import pandas as pd
```

```python
path = input('Please enter the path to the contents of the Discord "messages" folder: ')
li = []
for f in os.listdir(path):
    expected_csv_path = os.path.join(path, f, "messages.csv")
    csv_exists = os.path.isfile(expected_csv_path)
    if csv_exists:
        df = pd.read_csv(expected_csv_path, index_col=None, header=0)
        li.append(df)

df = pd.concat(li, axis=0, ignore_index=True, sort=False)
```

```python
<!--IMPORTS:[{"imported": "DiscordChatLoader", "source": "langchain_community.document_loaders.discord", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.discord.DiscordChatLoader.html", "title": "Discord"}]-->
from langchain_community.document_loaders.discord import DiscordChatLoader
```

```python
loader = DiscordChatLoader(df, user_id_col="ID")
print(loader.load())
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)