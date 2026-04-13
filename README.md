# CYCLOPS
# CYCLOPS: Cyclic Open Platform for Spatial Proteomics

CYCLOPS is an open, end-to-end workflow for cyclic multiplex immunofluorescence imaging and single-cell phenotypic analysis using standard microscopy infrastructure.

This repository contains all hardware designs, control scripts, and analysis pipelines required to reproduce the workflow described in [Manuscript Title].

---

## Overview

CYCLOPS integrates:
- Antibody–oligonucleotide conjugation using non-proprietary chemistry
- Arduino-based automated fluidics control
- A 3D-printed open-chamber stage insert
- Cyclic imaging using standard confocal or widefield microscopes
- Open-source image preprocessing and single-cell analysis pipelines

---

## Repository Structure

hardware/ → STL and CAD files for stage insert
arduino_control/ → Pump control code (.ino) and wiring diagram
cyclic_imaging/ → Imaging scripts and configuration files
image_preprocessing/ → ImageJ macros / scripts for correction and alignment
image_analysis/ → Segmentation (Cellpose), QuPath extraction, FlowJo gating, R scripts
example_data/ → Small demo dataset
docs/ → Setup instructions and troubleshooting
---

## License

Code: MIT License  
Hardware: CERN-OHL-S (or CC BY 4.0)

---

## Citation

If you use this work, please cite:

[Your paper citation]

---

## Contact

For questions or issues, please open a GitHub issue.
