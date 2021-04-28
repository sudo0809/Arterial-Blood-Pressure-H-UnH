%change the name of the file to get the data
clc
data = load('E:\NIT J\Minor_Project_Group_20\DATA_BTPm_Group20\Class_2\s19578ry.mat');
%File name to be given to excel file
baseFileName = 'final_class2_data.xlsx';
subject_id = 19578;

try
    x = data.tSS;
    y = data.pSS;
catch
    x = data.t;
    y = data.pAo;
end
%------------------------------------------------
%For Systolic
[pk,lk] = findpeaks(y, x, 'MinPeakProminence', 20);
% subplot(2,2,1);
findpeaks(y, x, 'MinPeakProminence', 20);
xlabel('tSS');
ylabel('pSS');
title('Systolic');
hold on;

mean_pk = mean(pk(:));

% Standand Deviation of systolic peaks
diff = (mean_pk - pk(:)).^2;
diff_sum = sum(diff);
len = length(pk);
var = diff_sum/len;
std_sys = sqrt(var);
%----------------------------------------------

%For Diastolic

y(:) = y(:)*-1;

[pkmin,lkmin] = findpeaks(y, x, 'MinPeakProminence', 20);
y(:) = y(:)*-1;
pkmin(:) = pkmin(:)*-1;

% subplot(2,2,3);
% plot(x,y);
% hold on;
plot(lkmin, pkmin, 'b^', 'MarkerFaceColor', 'b');
grid on;
xlabel('tSS');
ylabel('pSS');
title('Arterial Blood Pressure');

mean_pkmin = mean(pkmin(:));

% Standand Deviation of Diastolic peaks
diff_d = (mean_pkmin - pkmin(:)).^2;
diff_sum_d = sum(diff);
len = length(pkmin);
var = diff_sum_d/len;
std_dia = sqrt(var);

%-------------------------------------------------
%Mean Arterial Pressure
MAP = (mean_pk/3) + (2*mean_pkmin)/3;

%-------------------------------------------------
% Pulse Pressure to sheet G
len=min(length(pk),length(pkmin));

pp=[];
for i=1:len
     pp(end+1)=pk(i)-pkmin(i);
end
mean_pp = mean(pp(:));

%----------------------------------------------------
% Kick Ratio mean

lowest_sys_peak = min(pk) - 1;
highest_dia_peak = max(pkmin);
[pks1,locs1] = findpeaks(y, x, 'MinPeakHeight',highest_dia_peak);
[pks2,locs2] = findpeaks(y, x, 'MinPeakHeight',lowest_sys_peak-1);
[C, ia] = setdiff(locs1, locs2,'stable');
try
    MidPks = [pks1(ia) transpose(locs1(ia))];
catch
    MidPks = [transpose(pks1(ia)) transpose(locs1(ia))];
end

% MidPks = [[1.03,2.215,3.41, 4.56,10.37,5.705,11.385,9.12,7.88, 6.77]
% [89.905,89.08,88.909,89.775,86.4016,87.630,86.584,89.8386,89.20,88.052]];
figure(1)
plot(x, y)
hold on
plot(MidPks(:,2), MidPks(:,1), 'xr') 
hold on
grid

kick_ratio = [];
for i=1 : length(lkmin)-1
    prev = lkmin(i);
    next = lkmin(i+1);
    for j=1 : length(MidPks(:,2))
%         MidPks(j, 2)
        if (MidPks(j,2) > prev && MidPks(j,2) < next)
            num = MidPks(j,2) - prev;
            dentt = next - prev;
            ratio = num / dentt;
            kick_ratio(end+1) = ratio;
            break;
        end 
    end
end

kick_ratio_mean = mean(kick_ratio(:));

%-------------------------------------------------------
%Skewness and Kurtosis and Median
skew = skewness(y);
kurt = kurtosis(y);
med_y = median(y);

%--------------------------------------------------
%Adding values to excel sheet using column A to D
fullFileName = fullfile('E:\NIT J\Minor_Project_Group_20', baseFileName);
col_header1 = {'Id','Sys_mean','Std_Sys','Dia_mean','Std_Dia','Mean_AP','Pulse Pressure','Kick Ratio Mean','Median','Skewness', 'Kurtosis'};
values = [subject_id ,mean_pk, std_sys, mean_pkmin, std_dia, MAP, mean_pp, kick_ratio_mean, med_y, skew, kurt];
xlswrite(fullFileName, col_header1,'Sheet1','A1');
% xlswrite(fullFileName, subject_id,'Sheet1','A5');
xlswrite(fullFileName, values,'Sheet1','A35:k35');
