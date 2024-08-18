---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/grobid.ipynb
description: GROBID는 학술 논문을 효과적으로 파싱하고 재구성하는 머신러닝 라이브러리입니다. PDF를 문서로 변환하여 메타데이터를 유지합니다.
---

# Grobid

GROBID는 원시 문서를 추출, 파싱 및 재구성하기 위한 머신 러닝 라이브러리입니다.

이는 학술 논문을 파싱하는 데 사용되도록 설계되었으며, 특히 잘 작동합니다. 주의: Grobid에 제공된 문서가 특정 요소 수를 초과하는 대형 문서(예: 논문)인 경우 처리되지 않을 수 있습니다.

이 로더는 Grobid를 사용하여 PDF를 텍스트 섹션과 관련된 메타데이터를 유지하는 `Documents`로 파싱합니다.

* * *
최고의 접근 방식은 docker를 통해 Grobid를 설치하는 것입니다. 자세한 내용은 https://grobid.readthedocs.io/en/latest/Grobid-docker/를 참조하십시오.

(참고: 추가 지침은 [여기](/docs/integrations/providers/grobid)에서 확인할 수 있습니다.)

Grobid가 작동하기 시작하면 아래에 설명된 대로 상호작용할 수 있습니다.

이제 데이터 로더를 사용할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "GenericLoader", "source": "langchain_community.document_loaders.generic", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.generic.GenericLoader.html", "title": "Grobid"}, {"imported": "GrobidParser", "source": "langchain_community.document_loaders.parsers", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.parsers.grobid.GrobidParser.html", "title": "Grobid"}]-->
from langchain_community.document_loaders.generic import GenericLoader
from langchain_community.document_loaders.parsers import GrobidParser
```


```python
loader = GenericLoader.from_filesystem(
    "../Papers/",
    glob="*",
    suffixes=[".pdf"],
    parser=GrobidParser(segment_sentences=False),
)
docs = loader.load()
```


```python
docs[3].page_content
```


```output
'Unlike Chinchilla, PaLM, or GPT-3, we only use publicly available data, making our work compatible with open-sourcing, while most existing models rely on data which is either not publicly available or undocumented (e.g."Books -2TB" or "Social media conversations").There exist some exceptions, notably OPT (Zhang et al., 2022), GPT-NeoX (Black et al., 2022), BLOOM (Scao et al., 2022) and GLM (Zeng et al., 2022), but none that are competitive with PaLM-62B or Chinchilla.'
```


```python
docs[3].metadata
```


```output
{'text': 'Unlike Chinchilla, PaLM, or GPT-3, we only use publicly available data, making our work compatible with open-sourcing, while most existing models rely on data which is either not publicly available or undocumented (e.g."Books -2TB" or "Social media conversations").There exist some exceptions, notably OPT (Zhang et al., 2022), GPT-NeoX (Black et al., 2022), BLOOM (Scao et al., 2022) and GLM (Zeng et al., 2022), but none that are competitive with PaLM-62B or Chinchilla.',
 'para': '2',
 'bboxes': "[[{'page': '1', 'x': '317.05', 'y': '509.17', 'h': '207.73', 'w': '9.46'}, {'page': '1', 'x': '306.14', 'y': '522.72', 'h': '220.08', 'w': '9.46'}, {'page': '1', 'x': '306.14', 'y': '536.27', 'h': '218.27', 'w': '9.46'}, {'page': '1', 'x': '306.14', 'y': '549.82', 'h': '218.65', 'w': '9.46'}, {'page': '1', 'x': '306.14', 'y': '563.37', 'h': '136.98', 'w': '9.46'}], [{'page': '1', 'x': '446.49', 'y': '563.37', 'h': '78.11', 'w': '9.46'}, {'page': '1', 'x': '304.69', 'y': '576.92', 'h': '138.32', 'w': '9.46'}], [{'page': '1', 'x': '447.75', 'y': '576.92', 'h': '76.66', 'w': '9.46'}, {'page': '1', 'x': '306.14', 'y': '590.47', 'h': '219.63', 'w': '9.46'}, {'page': '1', 'x': '306.14', 'y': '604.02', 'h': '218.27', 'w': '9.46'}, {'page': '1', 'x': '306.14', 'y': '617.56', 'h': '218.27', 'w': '9.46'}, {'page': '1', 'x': '306.14', 'y': '631.11', 'h': '220.18', 'w': '9.46'}]]",
 'pages': "('1', '1')",
 'section_title': 'Introduction',
 'section_number': '1',
 'paper_title': 'LLaMA: Open and Efficient Foundation Language Models',
 'file_path': '/Users/31treehaus/Desktop/Papers/2302.13971.pdf'}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)