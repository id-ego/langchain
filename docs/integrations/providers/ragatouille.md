---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/providers/ragatouille.ipynb
description: RAGatouille는 ColBERT를 간편하게 사용할 수 있도록 도와주는 도구로, 대규모 텍스트 컬렉션에서 빠르고 정확한
  검색을 제공합니다.
---

# RAGatouille

[RAGatouille](https://github.com/bclavie/RAGatouille)는 ColBERT를 사용하는 것을 최대한 간단하게 만들어 줍니다! [ColBERT](https://github.com/stanford-futuredata/ColBERT)는 빠르고 정확한 검색 모델로, 수십 밀리초 내에 대규모 텍스트 컬렉션에 대한 BERT 기반 검색을 가능하게 합니다.

RAGatouille를 사용할 수 있는 여러 가지 방법이 있습니다.

## 설정

통합은 `ragatouille` 패키지에 있습니다.

```bash
pip install -U ragatouille
```


```python
from ragatouille import RAGPretrainedModel

RAG = RAGPretrainedModel.from_pretrained("colbert-ir/colbertv2.0")
```

```output
[Jan 10, 10:53:28] Loading segmented_maxsim_cpp extension (set COLBERT_LOAD_TORCH_EXTENSION_VERBOSE=True for more info)...
``````output
/Users/harrisonchase/.pyenv/versions/3.10.1/envs/langchain/lib/python3.10/site-packages/torch/cuda/amp/grad_scaler.py:125: UserWarning: torch.cuda.amp.GradScaler is enabled, but CUDA is not available.  Disabling.
  warnings.warn(
```

## 검색기

RAGatouille를 검색기로 사용할 수 있습니다. 이에 대한 자세한 내용은 [RAGatouille 검색기](/docs/integrations/retrievers/ragatouille)를 참조하세요.

## 문서 압축기

RAGatouille를 즉시 사용할 수 있는 재정렬기로도 사용할 수 있습니다. 이를 통해 ColBERT를 사용하여 일반 검색기에서 검색된 결과를 재정렬할 수 있습니다. 이점은 기존 인덱스 위에서 이를 수행할 수 있어 새로운 인덱스를 만들 필요가 없다는 것입니다. 이는 LangChain의 [문서 압축기](/docs/how_to/contextual_compression) 추상화를 사용하여 수행할 수 있습니다.

## 기본 검색기 설정

먼저, 예시로 기본 검색기를 설정해 보겠습니다.

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "RAGatouille"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "RAGatouille"}, {"imported": "RecursiveCharacterTextSplitter", "source": "langchain_text_splitters", "docs": "https://api.python.langchain.com/en/latest/character/langchain_text_splitters.character.RecursiveCharacterTextSplitter.html", "title": "RAGatouille"}]-->
import requests
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter


def get_wikipedia_page(title: str):
    """
    Retrieve the full text content of a Wikipedia page.

    :param title: str - Title of the Wikipedia page.
    :return: str - Full text content of the page as raw string.
    """
    # Wikipedia API endpoint
    URL = "https://en.wikipedia.org/w/api.php"

    # Parameters for the API request
    params = {
        "action": "query",
        "format": "json",
        "titles": title,
        "prop": "extracts",
        "explaintext": True,
    }

    # Custom User-Agent header to comply with Wikipedia's best practices
    headers = {"User-Agent": "RAGatouille_tutorial/0.0.1 (ben@clavie.eu)"}

    response = requests.get(URL, params=params, headers=headers)
    data = response.json()

    # Extracting page content
    page = next(iter(data["query"]["pages"].values()))
    return page["extract"] if "extract" in page else None


text = get_wikipedia_page("Hayao_Miyazaki")
text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=0)
texts = text_splitter.create_documents([text])
```


```python
retriever = FAISS.from_documents(texts, OpenAIEmbeddings()).as_retriever(
    search_kwargs={"k": 10}
)
```


```python
docs = retriever.invoke("What animation studio did Miyazaki found")
docs[0]
```


```output
Document(page_content='collaborative projects. In April 1984, Miyazaki opened his own office in Suginami Ward, naming it Nibariki.')
```


질문에 대한 결과가 그리 관련성이 높지 않음을 알 수 있습니다.

## ColBERT를 재정렬기로 사용하기

```python
<!--IMPORTS:[{"imported": "ContextualCompressionRetriever", "source": "langchain.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain.retrievers.contextual_compression.ContextualCompressionRetriever.html", "title": "RAGatouille"}]-->
from langchain.retrievers import ContextualCompressionRetriever

compression_retriever = ContextualCompressionRetriever(
    base_compressor=RAG.as_langchain_document_compressor(), base_retriever=retriever
)

compressed_docs = compression_retriever.invoke(
    "What animation studio did Miyazaki found"
)
```

```output
/Users/harrisonchase/.pyenv/versions/3.10.1/envs/langchain/lib/python3.10/site-packages/torch/amp/autocast_mode.py:250: UserWarning: User provided device_type of 'cuda', but CUDA is not available. Disabling
  warnings.warn(
```


```python
compressed_docs[0]
```


```output
Document(page_content='In June 1985, Miyazaki, Takahata, Tokuma and Suzuki founded the animation production company Studio Ghibli, with funding from Tokuma Shoten. Studio Ghibli\'s first film, Laputa: Castle in the Sky (1986), employed the same production crew of Nausicaä. Miyazaki\'s designs for the film\'s setting were inspired by Greek architecture and "European urbanistic templates". Some of the architecture in the film was also inspired by a Welsh mining town; Miyazaki witnessed the mining strike upon his first', metadata={'relevance_score': 26.5194149017334})
```


이 답변은 훨씬 더 관련성이 높습니다!