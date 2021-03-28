#!/bin/bash
#SBATCH --job-name=testRL
#SBATCH --nodelist=node043
#SBATCH --nodes=1
#SBATCH --mem=10G
#SBATCH --ntasks=16
#SBATCH --time=00:10:00 # format is hh:mm:ss
#SBATCH --mail-type=END
#SBATCH --mail-user=y.cao@uke.de

# Alternatively, you can call 16 workers using the following instead of ntasks
# SBATCH --sockets-per-node=2
# SBATCH --cores-per-socket=8
 
# execute a matlab script 'main.m':
matlab -nodisplay -nodesktop -r main