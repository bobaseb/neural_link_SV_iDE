# The neural link between subjective value and decision entropy

by Sebastian Bobadilla-Suarez, Olivia Guest and Bradley C. Love

Code repository for an fMRI study linking subjective value with inverse decision entropy (similar to confidence) in a mixed-gambles task [bioRxiv preprint](http://biorxiv.com). Both the original raw and preprocessed ([fMRIprep 1.1.6](https://fmriprep.readthedocs.io/en/stable/)) data was obtained from the [NARPS project](http://narps.info) ([bioRxiv preprint](https://doi.org/10.1101/843193), [data repository](https://doi.org/10.18112/openneuro.ds001734.v1.0.4), and [Scientific Data descriptor](https://doi.org/10.1038/s41597-019-0113-7)). Many thanks to the NARPS team and the (70) labs for making their data available. Note: the fMRI folder also contains bash scripts used for answering the nine hypotheses in the original NARPS project. For more information, see our [blog post](http://bradlove.org/blog/narps) or the supplemental information of our manuscript ([bioRxiv preprint](http://biorxiv.com)).

## Requirements

The repository is divided into behavioral and fMRI analysis. Scripts are in python and bash. Requirements include Python 2.7 or above, FSL 5.0.9 and python packages like Numpy, Pandas, Statsmodels, Scipy and PyMVPA 2.6.5.dev1 (which runs best on Python 2.7).
