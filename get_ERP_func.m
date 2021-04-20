

function results = get_ERP_func(EEG,epoch_twd,baseline_twd,markers)
% 
% %----------------------get single trial segment locked to time marker---------------
% epoch_twd = [-200,1000];%epoch time window to be extracted, with respect to stimulus onset
% baseline_twd = [-200,0];%baseline time window
% %set the conditions to be extracted
% 
% markers = {{'S 81'},{'S 82'}};
epoch_twd_d = round(epoch_twd*EEG.srate/1000);
ST = {};
bl = 1+round((baseline_twd(1) - epoch_twd(1))*EEG.srate/1000):round((baseline_twd(2) - epoch_twd(1))*EEG.srate/1000);
for m = 1:length(markers)
latencies = round([EEG.event(ismember({EEG.event.type},markers{m})).latency]);
ST{m} = [];
for j = 1:length(latencies)
    temp = EEG.data(:,(latencies(j)+epoch_twd_d(1)):(latencies(j)+epoch_twd_d(2)));
    ST{m}(:,:,j) = temp;
end
ST{m} = ST{m} - mean(ST{m}(:,bl,:),2);
end


%plot ERP S4 (rare) from Pz (and S5, frequent)
results.t_axis = linspace(epoch_twd(1),epoch_twd(2),size(ST{1},2));


for j = 1:length(ST)
    ERPs(:,:,j) = mean(ST{j},3);
end

results.ERPs = ERPs;
results.ST = ST;