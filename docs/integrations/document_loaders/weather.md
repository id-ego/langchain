---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/weather/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/weather.ipynb
---

# Weather

> [OpenWeatherMap](https://openweathermap.org/) is an open-source weather service provider

This loader fetches the weather data from the OpenWeatherMap's OneCall API, using the pyowm Python package. You must initialize the loader with your OpenWeatherMap API token and the names of the cities you want the weather data for.

```python
<!--IMPORTS:[{"imported": "WeatherDataLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.weather.WeatherDataLoader.html", "title": "Weather"}]-->
from langchain_community.document_loaders import WeatherDataLoader
```

```python
%pip install --upgrade --quiet  pyowm
```

```python
# Set API key either by passing it in to constructor directly
# or by setting the environment variable "OPENWEATHERMAP_API_KEY".

from getpass import getpass

OPENWEATHERMAP_API_KEY = getpass()
```

```python
loader = WeatherDataLoader.from_params(
    ["chennai", "vellore"], openweathermap_api_key=OPENWEATHERMAP_API_KEY
)
```

```python
documents = loader.load()
documents
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)