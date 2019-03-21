function [] = WriteKaimalUsrSpec(f,sigma,uHub)

fid = fopen('TurbSim_User.spectra','wt');

fprintf(fid,'%s\n',    '-------- User-Defined Spectra (Used only with USRINP spectral model) ------------------------------------');
fprintf(fid,'%s%f%s%f%s\n','--       The Kaimal spectra IEC 61400-1 Ed. 3 for Vhub=', uHub, ' m/s; Zhub>60 m; sigma_U=', sigma(1), ' m/s  --');
fprintf(fid,'%s\n',    '---------------------------------------------------------------------------------------------------------');
fprintf(fid,'%10.0f%s\n',  length(f),  '    f  NumUSRf        - Number of Frequencies [dictates how many lines to read from this file]');
fprintf(fid,'%s\n',    '1.0             SpecScale1     - scaling factor for the input u-component spectrum');
fprintf(fid,'%s\n',    '1.0             SpecScale2     - scaling factor for the input v-component spectrum');
fprintf(fid,'%s\n',    '1.0             SpecScale3     - scaling factor for the input w-component spectrum');
fprintf(fid,'%s\n',    '.........................................................................................................');
fprintf(fid,'%s\n',    'Frequency    u-component PSD   v-component PSD      w-component PSD');
fprintf(fid,'%s\n',    '(Hz)           (m^2/s)           (m^2/s)             (m^2/s)');   
fprintf(fid,'%s\n',    '---------------------------------------------------------------------------------------------------------');


S = KaimalSpectra(f,sigma,uHub);

fprintf(fid,'%f %f %f %f \n', [f(:) S]');

fclose(fid);

return;
