---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/mintbase.ipynb
description: 이 문서는 Near Blockchain의 Langchain Document Loader 기능을 테스트하기 위한 방법을 제공합니다.
  NFT 문서 로딩을 지원합니다.
---

# Near Blockchain

## 개요

이 노트북의 목적은 Near Blockchain을 위한 Langchain Document Loader의 기능을 테스트하는 수단을 제공하는 것입니다.

초기에는 이 로더가 다음을 지원합니다:

* NFT 스마트 계약(NEP-171 및 NEP-177)에서 문서로 NFT 로드
* Near Mainnet, Near Testnet (기본값은 mainnet)
* Mintbase의 Graph API

커뮤니티가 이 로더의 가치를 발견하면 확장할 수 있습니다. 구체적으로:

* 추가 API를 추가할 수 있습니다 (예: 거래 관련 API)

이 문서 로더는 다음을 요구합니다:

* 무료 [Mintbase API 키](https://docs.mintbase.xyz/dev/mintbase-graph/)

출력 형식은 다음과 같습니다:

- pageContent= 개별 NFT
- metadata={'source': 'nft.yearofchef.near', 'blockchain': 'mainnet', 'tokenId': '1846'}

## NFT를 문서 로더에 로드하기

```python
# get MINTBASE_API_KEY from https://docs.mintbase.xyz/dev/mintbase-graph/

mintbaseApiKey = "..."
```


### 옵션 1: 이더리움 메인넷 (기본 BlockchainType)

```python
from MintbaseLoader import MintbaseDocumentLoader

contractAddress = "nft.yearofchef.near"  # Year of chef contract address


blockchainLoader = MintbaseDocumentLoader(
    contract_address=contractAddress, blockchain_type="mainnet", api_key="omni-site"
)

nfts = blockchainLoader.load()

print(nfts[:1])

for doc in blockchainLoader.lazy_load():
    print()
    print(type(doc))
    print(doc)
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)