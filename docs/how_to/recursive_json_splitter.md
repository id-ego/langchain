---
canonical: https://python.langchain.com/v0.2/docs/how_to/recursive_json_splitter/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/recursive_json_splitter.ipynb
---

# How to split JSON data

This json splitter splits json data while allowing control over chunk sizes. It traverses json data depth first and builds smaller json chunks. It attempts to keep nested json objects whole but will split them if needed to keep chunks between a min_chunk_size and the max_chunk_size.

If the value is not a nested json, but rather a very large string the string will not be split. If you need a hard cap on the chunk size consider composing this with a Recursive Text splitter on those chunks. There is an optional pre-processing step to split lists, by first converting them to json (dict) and then splitting them as such.

1. How the text is split: json value.
2. How the chunk size is measured: by number of characters.

```python
%pip install -qU langchain-text-splitters
```

First we load some json data:

```python
import json

import requests

# This is a large nested json object and will be loaded as a python dict
json_data = requests.get("https://api.smith.langchain.com/openapi.json").json()
```

## Basic usage

Specify `max_chunk_size` to constrain chunk sizes:

```python
<!--IMPORTS:[{"imported": "RecursiveJsonSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/json/langchain_text_splitters.json.RecursiveJsonSplitter.html", "title": "How to split JSON data"}]-->
from langchain_text_splitters import RecursiveJsonSplitter

splitter = RecursiveJsonSplitter(max_chunk_size=300)
```

To obtain json chunks, use the `.split_json` method:

```python
# Recursively split json data - If you need to access/manipulate the smaller json chunks
json_chunks = splitter.split_json(json_data=json_data)

for chunk in json_chunks[:3]:
    print(chunk)
```
```output
{'openapi': '3.1.0', 'info': {'title': 'LangSmith', 'version': '0.1.0'}, 'servers': [{'url': 'https://api.smith.langchain.com', 'description': 'LangSmith API endpoint.'}]}
{'paths': {'/api/v1/sessions/{session_id}': {'get': {'tags': ['tracer-sessions'], 'summary': 'Read Tracer Session', 'description': 'Get a specific session.', 'operationId': 'read_tracer_session_api_v1_sessions__session_id__get'}}}}
{'paths': {'/api/v1/sessions/{session_id}': {'get': {'security': [{'API Key': []}, {'Tenant ID': []}, {'Bearer Auth': []}]}}}}
```
To obtain LangChain [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html) objects, use the `.create_documents` method:

```python
# The splitter can also output documents
docs = splitter.create_documents(texts=[json_data])

for doc in docs[:3]:
    print(doc)
```
```output
page_content='{"openapi": "3.1.0", "info": {"title": "LangSmith", "version": "0.1.0"}, "servers": [{"url": "https://api.smith.langchain.com", "description": "LangSmith API endpoint."}]}'
page_content='{"paths": {"/api/v1/sessions/{session_id}": {"get": {"tags": ["tracer-sessions"], "summary": "Read Tracer Session", "description": "Get a specific session.", "operationId": "read_tracer_session_api_v1_sessions__session_id__get"}}}}'
page_content='{"paths": {"/api/v1/sessions/{session_id}": {"get": {"security": [{"API Key": []}, {"Tenant ID": []}, {"Bearer Auth": []}]}}}}'
```
Or use `.split_text` to obtain string content directly:

```python
texts = splitter.split_text(json_data=json_data)

print(texts[0])
print(texts[1])
```
```output
{"openapi": "3.1.0", "info": {"title": "LangSmith", "version": "0.1.0"}, "servers": [{"url": "https://api.smith.langchain.com", "description": "LangSmith API endpoint."}]}
{"paths": {"/api/v1/sessions/{session_id}": {"get": {"tags": ["tracer-sessions"], "summary": "Read Tracer Session", "description": "Get a specific session.", "operationId": "read_tracer_session_api_v1_sessions__session_id__get"}}}}
```
## How to manage chunk sizes from list content

Note that one of the chunks in this example is larger than the specified `max_chunk_size` of 300. Reviewing one of these chunks that was bigger we see there is a list object there:

```python
print([len(text) for text in texts][:10])
print()
print(texts[3])
```
```output
[171, 231, 126, 469, 210, 213, 237, 271, 191, 232]

{"paths": {"/api/v1/sessions/{session_id}": {"get": {"parameters": [{"name": "session_id", "in": "path", "required": true, "schema": {"type": "string", "format": "uuid", "title": "Session Id"}}, {"name": "include_stats", "in": "query", "required": false, "schema": {"type": "boolean", "default": false, "title": "Include Stats"}}, {"name": "accept", "in": "header", "required": false, "schema": {"anyOf": [{"type": "string"}, {"type": "null"}], "title": "Accept"}}]}}}}
```
The json splitter by default does not split lists.

Specify `convert_lists=True` to preprocess the json, converting list content to dicts with `index:item` as `key:val` pairs:

```python
texts = splitter.split_text(json_data=json_data, convert_lists=True)
```

Let's look at the size of the chunks. Now they are all under the max

```python
print([len(text) for text in texts][:10])
```
```output
[176, 236, 141, 203, 212, 221, 210, 213, 242, 291]
```
The list has been converted to a dict, but retains all the needed contextual information even if split into many chunks:

```python
print(texts[1])
```
```output
{"paths": {"/api/v1/sessions/{session_id}": {"get": {"tags": {"0": "tracer-sessions"}, "summary": "Read Tracer Session", "description": "Get a specific session.", "operationId": "read_tracer_session_api_v1_sessions__session_id__get"}}}}
```

```python
# We can also look at the documents
docs[1]
```

```output
Document(page_content='{"paths": {"/api/v1/sessions/{session_id}": {"get": {"tags": ["tracer-sessions"], "summary": "Read Tracer Session", "description": "Get a specific session.", "operationId": "read_tracer_session_api_v1_sessions__session_id__get"}}}}')
```