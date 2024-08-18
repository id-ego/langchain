---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/graphs/amazon_neptune_sparql.ipynb
description: Amazon Neptune과 SPARQL을 사용하여 RDF 데이터를 쿼리하고 자연어 질문에 대한 응답을 반환하는 예제를 보여줍니다.
---

# 아마존 넵튠과 SPARQL

> [아마존 넵튠](https://aws.amazon.com/neptune/)은 뛰어난 확장성과 가용성을 위한 고성능 그래프 분석 및 서버리스 데이터베이스입니다.
> 
> 이 예제는 `SPARQL` 쿼리 언어를 사용하여 `Amazon Neptune` 그래프 데이터베이스에서 [자원 설명 프레임워크 (RDF)](https://en.wikipedia.org/wiki/Resource_Description_Framework) 데이터를 쿼리하고 인간이 읽을 수 있는 응답을 반환하는 QA 체인을 보여줍니다.
> 
> [SPARQL](https://en.wikipedia.org/wiki/SPARQL)은 `RDF` 그래프를 위한 표준 쿼리 언어입니다.

이 예제는 넵튠 데이터베이스와 연결하고 그 스키마를 로드하는 `NeptuneRdfGraph` 클래스를 사용합니다.
`NeptuneSparqlQAChain`은 그래프와 LLM을 연결하여 자연어 질문을 할 수 있도록 합니다.

이 노트북은 조직 데이터를 사용하는 예제를 보여줍니다.

이 노트북을 실행하기 위한 요구 사항:
- 이 노트북에서 접근 가능한 넵튠 1.2.x 클러스터
- Python 3.9 이상을 사용하는 커널
- 베드락 접근을 위해 IAM 역할에 이 정책이 포함되어야 합니다.

```json
{
        "Action": [
            "bedrock:ListFoundationModels",
            "bedrock:InvokeModel"
        ],
        "Resource": "*",
        "Effect": "Allow"
}
```


- 샘플 데이터를 위한 S3 버킷. 버킷은 넵튠과 동일한 계정/지역에 있어야 합니다.

## 설정하기

### W3C 조직 데이터 시드

W3C 조직 데이터, W3C 조직 온톨로지 및 몇 가지 인스턴스를 시드합니다.

동일한 지역과 계정에 S3 버킷이 필요합니다. 그 버킷의 이름을 `STAGE_BUCKET`으로 설정하세요.

```python
STAGE_BUCKET = "<bucket-name>"
```


```bash
%%bash  -s "$STAGE_BUCKET"

rm -rf data
mkdir -p data
cd data
echo getting org ontology and sample org instances
wget http://www.w3.org/ns/org.ttl 
wget https://raw.githubusercontent.com/aws-samples/amazon-neptune-ontology-example-blog/main/data/example_org.ttl 

echo Copying org ttl to S3
aws s3 cp org.ttl s3://$1/org.ttl
aws s3 cp example_org.ttl s3://$1/example_org.ttl

```


조직 ttl을 대량 로드합니다 - 온톨로지와 인스턴스 모두

```python
%load -s s3://{STAGE_BUCKET} -f turtle --store-to loadres --run
```


```python
%load_status {loadres['payload']['loadId']} --errors --details
```


### 체인 설정

```python
!pip install --upgrade --quiet langchain langchain-community langchain-aws
```


** 커널 재시작 **

### 예제 준비

```python
EXAMPLES = """

<question>
Find organizations.
</question>

<sparql>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX org: <http://www.w3.org/ns/org#> 

select ?org ?orgName where {{
    ?org rdfs:label ?orgName .
}} 
</sparql>

<question>
Find sites of an organization
</question>

<sparql>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX org: <http://www.w3.org/ns/org#> 

select ?org ?orgName ?siteName where {{
    ?org rdfs:label ?orgName .
    ?org org:hasSite/rdfs:label ?siteName . 
}} 
</sparql>

<question>
Find suborganizations of an organization
</question>

<sparql>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX org: <http://www.w3.org/ns/org#> 

select ?org ?orgName ?subName where {{
    ?org rdfs:label ?orgName .
    ?org org:hasSubOrganization/rdfs:label ?subName  .
}} 
</sparql>

<question>
Find organizational units of an organization
</question>

<sparql>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
PREFIX org: <http://www.w3.org/ns/org#> 

select ?org ?orgName ?unitName where {{
    ?org rdfs:label ?orgName .
    ?org org:hasUnit/rdfs:label ?unitName . 
}} 
</sparql>

<question>
Find members of an organization. Also find their manager, or the member they report to.
</question>

<sparql>
PREFIX org: <http://www.w3.org/ns/org#> 
PREFIX foaf: <http://xmlns.com/foaf/0.1/> 

select * where {{
    ?person rdf:type foaf:Person .
    ?person  org:memberOf ?org .
    OPTIONAL {{ ?person foaf:firstName ?firstName . }}
    OPTIONAL {{ ?person foaf:family_name ?lastName . }}
    OPTIONAL {{ ?person  org:reportsTo ??manager }} .
}}
</sparql>


<question>
Find change events, such as mergers and acquisitions, of an organization
</question>

<sparql>
PREFIX org: <http://www.w3.org/ns/org#> 

select ?event ?prop ?obj where {{
    ?org rdfs:label ?orgName .
    ?event rdf:type org:ChangeEvent .
    ?event org:originalOrganization ?origOrg .
    ?event org:resultingOrganization ?resultingOrg .
}}
</sparql>

"""
```


```python
<!--IMPORTS:[{"imported": "NeptuneSparqlQAChain", "source": "langchain_community.chains.graph_qa.neptune_sparql", "docs": "https://api.python.langchain.com/en/latest/chains/langchain_community.chains.graph_qa.neptune_sparql.NeptuneSparqlQAChain.html", "title": "Amazon Neptune with SPARQL"}, {"imported": "NeptuneRdfGraph", "source": "langchain_community.graphs", "docs": "https://api.python.langchain.com/en/latest/graphs/langchain_community.graphs.neptune_rdf_graph.NeptuneRdfGraph.html", "title": "Amazon Neptune with SPARQL"}]-->
import boto3
from langchain_aws import ChatBedrock
from langchain_community.chains.graph_qa.neptune_sparql import NeptuneSparqlQAChain
from langchain_community.graphs import NeptuneRdfGraph

host = "<your host>"
port = 8182  # change if different
region = "us-east-1"  # change if different
graph = NeptuneRdfGraph(host=host, port=port, use_iam_auth=True, region_name=region)

# Optionally change the schema
# elems = graph.get_schema_elements
# change elems ...
# graph.load_schema(elems)

MODEL_ID = "anthropic.claude-v2"
bedrock_client = boto3.client("bedrock-runtime")
llm = ChatBedrock(model_id=MODEL_ID, client=bedrock_client)

chain = NeptuneSparqlQAChain.from_llm(
    llm=llm,
    graph=graph,
    examples=EXAMPLES,
    verbose=True,
    top_K=10,
    return_intermediate_steps=True,
    return_direct=False,
)
```


## 질문하기
위에서 수집한 데이터에 따라 다릅니다.

```python
chain.invoke("""How many organizations are in the graph""")
```


```python
chain.invoke("""Are there any mergers or acquisitions""")
```


```python
chain.invoke("""Find organizations""")
```


```python
chain.invoke("""Find sites of MegaSystems or MegaFinancial""")
```


```python
chain.invoke("""Find a member who is manager of one or more members.""")
```


```python
chain.invoke("""Find five members and who their manager is.""")
```


```python
chain.invoke(
    """Find org units or suborganizations of The Mega Group. What are the sites of those units?"""
)
```