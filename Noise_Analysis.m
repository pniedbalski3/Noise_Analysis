clear;clc;close all;

%Script to analyze noise scans

%% Find folder where this is located so I know where to save the data
parent_path = which('Noise_Analysis');
idcs = strfind(parent_path,filesep);%determine location of file separators
parent_path = parent_path(1:idcs(end)-1);%remove file

%% Read in data file - do using a gui. Definitely not hard to automate if desired
%User select file
[myfile,mypath] = uigetfile('*.dat','Select a Noise File');
%Read in Raw data
twix_obj = mapVBVD(fullfile(mypath,myfile));
%Figure out name of sequence so we know what to do with the data
SeqName = twix_obj.hdr.Config.SequenceFileName;
scanDate = twix_obj.hdr.Phoenix.tReferenceImage0; 
scanDate = strsplit(scanDate,'.');
scanDate = scanDate{end};
scanDateStr = [scanDate(1:4),'-',scanDate(5:6),'-',scanDate(7:8)];
%get rid of '%CustomerSeq%\'
SeqName(1:14) = [];

%Possible_names = Noise_SeqNames();

%% Now, Match name to data type so that the right kind of analysis can be done:
%Let's only do Duke calibration, my calibration, spiral ventilation, GRE ventilation, standard
%gas exchange, and vent/gas exchange

