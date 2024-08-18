---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/geopandas.ipynb
description: GeoPandas는 파이썬에서 지리 공간 데이터를 쉽게 다룰 수 있도록 해주는 오픈 소스 프로젝트입니다.
---

# 지오판다스

[Geopandas](https://geopandas.org/en/stable/index.html)는 파이썬에서 지리 공간 데이터를 다루는 것을 더 쉽게 하기 위한 오픈 소스 프로젝트입니다.

GeoPandas는 기하학적 유형에 대한 공간 작업을 허용하기 위해 pandas에서 사용하는 데이터 유형을 확장합니다.

기하학적 작업은 shapely에 의해 수행됩니다. Geopandas는 파일 접근을 위해 fiona에, 플로팅을 위해 matplotlib에 추가로 의존합니다.

지리 공간 데이터를 활용하는 LLM 애플리케이션(채팅, QA)은 탐색할 흥미로운 영역입니다.

```python
%pip install --upgrade --quiet  sodapy
%pip install --upgrade --quiet  pandas
%pip install --upgrade --quiet  geopandas
```


```python
<!--IMPORTS:[{"imported": "OpenCityDataLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.open_city_data.OpenCityDataLoader.html", "title": "Geopandas"}]-->
import ast

import geopandas as gpd
import pandas as pd
from langchain_community.document_loaders import OpenCityDataLoader
```


예제 입력으로 [`Open City Data`](/docs/integrations/document_loaders/open_city_data)에서 GeoPandas 데이터프레임을 생성합니다.

```python
# Load Open City Data
dataset = "tmnf-yvry"  # San Francisco crime data
loader = OpenCityDataLoader(city_id="data.sfgov.org", dataset_id=dataset, limit=5000)
docs = loader.load()
```


```python
# Convert list of dictionaries to DataFrame
df = pd.DataFrame([ast.literal_eval(d.page_content) for d in docs])

# Extract latitude and longitude
df["Latitude"] = df["location"].apply(lambda loc: loc["coordinates"][1])
df["Longitude"] = df["location"].apply(lambda loc: loc["coordinates"][0])

# Create geopandas DF
gdf = gpd.GeoDataFrame(
    df, geometry=gpd.points_from_xy(df.Longitude, df.Latitude), crs="EPSG:4326"
)

# Only keep valid longitudes and latitudes for San Francisco
gdf = gdf[
    (gdf["Longitude"] >= -123.173825)
    & (gdf["Longitude"] <= -122.281780)
    & (gdf["Latitude"] >= 37.623983)
    & (gdf["Latitude"] <= 37.929824)
]
```


샌프란시스코 범죄 데이터 샘플의 시각화입니다.

```python
import matplotlib.pyplot as plt

# Load San Francisco map data
sf = gpd.read_file("https://data.sfgov.org/resource/3psu-pn9h.geojson")

# Plot the San Francisco map and the points
fig, ax = plt.subplots(figsize=(10, 10))
sf.plot(ax=ax, color="white", edgecolor="black")
gdf.plot(ax=ax, color="red", markersize=5)
plt.show()
```


하류 처리(임베딩, 채팅 등)를 위해 GeoPandas 데이터프레임을 `Document`로 로드합니다.

`geometry`는 기본 `page_content` 열이 되며, 모든 다른 열은 `metadata`에 배치됩니다.

그러나 `page_content_column`을 지정할 수 있습니다.

```python
<!--IMPORTS:[{"imported": "GeoDataFrameLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.geodataframe.GeoDataFrameLoader.html", "title": "Geopandas"}]-->
from langchain_community.document_loaders import GeoDataFrameLoader

loader = GeoDataFrameLoader(data_frame=gdf, page_content_column="geometry")
docs = loader.load()
```


```python
docs[0]
```


```output
Document(page_content='POINT (-122.420084075249 37.7083109744362)', metadata={'pdid': '4133422003074', 'incidntnum': '041334220', 'incident_code': '03074', 'category': 'ROBBERY', 'descript': 'ROBBERY, BODILY FORCE', 'dayofweek': 'Monday', 'date': '2004-11-22T00:00:00.000', 'time': '17:50', 'pddistrict': 'INGLESIDE', 'resolution': 'NONE', 'address': 'GENEVA AV / SANTOS ST', 'x': '-122.420084075249', 'y': '37.7083109744362', 'location': {'type': 'Point', 'coordinates': [-122.420084075249, 37.7083109744362]}, ':@computed_region_26cr_cadq': '9', ':@computed_region_rxqg_mtj9': '8', ':@computed_region_bh8s_q3mv': '309', ':@computed_region_6qbp_sg9q': nan, ':@computed_region_qgnn_b9vv': nan, ':@computed_region_ajp5_b2md': nan, ':@computed_region_yftq_j783': nan, ':@computed_region_p5aj_wyqh': nan, ':@computed_region_fyvs_ahh9': nan, ':@computed_region_6pnf_4xz7': nan, ':@computed_region_jwn9_ihcz': nan, ':@computed_region_9dfj_4gjx': nan, ':@computed_region_4isq_27mq': nan, ':@computed_region_pigm_ib2e': nan, ':@computed_region_9jxd_iqea': nan, ':@computed_region_6ezc_tdp2': nan, ':@computed_region_h4ep_8xdi': nan, ':@computed_region_n4xg_c4py': nan, ':@computed_region_fcz8_est8': nan, ':@computed_region_nqbw_i6c3': nan, ':@computed_region_2dwj_jsy4': nan, 'Latitude': 37.7083109744362, 'Longitude': -122.420084075249})
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)