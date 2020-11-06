% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function matlabbatch = setBatchCoregistrationFmap(BIDS, opt, subID)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  
  % TODO
  % assumes all the fieldmap relate to the current task
  % - use the "for" metadata field
  % - implement for 'phase12', 'fieldmap', 'epi'

  printBatchName('coregister fieldmaps data to functional');

  % Create rough mean of the 1rst run to improve SNR for coregistration
  % TODO use the slice timed EPI if STC was used ?
  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'Sessions');
  runs = getInfo(BIDS, subID, opt, 'Runs', sessions{1});
  [fileName, subFuncDataDir] = getBoldFilename(BIDS, subID, sessions{1}, runs{1}, opt);

  spmup_basics(fullfile(subFuncDataDir, fileName), 'mean');

  refImage = fullfile(subFuncDataDir, ['mean_', fileName]);

  matlabbatch = [];

  for iSes = 1:nbSessions

    runs = spm_BIDS(BIDS, 'runs', ...
                    'modality', 'fmap', ...
                    'sub', subID, ...
                    'ses', sessions{iSes});

    for iRun = 1:numel(runs)

      % TODO
      % - Move to getInfo
      fmapFiles = spm_BIDS(BIDS, 'data', ...
                           'modality', 'fmap', ...
                           'sub', subID, ...
                           'ses', sessions{iSes}, ...
                           'run', runs{iRun});

      srcImage = strrep(fmapFiles{1}, 'phasediff', 'magnitude1');

      otherImages = cell(2, 1);
      otherImages{1} = strrep(fmapFiles{1}, 'phasediff', 'magnitude2');
      otherImages{2} = fmapFiles{1};

      matlabbatch = setBatchCoregistration(matlabbatch, refImage, srcImage, otherImages);

    end

  end

end
