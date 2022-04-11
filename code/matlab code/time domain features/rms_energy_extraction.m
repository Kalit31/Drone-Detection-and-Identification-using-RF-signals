rng default

close all; clear; clc
load_filename = '/media/kalit/Data/CEERI Project/RF-based/main/DroneRF data/raw data/';     % Raw RF data folder
save_filename = '/media/kalit/Data/CEERI Project/RF-based/main/DroneRF data/rms_energy.csv'; 

%% Parameters
BUI{1,1} = {'00000'};                         % BUI of RF background activities
BUI{1,2} = {'10000','10001','10010','10011'}; % BUI of the Bebop drone RF activities
BUI{1,3} = {'10100','10101','10110','10111'}; % BUI of the AR drone RF activities
BUI{1,4} = {'11000'};                         % BUI of the Phantom drone RF activities
M = 1e6; % Window length
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
        data = [];
        cnt = 1;
        for n = 0:N
            % Loading raw csv files
            x = readmatrix([load_filename BUI{1,opt}{b} 'L_' num2str(n) '.csv']);
            y = readmatrix([load_filename BUI{1,opt}{b} 'H_' num2str(n) '.csv']);
            
            % window length = M
            x_rms = rms_energy(x,M);
            y_rms = rms_energy(y,M);

            data(1,cnt:cnt+length(x_rms)-1) = x_rms;
            data(2,cnt:cnt+length(y_rms)-1) = y_rms;
            
            cnt = cnt + length(x_rms);
            disp(100*n/N)
        end
        
        % Normalizing data
        data = data./max(max(data));        
        DATA = [DATA, data];
        LENGTHS = [LENGTHS, size(data,2)];
        clear data;
    end
end

%% Adding labels and saving
zeros(3,sum(LENGTHS));
Label(1,:) = [0*ones(1,LENGTHS(1)) 1*ones(1,sum(LENGTHS(2:end)))];
Label(2,:) = [0*ones(1,LENGTHS(1)) 1*ones(1,sum(LENGTHS(2:5))) 2*ones(1,sum(LENGTHS(6:9))) 3*ones(1,LENGTHS(10))];
temp = [];
for i = 1:length(LENGTHS)
    temp = [temp (i-1)*ones(1,LENGTHS(i))];
end
Label(3,:) = temp;

writematrix([DATA; Label],[save_filename]);

function y = rms_energy(signal, wl)
indices = 1:wl:length(signal);

if length(signal) - indices(end) + 1 < wl
    indices = indices(1:find(indices+wl-1 <= length(signal), 1, 'last'));
end

y = zeros(1,length(indices));
signal = signal.^2;
index = 0;
for i=indices
    index = index + 1;
    y(index) = sqrt(mean(signal(i:i+wl-1)));
end
end






