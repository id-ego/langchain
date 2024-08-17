---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/dataherald/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/dataherald.ipynb
---

# Dataherald

This notebook goes over how to use the dataherald component.

First, you need to set up your Dataherald account and get your API KEY:

1. Go to dataherald and sign up [here](https://www.dataherald.com/)
2. Once you are logged in your Admin Console, create an API KEY
3. pip install dataherald

Then we will need to set some environment variables:
1. Save your API KEY into DATAHERALD_API_KEY env variable

```python
pip install dataherald
%pip install --upgrade --quiet langchain-community
```

```python
import os

os.environ["DATAHERALD_API_KEY"] = ""
```

```python
<!--IMPORTS:[{"imported": "DataheraldAPIWrapper", "source": "langchain_community.utilities.dataherald", "docs": "https://api.python.langchain.com/en/latest/utilities/langchain_community.utilities.dataherald.DataheraldAPIWrapper.html", "title": "Dataherald"}]-->
from langchain_community.utilities.dataherald import DataheraldAPIWrapper
```

```python
dataherald = DataheraldAPIWrapper(db_connection_id="65fb766367dd22c99ce1a12d")
```

```python
dataherald.run("How many employees are in the company?")
```

```output
'select COUNT(*) from employees'
```

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)