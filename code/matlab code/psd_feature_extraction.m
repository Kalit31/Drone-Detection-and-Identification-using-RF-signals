rng default

close all; clear; clc
load_filename = '/media/kalit/Data/CEERI Project/RF-based/main/DroneRF data/raw data/';                 % Raw RF data folder
save_filename = '/media/kalit/Data/CEERI Project/RF-based/main/DroneRF data/psd'; 

%% Parameters
BUI{1,1} = {'00000'};                         % BUI of RF background activities
BUI{1,2} = {'10000','10001','10010','10011'}; % BUI of the Bebop drone RF activities
BUI{1,3} = {'10100','10101','10110','10111'}; % BUI of the AR drone RF activities
BUI{1,4} = {'11000'};                         % BUI of the Phantom drone RF activities
M = 4096; % Total number of frequency bins
L = 1e6;  % Total number samples in a segment
fs = 40e6; % Sampling frequency

%% Main

DATA_1024 = [];
DATA_1024_L = [];
DATA_1024_H = [];

DATA_2048 = [];
DATA_2048_L = [];
DATA_2048_H = [];

DATA_4096 = [];
DATA_4096_L = [];
DATA_4096_H = [];

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

        Data_1024 = [];
        Data_1024_L = [];
        Data_1024_H = [];
        
        Data_2048 = [];
        Data_2048_L = [];
        Data_2048_H = [];
        
        Data_4096 = [];
        Data_4096_L = [];
        Data_4096_H = [];

        cnt = 1;
        for n = 0:N
            % Loading raw csv files
            x = readmatrix([load_filename BUI{1,opt}{b} 'L_' num2str(n) '.csv']);
            y = readmatrix([load_filename BUI{1,opt}{b} 'H_' num2str(n) '.csv']);

            for i = 1:length(x)/L
                st = 1 + (i-1)*L;
                fi = i*L;
                
                M = 1024;
                x_transformed = pwelch(x(st:fi),M,M/2,M,fs);
                y_transformed = pwelch(y(st:fi),M,M/2,M,fs);
        
                Data_1024(:,cnt) = [x_transformed;y_transformed];
                Data_1024_L(:,cnt) = [x_transformed];
                Data_1024_H(:,cnt) = [y_transformed];
                    

                M = 2048;
                x_transformed = pwelch(x(st:fi),M,M/2,M,fs);
                y_transformed = pwelch(y(st:fi),M,M/2,M,fs);
        
                Data_2048(:,cnt) = [x_transformed;y_transformed];
                Data_2048_L(:,cnt) = [x_transformed];
                Data_2048_H(:,cnt) = [y_transformed];

                M = 4096;
                x_transformed = pwelch(x(st:fi),M,M/2,M,fs);
                y_transformed = pwelch(y(st:fi),M,M/2,M,fs);
        
                Data_4096(:,cnt) = [x_transformed;y_transformed];
                Data_4096_L(:,cnt) = [x_transformed];
                Data_4096_H(:,cnt) = [y_transformed];
                   
                cnt = cnt + 1;
            end
            disp(100*n/N)
        end

        %Normalizing data
        Data_1024 = Data_1024./max(max(Data_1024));
        Data_1024_L = Data_1024_L./max(max(Data_1024_L));
        Data_1024_H = Data_1024_H./max(max(Data_1024_H));
        
        DATA_1024 = [DATA_1024,Data_1024];
        DATA_1024_L = [DATA_1024_L,Data_1024_L];
        DATA_1024_H = [DATA_1024_H,Data_1024_H];

        Data_2048 = Data_2048./max(max(Data_2048));
        Data_2048_L = Data_2048_L./max(max(Data_2048_L));
        Data_2048_H = Data_2048_H./max(max(Data_2048_H));
        
        DATA_2048 = [DATA_2048,Data_2048];
        DATA_2048_L = [DATA_2048_L,Data_2048_L];
        DATA_2048_H = [DATA_2048_H,Data_2048_H];

        Data_4096 = Data_4096./max(max(Data_4096));
        Data_4096_L = Data_4096_L./max(max(Data_4096_L));
        Data_4096_H = Data_4096_H./max(max(Data_4096_H));

        DATA_4096 = [DATA_4096,Data_4096];
        DATA_4096_L = [DATA_4096_L,Data_4096_L];
        DATA_4096_H = [DATA_4096_H,Data_4096_H];
        
        LENGTHS = [LENGTHS, size(Data_1024,2)];

        clear Data_1024;
        clear Data_1024_L;
        clear Data_1024_H;
        clear Data_2048;
        clear Data_2048_L;
        clear Data_2048_H;
        clear Data_4096;
        clear Data_4096_L;
        clear Data_4096_H;
    end
end

% Apply labels and save
zeros(3,sum(LENGTHS));
Label(1,:) = [0*ones(1,LENGTHS(1)) 1*ones(1,sum(LENGTHS(2:end)))];
Label(2,:) = [0*ones(1,LENGTHS(1)) 1*ones(1,sum(LENGTHS(2:5))) 2*ones(1,sum(LENGTHS(6:9))) 3*ones(1,LENGTHS(10))];
temp = [];
for i = 1:length(LENGTHS)
    temp = [temp (i-1)*ones(1,LENGTHS(i))];
end
Label(3,:) = temp;

writematrix([DATA_1024; Label],[save_filename '_1024.csv']);
writematrix([DATA_1024_L; Label],[save_filename '_1024_L.csv']);
writematrix([DATA_1024_H; Label],[save_filename '_1024_H.csv']);

writematrix([DATA_2048; Label],[save_filename '_2048.csv']);
writematrix([DATA_2048_L; Label],[save_filename '_2048_L.csv']);
writematrix([DATA_2048_H; Label],[save_filename '_2048_H.csv']);

writematrix([DATA_4096; Label],[save_filename '_4096.csv']);
writematrix([DATA_4096_L; Label],[save_filename '_4096_L.csv']);
writematrix([DATA_4096_H; Label],[save_filename '_4096_H.csv']);
