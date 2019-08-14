# Synopsis Framework
OS X Framework to parse Synopsis metadata, run spotlight searches, and sort results based on metadata contents, and optionaly analyze video and generate metadata dictionaries.

### Dependencies:
* OpenCV 3.3 + (included)
* zstd (included)
* git lfs

`brew install git-lfs`

`git lfs install`

## Build Instructions

Synopsis framework can be compiled to provide just metadata reading / parsing / comparison - or in addition, providing analysis as well. These two build options are provided because to help with binary size. Decode only is much lighter and does not require the inclusion of larger CoreML models.


### Decode (Metadata read only)
To build a decode only Synopsis framework, simply check out the latest git repo, and compile the 'decoder' target. We include a small OpenCV2.framework pre-compiled in the git repo (without IPP)


### Analysis (Metadata generation, analysis, writing and reading)
You can optionally compile OpenCV with Intel Performance Primitives (IPP) for theoretical performance increases at a cost of 150MB additional binary size due to IPPICV library size. Our included OpenCV2.Framework in git LFS is the distirbution framework which includes iOS and x86 fat binary.

* OpenCV is now automatically download via Git LFS checkout, from an official OpenCV framework distribution.



