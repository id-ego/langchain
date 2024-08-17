---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/wolfram_alpha/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/wolfram_alpha.ipynb
---

# Wolfram Alpha

This notebook goes over how to use the wolfram alpha component.

First, you need to set up your Wolfram Alpha developer account and get your APP ID:

1. Go to wolfram alpha and sign up for a developer account [here](https://developer.wolframalpha.com/)
2. Create an app and get your APP ID
3. pip install wolframalpha

Then we will need to set some environment variables:
1. Save your APP ID into WOLFRAM_ALPHA_APPID env variable


```python
pip install wolframalpha
```


```python
import os

os.environ["WOLFRAM_ALPHA_APPID"] = ""
```


```python
<!--IMPORTS:[{"imported": "WolframAlphaAPIWrapper", "source": "langchain_community.utilities.wolfram_alpha", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.wolfram_alpha.WolframAlphaAPIWrapper.html", "title": "Wolfram Alpha"}]-->
from langchain_community.utilities.wolfram_alpha import WolframAlphaAPIWrapper
```


```python
wolfram = WolframAlphaAPIWrapper()
```


```python
wolfram.run("What is 2x+5 = -3x + 7?")
```



```output
'x = 2/5'
```



## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)