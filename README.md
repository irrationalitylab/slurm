<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
-->


<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Best-README-Template</h3>

  <p align="center">
    An awesome README template to jumpstart your projects!
    <br />
    <a href="https://github.com/othneildrew/Best-README-Template"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/othneildrew/Best-README-Template">View Demo</a>
    ·
    <a href="https://github.com/othneildrew/Best-README-Template/issues">Report Bug</a>
    ·
    <a href="https://github.com/othneildrew/Best-README-Template/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#preparing-a-submission-script">Preparing a submission script</a></li>
    <li><a href="#getting-Started">Getting Started</a></li>
    <li><a href="#rules">Rules</a></li>
    <li><a href="#check-job-status">Check job status</a></li>
    <li><a href="#display-outputs">Display outputs</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## Preparing a submission script

A submission script is a shell script that describes the processing to carry out (e.g. the application, its input and output, etc.) and requests computer resources (number of cpus, amount of memory, etc.) to use for processing. Here is an example submission script ([slurmtest_par.sh](https://github.com/irrationalitylab/slurm/blob/master/RLdemo/slurmtest_par.sh)) that executes a matlab function ([RLpar_model.m](https://github.com/irrationalitylab/slurm/blob/master/RLdemo/RLpar_model.m)) that simulates a Rescorla–Wagner agent and estimates the maximum-likelihood model parameters (you can download all relevant scripts [here](https://github.com/irrationalitylab/slurm/tree/master/RLdemo):

   ```sh
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
   ```
To submit the batch job, type the command:
   ```sh
   sbatch ./slurmtest_par.sh
   ```
In the terminal window, it will then show the information: `Submitted batch job 546`, with a unique job index e.g., 546.
To terminate the job:
   ```sh
   scancel 546
   ```
   
   
<!-- GETTING STARTED -->
## Getting Started

Currently, node020 and node022 are the 2 nodes for submitting slurm jobs.
node035, 036, 041, 042, 043, 046 are computing nodes.

To check how many cores each of the computing nodes supports, after ssh to a submitting node (e.g., ssh -X username@node020), type the command:
   ```sh
   scontrol show nodes
   ```
For instance, the node046 supports maxi. 32 workers:
   ```sh
   NodeName=node046 Arch=x86_64 CoresPerSocket=16 
   CPUAlloc=0 CPUTot=2 CPULoad=0.00
   AvailableFeatures=(null)
   ActiveFeatures=(null)
   Gres=(null)
   NodeAddr=node046 NodeHostName=node046 Version=18.08
   OS=Linux 4.19.0-12-amd64 #1 SMP Debian 4.19.152-1 (2020-10-18) 
   RealMemory=251000 AllocMem=0 FreeMem=255184 Sockets=2 Boards=1
   State=IDLE ThreadsPerCore=2 TmpDisk=0 Weight=1 Owner=N/A MCS_label=N/A
   Partitions=slurm 
   BootTime=2020-12-07T13:07:19 SlurmdStartTime=2021-03-16T17:56:24
   CfgTRES=cpu=2,mem=251000M,billing=2
   AllocTRES=
   CapWatts=n/a
   CurrentWatts=0 LowestJoules=0 ConsumedJoules=0
   ExtSensorsJoules=n/s ExtSensorsWatts=0 ExtSensorsTemp=n/s
   ```

## Rules

Be cautious about the jobs you plan to submit, the rule is max. 50 cores, with max 10gb memory each.

## Check job status
Check the job submitted by a specific user:
   ```sh
   squeue -u username
   ```
Check the jobs submitted by all users:
   ```sh
   squeue
   ```

## Display outputs
   ```sh
   cat slurm-*
   ```
   For instance, after completing the RL model fitting, it will display the matlab outputs:
   ```sh
Starting parallel pool (parpool) using the 'local' profile ...
Connected to the parallel pool (number of workers: 16).
>>>>>>> ok, we have simulated some data >>>>>>>
>>>>>>> ok, we have simulated some data >>>>>>>
>>>>>>> ok, we have simulated some data >>>>>>>
Elapsed time is 12.020845 seconds.
true alpha = 0.300000, estimated alpha = 0.294941
true beta = 2.600000, estimated beta = 2.553429
Parallel pool using the 'local' profile is shutting down.
   ``` 
   



