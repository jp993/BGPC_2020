function rawtimeY = load_raw_test(subj,param)

start_bgpc = param.start_challenge;
% PH=param.ph;
% start=param.wind;
% start_bgpc = PH + start;
raw_filename=['..\Ohio_Processed\Ohio',num2str(subj),'\Testing-',num2str(subj),'-ws-testing'];
load(raw_filename,'patient');

timeCGM = patient.timeseries.CGM.time;

rawtimeY = timeCGM(start_bgpc:end);