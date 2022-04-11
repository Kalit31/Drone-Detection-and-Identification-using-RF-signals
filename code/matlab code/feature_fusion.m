rng default

close all; clear; clc
load_filename = '/media/kalit/Data/CEERI Project/RF-based/main/DroneRF data/raw data/';                 % Raw RF data folder
save_filename = '/media/kalit/Data/CEERI Project/RF-based/main/DroneRF data/feature_fusion_mfcc_fft.csv'; 

%% Parameters
BUI{1,1} = {'00000'};                         % BUI of RF background activities
BUI{1,2} = {'10000','10001','10010','10011'}; % BUI of the Bebop drone RF activities
BUI{1,3} = {'10100','10101','10110','10111'}; % BUI of the AR drone RF activities
BUI{1,4} = {'11000'};                         % BUI of the Phantom drone RF activities
M = 2048; % Total number of frequency bins
L = 262144;  % Total number samples in a segment
fs = 40e6; % Sampling frequency

%% Main

DATA = [];
LENGTHS = [];

for opt = 1:length(BUI)
    % Loading and averaging
    for b = 1:length(BUI{1,opt})
        disp(BUI{1,opt}{b})
        if(strcmp(BUI{1,opt}{b},'00000'))
            N = 40;
        elseif(strcmp(BUI{1,opt}{b},'10111'))
            N = 17;
        else
            N = 20;
        end
        Data = [];
        cnt = 1;
        for n = 0:N
            % Loading raw csv files
            x = readmatrix([load_filename BUI{1,opt}{b} 'L_' num2str(n) '.csv']);
            y = readmatrix([load_filename BUI{1,opt}{b} 'H_' num2str(n) '.csv']);

            psd_x = pwelch(x,M,M/2,M,fs);
            psd_y = pwelch(y,M,M/2,M,fs);
            mfcc_x = v_melcepst(x,fs,'M0E',12,floor(3*log(fs)),L);
            mfcc_y = v_melcepst(y,fs,'M0E',12,floor(3*log(fs)),L);
            mfcc_x = x_c(:);
            mfcc_y = y_c(:);
            xf = abs(fftshift(fft(x-mean(x),M))); xf = xf(end/2+1:end);
            yf = abs(fftshift(fft(y-mean(y),M))); yf = yf(end/2+1:end);
            xf = xf(:);
            yf = yf(:);

            concat_arr = [x_transformed;y_transformed;x_c;xf;y_c;yf];

            Data(:,cnt) = concat_arr ;
            cnt = cnt + 1;
            disp(100*n/N)
        end
        %Normalizing data
        Data = Data./max(max(Data));
        DATA = [DATA, Data];
        LENGTHS = [LENGTHS, size(Data,2)];
        clear Data;
    end
end


%% Apply labels and save
zeros(3,sum(LENGTHS));
Label(1,:) = [0*ones(1,LENGTHS(1)) 1*ones(1,sum(LENGTHS(2:end)))];
Label(2,:) = [0*ones(1,LENGTHS(1)) 1*ones(1,sum(LENGTHS(2:5))) 2*ones(1,sum(LENGTHS(6:9))) 3*ones(1,LENGTHS(10))];
temp = [];
for i = 1:length(LENGTHS)
    temp = [temp (i-1)*ones(1,LENGTHS(i))];
end
Label(3,:) = temp;


writematrix([DATA; Label],[save_filename]);