#!/bin/bash -l
### Guppy can utilize one node
#SBATCH --nodes=1
### Each node on Topaz has 2 GPUs, we only request 1 though as my tests have shown that the additional GPU gives us a 10-15% boost, but we're chareged 2x the amount of service units
#SBATCH --gres=gpu:1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks-per-socket=1
#SBATCH --mem=150gb
#SBATCH --time=10:00:00
#SBATCH --partition=gpuq
#SBATCH --account=INSERT_YOUR_OWN
#SBATCH --export=NONE

# Load the necessary modules
module load singularity
module load cuda

# Image from https://hub.docker.com/repository/docker/jwdebler/megalodon_guppy
# Downloaded via singularity pull docker://jwdebler/megalodon_guppy:latest

# Adjust paths

srun -n 1 --export=all --gres=gpu:1 \
singularity exec --nv /PATH/TO/megalodon_guppy_latest.sif megalodon /PATH/TO/FAST5/FOLDER/ \
--guppy-server-path /home/ont-guppy/bin/guppy_basecall_server \
--guppy-params "-d /PATH/TO/rerio/basecall_models/ --chunk_size 1000" \
--guppy-config res_dna_r941_min_modbases_5mC_CpG_v001.cfg \
--outputs mod_mappings mods \
--reference /PATH/TO/REFERENCE.fasta \
--mod-motif m CG 0 \
--output-directory /PATH/FOR/MEGALODON/OUTPUT \
--overwrite \
--sort-mappings \
--devices cuda:all
