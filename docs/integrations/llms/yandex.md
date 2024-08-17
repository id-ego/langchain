---
canonical: https://python.langchain.com/v0.2/docs/integrations/llms/yandex/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/llms/yandex.ipynb
---

# YandexGPT

This notebook goes over how to use Langchain with [YandexGPT](https://cloud.yandex.com/en/services/yandexgpt).

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
<!--IMPORTS:[{"imported": "LLMChain", "source": "langchain.chains", "docs": "https://api.python.langchain.com/en/latest/chains/langchain.chains.llm.LLMChain.html", "title": "YandexGPT"}, {"imported": "YandexGPT", "source": "langchain_community.llms", "docs": "https://api.python.langchain.com/en/latest/llms/langchain_community.llms.yandex.YandexGPT.html", "title": "YandexGPT"}, {"imported": "PromptTemplate", "source": "langchain_core.prompts", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.prompt.PromptTemplate.html", "title": "YandexGPT"}]-->
from langchain.chains import LLMChain
from langchain_community.llms import YandexGPT
from langchain_core.prompts import PromptTemplate
```


```python
template = "What is the capital of {country}?"
prompt = PromptTemplate.from_template(template)
```


```python
llm = YandexGPT()
```


```python
llm_chain = LLMChain(prompt=prompt, llm=llm)
```


```python
country = "Russia"

llm_chain.invoke(country)
```



```output
'The capital of Russia is Moscow.'
```



## Related

- LLM [conceptual guide](/docs/concepts/#llms)
- LLM [how-to guides](/docs/how_to/#llms)