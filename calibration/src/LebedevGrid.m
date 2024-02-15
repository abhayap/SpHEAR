function [ a ] = LebedevGrid( order )
    %LebedevGrid Lebedev points and weights for spherical harmonic order
    %   Detailed explanation goes here
    
    degree = [6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, 230, 266, ...
        302, 350, 434, 590, 770, 974, 1202, 1454, 1730, 2030, 2354, ...
        2702, 3074, 3470, 3890, 4334, 4802, 5294, 5810];
    
    a = getLebedevSphere(degree(order));
    [ a.theta a.phi ] = cart2sph(a.x, a.y, a.z);

end

