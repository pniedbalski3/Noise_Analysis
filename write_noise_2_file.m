function write_noise_2_file(Noise,matfile,ScanDateStr)

parent_path = which('Noise_Analysis');
idcs = strfind(parent_path,filesep);%determine location of file separators
parent_path = parent_path(1:idcs(end)-1);%remove file

try
    load(fullfile(parent_path,'Noise_Summaries',[matfile '.mat']))
    match = find(strcmpi(Noise_Sum.Date{:},ScanDateStr));
catch
    if ~contains(matfile,'Gas_Exchange')
        headers = {'Date','Mean_Real','STD_Real','Mean_Imag','STD_Imag','Mean_Mag','STD_Mag'};
        Noise_Sum = cell2table(cell(0,size(headers,2)));
        Noise_Sum.Properties.VariableNames = headers;
    else
        headers = {'Date','Gas_Mean_Real','Gas_STD_Real','Gas_Mean_Imag','Gas_STD_Imag','Gas_Mean_Mag','Gas_STD_Mag','Dis_Mean_Real','Dis_STD_Real','Dis_Mean_Imag','Dis_STD_Imag','Dis_Mean_Mag','Dis_STD_Mag'};
        Noise_Sum = cell2table(cell(0,size(headers,2)));
        Noise_Sum.Properties.VariableNames = headers;
    end
    match = [];
end

if ~contains(matfile,'Gas_Exchange')
    NewData = {ScanDateStr,Noise.real_mean,Noise.real_std,Noise.imag_mean,Noise.imag_std,Noise.mag_mean,Noise.mag_std};
else
    NewData = {ScanDateStr,Noise.real_mean,Noise.real_std,Noise.imag_mean,Noise.imag_std,Noise.mag_mean,Noise.mag_std,Noise.dis_real_mean,Noise.dis_real_std,Noise.dis_imag_mean,Noise.dis_imag_std,Noise.dis_mag_mean,Noise.dis_mag_std};
end

if isempty(match)
    Noise_Sum = [Noise_Sum;NewData];
else
    Noise_Sum(match,:) = NewData;
end

Noise_Sum = sortrows(Noise_Sum,'Date');

save(fullfile(parent_path,'Noise_Summaries',[matfile '.mat']),'Noise_Sum');
writetable(Noise_Sum,fullfile(parent_path,'Noise_Summaries',[matfile '.xlsx']),'Sheet',1);
