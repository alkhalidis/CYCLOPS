# CYCLOPS
# CYCLOPS: Cyclic Open Platform for Spatial Proteomics

CYCLOPS is an open, end-to-end workflow for cyclic multiplex immunofluorescence imaging and single-cell phenotypic analysis using standard microscopy infrastructure.

This repository contains all hardware designs, control scripts, and analysis pipelines required to reproduce the workflow described in "CYCLOPS: an open end-to-end platform for cyclic multiplex imaging and single-cell phenotyping".

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

**Hardware:** Contains 3D print files for:
    - An insert that fits on a Nikon microscope stage and accomodates a 24x32mm coverslip. This is availbale in two versions, one with screws and one without, the latter is fixed to the microscope with BlutTack. The inner dimentions can be mosified to accomodate a variaty of coverslip sizes, and the outer parameters can be flexibly altered to fit the insert on any microscope.
      
    - Coverslip holder to store tissue-mounted 24x32mm coverslips, and a spereate file for the lid. The Dimentions can be altered to accomodate any coverslip size. 

Cyclic Imaging: Contains code required to operate the 

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
