---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/blackboard/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/blackboard.ipynb
---

# Blackboard

> [Blackboard Learn](https://en.wikipedia.org/wiki/Blackboard_Learn) (previously the Blackboard Learning Management System) is a web-based virtual learning environment and learning management system developed by Blackboard Inc. The software features course management, customizable open architecture, and scalable design that allows integration with student information systems and authentication protocols. It may be installed on local servers, hosted by `Blackboard ASP Solutions`, or provided as Software as a Service hosted on Amazon Web Services. Its main purposes are stated to include the addition of online elements to courses traditionally delivered face-to-face and development of completely online courses with few or no face-to-face meetings

This covers how to load data from a [Blackboard Learn](https://www.anthology.com/products/teaching-and-learning/learning-effectiveness/blackboard-learn) instance.

This loader is not compatible with all `Blackboard` courses. It is only
compatible with courses that use the new `Blackboard` interface.
To use this loader, you must have the BbRouter cookie. You can get this
cookie by logging into the course and then copying the value of the
BbRouter cookie from the browser's developer tools.

```python
<!--IMPORTS:[{"imported": "BlackboardLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.blackboard.BlackboardLoader.html", "title": "Blackboard"}]-->
from langchain_community.document_loaders import BlackboardLoader

loader = BlackboardLoader(
    blackboard_course_url="https://blackboard.example.com/webapps/blackboard/execute/announcement?method=search&context=course_entry&course_id=_123456_1",
    bbrouter="expires:12345...",
    load_all_recursively=True,
)
documents = loader.load()
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)