# Stanford MATALB High Performance Computing

MATLAB code related to testing and running analysis on Stanford's HPC systems, in particular Farmeshare or Sherlock.


## Blackjack Parallel Toolbox testing on local workstation

```Matlab
maxParallelJobsToTest = 2*java.lang.Runtime.getRuntime().availableProcessors;
[success speedup poolSizeVector] = parallelWorkerSpeedTest_mdcs('enableFigures',1,'numPlayersList',maxParallelJobsToTest,'numHandsList',[7e4],'localVsCluster','workstation_parpool');
```

## Blackjack Parallel Toolbox and MDCS benchmark on Stanford Farmshare clusters

To start, users want to see speedups like the blue, green, and purple curves below (they plateau around the maximum number of CPU cores for that computing environment).

![2017_08_21_famshare2_v_sherlock_workstations_blackjack_speedtest_v2](https://user-images.githubusercontent.com/5241605/53528259-fcf98c00-3a9d-11e9-9ec2-5b63af668fa2.png)


To run on Farmshare cluster, enter the below when logged into the cluster and in a directory containing this repository's functions.

```bash
# Start parallel test job, force UNIX-style line endings
sed 's/\r$//' parallelSpeedTest_rice.sbatch | sbatch

# Show job status
watch sacct -u $USER

```

Run the below commands while on a Farmshare node while in a directory containing `parallelWorkerSpeedTest_mdcs.m` and `getOptions.m`.

```bash
# Load MATLAB module
module load matlab/r2017a

# Load MATLAB
matlab

```

Then when inside MATLAB

```Matlab
configCluster
display('Running 1 nodes with 16 CPUs/node requested at 64GB ram')
display('Blackjack test case parallel speed test');
java.lang.Runtime.getRuntime().availableProcessors
currentDateTimeStr = datestr(now,'yyyy_mm_dd_HHMMSS','local');
parallelWorkerSpeedTest_mdcs(...
'localVsCluster','mdcs_parpool',...
'numHandsList',3e5,...
'numPlayersList',16*3,...
'tableSavePath',[currentDateTimeStr '_parallelSpeedTest_runtimes_farmshareMdcsParpool.csv'],...
'currentDateTimeStr',currentDateTimeStr,...
'clusterPartition','normal',...
'numWorkersToOpen',16*3);
exit
```

```Matlab
configCluster
display('Running 1 nodes with 1 CPUs/node requested at 64GB ram')
display('Blackjack test case parallel speed test');
java.lang.Runtime.getRuntime().availableProcessors
currentDateTimeStr = datestr(now,'yyyy_mm_dd_HHMMSS','local');
parallelWorkerSpeedTest_mdcs(...
'localVsCluster','mdcs_batch',...
'numHandsList',3e5,...
'numPlayersList',16*3,...
'tableSavePath',[currentDateTimeStr '_parallelSpeedTest_runtimes_farmshareMdcsBatch.csv'],...
'currentDateTimeStr',currentDateTimeStr,...
'clusterPartition','normal',...
'numWorkersToOpen',16*3);
exit
```

```Matlab
configCluster
display('Running 1 nodes with 16 CPUs/node requested at 64GB ram')
display('Blackjack test case parallel speed test');
java.lang.Runtime.getRuntime().availableProcessors
currentDateTimeStr = datestr(now,'yyyy_mm_dd_HHMMSS','local');
parallelWorkerSpeedTest_mdcs(...
'localVsCluster','local_parpool',...
'numHandsList',3e5,...
'numPlayersList',16*3,...
'tableSavePath',[currentDateTimeStr '_parallelSpeedTest_runtimes_farmshareLocalParpool.csv'],...
'currentDateTimeStr',currentDateTimeStr,...
'clusterPartition','normal',...
'numWorkersToOpen',16*3);
exit
```

## Blackjack Parallel Toolbox benchmark on Stanford Sherlock clusters

```bash
# Bigmem partition run, force UNIX-style line endings
sed 's/\r$//' parallelSpeedTest_sherlock2_bigmem.sbatch | sbatch

# Normal partition run, force UNIX-style line endings
sed 's/\r$//' parallelSpeedTest_sherlock2_normal.sbatch | sbatch

# Show job status
watch sacct -u $USER
```