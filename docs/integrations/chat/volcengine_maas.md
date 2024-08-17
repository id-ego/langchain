---
canonical: https://python.langchain.com/v0.2/docs/integrations/chat/volcengine_maas/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/volcengine_maas.ipynb
sidebar_label: Volc Enging Maas
---

# VolcEngineMaasChat

This notebook provides you with a guide on how to get started with volc engine maas chat models.

```python
# Install the package
%pip install --upgrade --quiet  volcengine
```

```python
<!--IMPORTS:[{"imported": "VolcEngineMaasChat", "source": "langchain_community.chat_models", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_community.chat_models.volcengine_maas.VolcEngineMaasChat.html", "title": "VolcEngineMaasChat"}, {"imported": "HumanMessage", "source": "langchain_core.messages", "docs": "https://api.python.langchain.com/en/latest/messages/langchain_core.messages.human.HumanMessage.html", "title": "VolcEngineMaasChat"}]-->
from langchain_community.chat_models import VolcEngineMaasChat
from langchain_core.messages import HumanMessage
```

```python
chat = VolcEngineMaasChat(volc_engine_maas_ak="your ak", volc_engine_maas_sk="your sk")
```

or you can set access_key and secret_key in your environment variables
```bash
export VOLC_ACCESSKEY=YOUR_AK
export VOLC_SECRETKEY=YOUR_SK
```

```python
chat([HumanMessage(content="给我讲个笑话")])
```

```output
AIMessage(content='好的，这是一个笑话：\n\n 为什么鸟儿不会玩电脑游戏？\n\n 因为它们没有翅膀！')
```

# volc engine maas chat with stream

```python
chat = VolcEngineMaasChat(
    volc_engine_maas_ak="your ak",
    volc_engine_maas_sk="your sk",
    streaming=True,
)
```

```python
chat([HumanMessage(content="给我讲个笑话")])
```

```output
AIMessage(content='好的，这是一个笑话：\n\n 三岁的女儿说她会造句了，妈妈让她用“年轻”造句，女儿说：“妈妈减肥，一年轻了好几斤”。')
```

## Related

- Chat model [conceptual guide](/docs/concepts/#chat-models)
- Chat model [how-to guides](/docs/how_to/#chat-models)