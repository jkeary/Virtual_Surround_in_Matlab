% Name: James Keary 
% Student ID: N12432851 
% NetID: jpk349 
% Due Date: 3/28/2012
% Assignment: Virtual Surround Sound
% 
% VirtSurrounder
%   function takes 5 channels of surround sound and makes them virtual for virtual surround sound headphone listening
%
% Inputs:
%
%   1)  cHRTFfilename   : Name of CENTER impulse response .wav file 
%   2)  rfHRTFfilename  : Name of RIGHT FRONT impulse response .wav file 
%   3)  rbHRTFfilename  : Name of RIGHT BACK impulse response .wav file 
%   4)  lbHRTFfilename  : Name of LEFT BACK impulse response .wav file 
%   5)  lfHRTFfilename  : Name of LEFT FRONT impulse response .wav file 
%   6)  cSIGfilename    : Name of CENTER signal .wav file 
%   7)  rfSIGfilename   : Name of RIGHT FRONT signal .wav file 
%   8)  rbSIGfilename   : Name of RIGHT BACK signal .wav file 
%   9)  lbSIGfilename   : Name of LEFT BACK signal .wav file 
%   10) lfSIGfilename   : Name of LEFT FRONT signal .wav file
%   11) OUTfile         : Name of .wav file to which the resulting 
%                         (convolved) signal will be written

function VirtSurrounder( cHRTFfilename , rfHRTFfilename, rbHRTFfilename ...
    , lbHRTFfilename , lfHRTFfilename , cSIGfilename , rfSIGfilename ,...
    rbSIGfilename , lbSIGfilename , lfSIGfilename , OUTfile )

% Read stereo HRTF files
	[cHRTF, sf1] = wavread(cHRTFfilename);
    [rfHRTF, sf2] = wavread(rfHRTFfilename);
    [rbHRTF, sf3] = wavread(rbHRTFfilename);
    [lbHRTF, sf4] = wavread(lbHRTFfilename);
    [lfHRTF, sf5] = wavread(lfHRTFfilename);
    
% Read mono SIG files
    [cSIG,sf6] = wavread(cSIGfilename);
    [rfSIG,sf7] = wavread(rfSIGfilename);
    [rbSIG,sf8] = wavread(rbSIGfilename);
    [lbSIG,sf9] = wavread(lbSIGfilename);
    [lfSIG,sf10] = wavread(lfSIGfilename);
    
% make sure sampling rates match up
    if sf1 ~= sf6 
        error('HRTF and signal sampling rates dont match');
    end
        
    if sf2 ~= sf7 
        error('HRTF and signal sampling rates dont match');
    end
    
    if sf3 ~= sf8
        error('HRTF and signal sampling rates dont match');
    end
    
    if sf4 ~= sf9 
        error('HRTF and signal sampling rates dont match');
    end
    
    if sf5 ~= sf10 
        error('HRTF and signal sampling rates dont match');
    end
        
% The length of front left SIG channel is 1235 samples longer than the 
% other signal channels.  Zero pad the other signals at beginning of signal
% so ALL SIGNAL LENGTHS ARE THE SAME.    
    cSIG = [zeros(1235, 1) ; cSIG];
    rfSIG = [zeros(1235, 1); rfSIG];
    rbSIG = [zeros(1235, 1) ; rbSIG];
    lbSIG = [zeros(1235, 1) ; lbSIG];

    % Put the signals in a matrix for later computations.    
    lengthSIG = length(lfSIG);
    SIGmtx = zeros(lengthSIG, 5);
    
    SIGmtx(:,1) = cSIG;
    SIGmtx(:,2) = rfSIG;
    SIGmtx(:,3) = rbSIG;
    SIGmtx(:,4) = lbSIG;
    SIGmtx(:,5) = lfSIG;  

