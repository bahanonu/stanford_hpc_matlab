function [success speedup poolSizeVector] = cellmax_parallelWorkerSpeedTest_mdcs_v16(varargin)
	% Test Parallel Computing Toolbox or MDCS speed-up on specific hardware
	% Based on https://www.mathworks.com/help/distcomp/examples/simple-benchmarking-of-parfor-using-blackjack.html
	% Biafra Ahanonu
	% started: 2016.10.31
	% inputs
		% see varargin below
	% outputs
		% success - 1 = run no errors, 0 = run with errors
		% speedup - speedup for each # of workers, [1 nWorkers]
		% poolSizeVector - number of workers used in each run, [1 nWorkers]

	% changelog
		% 2017.05.xx - added support for MDCS on Farmshare2
		% 2017.08.29 - starting at v12 refactored to make easier to read and also added in getOptions support.
	% TODO
		%

	% ========================
	% number of hands, increase to take more computation time
	options.numHandsList = [7e4];
	% number of players, most important for parallelization
	options.numPlayersList = [100];
	options.currentDateTimeStr = datestr(now,'yyyy_mm_dd_HHMMSS','local');
	% string indicating location of table path
	options.tableSavePath = [options.currentDateTimeStr '_parallelSpeedTest_runtimes.csv'];
	% 1 = enable, 0 = don't display
	options.enableFigures = 0;
	% check maximum number of cores available (e.g. workers to run)
	options.numWorkersToOpen = java.lang.Runtime.getRuntime().availableProcessors-1;
	% local_parpool - local parpool, mdcs_parpool - mdcs with parpool, mdcs_batch - mdcs with batch
	options.localVsCluster = 'local_parpool';
	% 'normal','bigmem'
	options.clusterPartition = 'bigmem';

	% get options
	options = getOptions(options,varargin);
	display(options)
	% unpack options into current workspace
	% fn=fieldnames(options);
	% for i=1:length(fn)
	% 	eval([fn{i} '=options.' fn{i} ';']);
	% end
	% ========================

	try
		configCluster
		% ========================
		% put variables into workspace.
		numHandsList = options.numHandsList;
		numPlayersList = options.numPlayersList;
		currentDateTimeStr = options.currentDateTimeStr;
		tableSavePath = options.tableSavePath;
		enableFigures = options.enableFigures;
		numWorkersToOpen = options.numWorkersToOpen;
		localVsCluster = options.localVsCluster;
		clusterPartition = options.clusterPartition;
		% ========================

		% setup debug log cell array
		debugLogArray = {};
		debugLogSavePath = [currentDateTimeStr '_parallelSpeedTest_debugLogs.mat'];

		% Setup table to output results
		runtimeTablePath = tableSavePath;
		runtimeTable = table(...
			0,...
			0,...
			0,...
			0,...
			0,...
			'VariableNames',{
			'numHands',...
			'numPlayers',...
			'speedup',...
			'runtime',...
			'poolSizeVector'});

		% Open parallel pool, can also run manageParallelWorkers.m
		nHands = length(numHandsList);
		nPlayers = length(numPlayersList);

		% open max workers if pool not already available
		% ignore for now

		% close any open pool
		if ~isempty(gcp('nocreate'))
			delete(gcp)
		end

		% change configuration of parallel cluster depending on user input.
		[c] = subfxn_setupParallelEnvironment();

		% loop over all hand and player configurations
		for handNo = 1:nHands
			for playerNo = 1:nPlayers
				numHands = numHandsList(handNo);
				numPlayers = numPlayersList(playerNo);
				success = 0;
				poolSize = numWorkersToOpen;

				fprintf('Simulating each player playing %d hands.\n', numHands);
				% poolSizeVector = 1:(poolSize+1);
				poolSizeVector = 0:poolSize;
				% poolSizeVector = [1 16 32 48];
				% poolSizeVector = [0 1 16 32 48];
				timesVector = zeros(1, length(poolSizeVector));

				% do a speed test for a given worker configuration
				subfxn_runParallelTest();

				% =====================
				% write out data to table
				subfxn_writeOutData()

				% =====================
				% plot data if requested
				subfxn_plotData();
			end
		end
	catch err
		success = 0;
		try
			% =====================
			subfxn_writeOutData()
		catch err
			% display error log
			display(repmat('@',1,7))
			disp(getReport(err,'extended','hyperlinks','on'));
			display(repmat('@',1,7))
		end
		% display error log
		display(repmat('@',1,7))
		disp(getReport(err,'extended','hyperlinks','on'));
		display(repmat('@',1,7))
	end
	function [c] = subfxn_setupParallelEnvironment()
		if strcmp('local_parpool',localVsCluster)
			display(repmat('=',1,21))
			display('Parallel using local profile')
			% check that local matlabpool configuration is correct
			myCluster = parcluster('local');
			if myCluster.NumWorkers~=numWorkersToOpen
				myCluster.NumWorkers = numWorkersToOpen; % 'Modified' property now TRUE
				saveProfile(myCluster);   % 'local' profile now updated
			end
			% matlabpool('open',maxCores-1);
			% parpool('local',numWorkersToOpen,'IdleTimeout', Inf);
			parpool('local',numWorkersToOpen);
			c = [];
		elseif strcmp('mdcs_parpool',localVsCluster)
			display(repmat('=',1,21))
			display('Parallel using MDCS with parpool')
			c = parcluster;
			c.AdditionalProperties.AdditionalSubmitArgs = ' --cpus-per-task=2 ';
			c.AdditionalProperties.QueueName = clusterPartition;
			c.AdditionalProperties.WallTime = '16:10:00'
			% c.AdditionalProperties.WallTime = '';
			c.AdditionalProperties.EmailAddress = 'bahanonu@gmail.com';
			c.AdditionalProperties.MemUsage = '4Gb';
			c.AdditionalProperties.DebugMessagesTurnedOn=true;
			% c.NumThreads = numWorkersToOpen;
			c.NumThreads = 1;
			c.saveProfile;
			c.AdditionalProperties
			c
			% parallel.clusterProfiles
			% parallel.defaultClusterProfile
			parpool(numWorkersToOpen);
		elseif strcmp('mdcs_batch',localVsCluster)
			display(repmat('=',1,21))
			display('Parallel using MDCS with batch()')
			c = parcluster;
			c.AdditionalProperties.AdditionalSubmitArgs = ' --cpus-per-task=2 ';
			c.AdditionalProperties.QueueName = clusterPartition;
			c.AdditionalProperties.WallTime = '16:10:00'
			% c.AdditionalProperties.WallTime = '';
			c.AdditionalProperties.EmailAddress = 'bahanonu@gmail.com';
			c.AdditionalProperties.MemUsage = '4Gb';
			c.AdditionalProperties.DebugMessagesTurnedOn=true;
			% c.NumThreads = numWorkersToOpen;
			c.NumThreads = 1;
			c.saveProfile;
			c.AdditionalProperties
			c
			% parallel.clusterProfileswatch
			% parallel.defaultClusterProfile
		end
	end
	function subfxn_runParallelTest()
		for workerNo = 1:length(poolSizeVector)
			nPoolWorkers = poolSizeVector(workerNo);
			try
				if strcmp('local_parpool',localVsCluster)|strcmp('mdcs_parpool',localVsCluster)
					subfxn_spmdCheck();

			        outputTime = pctdemo_aux_parforbenchLocal(numHands, numPlayers, nPoolWorkers, localVsCluster);
				    timesVector(workerNo) = outputTime;
				    fprintf('%d workers simulated %d players in %3.2f seconds.\n', nPoolWorkers, numPlayers, timesVector(workerNo));
				elseif strcmp('mdcs_batch',localVsCluster)
					subfxn_spmdCheck();

					pctconfig('preservejobs',true)
				    j = c.batch(@pctdemo_aux_parforbenchLocal, 1, {numHands, numPlayers, nPoolWorkers, localVsCluster}, 'Pool', nPoolWorkers);
				    % get rid of this and check for them in a while loop later
				    wait(j);
				    % while ~strcmp(j.State,'finished'); end;
				    j.State
				    % c.getDebugLog(j)
					timesVector(workerNo) = j.fetchOutputs{:};
					try
						debugLogArray{end+1} = c.getDebugLog(j);
					catch
						debugLogArray{end+1} = [];
					end
					fprintf('%d workers simulated %d players in %3.2f seconds.\n', nPoolWorkers, numPlayers, timesVector(workerNo));
				end
			catch err
				display(repmat('@',1,7))
				disp(getReport(err,'extended','hyperlinks','on'));
				display(repmat('@',1,7))
			end
		end
		timesVector
		% poolSizeVector = poolSizeVector-1;
		singleWorkerIdx = find(poolSizeVector==1);
		speedup = timesVector(singleWorkerIdx)./timesVector;
	end
	function subfxn_writeOutData()
		% Add to save table and save continuously in case of crash
		% addRow = size(opts.runtimeTable,1)+1;
		numPtsToAdd = length(speedup(:));
		% opts.runtimeTable = table2struct(opts.runtimeTable);
		runtimeTable.numHands(end+1:end+numPtsToAdd,1) = numHands;
		runtimeTable.numPlayers(end-numPtsToAdd+1:end,1) = numPlayers;
		runtimeTable.speedup(end-numPtsToAdd+1:end,1) = speedup(:);
		runtimeTable.runtime(end-numPtsToAdd+1:end,1) = timesVector(:);
		runtimeTable.poolSizeVector(end-numPtsToAdd+1:end,1) = poolSizeVector(:);

		runtimeTable
		% runtimeTableExists = 1;
		writetable(runtimeTable,runtimeTablePath,'FileType','text','Delimiter',',');

		% write out log information
		fprintf('Saving log file to: %s\n',debugLogSavePath)
		save(debugLogSavePath,'debugLogArray','-v7.3');
	end
	function subfxn_plotData()
		if enableFigures==1
			fig = pctdemo_setup_blackjack(1.0);
				fig.Visible = 'on';
				ax = axes('parent', fig);
				x = plot(ax, poolSizeVector, poolSizeVector, '--', ...
				    poolSizeVector, speedup, 's', 'MarkerFaceColor', 'b');
				t = ax.XTick;
				t(t ~= round(t)) = []; % Remove all non-integer x-axis ticks.
				ax.XTick = t;
				legend(x, 'Linear Speedup', 'Measured Speedup', 'Location', 'NorthWest');
				xlabel(ax, ['Number of MATLAB workers participating in computations' 10 '(0 = parfor OFF)']);
				ylabel(ax, 'Speedup');
				hold on;

				success = 1;
		end
	end
end
function subfxn_spmdCheck()
	lidx=[];numlabsIdx=[];spmd;lidx(end+1)=labindex;numlabsIdx(end+1)=numlabs;end;
	for i=1:length(lidx);fprintf('numlabs = %d | labindex = %d\n',numlabsIdx{i}, lidx{i});end;
end
function t = pctdemo_aux_parforbenchLocal(numHands, numPlayers, n, localVsCluster)
	% PCTDEMO_AUX_PARFORBENCH Use parfor to play blackjack.
	%   S = pctdemo_aux_parforbench(numHands, numPlayers, n) plays
	%   numHands hands of blackjack numPlayers times, and uses no
	%   more than n MATLAB(R) workers for the computations.

	%   Copyright 2007-2009 The MathWorks, Inc.
	t0 = tic;
	S = zeros(numHands, numPlayers);
	% subfxn_spmdCheck();
	if strcmp('mdcs_batch',localVsCluster)
		ticBytes(gcp);
	end
	parfor (i = 1:numPlayers, n)
		S(:, i) = pctdemo_task_blackjack(numHands, 1);
	end
	if strcmp('mdcs_batch',localVsCluster)
		tocBytes(gcp)
	end
	t = toc(t0);
end