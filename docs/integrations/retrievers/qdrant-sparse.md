---
canonical: https://python.langchain.com/v0.2/docs/integrations/retrievers/qdrant-sparse/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/retrievers/qdrant-sparse.ipynb
---

# Qdrant Sparse Vector

> [Qdrant](https://qdrant.tech/) is an open-source, high-performance vector search engine/database.

> `QdrantSparseVectorRetriever` uses [sparse vectors](https://qdrant.tech/articles/sparse-vectors/) introduced in `Qdrant` [v1.7.0](https://qdrant.tech/articles/qdrant-1.7.x/) for document retrieval.

Install the 'qdrant_client' package:

```python
%pip install --upgrade --quiet  qdrant_client
```

```python
from qdrant_client import QdrantClient, models

client = QdrantClient(location=":memory:")
collection_name = "sparse_collection"
vector_name = "sparse_vector"

client.create_collection(
    collection_name,
    vectors_config={},
    sparse_vectors_config={
        vector_name: models.SparseVectorParams(
            index=models.SparseIndexParams(
                on_disk=False,
            )
        )
    },
)
```

```output
True
```

```python
<!--IMPORTS:[{"imported": "QdrantSparseVectorRetriever", "source": "langchain_community.retrievers", "docs": "https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.qdrant_sparse_vector_retriever.QdrantSparseVectorRetriever.html", "title": "Qdrant Sparse Vector"}, {"imported": "Document", "source": "langchain_core.documents", "docs": "https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html", "title": "Qdrant Sparse Vector"}]-->
from langchain_community.retrievers import (
    QdrantSparseVectorRetriever,
)
from langchain_core.documents import Document
```

Create a demo encoder function:

```python
import random


def demo_encoder(_: str) -> tuple[list[int], list[float]]:
    return (
        sorted(random.sample(range(100), 100)),
        [random.uniform(0.1, 1.0) for _ in range(100)],
    )


# Create a retriever with a demo encoder
retriever = QdrantSparseVectorRetriever(
    client=client,
    collection_name=collection_name,
    sparse_vector_name=vector_name,
    sparse_encoder=demo_encoder,
)
```

Add some documents:

```python
docs = [
    Document(
        metadata={
            "title": "Beyond Horizons: AI Chronicles",
            "author": "Dr. Cassandra Mitchell",
        },
        page_content="An in-depth exploration of the fascinating journey of artificial intelligence, narrated by Dr. Mitchell. This captivating account spans the historical roots, current advancements, and speculative futures of AI, offering a gripping narrative that intertwines technology, ethics, and societal implications.",
    ),
    Document(
        metadata={
            "title": "Synergy Nexus: Merging Minds with Machines",
            "author": "Prof. Benjamin S. Anderson",
        },
        page_content="Professor Anderson delves into the synergistic possibilities of human-machine collaboration in 'Synergy Nexus.' The book articulates a vision where humans and AI seamlessly coalesce, creating new dimensions of productivity, creativity, and shared intelligence.",
    ),
    Document(
        metadata={
            "title": "AI Dilemmas: Navigating the Unknown",
            "author": "Dr. Elena Rodriguez",
        },
        page_content="Dr. Rodriguez pens an intriguing narrative in 'AI Dilemmas,' probing the uncharted territories of ethical quandaries arising from AI advancements. The book serves as a compass, guiding readers through the complex terrain of moral decisions confronting developers, policymakers, and society as AI evolves.",
    ),
    Document(
        metadata={
            "title": "Sentient Threads: Weaving AI Consciousness",
            "author": "Prof. Alexander J. Bennett",
        },
        page_content="In 'Sentient Threads,' Professor Bennett unravels the enigma of AI consciousness, presenting a tapestry of arguments that scrutinize the very essence of machine sentience. The book ignites contemplation on the ethical and philosophical dimensions surrounding the quest for true AI awareness.",
    ),
    Document(
        metadata={
            "title": "Silent Alchemy: Unseen AI Alleviations",
            "author": "Dr. Emily Foster",
        },
        page_content="Building upon her previous work, Dr. Foster unveils 'Silent Alchemy,' a profound examination of the covert presence of AI in our daily lives. This illuminating piece reveals the subtle yet impactful ways in which AI invisibly shapes our routines, emphasizing the need for heightened awareness in our technology-driven world.",
    ),
]
```

Perform a retrieval:

```python
retriever.add_documents(docs)
```

```output
['1a3e0d292e6444d39451d0588ce746dc',
 '19b180dd31e749359d49967e5d5dcab7',
 '8de69e56086f47748e32c9e379e6865b',
 'f528fac385954e46b89cf8607bf0ee5a',
 'c1a6249d005d4abd9192b1d0b829cebe']
```

```python
retriever.invoke(
    "Life and ethical dilemmas of AI",
)
```

```output
[Document(page_content="In 'Sentient Threads,' Professor Bennett unravels the enigma of AI consciousness, presenting a tapestry of arguments that scrutinize the very essence of machine sentience. The book ignites contemplation on the ethical and philosophical dimensions surrounding the quest for true AI awareness.", metadata={'title': 'Sentient Threads: Weaving AI Consciousness', 'author': 'Prof. Alexander J. Bennett'}),
 Document(page_content="Dr. Rodriguez pens an intriguing narrative in 'AI Dilemmas,' probing the uncharted territories of ethical quandaries arising from AI advancements. The book serves as a compass, guiding readers through the complex terrain of moral decisions confronting developers, policymakers, and society as AI evolves.", metadata={'title': 'AI Dilemmas: Navigating the Unknown', 'author': 'Dr. Elena Rodriguez'}),
 Document(page_content="Professor Anderson delves into the synergistic possibilities of human-machine collaboration in 'Synergy Nexus.' The book articulates a vision where humans and AI seamlessly coalesce, creating new dimensions of productivity, creativity, and shared intelligence.", metadata={'title': 'Synergy Nexus: Merging Minds with Machines', 'author': 'Prof. Benjamin S. Anderson'}),
 Document(page_content='An in-depth exploration of the fascinating journey of artificial intelligence, narrated by Dr. Mitchell. This captivating account spans the historical roots, current advancements, and speculative futures of AI, offering a gripping narrative that intertwines technology, ethics, and societal implications.', metadata={'title': 'Beyond Horizons: AI Chronicles', 'author': 'Dr. Cassandra Mitchell'})]
```

## Related

- Retriever [conceptual guide](/docs/concepts/#retrievers)
- Retriever [how-to guides](/docs/how_to/#retrievers)