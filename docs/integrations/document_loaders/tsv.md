---
canonical: https://python.langchain.com/v0.2/docs/integrations/document_loaders/tsv/
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/tsv.ipynb
---

# TSV

> A [tab-separated values (TSV)](https://en.wikipedia.org/wiki/Tab-separated_values) file is a simple, text-based file format for storing tabular data.[3] Records are separated by newlines, and values within a record are separated by tab characters.

## `UnstructuredTSVLoader`

You can also load the table using the `UnstructuredTSVLoader`. One advantage of using `UnstructuredTSVLoader` is that if you use it in `"elements"` mode, an HTML representation of the table will be available in the metadata.

```python
<!--IMPORTS:[{"imported": "UnstructuredTSVLoader", "source": "langchain_community.document_loaders.tsv", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.tsv.UnstructuredTSVLoader.html", "title": "TSV"}]-->
from langchain_community.document_loaders.tsv import UnstructuredTSVLoader

loader = UnstructuredTSVLoader(
    file_path="./example_data/mlb_teams_2012.csv", mode="elements"
)
docs = loader.load()

print(docs[0].metadata["text_as_html"])
```
```output
<table border="1" class="dataframe">
  <tbody>
    <tr>
      <td>Team, "Payroll (millions)", "Wins"</td>
    </tr>
    <tr>
      <td>Nationals,     81.34, 98</td>
    </tr>
    <tr>
      <td>Reds,          82.20, 97</td>
    </tr>
    <tr>
      <td>Yankees,      197.96, 95</td>
    </tr>
    <tr>
      <td>Giants,       117.62, 94</td>
    </tr>
    <tr>
      <td>Braves,        83.31, 94</td>
    </tr>
    <tr>
      <td>Athletics,     55.37, 94</td>
    </tr>
    <tr>
      <td>Rangers,      120.51, 93</td>
    </tr>
    <tr>
      <td>Orioles,       81.43, 93</td>
    </tr>
    <tr>
      <td>Rays,          64.17, 90</td>
    </tr>
    <tr>
      <td>Angels,       154.49, 89</td>
    </tr>
    <tr>
      <td>Tigers,       132.30, 88</td>
    </tr>
    <tr>
      <td>Cardinals,    110.30, 88</td>
    </tr>
    <tr>
      <td>Dodgers,       95.14, 86</td>
    </tr>
    <tr>
      <td>White Sox,     96.92, 85</td>
    </tr>
    <tr>
      <td>Brewers,       97.65, 83</td>
    </tr>
    <tr>
      <td>Phillies,     174.54, 81</td>
    </tr>
    <tr>
      <td>Diamondbacks,  74.28, 81</td>
    </tr>
    <tr>
      <td>Pirates,       63.43, 79</td>
    </tr>
    <tr>
      <td>Padres,        55.24, 76</td>
    </tr>
    <tr>
      <td>Mariners,      81.97, 75</td>
    </tr>
    <tr>
      <td>Mets,          93.35, 74</td>
    </tr>
    <tr>
      <td>Blue Jays,     75.48, 73</td>
    </tr>
    <tr>
      <td>Royals,        60.91, 72</td>
    </tr>
    <tr>
      <td>Marlins,      118.07, 69</td>
    </tr>
    <tr>
      <td>Red Sox,      173.18, 69</td>
    </tr>
    <tr>
      <td>Indians,       78.43, 68</td>
    </tr>
    <tr>
      <td>Twins,         94.08, 66</td>
    </tr>
    <tr>
      <td>Rockies,       78.06, 64</td>
    </tr>
    <tr>
      <td>Cubs,          88.19, 61</td>
    </tr>
    <tr>
      <td>Astros,        60.65, 55</td>
    </tr>
  </tbody>
</table>
```

## Related

- Document loader [conceptual guide](/docs/concepts/#document-loaders)
- Document loader [how-to guides](/docs/how_to/#document-loaders)