---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/subtitle/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/subtitle.ipynb
---

# Subtitle

>[The SubRip file format](https://en.wikipedia.org/wiki/SubRip#SubRip_file_format) is described on the `Matroska` multimedia container format website as "perhaps the most basic of all subtitle formats." `SubRip (SubRip Text)` files are named with the extension `.srt`, and contain formatted lines of plain text in groups separated by a blank line. Subtitles are numbered sequentially, starting at 1. The timecode format used is hours:minutes:seconds,milliseconds with time units fixed to two zero-padded digits and fractions fixed to three zero-padded digits (00:00:00,000). The fractional separator used is the comma, since the program was written in France.

How to load data from subtitle (`.srt`) files

Please, download the [example .srt file from here](https://www.opensubtitles.org/en/subtitles/5575150/star-wars-the-clone-wars-crisis-at-the-heart-en).


```python
%pip install --upgrade --quiet  pysrt
```


```python
<!--IMPORTS:[{"imported": "SRTLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.srt.SRTLoader.html", "title": "Subtitle"}]-->
from langchain_community.document_loaders import SRTLoader
```


```python
loader = SRTLoader(
    "example_data/Star_Wars_The_Clone_Wars_S06E07_Crisis_at_the_Heart.srt"
)
```


```python
docs = loader.load()
```


```python
docs[0].page_content[:100]
```



```output
'<i>Corruption discovered\nat the core of the Banking Clan!</i> <i>Reunited, Rush Clovis\nand Senator A'
```



## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)