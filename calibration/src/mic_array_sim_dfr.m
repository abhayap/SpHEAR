%% Simulate the Diffuse Field Response of Microphone Array
%     Aaron J. Heller (heller@ai.sri.com) 
%     28-May-2012, revised 22-Jun-2012, 12-Jan-2013
%     tested with MATLAB R2012b and GNU Octave, version 3.2.4

% make sure octave treats this as a script file
1;

%% Main function for simulator
function [dfr, ffr] = mic_array_sim_dfr( M, output_file )
    % MIC_ARRAY_SIM_DFR simulate diffuse field response pf mic array M
    %
    %  M.name ... name of array
    %  M.o    ... orientaton of capsules (direction cosines)
    %  M.u    ... positions of capsules (in meters)
    %  M.alpha .. directivities of capsules, by order
    %  M.a2b  ... the A-to-B matrix
    %             (Batke and Elko call this the mode matrix, \Psi)
    %    see MIC_ARRAY_Tetra and _Velan functions below for examples
    
    %% array to be simulated, all array parameteters in structure M
    if ~exist('M', 'var')
      M = CalrecMkIV;
      %%M.a2b = A2B';
    end
    %display(M.name);
    %% Physical constants and simulation parameters
    
    % speed of sound
    c = 340.29; % meters/sec
    
    % number of frequencies for simulation
    n_freqs = 200;
    low_freq = 100;
    high_freq = 20000;
    
    % log or linear
    log_freqs = false;
    
    % indexes of free-field responses to write out
    ffr_save = 1:6;
    
    % file for output, set to false for no file
    if ~exist('output_file', 'var')
        output_file = ['sim_output_', M.name, '.csv'];
    end
    
    % draw a graph?  
    graph_response = true;
    
    
    %% Integration on the Sphere
    % use order 20 Lebedev-Laikov quadrature
    a = LebedevGrid(20);
    
    % excitation directions,
    x = [a.x'; a.y'; a.z'];
    
    % number of outputs is number of rows in a2b matrix
    n_Bout = size(M.a2b,2);
    
    % quadrature weights, a.w is for full sphere, normalize to 1, duplicate
    % for each output
    qw = a.w(:,ones(1,n_Bout))' / (4*pi);
    
    % projections of capsule positions along the excitation directions
    d = M.u * x;
    
    % cosine of angle between capsule orientation and excitation directions
    cos_theta = (M.o * x);
    size_cos_theta = size(cos_theta); % for octave
    
    % directional gain for order i is the Legendre Polynomial, P_i
    % evaluated at cos_theta
    dir_gain = diag(M.alpha(:,1)) * ones(size(cos_theta)); % P_0(x) = 1
    for i = 2:size(M.alpha,2)
        if false
            P_i = legendre(i-1, cos_theta);
            P_i = squeeze(P_i(1,:,:));
        else % for octave
            P_i = reshape(legendre(i-1, cos_theta(:)'), [i,size_cos_theta]);
            P_i = squeeze(P_i(1,:,:));
        end
        dir_gain = dir_gain + diag(M.alpha(:,i)) * P_i;
    end
    
    % allocate array to hold diffuse-field frequency response
    dfr = zeros(n_freqs, n_Bout);
    
    % allocate array to hold free-field frequency response
    ffr = zeros(n_freqs, n_Bout, numel(ffr_save));
    
    % test frequencies
    if log_freqs
        freqs = logspace(log10(low_freq), log10(high_freq), n_freqs);
    else
        freqs = linspace(low_freq, high_freq, n_freqs);
    end
    
    i = 1;
    for k = freqs * (2*pi)/c % k is wavenumber
        % compute B-format outputs at this frequency
        B = M.a2b * ( dir_gain .* exp( +1j * k * d ) );
        ffr(i,:,:) = B(:,ffr_save);
        
        % compute RMS responses over surface of sphere
        dfr(i,:) = sqrt( sum(B .* conj(B) .* qw, 2) );
        i = i + 1;
    end
    
    if output_file
        dlmwrite(...
            output_file,...
            [freqs', ...   % column 1
            dfr, ...       % columns 2 ... n_Bout
            reshape(abs(ffr), numel(freqs), n_Bout*numel(ffr_save))],...
            'precision', '%16g');
    end
    
    if graph_response
        % Graph it
        % dfr(:,1) is W, dfr(:,2) is X
        createfigure(M, freqs, 20*log10(dfr(:,1:2)));
    end
end

%% Generic tetrahedral array
function M = MIC_ARRAY_Tetra(radius, alpha1)
    % mic_array_tetra return parameters for generic tetra microphone
    %  RADIUS is the acoustic radius of the array, typically 10% larger
    %  than physical radius.
    %  ALPHA1 is the gain of the first-order parameter
    %   0 = omni, 
    %   1/2 = cardioid, 
    %   1 = fig-8
    %   (3-sqrt(3))/2 = supercardioid (~0.63397)
    %   3/4 = hypercardoid
    %
    % The default values for RADIUS and ALPHA1 give the results shown in
    % Gerzon, "The Design of Precisely Coincident Microphone Arrays for
    % Stereo and Surround Sound", 50th AES Convention, London, 1975.
    
    M.name = 'Tetra';
    
    % Soundfield mic is four mics mounted on the faces of a tetrahedron.
    if ~exist('radius', 'var')
        M.r = 1.47 * 1e-2; % meters
    else
        M.r = radius;
    end
    
    % capsule directivities
    %      for first-order mic: omni=[1,0]; cardioid=[0.5,0.5],fig8=[0,1];
    if ~exist('alpha1', 'var')
        alpha1 = 0.5;
    end
    
    M.alpha = [ ...
        1-alpha1 alpha1;
        1-alpha1 alpha1;
        1-alpha1 alpha1;
        1-alpha1 alpha1; ];
    
    
    % capsule orientations, direciton cosines
    M.o = [ ...
        -1  1 -1; % back-left-down .... LBD
        +1  1  1; % front-left-up ..... LFU
        +1 -1 -1; % front-right-down .. RFD
        -1 -1  1; % back-right-up ..... RBU
        ];
    % normalize
    M.o = diag(1./sqrt(diag(M.o * M.o'))) * M.o;
    
    % capsule positions for radial array, in meters
    M.u = M.o * M.r;
    
    % a2b matrix, Batke calls this the mode matrix, \Psi
    M.a2b = [ones(size(M.o,1),1), sign(M.o)]';
end

%% TinySpHEAR prototype #1
function M = MIC_ARRAY_TinySpHEAR()
    % 
    M = MIC_ARRAY_Tetra(0.96e-2, 0.66);
    M.name = 'TinySpHEAR';
end

%% Calrec MkIV
function M = MIC_ARRAY_CalrecMkIV()
    % original Calrec capsules 10.5 dB f/b ratio
    M = MIC_ARRAY_Tetra(1.47e-2, 0.35073087);
    M.name = 'Calrec_MkIV';
end

%% Soundfield MkV
function M = MIC_ARRAY_SFRMkV()
    % new capsules used by Sounfield Research, 9.5 dB f/b ratio
    M = MIC_ARRAY_Tetra(1.47e-2, 0.33251727);
    M.name = 'Soundfield_Research_MkV';
end

%% Danish Pro Audio DPA-4
function M = MIC_ARRAY_DPA()
    % DPA-4 array
    M = MIC_ARRAY_Tetra(2.5e-2, 0.5);
    M.name = 'DPA-4';
    
    % DPA uses different A format order and alternate tetrahedral config
    % M.a2b = ???????  (get data from Eric, fill in here )
end

%% Umashankar's Velan
function M = MIC_ARRAY_Velan()
 
    M.name = 'Velan';
    
    % Umashankar's Velan is four TSB-140 cardioids with pairs pointed along
    % axis with separation 14.3 mm.  See
    %    http://www.shapeways.com/model/143678/velan-140-internals.html
    %    http://www.firstpr.com.au/rwi/mics/2009-09-a/2011052109473129207TSB-140A25-GP.jpg
    % TSB-140 is 14mm diameter x 6.3mm depth.  I assume the rings are 1 mm
    % thick.  Acoustic radius is typically 20% larger than physical.
    M.r = 1.2*(14+2+2*6.3)/2 * 1e-3; % meters
    
    % capsule directivities
    %      for first-order mic: omni=[1,0]; cardioid=[0.5,0.5],fig8=[0,1];
    M.alpha = [ ...
        0.5 0.5;
        0.5 0.5;
        0.5 0.5;
        0.5 0.5;
        0.5 0.5;
        0.5 0.5 ];
    
    % capsule orientations, direciton cosines
    % a row for each capsule, columns are x,y,z
    M.o = [ ...
        1  0  0;
       -1  0  0;
        0  1  0;
        0 -1  0;
        0  0  1;
        0  0 -1];
    
    if false
        % specify in spherical (az, el, r), like this
        M.o = [...
              0,  0, 1;
            180,  0, 1;
             90,  0, 1;
            -90,  0, 1;
              0, 90, 1;
              0,-90, 1 ];
        % convert to radians
        M.o(:,1:2) = M.o(:,1:2)*pi/180;
        % convert to cartesian
        [M.o(:,1), M.o(:,2), M.o(:,3)] = ...
            sph2cart(M.o(:,1),M.o(:,2),M.o(:,3));
    end
    
    % capsule positions for radial array, in meters
    M.u = M.o .* M.r;
    
    % a2b matrix, Batke calls this the mode matrix, \Psi
    % a column for each capsule, a row for each array output
    M.a2b = [ ...
        0.2357    0.2357    0.2357    0.2357    0.2357    0.2357;
        1.0000   -1.0000    0.0000    0.0000    0.0000    0.0000;
        0.0000    0.0000    1.0000   -1.0000    0.0000    0.0000;
        0         0         0         0         1.0000   -1.0000];
end

%% Plotting function
function createfigure(M, X1,YMatrix1)
    %  X1:  vector of x data
    %  YMATRIX1:  matrix of y data
    
    %  Auto-generated by MATLAB on 12-Mar-2011 11:02:34
    
    % Create figure
    figure1 = figure();
    
    % Create axes
    axes1 = axes('Parent',figure1,'YGrid','on','XGrid','on',...
        'XMinorTick','on','YMinorTick','on','FontSize',12);
    box(axes1,'on');
    hold(axes1,'all');
    
    % Create multiple lines using matrix input to plot
    plot1 = plot(X1,YMatrix1,'Parent',axes1);
    set(plot1(1),'DisplayName','W');
    set(plot1(2),'DisplayName','XYZ');
    %set(plot1(3),'DisplayName','Y');
    
    % Create title
    name_sanitized = strrep(M.name, '_', '\_');
    if false
        title(sprintf(...
            ['Diffuse Field Response of simulated %s Mic Array' ...
            '\n(r=%0.3fcm, \\alpha=%0.3f)'], ...
            name_sanitized, M.r*100, M.alpha),...
            'FontWeight','bold',...
            'FontSize',12);
    else
        title(sprintf(...
            'Diffuse Field Response of simulated %s Mic Array', ...
            name_sanitized), ...
            'FontWeight','bold',...
            'FontSize',12);
    end
    
    % Create xlabel
    xlabel('Frequency (Hz x 10^4)', 'FontAngle', 'italic');
    % Create ylabel
    ylabel('Relative Response (dB)', 'FontAngle', 'italic');
    % Create legend
    legend1 = legend(axes1,'show');
    set(legend1,'Location','SouthWest');
end
%% EMB's Octathingy
function M = MIC_ARRAY_Octathingy(radius, alpha1)
    % mic_array_octathingy return parameters for generic tetra microphone
    %  RADIUS is the acoustic radius of the array, typically 10% larger
    %  than physical radius.
    %  ALPHA1 is the gain of the first-order parameter
    %   0 = omni, 
    %   1/2 = cardioid, 
    %   1 = fig-8
    %   (3-sqrt(3))/2 = supercardioid (~0.63397)
    %   3/4 = hypercardoid
    %
    
    M.name = 'Octathingy';
    
    % The octathingy is an octahedron (capsules at the vertices of a cube),
    % with the top rotated 45deg, so it can do 2nd-order horizontal,
    % 1st-order vertical.
    
    if ~exist('radius', 'var')
        M.r = 1.47 * 1e-2; % meters
    else
        M.r = radius;
    end
    
    % capsule directivities
    %      for first-order mic: omni=[1,0]; cardioid=[0.5,0.5],fig8=[0,1];
    if ~exist('alpha1', 'var')
        alpha1 = 0.5;
    end
    
    M.alpha = [ ...
        1-alpha1 alpha1;
        1-alpha1 alpha1;
        1-alpha1 alpha1;
        1-alpha1 alpha1;
        1-alpha1 alpha1;
        1-alpha1 alpha1;
        1-alpha1 alpha1;
        1-alpha1 alpha1 ];
    
    
    % capsule orientations, direciton cosines
    M.o = [ ...
        % bottom ring
        -1  1 -1; % back-left-down .... LBD
         1  1 -1; % front-left-down
        +1 -1 -1; % front-right-down .. RFD
        -1 -1 -1; % back-right-down
        
         0  1  1; % left-up
        +1  0  1; % front-up
         0 -1  1; % right-up
        -1  0  1; % back-up
        ];
    % normalize
    M.o = diag(1./sqrt(diag(M.o * M.o'))) * M.o;
    
    % capsule positions for radial array, in meters
    M.u = M.o * M.r;
    
    % a2b matrix, Batke calls this the mode matrix, \Psi
    M.a2b = [ones(size(M.o,1),1), sign(M.o)]';
end

