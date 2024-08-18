---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/chat/llama_api.ipynb
description: 이 문서는 LangChain과 LlamaAPI를 사용하여 함수 호출을 지원하는 Llama2의 호스팅 버전을 활용하는 방법을
  보여줍니다.
sidebar_label: Llama API
---

# ChatLlamaAPI

이 노트북은 함수 호출 지원을 추가한 Llama2의 호스팅 버전인 [LlamaAPI](https://llama-api.com/)와 LangChain을 사용하는 방법을 보여줍니다.

%pip install --upgrade --quiet  llamaapi

```python
from llamaapi import LlamaAPI

# Replace 'Your_API_Token' with your actual API token
llama = LlamaAPI("Your_API_Token")
```


```python
<!--IMPORTS:[{"imported": "ChatLlamaAPI", "source": "langchain_experimental.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_experimental.llms.llamaapi.ChatLlamaAPI.html", "title": "ChatLlamaAPI"}]-->
from langchain_experimental.llms import ChatLlamaAPI
```

```output
/Users/harrisonchase/.pyenv/versions/3.9.1/envs/langchain/lib/python3.9/site-packages/deeplake/util/check_latest_version.py:32: UserWarning: A newer version of deeplake (3.6.12) is available. It's recommended that you update to the latest version using `pip install -U deeplake`.
  warnings.warn(
```


```python
model = ChatLlamaAPI(client=llama)
```


```python
<!--IMPORTS:[{"imported": "create_tagging_chain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.openai_functions.tagging.create_tagging_chain.html", "title": "ChatLlamaAPI"}]-->
from langchain.chains import create_tagging_chain

schema = {
    "properties": {
        "sentiment": {
            "type": "string",
            "description": "the sentiment encountered in the passage",
        },
        "aggressiveness": {
            "type": "integer",
            "description": "a 0-10 score of how aggressive the passage is",
        },
        "language": {"type": "string", "description": "the language of the passage"},
    }
}

chain = create_tagging_chain(schema, model)
```


```python
chain.run("give me your money")
```


```output
{'sentiment': 'aggressive', 'aggressiveness': 8, 'language': 'english'}
```


## 관련

- 채팅 모델 [개념 가이드](/docs/concepts/#chat-models)
- 채팅 모델 [사용 방법 가이드](/docs/how_to/#chat-models)