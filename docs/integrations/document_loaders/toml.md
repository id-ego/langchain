---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/toml/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/toml.ipynb
---

# TOML

>[TOML](https://en.wikipedia.org/wiki/TOML) is a file format for configuration files. It is intended to be easy to read and write, and is designed to map unambiguously to a dictionary. Its specification is open-source. `TOML` is implemented in many programming languages. The name `TOML` is an acronym for "Tom's Obvious, Minimal Language" referring to its creator, Tom Preston-Werner.

If you need to load `Toml` files, use the `TomlLoader`.


```python
<!--IMPORTS:[{"imported": "TomlLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.toml.TomlLoader.html", "title": "TOML"}]-->
from langchain_community.document_loaders import TomlLoader
```


```python
loader = TomlLoader("example_data/fake_rule.toml")
```


```python
rule = loader.load()
```


```python
rule
```



```output
[Document(page_content='{"internal": {"creation_date": "2023-05-01", "updated_date": "2022-05-01", "release": ["release_type"], "min_endpoint_version": "some_semantic_version", "os_list": ["operating_system_list"]}, "rule": {"uuid": "some_uuid", "name": "Fake Rule Name", "description": "Fake description of rule", "query": "process where process.name : \\"somequery\\"\\n", "threat": [{"framework": "MITRE ATT&CK", "tactic": {"name": "Execution", "id": "TA0002", "reference": "https://attack.mitre.org/tactics/TA0002/"}}]}}', metadata={'source': 'example_data/fake_rule.toml'})]
```



## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)