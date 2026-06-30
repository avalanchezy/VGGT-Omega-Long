#!/bin/bash
set -e

mkdir -p weights
cd ./weights

# SALAD (~ 350 MiB)
echo "Downloading SALAD weights..."
SALAD_URL="https://github.com/serizba/salad/releases/download/v1.0.0/dino_salad.ckpt"
curl -L "$SALAD_URL" -o "./dino_salad.ckpt"

# DINO (~ 340 MiB)
echo "Downloading DINO weights..."
wget https://dl.fbaipublicfiles.com/dinov2/dinov2_vitb14/dinov2_vitb14_pretrain.pth

# DBoW (~ 40 MiB of tar.gz, ~145 MiB of txt)
echo "Downloading DBoW weights..."
(wget https://github.com/UZ-SLAMLab/ORB_SLAM3/raw/master/Vocabulary/ORBvoc.txt.tar.gz) & wait
tar -xzvf ORBvoc.txt.tar.gz
rm ORBvoc.txt.tar.gz

# VGGT-Omega (~ checkpoint access may require Hugging Face approval)
echo "Downloading VGGT-Omega weights..."
huggingface-cli download facebook/VGGT-Omega vggt_omega_1b_512.pt \
  --local-dir . \
  --local-dir-use-symlinks False

# you will see 4 files under `./weights` when finished
# - vggt_omega_1b_512.pt
# - dino_salad.ckpt
# - dinov2_vitb14_pretrain.pth
# - ORBvoc.txt
