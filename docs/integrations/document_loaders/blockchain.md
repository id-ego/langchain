---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/document_loaders/blockchain.ipynb
description: 이 문서는 Langchain Document Loader의 기능을 테스트하기 위한 것으로, NFT 및 다양한 블록체인 네트워크에서
  문서를 로드하는 방법을 설명합니다.
---

# 블록체인

## 개요

이 노트북의 목적은 Langchain 문서 로더의 기능을 테스트하는 수단을 제공하는 것입니다.

초기에는 이 로더가 다음을 지원합니다:

* NFT 스마트 계약(ERC721 및 ERC1155)에서 문서로 NFT 로드
* 이더리움 메인넷, 이더리움 테스트넷, 폴리곤 메인넷, 폴리곤 테스트넷(기본값은 eth-mainnet)
* 알케미의 getNFTsForCollection API

커뮤니티가 이 로더에 가치를 찾으면 확장할 수 있습니다. 구체적으로:

* 추가 API를 추가할 수 있습니다(예: 트랜잭션 관련 API)

이 문서 로더는 다음을 요구합니다:

* 무료 [알케미 API 키](https://www.alchemy.com/)

출력은 다음 형식을 취합니다:

- pageContent= 개별 NFT
- metadata={'source': '0x1a92f7381b9f03921564a437210bb9396471050c', 'blockchain': 'eth-mainnet', 'tokenId': '0x15'})

## NFT를 문서 로더에 로드하기

```python
# get ALCHEMY_API_KEY from https://www.alchemy.com/

alchemyApiKey = "..."
```


### 옵션 1: 이더리움 메인넷 (기본 블록체인 유형)

```python
<!--IMPORTS:[{"imported": "BlockchainDocumentLoader", "source": "langchain_community.document_loaders.blockchain", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.blockchain.BlockchainDocumentLoader.html", "title": "Blockchain"}, {"imported": "BlockchainType", "source": "langchain_community.document_loaders.blockchain", "docs": "https://api.python.langchain.com/en/latest/document_loaders/langchain_community.document_loaders.blockchain.BlockchainType.html", "title": "Blockchain"}]-->
from langchain_community.document_loaders.blockchain import (
    BlockchainDocumentLoader,
    BlockchainType,
)

contractAddress = "0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d"  # Bored Ape Yacht Club contract address

blockchainType = BlockchainType.ETH_MAINNET  # default value, optional parameter

blockchainLoader = BlockchainDocumentLoader(
    contract_address=contractAddress, api_key=alchemyApiKey
)

nfts = blockchainLoader.load()

nfts[:2]
```


### 옵션 2: 폴리곤 메인넷

```python
contractAddress = (
    "0x448676ffCd0aDf2D85C1f0565e8dde6924A9A7D9"  # Polygon Mainnet contract address
)

blockchainType = BlockchainType.POLYGON_MAINNET

blockchainLoader = BlockchainDocumentLoader(
    contract_address=contractAddress,
    blockchainType=blockchainType,
    api_key=alchemyApiKey,
)

nfts = blockchainLoader.load()

nfts[:2]
```


## 관련

- 문서 로더 [개념 가이드](/docs/concepts/#document-loaders)
- 문서 로더 [사용 방법 가이드](/docs/how_to/#document-loaders)