switch SeqName
    case 'fid_xe_calibration_2101' %John's/Duke Calibration - Seems to be working
        raw = squeeze(double(twix_obj.image()));
        raw1 = real(raw);
        raw2 = imag(raw);
        %I think let's just put all fids back-to-back and plot, calculate
        %mean and stdev.
        line_up_and_plot(raw1,'Real Noise');
        line_up_and_plot(raw2,'Imaginary Noise');
        line_up_and_plot(abs(raw),'Magnitude Noise');
        Noise.real_mean = mean(raw1(:));
        Noise.real_std = std(raw1(:));
        Noise.imag_mean = mean(raw2(:));
        Noise.imag_std = std(raw2(:));
        Noise.mag_mean = mean(abs(raw(:)));
        Noise.mag_std = std(abs(raw(:)));
        
        matfile = 'Duke_Cal_Noise';
        write_noise_2_file(Noise,matfile,scanDateStr);
    case 'XeCal_ShortTR' %KUMC short TR Calibration
        raw = squeeze(double(twix_obj.image()));
        raw1 = real(raw);
        raw2 = imag(raw);
        line_up_and_plot(raw1,'Real Noise');
        line_up_and_plot(raw2,'Imaginary Noise');
        line_up_and_plot(abs(raw),'Magnitude Noise');
        Noise.real_mean = mean(raw1(:));
        Noise.real_std = std(raw1(:));
        Noise.imag_mean = mean(raw2(:));
        Noise.imag_std = std(raw2(:));
        Noise.mag_mean = mean(abs(raw(:)));
        Noise.mag_std = std(abs(raw(:)));
        
        matfile = 'KUMC_Cal_Noise';
        write_noise_2_file(Noise,matfile,scanDateStr);
    case 'SPIRAL' %Spiral Ventilation
        raw = squeeze(double(twix_obj.image()));
        raw1 = real(raw);
        raw2 = imag(raw);
        line_up_and_plot(raw1,'Real Noise');
        line_up_and_plot(raw2,'Imaginary Noise');
        line_up_and_plot(abs(raw),'Magnitude Noise');
        Noise.real_mean = mean(raw1(:));
        Noise.real_std = std(raw1(:));
        Noise.imag_mean = mean(raw2(:));
        Noise.imag_std = std(raw2(:));
        Noise.mag_mean = mean(abs(raw(:)));
        Noise.mag_std = std(abs(raw(:)));
        
        matfile = 'SPIRAL_Vent_Noise';
        write_noise_2_file(Noise,matfile,scanDateStr);
    case 'xe_radial_Dixon_2102' %John's Radial Dixon
        Xe_Raw = DataImport.ReadSiemensMeasVD13_idea(fullfile(mypath,myfile));
        fid = Xe_Raw.rawdata;
        loop = Xe_Raw.loopcounters;
        first_nrep = find(loop(:,7)==1,2); %index 1 will be first index of pre-spectra
        first_nrep = first_nrep(2); %this index will be first index of images
        last_rep = find(loop(:,7)==1,1,'last'); %this index will be first index of post-spectra
        Spec_Pre = zeros(max(loop(1:first_nrep,7)),loop(1,16));
        Im_Raw = zeros(max(loop(:,1)),loop(first_nrep,16),2);
        Spec_Post = zeros(size(loop,1)-last_rep+1,loop(last_rep,16));
        for i = 1:size(loop,1)
            %get pre-spectroscopy data
            if loop(i,4) == 1 && loop(i,29) < 0.5*size(loop,1)
                Spec_Pre(loop(i,7),:) = fid(i,1:loop(1,16));
            elseif loop(i,4) == 33
                Im_Raw(loop(i,1),:,loop(i,5)) = fid(i,1:loop(first_nrep,16));
            else
                Spec_Post(loop(i,7),:) = fid(i,1:loop(last_rep,16));
            end
        end
        Xe_Raw = Im_Raw;
        Xe_Raw = permute(Xe_Raw,[2 1 3]);
        Raw = Xe_Raw;

        Gas = Raw(:,:,1);
        Dis = Raw(:,:,2);
        
        raw1 = real(Gas);
        raw2 = imag(Gas);
        line_up_and_plot(raw1,'Real Noise - Gas');
        line_up_and_plot(raw2,'Imaginary Noise - Gas');
        line_up_and_plot(abs(Gas),'Magnitude Noise - Gas');
        
        Noise.real_mean = mean(raw1(:));
        Noise.real_std = std(raw1(:));
        Noise.imag_mean = mean(raw2(:));
        Noise.imag_std = std(raw2(:));
        Noise.mag_mean = mean(abs(Gas(:)));
        Noise.mag_std = std(abs(Gas(:)));
        
        raw1 = real(Dis);
        raw2 = imag(Dis);
        line_up_and_plot(raw1,'Real Noise - Dis');
        line_up_and_plot(raw2,'Imaginary Noise - Dis');
        line_up_and_plot(abs(Dis),'Magnitude Noise - Dis');
        
        Noise.dis_real_mean = mean(raw1(:));
        Noise.dis_real_std = std(raw1(:));
        Noise.dis_imag_mean = mean(raw2(:));
        Noise.dis_imag_std = std(raw2(:));
        Noise.dis_mag_mean = mean(abs(Dis(:)));
        Noise.dis_mag_std = std(abs(Dis(:)));
        
        matfile = 'Radial_Gas_Exchange_Noise';
        write_noise_2_file(Noise,matfile,scanDateStr);
    case 'SPIRAL_Rad_DIXON'
        Xe_Raw = DataImport.ReadSiemensMeasVD13_idea(fullfile(mypath,myfile));
        fid = Xe_Raw.rawdata;
        loop = Xe_Raw.loopcounters;

        %I could do something more elegant, but really, this is just every other,
        %starting with Dis
        Dis = fid(1:2:end,:);
        %Again could do something more elegant, but start with easy
        Dis(:,65:end) = [];
        Dis = Dis';

        Gas = fid(2:2:end,:);
        Gas = Gas';
        
        raw1 = real(Gas);
        raw2 = imag(Gas);
        line_up_and_plot(raw1,'Real Noise - Gas');
        line_up_and_plot(raw2,'Imaginary Noise - Gas');
        line_up_and_plot(abs(Gas),'Magnitude Noise - Gas');
        
        Noise.real_mean = mean(raw1(:));
        Noise.real_std = std(raw1(:));
        Noise.imag_mean = mean(raw2(:));
        Noise.imag_std = std(raw2(:));
        Noise.mag_mean = mean(abs(Gas(:)));
        Noise.mag_std = std(abs(Gas(:)));
        
        raw1 = real(Dis);
        raw2 = imag(Dis);
        line_up_and_plot(raw1,'Real Noise - Dis');
        line_up_and_plot(raw2,'Imaginary Noise - Dis');
        line_up_and_plot(abs(Dis),'Magnitude Noise - Dis');
        
        Noise.dis_real_mean = mean(raw1(:));
        Noise.dis_real_std = std(raw1(:));
        Noise.dis_imag_mean = mean(raw2(:));
        Noise.dis_imag_std = std(raw2(:));
        Noise.dis_mag_mean = mean(abs(Dis(:)));
        Noise.dis_mag_std = std(abs(Dis(:)));
        
        matfile = 'Spiral_Vent_Radial_Gas_Exchange_Noise';
        write_noise_2_file(Noise,matfile,scanDateStr);
end
        