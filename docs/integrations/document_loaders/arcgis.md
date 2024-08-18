---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/arcgis.ipynb
description: 이 노트북은 `langchain_community.document_loaders.ArcGISLoader` 클래스를 사용하여
  ArcGIS 데이터를 로드하는 방법을 보여줍니다.
---

# ArcGIS

이 노트북은 `langchain_community.document_loaders.ArcGISLoader` 클래스를 사용하는 방법을 보여줍니다.

Python용 ArcGIS API `arcgis`와 선택적으로 `bs4.BeautifulSoup`를 설치해야 합니다.

인증된 데이터 로딩을 위해 `arcgis.gis.GIS` 객체를 사용할 수 있으며, 공용 데이터에 접근하려면 비워둘 수 있습니다.

```python
<!--IMPORTS:[{"imported": "ArcGISLoader", "source": "langchain_community.document_loaders", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.arcgis_loader.ArcGISLoader.html", "title": "ArcGIS"}]-->
from langchain_community.document_loaders import ArcGISLoader

URL = "https://maps1.vcgov.org/arcgis/rest/services/Beaches/MapServer/7"
loader = ArcGISLoader(URL)

docs = loader.load()
```


로더 지연 시간을 측정해 봅시다.

```python
%%time

docs = loader.load()
```

```output
CPU times: user 2.37 ms, sys: 5.83 ms, total: 8.19 ms
Wall time: 1.05 s
```


```python
docs[0].metadata
```


```output
{'accessed': '2023-09-13T19:58:32.546576+00:00Z',
 'name': 'Beach Ramps',
 'url': 'https://maps1.vcgov.org/arcgis/rest/services/Beaches/MapServer/7',
 'layer_description': '(Not Provided)',
 'item_description': '(Not Provided)',
 'layer_properties': {
   "currentVersion": 10.81,
   "id": 7,
   "name": "Beach Ramps",
   "type": "Feature Layer",
   "description": "",
   "geometryType": "esriGeometryPoint",
   "sourceSpatialReference": {
     "wkid": 2881,
     "latestWkid": 2881
   },
   "copyrightText": "",
   "parentLayer": null,
   "subLayers": [],
   "minScale": 750000,
   "maxScale": 0,
   "drawingInfo": {
     "renderer": {
       "type": "simple",
       "symbol": {
         "type": "esriPMS",
         "url": "9bb2e5ca499bb68aa3ee0d4e1ecc3849",
         "imageData": "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IB2cksfwAAAAlwSFlzAAAOxAAADsQBlSsOGwAAAJJJREFUOI3NkDEKg0AQRZ9kkSnSGBshR7DJqdJYeg7BMpcS0uQWQsqoCLExkcUJzGqT38zw2fcY1rEzbp7vjXz0EXC7gBxs1ABcG/8CYkCcDqwyLqsV+RlV0I/w7PzuJBArr1VB20H58Ls6h+xoFITkTwWpQJX7XSIBAnFwVj7MLAjJV/AC6G3QoAmK+74Lom04THTBEp/HCSc6AAAAAElFTkSuQmCC",
         "contentType": "image/png",
         "width": 12,
         "height": 12,
         "angle": 0,
         "xoffset": 0,
         "yoffset": 0
       },
       "label": "",
       "description": ""
     },
     "transparency": 0,
     "labelingInfo": null
   },
   "defaultVisibility": true,
   "extent": {
     "xmin": -81.09480168806815,
     "ymin": 28.858349245353473,
     "xmax": -80.77512908572814,
     "ymax": 29.41078388840041,
     "spatialReference": {
       "wkid": 4326,
       "latestWkid": 4326
     }
   },
   "hasAttachments": false,
   "htmlPopupType": "esriServerHTMLPopupTypeNone",
   "displayField": "AccessName",
   "typeIdField": null,
   "subtypeFieldName": null,
   "subtypeField": null,
   "defaultSubtypeCode": null,
   "fields": [
     {
       "name": "OBJECTID",
       "type": "esriFieldTypeOID",
       "alias": "OBJECTID",
       "domain": null
     },
     {
       "name": "Shape",
       "type": "esriFieldTypeGeometry",
       "alias": "Shape",
       "domain": null
     },
     {
       "name": "AccessName",
       "type": "esriFieldTypeString",
       "alias": "AccessName",
       "length": 40,
       "domain": null
     },
     {
       "name": "AccessID",
       "type": "esriFieldTypeString",
       "alias": "AccessID",
       "length": 50,
       "domain": null
     },
     {
       "name": "AccessType",
       "type": "esriFieldTypeString",
       "alias": "AccessType",
       "length": 25,
       "domain": null
     },
     {
       "name": "GeneralLoc",
       "type": "esriFieldTypeString",
       "alias": "GeneralLoc",
       "length": 100,
       "domain": null
     },
     {
       "name": "MilePost",
       "type": "esriFieldTypeDouble",
       "alias": "MilePost",
       "domain": null
     },
     {
       "name": "City",
       "type": "esriFieldTypeString",
       "alias": "City",
       "length": 50,
       "domain": null
     },
     {
       "name": "AccessStatus",
       "type": "esriFieldTypeString",
       "alias": "AccessStatus",
       "length": 50,
       "domain": null
     },
     {
       "name": "Entry_Date_Time",
       "type": "esriFieldTypeDate",
       "alias": "Entry_Date_Time",
       "length": 8,
       "domain": null
     },
     {
       "name": "DrivingZone",
       "type": "esriFieldTypeString",
       "alias": "DrivingZone",
       "length": 50,
       "domain": null
     }
   ],
   "geometryField": {
     "name": "Shape",
     "type": "esriFieldTypeGeometry",
     "alias": "Shape"
   },
   "indexes": null,
   "subtypes": [],
   "relationships": [],
   "canModifyLayer": true,
   "canScaleSymbols": false,
   "hasLabels": false,
   "capabilities": "Map,Query,Data",
   "maxRecordCount": 1000,
   "supportsStatistics": true,
   "supportsAdvancedQueries": true,
   "supportedQueryFormats": "JSON, geoJSON",
   "isDataVersioned": false,
   "ownershipBasedAccessControlForFeatures": {
     "allowOthersToQuery": true
   },
   "useStandardizedQueries": true,
   "advancedQueryCapabilities": {
     "useStandardizedQueries": true,
     "supportsStatistics": true,
     "supportsHavingClause": true,
     "supportsCountDistinct": true,
     "supportsOrderBy": true,
     "supportsDistinct": true,
     "supportsPagination": true,
     "supportsTrueCurve": true,
     "supportsReturningQueryExtent": true,
     "supportsQueryWithDistance": true,
     "supportsSqlExpression": true
   },
   "supportsDatumTransformation": true,
   "dateFieldsTimeReference": null,
   "supportsCoordinatesQuantization": true
 }}
```


