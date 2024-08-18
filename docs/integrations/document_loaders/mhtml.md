---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/mhtml.ipynb
description: MHTML은 이메일과 웹페이지 아카이브에 사용되는 단일 파일 형식으로, HTML 코드와 다양한 미디어 파일을 포함합니다.
---

# mhtml

MHTML은 이메일뿐만 아니라 아카이브된 웹페이지에도 사용됩니다. MHTML은 때때로 MHT라고도 하며, MIME HTML을 의미하며 전체 웹페이지가 아카이브된 단일 파일입니다. 웹페이지를 MHTML 형식으로 저장하면 이 파일 확장자는 HTML 코드, 이미지, 오디오 파일, 플래시 애니메이션 등을 포함하게 됩니다.

```python
<!--IMPORTS:[{"imported": "MHTMLLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.mhtml.MHTMLLoader.html", "title": "mhtml"}]-->
from langchain_community.document_loaders import MHTMLLoader
```


```python
# Create a new loader object for the MHTML file
loader = MHTMLLoader(
    file_path="../../../../../../tests/integration_tests/examples/example.mht"
)

# Load the document from the file
documents = loader.load()

# Print the documents to see the results
for doc in documents:
    print(doc)
```

```output
page_content='LangChain\nLANG CHAIN 🦜️🔗Official Home Page\xa0\n\n\n\n\n\n\n\nIntegrations\n\n\n\nFeatures\n\n\n\n\nBlog\n\n\n\nConceptual Guide\n\n\n\n\nPython Repo\n\n\nJavaScript Repo\n\n\n\nPython Documentation \n\n\nJavaScript Documentation\n\n\n\n\nPython ChatLangChain \n\n\nJavaScript ChatLangChain\n\n\n\n\nDiscord \n\n\nTwitter\n\n\n\n\nIf you have any comments about our WEB page, you can \nwrite us at the address shown above.  However, due to \nthe limited number of personnel in our corporate office, we are unable to \nprovide a direct response.\n\nCopyright © 2023-2023 LangChain Inc.\n\n\n' metadata={'source': '../../../../../../tests/integration_tests/examples/example.mht', 'title': 'LangChain'}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)