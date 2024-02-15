%% [sm] = mps(s) 
%% create minimum-phase spectrum sm from complex spectrum s
%%
%% https://ccrma.stanford.edu/~jos/fp2/Matlab_listing_mps_m.html

function [sm] = mps(s) 
  sm = exp( fft( fold( ifft( log( clipdb(s,-100) )))));
end
