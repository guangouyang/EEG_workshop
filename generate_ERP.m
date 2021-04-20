
clear;
eeglab nogui

%% data loading
data_path = 'D:\EEG_workshop\data\';
%need to change to your actual data path

parti = 'sample_visual_oddball';
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
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'stop',0.001);
%automatically detec artifacts and clean the data
[comps,info] = MARA(EEG);
EEG = pop_subcomp( EEG, comps, 0);


%% generate ERP
epoch_twd = [-200,1000];%epoch time window
bl_twd = [-200, 0]; %baseline time window

ERPs = get_ERP_func(EEG,epoch_twd,bl_twd,{{'S 21'},{'S 22'}});

ch = find(strcmpi({EEG.chanlocs.labels},'Pz'));
figure;plot(ERPs.t_axis,squeeze(ERPs.ERPs(ch,:,:)));
xlabel('time after stimulus (ms)');
ylabel('amplitude (\muV)');
title('brain response pattern');
ylim([-10,10]);

%% generate scalp map of ERP difference
effect_twd = [300,600];
eff_twd1 = round((effect_twd - epoch_twd(1))*EEG.srate/1000);
topo_diff = mean(ERPs.ERPs(:,eff_twd1(1):eff_twd1(2),1) - ERPs.ERPs(:,eff_twd1(1):eff_twd1(2),2),2);
figure;topoplot(topo_diff,EEG.chanlocs,'electrodes','labelpoint','headrad','rim');axis([-.65,.65,-.65,.65]);


%% development of difference map across time
n = 10;
t_points = linspace(100,800,n);
t_width = 50;

figure;
for j = 1:n
    subplot(1,n,j);
    effect_twd = [t_points(j),t_points(j)+t_width];
    eff_twd1 = round((effect_twd - epoch_twd(1))*EEG.srate/1000);
    topo_diff = mean(ERPs.ERPs(:,eff_twd1(1):eff_twd1(2),1) - ERPs.ERPs(:,eff_twd1(1):eff_twd1(2),2),2);
    topoplot(topo_diff,EEG.chanlocs,'electrodes','off','headrad','rim','style','map');axis([-.65,.65,-.65,.65]);
    caxis([-7,7]);title([num2str(round(effect_twd(1))),'-',num2str(round(effect_twd(2)))]);
end