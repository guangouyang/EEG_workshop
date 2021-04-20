
clear;
eeglab nogui

%% data loading
data_path = 'D:\EEG_workshop\data\thirty_participants\';
temp = dir([data_path,'*.set']);
subs = cellfun(@(x) x(1:end-4),{temp.name},'UniformOutput',false);
%need to change to your actual data path

%% calcualte ERP for all participants
epoch_twd = [-200,1000];%epoch time window
bl_twd = [-200, 0]; %baseline time window
ERPs_all = [];
for j = 1:length(subs)
    EEG = pop_loadset('filename',[subs{j},'.set'],'filepath',data_path);
    ERPs = get_ERP_func(EEG,epoch_twd,bl_twd,{{'S 21'},{'S 22'}});
    ERPs_all(:,:,:,j) = ERPs.ERPs;
end

%% plot grand average ERP
ch = find(strcmpi({EEG.chanlocs.labels},'Pz'));

ERP_grand_ave = mean(ERPs_all,4);
figure;plot(ERPs.t_axis,squeeze(ERP_grand_ave(ch,:,:)));
xlabel('time after stimulus (ms)');
ylabel('amplitude (\muV)');
title('brain response pattern');
ylim([-10,10]);



%% simple stats
effect_twd = [300,600];
eff_twd1 = round((effect_twd - epoch_twd(1))*EEG.srate/1000);
amp_diff = squeeze(mean(ERPs_all(ch,eff_twd1(1):eff_twd1(2),1,:),2)) - ...
    squeeze(mean(ERPs_all(ch,eff_twd1(1):eff_twd1(2),2,:),2));

figure;plot(amp_diff,'o','markerfacecolor','b');
ylim([-10,10]);hold on;plot([0,length(subs)],[0 0],'--k');
xlabel('subject number');ylabel('ERP effect');

figure;histogram(amp_diff,10,'orientation','horizontal');
ylim([-10,10]);

[a,b,c,d] = ttest(amp_diff)