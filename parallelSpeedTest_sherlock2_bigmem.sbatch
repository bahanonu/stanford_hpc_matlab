#!/bin/bash
#
#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling
#################
#set a job name
#SBATCH --job-name=cellmaxSpeedTest_v6_sherlock2_bigmem
#################
#a file for job output, you can check job progress, append the job ID with %j to make it unique
#SBATCH --output=cellmaxSpeedTest_v6_sherlock2_bigmem.%j.out
#################
# a file for errors from the job
#SBATCH --error=cellmaxSpeedTest_v6_sherlock2_bigmem.%j.err
#################
#time you think you need; default is 2 hours
#format could be dd-hh:mm:ss, hh:mm:ss, mm:ss, or mm
#SBATCH --time=02:00:00
#################
#Quality of Service (QOS); think of it as job priority, there is also --qos=long for with a max job length of 7 days, qos normal is 48 hours.
# REMOVE "normal" and set to "long" if you want your job to run longer than 48 hours,
# NOTE- in the hns partition the default max run time is 7 days , so you wont need to include qos
# We are submitting to the dev partition, there are several on sherlock: normal, gpu, owners, hns, bigmem (jobs requiring >64Gigs RAM)
# The more partitions you can submit to the less time you will wait, you can submit to multiple partitions with -p at once in comma separated format.
#SBATCH -p bigmem
#################
#number of nodes you are requesting, the more you ask for the longer you wait
#SBATCH --nodes=1
#################
# --mem is memory per node; default is 4000 MB per CPU, remember to ask for enough mem to match your CPU request, since
# sherlock automatically allocates 8 Gigs of RAM/CPU, if you ask for 8 CPUs you will need 32 Gigs of RAM, so either
# leave --mem commented out or request >= to the RAM needed for your CPU request.
#SBATCH --mem=224000
#SBATCH --cpus-per-task=56
#################
# Have SLURM send you an email when the job ends or fails, careful, the email could end up in your clutter folder
# Also, if you submit hundreds of jobs at once you will get hundreds of emails.
#SBATCH --mail-type=END,FAIL # notifications for job done & fail
# Remember to change this to your email
#SBATCH --mail-user=YourSUNetID@stanford.edu
#now run normal batch commands
# note the "CMD BATCH is an R specific command
module load matlab/R2017a
# You can use srun if your job is parallel
#srun R CMD BATCH  ./rtest.R
# otherwise:

matlab -nodesktop <<EOF
display('Running 1 nodes with 56 CPUs/node requesting 224GB RAM | bigmem partition')
display('CELLMax test case parallel');
java.lang.Runtime.getRuntime().availableProcessors
parallelWorkerSpeedTest_mdcs([1e5],[100 200],[datestr(now,'yyyy_mm_dd_HHMMSS','local') '_parallelSpeedTest_runtimes_sherlockBigmem.csv'],0,56);
EOF