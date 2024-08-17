---
canonical: https://python.langchain.com/v0.2/docs/integrations/chat/yandex/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/yandex.ipynb
sidebar_label: YandexGPT
---

# ChatYandexGPT

This notebook goes over how to use Langchain with [YandexGPT](https://cloud.yandex.com/en/services/yandexgpt) chat model.

To use, you should have the `yandexcloud` python package installed.

```python
%pip install --upgrade --quiet  yandexcloud
```

First, you should [create service account](https://cloud.yandex.com/en/docs/iam/operations/sa/create) with the `ai.languageModels.user` role.

Next, you have two authentication options:
- [IAM token](https://cloud.yandex.com/en/docs/iam/operations/iam-token/create-for-sa).
You can specify the token in a constructor parameter `iam_token` or in an environment variable `YC_IAM_TOKEN`.
- [API key](https://cloud.yandex.com/en/docs/iam/operations/api-key/create)
You can specify the key in a constructor parameter `api_key` or in an environment variable `YC_API_KEY`.

To specify the model you can use `model_uri` parameter, see [the documentation](https://cloud.yandex.com/en/docs/yandexgpt/concepts/models#yandexgpt-generation) for more details.

By default, the latest version of `yandexgpt-lite` is used from the folder specified in the parameter `folder_id` or `YC_FOLDER_ID` environment variable.

```python
<!--IMPORTS:[{"imported": "ChatYandexGPT", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.yandex.ChatYandexGPT.html", "title": "ChatYandexGPT"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "ChatYandexGPT"}, {"imported": "SystemMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.system.SystemMessage.html", "title": "ChatYandexGPT"}]-->
from langchain_community.chat_models import ChatYandexGPT
from langchain_core.messages import HumanMessage, SystemMessage
```

```python
chat_model = ChatYandexGPT()
```

```python
answer = chat_model.invoke(
    [
        SystemMessage(
            content="You are a helpful assistant that translates English to French."
        ),
        HumanMessage(content="I love programming."),
    ]
)
answer
```

```output
AIMessage(content='Je adore le programmement.')
```

## Related

- Chat model [conceptual guide](/docs/concepts/#chat-models)
- Chat model [how-to guides](/docs/how_to/#chat-models)