

function results = get_spectrum_func(EEG,b)
% 
%----------------------get spectrum from EEG using Bartlett's method---------------
%length of non-overlapping time window: 1 second
% b = [1,9831];%boundary of the data to be calculated
%b = [9831,18830];

data = EEG.data(:,b(1):b(2));


segs = fix((b(2)-b(1)+1)/EEG.srate);

for j = 1:segs
    temp = data(:,1+(j-1)*EEG.srate:j*EEG.srate)';
    temp = abs(2*fft(temp)/EEG.srate);
    temp = temp(2:fix(EEG.srate/2),:);
    fft_temp(:,:,j) = temp;
end

results.spectrum = mean(fft_temp,3);
results.spectrum_i = fft_temp;

