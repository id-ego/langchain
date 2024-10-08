---
canonical: https://python.langchain.com/v0.2/docs/integrations/tools/upstage_groundedness_check/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/tools/upstage_groundedness_check.ipynb
sidebar_label: Upstage
---

# Upstage Groundedness Check

This notebook covers how to get started with Upstage groundedness check models.

## Installation

Install `langchain-upstage` package.

```bash
pip install -U langchain-upstage
```

## Environment Setup

Make sure to set the following environment variables:

- `UPSTAGE_API_KEY`: Your Upstage API key from [Upstage developers document](https://developers.upstage.ai/docs/getting-started/quick-start).

```python
import os

os.environ["UPSTAGE_API_KEY"] = "YOUR_API_KEY"
```

## Usage

Initialize `UpstageGroundednessCheck` class.

```python
from langchain_upstage import UpstageGroundednessCheck

groundedness_check = UpstageGroundednessCheck()
```

Use the `run` method to check the groundedness of the input text.

```python
request_input = {
    "context": "Mauna Kea is an inactive volcano on the island of Hawai'i. Its peak is 4,207.3 m above sea level, making it the highest point in Hawaii and second-highest peak of an island on Earth.",
    "answer": "Mauna Kea is 5,207.3 meters tall.",
}

response = groundedness_check.invoke(request_input)
print(response)
```

## Related

- Tool [conceptual guide](/docs/concepts/#tools)
- Tool [how-to guides](/docs/how_to/#tools)