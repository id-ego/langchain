---
canonical: https://python.langchain.com/v0.2/docs/how_to/document_loader_pdf/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/how_to/document_loader_pdf.ipynb
---

# How to load PDFs

[Portable Document Format (PDF)](https://en.wikipedia.org/wiki/PDF), standardized as ISO 32000, is a file format developed by Adobe in 1992 to present documents, including text formatting and images, in a manner independent of application software, hardware, and operating systems.

This guide covers how to load `PDF` documents into the LangChain [Document](https://api.python.langchain.com/en/latest/documents/langchain_core.documents.base.Document.html#langchain_core.documents.base.Document) format that we use downstream.

LangChain integrates with a host of PDF parsers. Some are simple and relatively low-level; others will support OCR and image-processing, or perform advanced document layout analysis. The right choice will depend on your application. Below we enumerate the possibilities.

## Using PyPDF

Here we load a PDF using `pypdf` into array of documents, where each document contains the page content and metadata with `page` number.

```python
%pip install --upgrade --quiet pypdf
```

```python
<!--IMPORTS:[{"imported": "PyPDFLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pdf.PyPDFLoader.html", "title": "How to load PDFs"}]-->
from langchain_community.document_loaders import PyPDFLoader

file_path = (
    "../../docs/integrations/document_loaders/example_data/layout-parser-paper.pdf"
)
loader = PyPDFLoader(file_path)
pages = loader.load_and_split()

pages[0]
```

```output
Document(page_content='LayoutParser : A Uniﬁed Toolkit for Deep\nLearning Based Document Image Analysis\nZejiang Shen1( \x00), Ruochen Zhang2, Melissa Dell3, Benjamin Charles Germain\nLee4, Jacob Carlson3, and Weining Li5\n1Allen Institute for AI\nshannons@allenai.org\n2Brown University\nruochen zhang@brown.edu\n3Harvard University\n{melissadell,jacob carlson }@fas.harvard.edu\n4University of Washington\nbcgl@cs.washington.edu\n5University of Waterloo\nw422li@uwaterloo.ca\nAbstract. Recent advances in document image analysis (DIA) have been\nprimarily driven by the application of neural networks. Ideally, research\noutcomes could be easily deployed in production and extended for further\ninvestigation. However, various factors like loosely organized codebases\nand sophisticated model conﬁgurations complicate the easy reuse of im-\nportant innovations by a wide audience. Though there have been on-going\neﬀorts to improve reusability and simplify deep learning (DL) model\ndevelopment in disciplines like natural language processing and computer\nvision, none of them are optimized for challenges in the domain of DIA.\nThis represents a major gap in the existing toolkit, as DIA is central to\nacademic research across a wide range of disciplines in the social sciences\nand humanities. This paper introduces LayoutParser , an open-source\nlibrary for streamlining the usage of DL in DIA research and applica-\ntions. The core LayoutParser library comes with a set of simple and\nintuitive interfaces for applying and customizing DL models for layout de-\ntection, character recognition, and many other document processing tasks.\nTo promote extensibility, LayoutParser also incorporates a community\nplatform for sharing both pre-trained models and full document digiti-\nzation pipelines. We demonstrate that LayoutParser is helpful for both\nlightweight and large-scale digitization pipelines in real-word use cases.\nThe library is publicly available at https://layout-parser.github.io .\nKeywords: Document Image Analysis ·Deep Learning ·Layout Analysis\n·Character Recognition ·Open Source library ·Toolkit.\n1 Introduction\nDeep Learning(DL)-based approaches are the state-of-the-art for a wide range of\ndocument image analysis (DIA) tasks including document image classiﬁcation [ 11,arXiv:2103.15348v2  [cs.CV]  21 Jun 2021', metadata={'source': '../../docs/integrations/document_loaders/example_data/layout-parser-paper.pdf', 'page': 0})
```

An advantage of this approach is that documents can be retrieved with page numbers.

### Vector search over PDFs

Once we have loaded PDFs into LangChain `Document` objects, we can index them (e.g., a RAG application) in the usual way:

```python
%pip install --upgrade --quiet faiss-cpu 
# use `pip install faiss-gpu` for CUDA GPU support
```

```python
import getpass
import os

os.environ["OPENAI_API_KEY"] = getpass.getpass("OpenAI API Key:")
```

```python
<!--IMPORTS:[{"imported": "FAISS", "source": "langchain_community.vectorstores", "docs": "https://api.python.langchain.com/en/latest/vectorstores/langchain_community.vectorstores.faiss.FAISS.html", "title": "How to load PDFs"}, {"imported": "OpenAIEmbeddings", "source": "langchain_openai", "docs": "https://api.python.langchain.com/en/latest/embeddings/langchain_openai.embeddings.base.OpenAIEmbeddings.html", "title": "How to load PDFs"}]-->
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings

faiss_index = FAISS.from_documents(pages, OpenAIEmbeddings())
docs = faiss_index.similarity_search("What is LayoutParser?", k=2)
for doc in docs:
    print(str(doc.metadata["page"]) + ":", doc.page_content[:300])
```
```output
13: 14 Z. Shen et al.
6 Conclusion
LayoutParser provides a comprehensive toolkit for deep learning-based document
image analysis. The oﬀ-the-shelf library is easy to install, and can be used to
build ﬂexible and accurate pipelines for processing documents with complicated
structures. It also supports hi
0: LayoutParser : A Uniﬁed Toolkit for Deep
Learning Based Document Image Analysis
Zejiang Shen1(  ), Ruochen Zhang2, Melissa Dell3, Benjamin Charles Germain
Lee4, Jacob Carlson3, and Weining Li5
1Allen Institute for AI
shannons@allenai.org
2Brown University
ruochen zhang@brown.edu
3Harvard University
```
### Extract text from images

Some PDFs contain images of text -- e.g., within scanned documents, or figures. Using the `rapidocr-onnxruntime` package we can extract images as text as well:

```python
%pip install --upgrade --quiet rapidocr-onnxruntime
```

```python
loader = PyPDFLoader("https://arxiv.org/pdf/2103.15348.pdf", extract_images=True)
pages = loader.load()
pages[4].page_content
```

```output
'LayoutParser : A Uniﬁed Toolkit for DL-Based DIA 5\nTable 1: Current layout detection models in the LayoutParser model zoo\nDataset Base Model1Large Model Notes\nPubLayNet [38] F / M M Layouts of modern scientiﬁc documents\nPRImA [3] M - Layouts of scanned modern magazines and scientiﬁc reports\nNewspaper [17] F - Layouts of scanned US newspapers from the 20th century\nTableBank [18] F F Table region on modern scientiﬁc and business document\nHJDataset [31] F / M - Layouts of history Japanese documents\n1For each dataset, we train several models of diﬀerent sizes for diﬀerent needs (the trade-oﬀ between accuracy\nvs. computational cost). For “base model” and “large model”, we refer to using the ResNet 50 or ResNet 101\nbackbones [ 13], respectively. One can train models of diﬀerent architectures, like Faster R-CNN [ 28] (F) and Mask\nR-CNN [ 12] (M). For example, an F in the Large Model column indicates it has a Faster R-CNN model trained\nusing the ResNet 101 backbone. The platform is maintained and a number of additions will be made to the model\nzoo in coming months.\nlayout data structures , which are optimized for eﬃciency and versatility. 3) When\nnecessary, users can employ existing or customized OCR models via the uniﬁed\nAPI provided in the OCR module . 4)LayoutParser comes with a set of utility\nfunctions for the visualization and storage of the layout data. 5) LayoutParser\nis also highly customizable, via its integration with functions for layout data\nannotation and model training . We now provide detailed descriptions for each\ncomponent.\n3.1 Layout Detection Models\nInLayoutParser , a layout model takes a document image as an input and\ngenerates a list of rectangular boxes for the target content regions. Diﬀerent\nfrom traditional methods, it relies on deep convolutional neural networks rather\nthan manually curated rules to identify content regions. It is formulated as an\nobject detection problem and state-of-the-art models like Faster R-CNN [ 28] and\nMask R-CNN [ 12] are used. This yields prediction results of high accuracy and\nmakes it possible to build a concise, generalized interface for layout detection.\nLayoutParser , built upon Detectron2 [ 35], provides a minimal API that can\nperform layout detection with only four lines of code in Python:\n1import layoutparser as lp\n2image = cv2. imread (" image_file ") # load images\n3model = lp. Detectron2LayoutModel (\n4 "lp :// PubLayNet / faster_rcnn_R_50_FPN_3x / config ")\n5layout = model . detect ( image )\nLayoutParser provides a wealth of pre-trained model weights using various\ndatasets covering diﬀerent languages, time periods, and document types. Due to\ndomain shift [ 7], the prediction performance can notably drop when models are ap-\nplied to target samples that are signiﬁcantly diﬀerent from the training dataset. As\ndocument structures and layouts vary greatly in diﬀerent domains, it is important\nto select models trained on a dataset similar to the test samples. A semantic syntax\nis used for initializing the model weights in LayoutParser , using both the dataset\nname and model name lp://<dataset-name>/<model-architecture-name> .'
```

## Using other PDF loaders

For a list of other PDF loaders to use, please see [this table](https://python.langchain.com/v0.2/docs/integrations/document_loaders/#pdfs)