### 기하학 정보 검색

피처 기하학을 검색하려면 `return_geometry` 키워드를 사용할 수 있습니다.

각 문서의 기하학 정보는 메타데이터 사전에 저장됩니다.

```python
loader_geom = ArcGISLoader(URL, return_geometry=True)
```


```python
%%time

docs = loader_geom.load()
```

```output
CPU times: user 9.6 ms, sys: 5.84 ms, total: 15.4 ms
Wall time: 1.06 s
```


```python
docs[0].metadata["geometry"]
```


```output
{'x': -81.01508803280349,
 'y': 29.24246579525828,
 'spatialReference': {'wkid': 4326, 'latestWkid': 4326}}
```


```python
for doc in docs:
    print(doc.page_content)
```

```output
{"OBJECTID": 4, "AccessName": "UNIVERSITY BLVD", "AccessID": "DB-048", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "900 BLK N ATLANTIC AV", "MilePost": 13.74, "City": "DAYTONA BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694597536000, "DrivingZone": "BOTH"}
{"OBJECTID": 18, "AccessName": "BEACHWAY AV", "AccessID": "NS-106", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "1400 N ATLANTIC AV", "MilePost": 1.57, "City": "NEW SMYRNA BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694600478000, "DrivingZone": "YES"}
{"OBJECTID": 24, "AccessName": "27TH AV", "AccessID": "NS-141", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "3600 BLK S ATLANTIC AV", "MilePost": 4.83, "City": "NEW SMYRNA BEACH", "AccessStatus": "CLOSED FOR HIGH TIDE", "Entry_Date_Time": 1694619363000, "DrivingZone": "BOTH"}
{"OBJECTID": 26, "AccessName": "SEABREEZE BLVD", "AccessID": "DB-051", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "500 BLK N ATLANTIC AV", "MilePost": 14.24, "City": "DAYTONA BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694597536000, "DrivingZone": "BOTH"}
{"OBJECTID": 30, "AccessName": "INTERNATIONAL SPEEDWAY BLVD", "AccessID": "DB-059", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "300 BLK S ATLANTIC AV", "MilePost": 15.27, "City": "DAYTONA BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694598638000, "DrivingZone": "BOTH"}
{"OBJECTID": 33, "AccessName": "GRANADA BLVD", "AccessID": "OB-030", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "20 BLK OCEAN SHORE BLVD", "MilePost": 10.02, "City": "ORMOND BEACH", "AccessStatus": "4X4 ONLY", "Entry_Date_Time": 1694595424000, "DrivingZone": "BOTH"}
{"OBJECTID": 39, "AccessName": "BEACH ST", "AccessID": "PI-097", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "4890 BLK S ATLANTIC AV", "MilePost": 25.85, "City": "PONCE INLET", "AccessStatus": "4X4 ONLY", "Entry_Date_Time": 1694596294000, "DrivingZone": "BOTH"}
{"OBJECTID": 44, "AccessName": "SILVER BEACH AV", "AccessID": "DB-064", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "1000 BLK S ATLANTIC AV", "MilePost": 15.98, "City": "DAYTONA BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694598638000, "DrivingZone": "YES"}
{"OBJECTID": 45, "AccessName": "BOTEFUHR AV", "AccessID": "DBS-067", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "1900 BLK S ATLANTIC AV", "MilePost": 16.68, "City": "DAYTONA BEACH SHORES", "AccessStatus": "OPEN", "Entry_Date_Time": 1694598638000, "DrivingZone": "YES"}
{"OBJECTID": 46, "AccessName": "MINERVA RD", "AccessID": "DBS-069", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "2300 BLK S ATLANTIC AV", "MilePost": 17.52, "City": "DAYTONA BEACH SHORES", "AccessStatus": "OPEN", "Entry_Date_Time": 1694598638000, "DrivingZone": "YES"}
{"OBJECTID": 56, "AccessName": "3RD AV", "AccessID": "NS-118", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "1200 BLK HILL ST", "MilePost": 3.25, "City": "NEW SMYRNA BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694600478000, "DrivingZone": "YES"}
{"OBJECTID": 65, "AccessName": "MILSAP RD", "AccessID": "OB-037", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "700 BLK S ATLANTIC AV", "MilePost": 11.52, "City": "ORMOND BEACH", "AccessStatus": "4X4 ONLY", "Entry_Date_Time": 1694595749000, "DrivingZone": "YES"}
{"OBJECTID": 72, "AccessName": "ROCKEFELLER DR", "AccessID": "OB-034", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "400 BLK S ATLANTIC AV", "MilePost": 10.9, "City": "ORMOND BEACH", "AccessStatus": "CLOSED - SEASONAL", "Entry_Date_Time": 1694591351000, "DrivingZone": "YES"}
{"OBJECTID": 74, "AccessName": "DUNLAWTON BLVD", "AccessID": "DBS-078", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "3400 BLK S ATLANTIC AV", "MilePost": 20.61, "City": "DAYTONA BEACH SHORES", "AccessStatus": "OPEN", "Entry_Date_Time": 1694601124000, "DrivingZone": "YES"}
{"OBJECTID": 77, "AccessName": "EMILIA AV", "AccessID": "DBS-082", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "3790 BLK S ATLANTIC AV", "MilePost": 21.38, "City": "DAYTONA BEACH SHORES", "AccessStatus": "OPEN", "Entry_Date_Time": 1694601124000, "DrivingZone": "BOTH"}
{"OBJECTID": 84, "AccessName": "VAN AV", "AccessID": "DBS-075", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "3100 BLK S ATLANTIC AV", "MilePost": 19.6, "City": "DAYTONA BEACH SHORES", "AccessStatus": "OPEN", "Entry_Date_Time": 1694601124000, "DrivingZone": "YES"}
{"OBJECTID": 104, "AccessName": "HARVARD DR", "AccessID": "OB-038", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "900 BLK S ATLANTIC AV", "MilePost": 11.72, "City": "ORMOND BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694597536000, "DrivingZone": "YES"}
{"OBJECTID": 106, "AccessName": "WILLIAMS AV", "AccessID": "DB-042", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "2200 BLK N ATLANTIC AV", "MilePost": 12.5, "City": "DAYTONA BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694597536000, "DrivingZone": "YES"}
{"OBJECTID": 109, "AccessName": "HARTFORD AV", "AccessID": "DB-043", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "1890 BLK N ATLANTIC AV", "MilePost": 12.76, "City": "DAYTONA BEACH", "AccessStatus": "CLOSED - SEASONAL", "Entry_Date_Time": 1694591351000, "DrivingZone": "YES"}
{"OBJECTID": 138, "AccessName": "CRAWFORD RD", "AccessID": "NS-108", "AccessType": "OPEN VEHICLE RAMP - PASS", "GeneralLoc": "800 BLK N ATLANTIC AV", "MilePost": 2.19, "City": "NEW SMYRNA BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694600478000, "DrivingZone": "YES"}
{"OBJECTID": 140, "AccessName": "FLAGLER AV", "AccessID": "NS-110", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "500 BLK FLAGLER AV", "MilePost": 2.57, "City": "NEW SMYRNA BEACH", "AccessStatus": "OPEN", "Entry_Date_Time": 1694600478000, "DrivingZone": "YES"}
{"OBJECTID": 144, "AccessName": "CARDINAL DR", "AccessID": "OB-036", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "600 BLK S ATLANTIC AV", "MilePost": 11.27, "City": "ORMOND BEACH", "AccessStatus": "4X4 ONLY", "Entry_Date_Time": 1694595749000, "DrivingZone": "YES"}
{"OBJECTID": 174, "AccessName": "EL PORTAL ST", "AccessID": "DBS-076", "AccessType": "OPEN VEHICLE RAMP", "GeneralLoc": "3200 BLK S ATLANTIC AV", "MilePost": 20.04, "City": "DAYTONA BEACH SHORES", "AccessStatus": "OPEN", "Entry_Date_Time": 1694601124000, "DrivingZone": "YES"}
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)