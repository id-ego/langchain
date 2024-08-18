---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/figma.ipynb
description: Figma REST API에서 데이터를 로드하여 LangChain에 적합한 형식으로 변환하는 방법과 코드 생성 예제를 다룹니다.
---

# Figma

> [Figma](https://www.figma.com/)는 인터페이스 디자인을 위한 협업 웹 애플리케이션입니다.

이 노트북은 `Figma` REST API에서 데이터를 로드하여 LangChain에 수용할 수 있는 형식으로 변환하는 방법과 코드 생성을 위한 예제 사용법을 다룹니다.

```python
<!--IMPORTS:[{"imported": "VectorstoreIndexCreator", "source": "langchain.indexes", "docs": "https://api.python.langchain.com/en/latest/indexes/langchain.indexes.vectorstore.VectorstoreIndexCreator.html", "title": "Figma"}, {"imported": "FigmaFileLoader", "source": "langchain_community.document_loaders.figma", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.figma.FigmaFileLoader.html", "title": "Figma"}, {"imported": "ChatPromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.ChatPromptTemplate.html", "title": "Figma"}, {"imported": "HumanMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.HumanMessagePromptTemplate.html", "title": "Figma"}, {"imported": "SystemMessagePromptTemplate", "source": "langchain_core.prompts.chat", "docs": "https://api.python.langchain.com/en/latest/prompts/langchain_core.prompts.chat.SystemMessagePromptTemplate.html", "title": "Figma"}, {"imported": "ChatOpenAI", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/chat_models/langchain_openai.chat_models.base.ChatOpenAI.html", "title": "Figma"}]-->
import os

from langchain.indexes import VectorstoreIndexCreator
from langchain_community.document_loaders.figma import FigmaFileLoader
from langchain_core.prompts.chat import (
    ChatPromptTemplate,
    HumanMessagePromptTemplate,
    SystemMessagePromptTemplate,
)
from langchain_openai import ChatOpenAI
```


Figma API는 액세스 토큰, node_ids 및 파일 키가 필요합니다.

파일 키는 URL에서 가져올 수 있습니다. https://www.figma.com/file/{filekey}/sampleFilename

Node ID는 URL에서도 확인할 수 있습니다. 아무 것이나 클릭하고 '?node-id={node_id}' 매개변수를 찾으세요.

액세스 토큰에 대한 지침은 Figma 도움말 센터 기사에서 확인할 수 있습니다: https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens

```python
figma_loader = FigmaFileLoader(
    os.environ.get("ACCESS_TOKEN"),
    os.environ.get("NODE_IDS"),
    os.environ.get("FILE_KEY"),
)
```


```python
# see https://python.langchain.com/en/latest/modules/data_connection/getting_started.html for more details
index = VectorstoreIndexCreator().from_loaders([figma_loader])
figma_doc_retriever = index.vectorstore.as_retriever()
```


```python
def generate_code(human_input):
    # I have no idea if the Jon Carmack thing makes for better code. YMMV.
    # See https://python.langchain.com/en/latest/modules/models/chat/getting_started.html for chat info
    system_prompt_template = """You are expert coder Jon Carmack. Use the provided design context to create idiomatic HTML/CSS code as possible based on the user request.
    Everything must be inline in one file and your response must be directly renderable by the browser.
    Figma file nodes and metadata: {context}"""

    human_prompt_template = "Code the {text}. Ensure it's mobile responsive"
    system_message_prompt = SystemMessagePromptTemplate.from_template(
        system_prompt_template
    )
    human_message_prompt = HumanMessagePromptTemplate.from_template(
        human_prompt_template
    )
    # delete the gpt-4 model_name to use the default gpt-3.5 turbo for faster results
    gpt_4 = ChatOpenAI(temperature=0.02, model_name="gpt-4")
    # Use the retriever's 'get_relevant_documents' method if needed to filter down longer docs
    relevant_nodes = figma_doc_retriever.invoke(human_input)
    conversation = [system_message_prompt, human_message_prompt]
    chat_prompt = ChatPromptTemplate.from_messages(conversation)
    response = gpt_4(
        chat_prompt.format_prompt(
            context=relevant_nodes, text=human_input
        ).to_messages()
    )
    return response
```


```python
response = generate_code("page top header")
```


`response.content`에서 다음을 반환합니다:
```
<!DOCTYPE html>\n<html lang="en">\n<head>\n    <meta charset="UTF-8">\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n    <style>\n        @import url(\'https://fonts.googleapis.com/css2?family=DM+Sans:wght@500;700&family=Inter:wght@600&display=swap\');\n\n        body {\n            margin: 0;\n            font-family: \'DM Sans\', sans-serif;\n        }\n\n        .header {\n            display: flex;\n            justify-content: space-between;\n            align-items: center;\n            padding: 20px;\n            background-color: #fff;\n            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);\n        }\n\n        .header h1 {\n            font-size: 16px;\n            font-weight: 700;\n            margin: 0;\n        }\n\n        .header nav {\n            display: flex;\n            align-items: center;\n        }\n\n        .header nav a {\n            font-size: 14px;\n            font-weight: 500;\n            text-decoration: none;\n            color: #000;\n            margin-left: 20px;\n        }\n\n        @media (max-width: 768px) {\n            .header nav {\n                display: none;\n            }\n        }\n    </style>\n</head>\n<body>\n    <header class="header">\n        <h1>Company Contact</h1>\n        <nav>\n            <a href="#">Lorem Ipsum</a>\n            <a href="#">Lorem Ipsum</a>\n            <a href="#">Lorem Ipsum</a>\n        </nav>\n    </header>\n</body>\n</html>
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)