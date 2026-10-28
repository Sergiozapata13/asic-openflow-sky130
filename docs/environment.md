# Environment

All runs in this repository used the setup below.

| Item | Value |
| --- | --- |
| Host | Windows with WSL2, Ubuntu 24.04 (limited to 8 GB RAM and 8 processors via `.wslconfig`) |
| Container runtime | Docker (`docker.io` package) inside Ubuntu |
| ORFS | commit `64939f371` (2026-10-25), unmodified apart from added design directories |
| Docker image | `openroad/orfs:latest`, digest `sha256:6810dbf0e03dddbc89ed8c0a1e13cad09ce4c98d40c4ac0ab99fdc04b0676347` |
| Yosys | 0.68 |
| KLayout | 0.30.12 |
| PDK / library | SkyWater 130 nm, `sky130hd` platform shipped with ORFS |

## Reproducing a run

1. Clone ORFS and check out the commit above.
2. Copy this repository's designs into the ORFS checkout with `scripts/sync_to_orfs.sh ~/OpenROAD-flow-scripts`.
3. From `flow/`, run `util/docker_shell make DESIGN_CONFIG=/work/designs/sky130hd/<run>/config.mk`. Docker mounts `flow/` as `/work`, so the path must be absolute under `/work`.
4. Append `synth` to run synthesis only, or `drc` to run the KLayout DRC on the final GDS.

## Pinning the Docker image

`latest` is a moving tag. `util/docker_shell` accepts another image through `--image` or the `OR_IMAGE` variable (not tested here). To use the exact image from these runs, set `OR_IMAGE=openroad/orfs@sha256:6810dbf0e03dddbc89ed8c0a1e13cad09ce4c98d40c4ac0ab99fdc04b0676347` before calling `util/docker_shell`.
