# Stanford MATALB High Performance Computing

MATLAB code related to testing and running analysis on Stanford's HPC systems, in particular Farmeshare or Sherlock.


## Blackjack benchmark on Stanford Farmshare clusters

To run on Farmshare cluster, enter the below when logged into the cluster and in a directory containing this repository's functions.

```bash
# Start parallel test job
sbatch parallelSpeedTest_rice.sbatch

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