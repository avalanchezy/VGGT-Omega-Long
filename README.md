# VGGT-Omega-Long

VGGT-Omega-Long extends the VGGT-Long long-sequence reconstruction pipeline with
VGGT-Omega as the local feed-forward 3D backbone.

The long-sequence mechanism follows VGGT-Long: images are split into overlapping
chunks, loop candidates are detected with image retrieval, adjacent and loop
chunks are aligned by dense point-map Sim(3), and the aligned chunks are fused
into a global point cloud. The only backbone-specific part is a
`VGGTOmegaAdapter`, which preserves VGGT-Omega's native preprocessing, 9D camera
encoding, FoV-derived intrinsics, depth prediction, and depth confidence.

## What Is Different From VGGT-Long

VGGT predicts point maps directly. VGGT-Omega predicts camera pose encoding,
depth, and depth confidence. VGGT-Omega-Long converts those outputs into the
same interface expected by VGGT-Long:

- `pose_enc` is decoded into camera-from-world extrinsics and intrinsics.
- depth is unprojected into dense world point maps.
- `depth_conf` is used as the point-map confidence.
- camera poses are converted to camera-to-world matrices for trajectory output.

After this adapter layer, retrieval, overlap alignment, loop optimization, and
point-cloud fusion are the original Long pipeline.

## Installation

Create an environment and install PyTorch first. Pick the CUDA wheel matching
your machine.

```bash
conda create -n vggt-omega-long python=3.10 -y
conda activate vggt-omega-long

pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu124
pip install -r requirements.txt
```

The optional C++ Sim3 solver can be compiled with:

```bash
python setup.py install
```

If it is not compiled, the Python Sim3 implementation is used automatically.

## Weights

VGGT-Omega checkpoints are hosted on Hugging Face and may require access approval
from the original model page. After access is available, run:

```bash
bash scripts/download_weights.sh
```

This downloads:

- `weights/vggt_omega_1b_512.pt`
- `weights/dino_salad.ckpt`
- `weights/dinov2_vitb14_pretrain.pth`
- `weights/ORBvoc.txt`

You can also place `vggt_omega_1b_512.pt` manually under `weights/`.

## Run

Prepare a directory of ordered RGB images:

```bash
python vggt_omega_long.py --image_dir /path/to/images --config configs/vggt_omega.yaml
```

The legacy entry point is also kept:

```bash
python vggt_long.py --image_dir /path/to/images --config configs/vggt_omega.yaml
```

Useful config fields in `configs/vggt_omega.yaml`:

```yaml
Model:
  chunk_size: 60
  overlap: 30
  loop_enable: True
  omega_image_resolution: 512
  omega_preprocess_mode: 'max_size'
```

For videos, extract frames first:

```bash
mkdir -p frames
ffmpeg -i input.mp4 -vf "fps=2" frames/frame_%06d.jpg
```

## Outputs

Each run creates an experiment directory under `exps/` containing:

- `pcd/combined_pcd.ply`: fused global point cloud.
- `camera_poses.txt`: estimated camera-to-world poses.
- `camera_poses.ply`: camera trajectory visualization.
- temporary aligned/unaligned chunks, unless `delete_temp_files: True`.

## Notes

- VGGT-Omega-Long is most comparable to VGGT-Long when using the same
  `chunk_size`, `overlap`, and loop settings.
- `omega_preprocess_mode: max_size` is memory-friendlier; `balanced` follows
  VGGT-Omega's default token-budget behavior.
- Because Omega produces depth rather than direct point maps, this repository
  intentionally keeps the depth-unprojection step inside the adapter instead of
  changing the Long alignment code.

## License

This repository combines the VGGT-Long pipeline with VGGT-Omega model code.
See `LICENSE` / `LICENSE_VGGT_OMEGA` for the VGGT-Omega license and
`LICENSE.txt` for the inherited VGGT-Long license.