% We know all HRTF lengths are equal.  Based on that length, allocate a
% matrix of vectors for the HRTF stereo files.
    lengthHRTF = (length(cHRTF));
    HRTFmtx = zeros(lengthHRTF, 10);

    % Split the HRTF stereo channels into left and right vectors
	CleftHRFT = cHRTF(:,1);
    CrightHRFT = cHRTF(:,2);
    RFleftHRFT = rfHRTF(:,1);
    RFrightHRFT = rfHRTF(:,2);
    RBleftHRFT = rbHRTF(:,1);
    RBrightHRFT = rbHRTF(:,2);
    LBleftHRFT = lbHRTF(:,1);
    LBrightHRFT = lbHRTF(:,2);
    LFleftHRFT = lfHRTF(:,1);
    LFrightHRFT = lfHRTF(:,2);
    
    % put vectors into matrix
    HRTFmtx(:,1) = CleftHRFT;
    HRTFmtx(:,2) = CrightHRFT;
    HRTFmtx(:,3) = RFleftHRFT;
    HRTFmtx(:,4) = RFrightHRFT;
    HRTFmtx(:,5) = RBleftHRFT;
    HRTFmtx(:,6) = RBrightHRFT;
    HRTFmtx(:,7) = LBleftHRFT;
    HRTFmtx(:,8) = LBrightHRFT;
    HRTFmtx(:,9) = LFleftHRFT;
    HRTFmtx(:,10) = LFrightHRFT;

% Convolve corresponding HRTFs to SIG vectors.

    % find length of convolution vector
    lengthCONVec = (lengthHRTF + lengthSIG) - 1;

    % Allocate left and right channel matrices.
    leftMTX = zeros(lengthCONVec, 5);
    rightMTX = zeros(lengthCONVec, 5);
    
    % convolve 
    Cleft = conv(HRTFmtx(:,1), SIGmtx(:,1));
    Cright = conv(HRTFmtx(:,2), SIGmtx(:,1));
    RFleft = conv(HRTFmtx(:,3), SIGmtx(:,2));
    RFright = conv(HRTFmtx(:,4), SIGmtx(:,2));
    RBleft = conv(HRTFmtx(:,5), SIGmtx(:,3));
    RBright = conv(HRTFmtx(:,6), SIGmtx(:,3));
    LBleft = conv(HRTFmtx(:,7), SIGmtx(:,4));
    LBright = conv(HRTFmtx(:,8), SIGmtx(:,4));
    LFleft = conv(HRTFmtx(:,9), SIGmtx(:,5));
    LFright = conv(HRTFmtx(:,10), SIGmtx(:,5));        
   
    % Place vectors in channel matrices.  
    % LEFT
    leftMTX(:,1) = Cleft;
    leftMTX(:,2) = RFleft;
    leftMTX(:,3) = RBleft;
    leftMTX(:,4) = LBleft;
    leftMTX(:,5) = LFleft;
    
    % RIGHT
    rightMTX(:,1) = Cright;
    rightMTX(:,2) = RFright;
    rightMTX(:,3) = RBright;
    rightMTX(:,4) = LBright;
    rightMTX(:,5) = LFright;

% Make a left and a right channel from your 10 virtual surround sound
    % Allocate vectors and output matrix.
    leftVEC = zeros(length(leftMTX), 1);
    rightVEC = zeros(length(rightMTX), 1);
    outputMTX = zeros(length(leftVEC), 2);
    
    % sum rows of MTXlefts and place into leftsVEC, same for MTXrights into
    % rightsVEC for virtual surround mix
    leftMTX = leftMTX';
    rightMTX = rightMTX';
    
    sumLEFTrow = (sum(leftMTX))/5;
    sumRIGHTrow = (sum(rightMTX))/5;
    
    leftVEC = sumLEFTrow';
    rightVEC = sumRIGHTrow';
    
    % then put together into outputMTX
    outputMTX(:,1) = leftVEC;
    outputMTX(:,2) = rightVEC;

% normalize 
    vectorMAX = 1.001 * (max(abs(outputMTX)));
    outputMTX = outputMTX / max(vectorMAX);
    
% wavwrite
    wavwrite (outputMTX, 44100, OUTfile);

end


