---
custom_edit_url: https://github.com/langchain-ai/langchain/edit/master/docs/docs/integrations/text_embedding/open_clip.ipynb
description: OpenClip은 OpenAI의 CLIP을 구현한 소스 코드로, 이미지와 텍스트를 임베딩하는 다중 모달 임베딩을 제공합니다.
---

# OpenClip

[OpenClip](https://github.com/mlfoundations/open_clip/tree/main)은 OpenAI의 CLIP의 소스 구현입니다.

이 다중 모달 임베딩은 이미지나 텍스트를 임베드하는 데 사용될 수 있습니다.

```python
%pip install --upgrade --quiet  langchain-experimental
```


```python
%pip install --upgrade --quiet  pillow open_clip_torch torch matplotlib
```


사용 가능한 CLIP 임베딩 모델 및 체크포인트 목록을 확인할 수 있습니다:

```python
import open_clip

open_clip.list_pretrained()
```


아래에서는 테이블을 기반으로 한 더 크지만 성능이 더 좋은 모델을 테스트합니다 ([여기](https://github.com/mlfoundations/open_clip)):
```
model_name = "ViT-g-14"
checkpoint = "laion2b_s34b_b88k"
```


하지만, 더 작고 성능이 낮은 모델을 선택할 수도 있습니다:
```
model_name = "ViT-B-32"
checkpoint = "laion2b_s34b_b79k"
```


모델 `model_name`, `checkpoint`는 `langchain_experimental.open_clip.py`에 설정됩니다.

텍스트의 경우, 다른 임베딩 모델과 동일한 방법인 `embed_documents`를 사용하십시오.

이미지의 경우, `embed_image`를 사용하고 이미지의 URI 목록을 간단히 전달하십시오.

```python
<!--IMPORTS:[{"imported": "OpenCLIPEmbeddings", "source": "langchain_experimental.open_clip", "docs": "https://api.python.langchain.com/en/latest/open_clip/langchain_experimental.open_clip.open_clip.OpenCLIPEmbeddings.html", "title": "OpenClip"}]-->
import numpy as np
from langchain_experimental.open_clip import OpenCLIPEmbeddings
from PIL import Image

# Image URIs
uri_dog = "/Users/rlm/Desktop/test/dog.jpg"
uri_house = "/Users/rlm/Desktop/test/house.jpg"

# Embe images or text
clip_embd = OpenCLIPEmbeddings(model_name="ViT-g-14", checkpoint="laion2b_s34b_b88k")
img_feat_dog = clip_embd.embed_image([uri_dog])
img_feat_house = clip_embd.embed_image([uri_house])
text_feat_dog = clip_embd.embed_documents(["dog"])
text_feat_house = clip_embd.embed_documents(["house"])
```


## Sanity Check

OpenClip Colab에서 보여준 결과를 재현해 보겠습니다 [여기](https://colab.research.google.com/github/mlfoundations/open_clip/blob/master/docs/Interacting_with_open_clip.ipynb#scrollTo=tMc1AXzBlhzm).

```python
import os
from collections import OrderedDict

import IPython.display
import matplotlib.pyplot as plt
import skimage

%matplotlib inline
%config InlineBackend.figure_format = 'retina'

descriptions = {
    "page": "a page of text about segmentation",
    "chelsea": "a facial photo of a tabby cat",
    "astronaut": "a portrait of an astronaut with the American flag",
    "rocket": "a rocket standing on a launchpad",
    "motorcycle_right": "a red motorcycle standing in a garage",
    "camera": "a person looking at a camera on a tripod",
    "horse": "a black-and-white silhouette of a horse",
    "coffee": "a cup of coffee on a saucer",
}

original_images = []
images = []
image_uris = []  # List to store image URIs
texts = []
plt.figure(figsize=(16, 5))

# Loop to display and prepare images and assemble URIs
for filename in [
    filename
    for filename in os.listdir(skimage.data_dir)
    if filename.endswith(".png") or filename.endswith(".jpg")
]:
    name = os.path.splitext(filename)[0]
    if name not in descriptions:
        continue

    image_path = os.path.join(skimage.data_dir, filename)
    image = Image.open(image_path).convert("RGB")

    plt.subplot(2, 4, len(images) + 1)
    plt.imshow(image)
    plt.title(f"{filename}\n{descriptions[name]}")
    plt.xticks([])
    plt.yticks([])

    original_images.append(image)
    images.append(image)  # Origional code does preprocessing here
    texts.append(descriptions[name])
    image_uris.append(image_path)  # Add the image URI to the list

plt.tight_layout()
```


![](/img/98172ca2186c619eccc65c6d5e362a22.png)

```python
# Instantiate your model
clip_embd = OpenCLIPEmbeddings()

# Embed images and text
img_features = clip_embd.embed_image(image_uris)
text_features = clip_embd.embed_documents(["This is " + desc for desc in texts])

# Convert the list of lists to numpy arrays for matrix operations
img_features_np = np.array(img_features)
text_features_np = np.array(text_features)

# Calculate similarity
similarity = np.matmul(text_features_np, img_features_np.T)

# Plot
count = len(descriptions)
plt.figure(figsize=(20, 14))
plt.imshow(similarity, vmin=0.1, vmax=0.3)
# plt.colorbar()
plt.yticks(range(count), texts, fontsize=18)
plt.xticks([])
for i, image in enumerate(original_images):
    plt.imshow(image, extent=(i - 0.5, i + 0.5, -1.6, -0.6), origin="lower")
for x in range(similarity.shape[1]):
    for y in range(similarity.shape[0]):
        plt.text(x, y, f"{similarity[y, x]:.2f}", ha="center", va="center", size=12)

for side in ["left", "top", "right", "bottom"]:
    plt.gca().spines[side].set_visible(False)

plt.xlim([-0.5, count - 0.5])
plt.ylim([count + 0.5, -2])

plt.title("Cosine similarity between text and image features", size=20)
```


```output
Text(0.5, 1.0, 'Cosine similarity between text and image features')
```


![](/img/8eea16a4f653471adb675babc9733590.png)

## Related

- 임베딩 모델 [개념 가이드](/docs/concepts/#embedding-models)
- 임베딩 모델 [사용 방법 가이드](/docs/how_to/#embedding-models)