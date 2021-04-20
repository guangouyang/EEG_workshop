
clear;
eeglab nogui

%% data loading
data_path = 'D:\EEG_workshop\data\';
%need to change to your actual data path

parti = 'sample_resting';
EEG = pop_loadset('filename',[parti,'.set'],'filepath',data_path);

    
%% pre-processing
%the following pre-processing assumes the data is largely homogeneous and
%stable (e.g., not from data segments in various kinds of contexts, from
%various tasks (espectially those with movements). It is not a
%preprocessing procedure for generic use.
%The MARA extension needs to be installed


%bandpass filtering
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',45,'plotfreqz',0);
%average referencing
EEG = pop_reref( EEG, []);
%run ica (the stop criterion usually needs to be lower)
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'stop',0.001,'interrupt','on');
%automatically detec artifacts and clean the data
[comps,info] = MARA(EEG);
EEG = pop_subcomp( EEG, comps, 0);


%% generate spectrum
eye_open_twd = [1,9831];
eye_close_twd = [9831,18830];

spectrum_open = get_spectrum_func(EEG,eye_open_twd);
spectrum_close = get_spectrum_func(EEG,eye_close_twd);

f_range = 1:30;

ch = find(strcmpi({EEG.chanlocs.labels},'Fz'));


figure;plot(f_range,spectrum_open.spectrum(f_range,ch));
hold on;plot(f_range,spectrum_close.spectrum(f_range,ch));
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('spectrum');
ylim([0,5]);

%% scalp map of between-condition difference
f_wd = 8:12;
temp = mean(spectrum_close.spectrum(f_wd,:)) - mean(spectrum_open.spectrum(f_wd,:));
figure;topoplot(temp,EEG.chanlocs,'electrodes','labelpoint','headrad','rim');axis([-.65,.65,-.65,.65]);