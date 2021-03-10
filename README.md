# Megalodon and GPU guppy Dockerfile  

This builds a container that is ready to run [Megalodon](https://github.com/nanoporetech/megalodon) and the GPU version of the Guppy Nanopore basecaller. 

Unfortunately I have not yet figured out how to access the rerio models inside the container when running Megalodon on the HPC. Therefore you have to download them yourself and put them on the HPC together with your fast5 files.

```
git clone https://github.com/nanoporetech/rerio /home/rerio

/home/rerio/download_model.py /home/rerio/basecall_models/res_dna_r941_min_modbases_5mC_CpG_v001
```
This image is based on Cuda 9.0
