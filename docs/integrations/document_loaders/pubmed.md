---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/pubmed.ipynb
description: PubMed는 3500만 개 이상의 생물 의학 문헌 인용을 포함하며, MEDLINE, 생명 과학 저널 및 온라인 서적의 자료를
  제공합니다.
---

# PubMed

> [PubMed®](https://pubmed.ncbi.nlm.nih.gov/)는 `국립 생명공학 정보 센터, 국립 의학 도서관`에서 제공하며, `MEDLINE`, 생명 과학 저널 및 온라인 서적의 생물 의학 문헌에 대한 3,500만 개 이상의 인용을 포함합니다. 인용에는 `PubMed Central` 및 출판사 웹사이트의 전체 텍스트 콘텐츠에 대한 링크가 포함될 수 있습니다.

```python
<!--IMPORTS:[{"imported": "PubMedLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.pubmed.PubMedLoader.html", "title": "PubMed"}]-->
from langchain_community.document_loaders import PubMedLoader
```


```python
loader = PubMedLoader("chatgpt")
```


```python
docs = loader.load()
```


```python
len(docs)
```


```output
3
```


```python
docs[1].metadata
```


```output
{'uid': '37548997',
 'Title': 'Performance of ChatGPT on the Situational Judgement Test-A Professional Dilemmas-Based Examination for Doctors in the United Kingdom.',
 'Published': '2023-08-07',
 'Copyright Information': '©Robin J Borchert, Charlotte R Hickman, Jack Pepys, Timothy J Sadler. Originally published in JMIR Medical Education (https://mededu.jmir.org), 07.08.2023.'}
```


```python
docs[1].page_content
```


```output
"BACKGROUND: ChatGPT is a large language model that has performed well on professional examinations in the fields of medicine, law, and business. However, it is unclear how ChatGPT would perform on an examination assessing professionalism and situational judgement for doctors.\nOBJECTIVE: We evaluated the performance of ChatGPT on the Situational Judgement Test (SJT): a national examination taken by all final-year medical students in the United Kingdom. This examination is designed to assess attributes such as communication, teamwork, patient safety, prioritization skills, professionalism, and ethics.\nMETHODS: All questions from the UK Foundation Programme Office's (UKFPO's) 2023 SJT practice examination were inputted into ChatGPT. For each question, ChatGPT's answers and rationales were recorded and assessed on the basis of the official UK Foundation Programme Office scoring template. Questions were categorized into domains of Good Medical Practice on the basis of the domains referenced in the rationales provided in the scoring sheet. Questions without clear domain links were screened by reviewers and assigned one or multiple domains. ChatGPT's overall performance, as well as its performance across the domains of Good Medical Practice, was evaluated.\nRESULTS: Overall, ChatGPT performed well, scoring 76% on the SJT but scoring full marks on only a few questions (9%), which may reflect possible flaws in ChatGPT's situational judgement or inconsistencies in the reasoning across questions (or both) in the examination itself. ChatGPT demonstrated consistent performance across the 4 outlined domains in Good Medical Practice for doctors.\nCONCLUSIONS: Further research is needed to understand the potential applications of large language models, such as ChatGPT, in medical education for standardizing questions and providing consistent rationales for examinations assessing professionalism and ethics."
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)