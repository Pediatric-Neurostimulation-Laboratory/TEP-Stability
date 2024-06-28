# TEP-Stability
This repository contains MATLAB scripts that can perform TEP stability analyses

Author: Xiwei She, Ph.D.

The main script for TEP stability analyese is named TEPStabilityAnalysis_v2.m. It calls some scripts saved in the folder named "toolbox" which contains all necessary functions for calculation the minimum number of pulse (MNP). However, due to the maximum number of files that can be uploaded into this repository, user needs to dowload the toolbox "eeglab" separately from its official website: https://sccn.ucsd.edu/eeglab/index.php.  After downloading, please add the eeglab into the MATLAB path. (The TEPStabilityAnalysis_v2.m already has corresponding line to do this)

We also provide example datasets stored in the Folder named "ExampleData". Each of them was used for generating a "candidate" TEP using the method decribed in the paper. It can be used for testing the methodology and reproducing the MNP plot we shown in Figure 1 in the paper. However, although fully de-identified, this dataset is for testing the script only. Please do not distrbute the dataset without the permission of the authors.

Please contact xiweishe@stanford.edu or fbaumer@stanford.edu for any questions

This work is published on Scientific Reports: https://www.nature.com/articles/s41598-024-59468-8
