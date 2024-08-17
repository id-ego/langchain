---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/airbyte_stripe/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/airbyte_stripe.ipynb
sidebar_class_name: hidden
---

# Airbyte Stripe (Deprecated)

Note: This connector-specific loader is deprecated. Please use [`AirbyteLoader`](/docs/integrations/document_loaders/airbyte) instead.

> [Airbyte](https://github.com/airbytehq/airbyte) is a data integration platform for ELT pipelines from APIs, databases & files to warehouses & lakes. It has the largest catalog of ELT connectors to data warehouses and databases.

This loader exposes the Stripe connector as a document loader, allowing you to load various Stripe objects as documents.

## Installation

First, you need to install the `airbyte-source-stripe` python package.

```python
%pip install --upgrade --quiet  airbyte-source-stripe
```

## Example

Check out the [Airbyte documentation page](https://docs.airbyte.com/integrations/sources/stripe/) for details about how to configure the reader.
The JSON schema the config object should adhere to can be found on Github: [https://github.com/airbytehq/airbyte/blob/master/airbyte-integrations/connectors/source-stripe/source_stripe/spec.yaml](https://github.com/airbytehq/airbyte/blob/master/airbyte-integrations/connectors/source-stripe/source_stripe/spec.yaml).

The general shape looks like this:
```python
{
  "client_secret": "<secret key>",
  "account_id": "<account id>",
  "start_date": "<date from which to start retrieving records from in ISO format, e.g. 2020-10-20T00:00:00Z>",
}
```

By default all fields are stored as metadata in the documents and the text is set to an empty string. Construct the text of the document by transforming the documents returned by the reader.

```python
<!--IMPORTS:[{"imported": "AirbyteStripeLoader", "source": "langchain_community.document_loaders.airbyte", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.airbyte.AirbyteStripeLoader.html", "title": "Airbyte Stripe (Deprecated)"}]-->
from langchain_community.document_loaders.airbyte import AirbyteStripeLoader

config = {
    # your stripe configuration
}

loader = AirbyteStripeLoader(
    config=config, stream_name="invoices"
)  # check the documentation linked above for a list of all streams
```

Now you can load documents the usual way

```python
docs = loader.load()
```

As `load` returns a list, it will block until all documents are loaded. To have better control over this process, you can also you the `lazy_load` method which returns an iterator instead:

```python
docs_iterator = loader.lazy_load()
```

Keep in mind that by default the page content is empty and the metadata object contains all the information from the record. To create documents in a different, pass in a record_handler function when creating the loader:

```python
<!--IMPORTS:[{"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Airbyte Stripe (Deprecated)"}]-->
from langchain_core.documents import Document


def handle_record(record, id):
    return Document(page_content=record.data["title"], metadata=record.data)


loader = AirbyteStripeLoader(
    config=config, record_handler=handle_record, stream_name="invoices"
)
docs = loader.load()
```

## Incremental loads

Some streams allow incremental loading, this means the source keeps track of synced records and won't load them again. This is useful for sources that have a high volume of data and are updated frequently.

To take advantage of this, store the `last_state` property of the loader and pass it in when creating the loader again. This will ensure that only new records are loaded.

```python
last_state = loader.last_state  # store safely

incremental_loader = AirbyteStripeLoader(
    config=config,
    record_handler=handle_record,
    stream_name="invoices",
    state=last_state,
)

new_docs = incremental_loader.load()
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)