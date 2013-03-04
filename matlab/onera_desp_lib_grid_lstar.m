function [Lstar,traces] = onera_desp_lib_grid_lstar(kext,options,sysaxes,matlabd,x1,x2,x3,maginput,varargin)
% [Lstar,traces] = onera_desp_lib_grid_lstar(kext,options,sysaxes,matlabd,x1,x2,x3,maginput,...)
% compute Lstar on a grid
% kext, options, sysaxes, matlabd, and maginput are as required by onera_desp_lib_trace_field_line
% x1, x2, x3 are [N1,N2] matrices of launch points
%  coordinate N1 is a radial or latitude dimension
%  coordinate N2 is a periodic dimension like MLT or longitude
% ***Pption Bm, a0, or K is required
% keyword options:
% 'G' - set Bunit to G (default Bunit is nT)
% 'Phi' - return Phi in nT-RE^2 rather than Lstar
% param/value options:
% 'Bm' - grid of Bmirror values in Bunit [N3x1]
% 'a0' - grid of equatorial pitch angles in degrees [N3x1] (much slower)
% 'K' - grid of K values in RE-sqrt(Bunit) [N3x1]
% 'k0' - magnetic moment for Lstar = 2*pi*k0/Phi, Bunit-RE^3
%   default is 0.301153e5 nT-RE^3 for epoch 2000.0
% 'R0' - minimum tracing radius, RE, passed on to
%   onera_desp_lib_trace_field_line
% 'NptsI' - number of points for I integral (default 1000)
% 'dlat' - latitude spacing for Phi integral (degrees, default 0.1)
% 'verbose' - verbose setting for diagnostic/status output
%   (default is 0, set to 1 for about 1 report per second. 
%    higher integers have more reports)
% 'maxLm' - stop tracing in dimension 1 if |Lm| exceeds maxLm
%   set maxLm negative to trace from N1 down to 1
%
% output:
% Lstar - L* [N1 x N2 x N3], in RE. NaN on open/shabansky orbits
% traces - cell array [N1 x N2] of structures containing trace information
%             Nt: is number of points in field line trace
%             Lm: McIlwain's L, RE
%         Blocal: [Ntx1] local field strength, Bunit
%           Bmin: minimum field strength on field line, Bunit
%              J: I for particle mirroring at launch point x1(i1,i2), x2(i1,i2), x3(i1,i2), RE
%            GEO: [Nx3] field points in GEO
%            RLL: [Ntx3] geographic radius, lat, lon (RE, deg, deg)
%     NorthPoint: [lat, lon] geographic location of R=1 in northern foot point, (deg)
%          nmins: 1
%          imins: [nmins x 1] index of minima
%          Bmins: [nmins x 1] B at minima, Bunit
%          imaxs: [nmaxs x 1] index of maxima
%          Bmaxs: [nmaxs x 1] B at maxima, Bunit
%             Bm: [N3x1] Bmirror, Bunit
%      alpha0deg: [N3x1] equatorial pitch angle, deg
%     alpha0rads: [N3x1] equatorial pitch angle, radians
%              I: [N3x1] I, RE
%              K: [N3x1] K, RE*sqrt(Bunit)
%              Phi: [N3x1] Phi, RE^2*Bunit
%              Lstar: [N3x1] Lstar, RE
%              foot_points: [N3x1] cell array of [N2x2] lat,lon (deg) of northern foot points of drift shell
%
% call with no inputs to run test

if nargin == 0, % test
    [Lstar,traces] = test;
    return;
end

nT = 1; % assume nT
k0 = nan;
Bm_option = '';
output_option = 'Lstar';
R0 = 1.0;
NptsI = 1000; % number of points for I integral
dlat = 0.1; % latitude spacing for Phi integrals
verbose = 0;
maxLm = inf;

i = 1;
while i <= length(varargin),
    switch(lower(varargin{i})),
        case 'maxlm',
            i = i+1;
            maxLm = varargin{i};
        case 'r0',
            i = i+1;
            R0 = varargin{i};
        case 'k0',
            i = i+1;
            k0 = varargin{i};
        case 'bm',
            Bm_option = 'Bm';
            i = i+1;
            z = varargin{i};
        case 'k',
            Bm_option = 'K';
            i = i+1;
            z = varargin{i};
        case {'a0','alpha0','alpha0deg','a0deg'},
            Bm_option = 'a0';
            i = i+1;
            z = varargin{i};
        case 'phi',
            output_option = 'Phi';
        case 'g',
            nT = 1e-5; % multiply nT by this to get Gauss
        case 'nptsi',
            i = i+1;
            NptsI = varargin{i};
        case 'verbose',
            i = i+1;
            verbose = varargin{i};
        otherwise
            error('Unknown option %s',varargin{i});
    end
    i = i+1;
end
if isempty(Bm_option),
    error('Option a0 or Bm is required');
end

z = z(:); % column vector

if ~isfinite(k0),
    k0 = 0.301153e5*nT; % k0 in nT-RE^3 for 2000.0
end

maginput = onera_desp_lib_maginputs(maginput);
[N1,N2] = size(x1);
N3 = length(z);
if verbose,
    fprintf('grid size is [%d,%d,%d]\n',N1,N2,N3);
end

if maxLm<0,
    I1 = N1:-1:1; % trace from high to low in dim 1
else
    I1 = 1:N1;
end

traces = cell([N1,N2]);
Phi = nan([N1,N2,N3]);

last_t = now;
for i2 = 1:N2,
    for i1 = I1,
        clear trace
        if verbose >= 2,
            fprintf('Tracing (%d,%d) = (%g,%g,%g)\n',i1,i2,x1(i1,i2),x2(i1,i2),x3(i1,i2));
        end
        [trace.Lm,trace.Blocal,trace.Bmin,trace.J,trace.GEO] = onera_desp_lib_trace_field_line(kext,options,sysaxes,matlabd,x1(i1,i2),x2(i1,i2),x3(i1,i2),maginput,R0);
        if isempty(trace.Blocal),
            break;
        end
        if (abs(trace.Lm)>abs(maxLm)),
            break;
        end
        trace.Nt = length(trace.Blocal);
        % convert nT to Bunit
        trace.Blocal = trace.Blocal*nT;
        trace.Bmin = trace.Bmin*nT;
        % check for Shabansky
        dir = -1; % B decreasing
        imins = [];
        imaxs = [];
        for i = 2:length(trace.Blocal),
            newdir = sign(trace.Blocal(i)-trace.Blocal(i-1));
            if newdir == 0,
                newdir = dir;
            end
            
            if newdir ~= dir,
                if (dir == +1) && (newdir == -1),
                    % change from increasing to decreasing
                    imaxs(end+1) = i-1;
                elseif (dir == -1) && (newdir == +1),
                    % change from decreasing to increasing
                    imins(end+1) = i-1;
                end
                dir = newdir;
            end
        end
        trace.imins = imins;
        trace.imaxs = imaxs;
        trace.Bmins = trace.Blocal(imins);
        trace.Bmaxs = trace.Blocal(imaxs);
        trace.nmins = length(imins);
        Bm = unique(trace.Blocal); % try all Blocal as Bm
        Bm = Bm(Bm <= min(trace.Blocal([1,end]))); % remove Bm in bounce loss cone
        
        if trace.nmins > 1, % at least two local minima
            Bm = Bm(Bm>max(trace.Bmaxs)); % omit points in local magnetic bottle
        end
        
        I = nan(size(Bm)); % allocate space for I
        ds = sqrt(sum(diff(trace.GEO,1,1).^2,2)); % step
        s = [0;cumsum(ds)]; % distance along field line
        for i = 1:length(Bm),
            if Bm(i) <= trace.Bmin, % equatorial case
                I(i) = 0;
            else
                bm = Bm(i); % Bmirror
                s1 = interp1(trace.Blocal(1:imins(1)),s(1:imins(1)),bm,'linear'); % one mirror point
                s2 = interp1(trace.Blocal(imins(1):end),s(imins(1):end),bm,'linear'); % other mirror point
                if s1==s2,
                    I(i) = 0;
                else
                    si = linspace(s1,s2,NptsI); % grid in s betwen mirror points
                    bi = interp1(s,trace.Blocal,si,'linear');
                    assert(all(bi./bm<=1.001)); % allow only a little fudge for numerics
                    I(i) = trapz(si,sqrt(1-min(bi./bm,1))); % integrate
                end
            end
        end
        K = I.*sqrt(Bm); % RE*sqrt(Bunit)
        switch(Bm_option),
            case 'Bm',
                trace.Bm = z;
                trace.alpha0deg = asind(sqrt(trace.Bmin./trace.Bm));
                trace.I = interp1(Bm,I,z,'linear');
                trace.K = trace.I.*sqrt(trace.Bm);
            case 'a0',
                trace.alpha0deg = z;
                trace.Bm = trace.Bmin./sind(trace.alpha0deg).^2;
                trace.I = interp1(Bm,I,trace.Bm,'linear');
                trace.I(trace.alpha0deg==90) = 0; % equatorial case
                trace.K = trace.I.*sqrt(trace.Bm);
            case 'K',
                trace.K = z;
                trace.Bm = interp1(K,Bm,trace.K,'linear');
                trace.I = trace.K./sqrt(trace.Bm);
                trace.alpha0deg = asind(sqrt(trace.Bmin./Bm));
            otherwise,
                error('Unknown Bm_option %s',Bm_option);
        end
        trace.alpha0rads = trace.alpha0deg*pi/180;
        trace.RLL = onera_desp_lib_coord_trans(trace.GEO,'GEO2RLL',matlabd);
        % find NorthPoint geographic LAT,LON in deg of northern crossing of
        % R=1
        fNorth = find(trace.RLL(:,2)>=median(trace.RLL(:,2)));
        [Rmin,imin] = min(trace.RLL(fNorth,1));
        [Rmax,imax] = max(trace.RLL(fNorth,1));
        if Rmin>1,
            trace.NorthPoint = trace.RLL(fNorth(imin),2:3); % project along radius to R=1
        elseif Rmax<1,
            trace.NorthPoint = trace.RLL(fNorth(imax),2:3); % project along radius to R=1
        else
            trace.NorthPoint = interp1(trace.RLL(fNorth,1),trace.RLL(fNorth,2:3),1.0,'linear'); % interpolate to R=1
        end
        if (verbose>=1) && (now-last_t>1/24/60/60),
            fprintf('Traced [%d,%d], Lm=%g\n',i1,i2,trace.Lm);
            last_t = now;
        end
        traces{i1,i2} = trace;
    end
end

switch(Bm_option),
    case 'Bm', % contours of constant I on grid in Bm with I(i1,i2,Bm)
        [Phi,traces] = Phi_at_fixed_i3(kext,options,matlabd,maginput,dlat,traces,'I',verbose,nT,k0);
    case 'a0', % contours of constant I at fixed Bm but with I(i1,i2,a0)
        [Phi,traces] = Phi_at_fixed_a0(kext,options,matlabd,maginput,dlat,traces,verbose,nT,k0);
    case 'K', % contours of constant Bm at fixed K with Bm(i1,i2,K)
        [Phi,traces] = Phi_at_fixed_i3(kext,options,matlabd,maginput,dlat,traces,'Bm',verbose,nT,k0);
    otherwise,
        error('Unknown Bm_option %s',Bm_option);
end

switch(output_option),
    case 'Phi',
        Lstar = Phi;
    case 'Lstar',
        Lstar = 2*pi*k0./Phi;
        for i = 1:numel(traces),
            if ~isempty(traces{i}),
                traces{i}.Lstar = 2*pi*k0./traces{i}.Phi;
            end
        end
    otherwise
        error('Unknown output option %s',output_option);
end

function Phi = computePhi(kext,options,matlabd,lat,lon,maginput,dlat)
% compute northern poalr cap Phi integral inside trajectory lat,lon with
% latitude spacing dlat

% we'll precompute the latitude line integral on a grid
persistent settings grid
newsettings = {kext,options,matlabd,maginput,dlat}; % can we re-use the grid?
if ~isequal(settings,newsettings),
    settings = newsettings;
    grid.lat = linspace(-20,90,ceil((90--20)/dlat));
    grid.NLAT = length(grid.lat);
    grid.lon = linspace(0,360,2*length(lon)); % overkill longitude spacing, just in case
    grid.NLON = length(grid.lon);
    [grid.LAT,grid.LON] = meshgrid(grid.lat,grid.lon);
    grid.N = numel(grid.LAT);
    [Bgeo,B] = onera_desp_lib_get_field(kext,options,'RLL',repmat(matlabd,grid.N,1),ones(grid.N,1),grid.LAT(:),grid.LON(:),repmat(maginput,grid.N,1));
    rhat = [cosd(grid.LAT(:)).*cosd(grid.LON(:)), cosd(grid.LAT(:)).*sind(grid.LON(:)), sind(grid.LAT(:))];
    Bdotr = reshape(sum(rhat.*Bgeo,2),size(grid.LAT));
    grid.partialPhi = cumtrapz(sind(grid.lat),Bdotr,2);
    grid.partialPhi = grid.partialPhi-repmat(grid.partialPhi(:,end),1,grid.NLAT); % includes minus sign for northern hemi
    % grid.partialPhi(ilon,ilat) is the line integral from
    % [grid.lat(ilat),grid.lon(ilon)] to [90,grid.lon(ilon)] of {B dot rhat dsin(LAT)}
end

% prepare for lon integral
dlon = [lon(2)-lon(end);lon(3:end)-lon(1:(end-2));lon(1)-lon(end-1)]; % centered longitude spacing, with wrap
dlon = rem(2*360+180+dlon,360)-180; % deal with mod 360
dlon = dlon/2; % dlon is half of distance between neighbors i+1 and i-1
dlon = pi/180*dlon; % convert to radians
lon = rem(lon+360*2,360); % force onto 0,360 interval
% interpolate partialPhi (lat line integral) onto lat/lon's
partialPhi = interp2(grid.LAT,grid.LON,grid.partialPhi,lat,lon,'linear');
% perform longitude integral
Phi = dlon'*partialPhi; % northern hemisphere integral is negative B.r<0

function [Phi,traces] = Phi_at_fixed_i3(kext,options,matlabd,maginput,dlat,traces,yvar,verbose,nT,k0)
% yvar is Bm for traces at fixed K, yvar is I for traces at fixed Bm
last_t = now;
[N1,N2] = size(traces);
% northern foot points at R=1
LAT = nan([N1,N2]); % geographic latitude, degrees
LON = nan([N1,N2]); % geographic longitude, degrees
% I vs i1, i2, z
y = [];
for i1 = 1:N1,
    for i2 = 1:N2,
        if ~isempty(traces{i1,i2}),
            if isempty(y),
                N3 = length(traces{i1,i2}.(yvar));
                y = nan([N1,N2,N3]);
            end
            traces{i1,i2}.Phi = nan(N3,1);
            traces{i1,i2}.foot_points = cell(N3,1);
            y(i1,i2,:) = traces{i1,i2}.(yvar);
            LAT(i1,i2) = traces{i1,i2}.NorthPoint(1);
            LON(i1,i2) = traces{i1,i2}.NorthPoint(2);
        end
    end
end
Phi = nan([N1,N2,N3]);

% make contours
for i1 = 1:N1,
    for i2 = 1:N2,
        for i3 = 1:N3,
            y0 = y(i1,i2,i3);
            if ~isfinite(y0),
                continue; % cannot do this launch point
            end
            % trajectory points
            lat = nan(N2,1);
            lon = nan(N2,1);
            % starting point
            j2 = i2;
            lat(1) = LAT(i1,i2);
            lon(1) = LON(i1,i2);
            failed = false;
            for i = 2:N2,
                j2 = 1+rem(j2,N2);
                f = isfinite(y(:,j2,i3));
                if sum(f)>=2,
                    lat(i) = interp1(y(f,j2,i3),LAT(f,j2),y0,'linear');
                end
                if ~isfinite(lat(i)),
                    failed = true;
                    break
                end
                DLON = rem(2*360+180+LON(:,j2)-lon(i-1),360)-180;
                dlon = interp1(y(f,j2,i3),DLON(f),y0,'linear');
                lon(i) = rem(2*360+lon(i-1) + dlon,360);
                if ~isfinite(lon(i)),
                    failed = true;
                    break;
                end
            end
            if ~failed,
                traces{i1,i2}.foot_points{i3} = [lat,lon];
                traces{i1,i2}.Phi(i3) = computePhi(kext,options,matlabd,lat,lon,maginput,dlat)*nT;
                Phi(i1,i2,i3) = traces{i1,i2}.Phi(i3);
                if (verbose>=1) && (now-last_t>1/24/60/60),
                    fprintf('Phi(%d,%d,%d) = %g (Lstar = %g)\n',i1,i2,i3,Phi(i1,i2,i3),2*pi*k0/Phi(i1,i2,i3));
                    last_t = now;
                end
            end
        end
    end
end


function [Phi,traces] = Phi_at_fixed_a0(kext,options,matlabd,maginput,dlat,traces,verbose,nT,k0)
last_t = now;
[N1,N2] = size(traces);
% northern foot points at R=1
LAT = nan([N1,N2]); % geographic latitude, degrees
LON = nan([N1,N2]); % geographic longitude, degrees
% I,Bm vs i1, i2, z
I = [];
Bm = [];
for i1 = 1:N1,
    for i2 = 1:N2,
        if ~isempty(traces{i1,i2}),
            if isempty(I),
                N3 = length(traces{i1,i2}.alpha0deg);
                I = nan([N1,N2,N3]);
                Bm = nan([N1,N2,N3]);
            end
            traces{i1,i2}.Phi = nan(N3,1);
            traces{i1,i2}.foot_points = cell(N3,1);
            I(i1,i2,:) = traces{i1,i2}.I;
            Bm(i1,i2,:) = traces{i1,i2}.Bm;
            LAT(i1,i2) = traces{i1,i2}.NorthPoint(1);
            LON(i1,i2) = traces{i1,i2}.NorthPoint(2);
        end
    end
end

% now we have
% I(LAT,LON,a0)
% Bm(LAT,LON,a0)

Phi = nan([N1,N2,N3]);
% make contours
for i1 = 1:N1,
    for i2 = 1:N2,
        for i3 = 1:N3,
            I0 = I(i1,i2,i3);
            Bm0 = Bm(i1,i2,i3);
            if ~isfinite(I0) || ~isfinite(Bm0),
                continue; % cannot do this launch point
            end
            % trajectory points
            lat = nan(N2,1);
            lon = nan(N2,1);
            % starting point
            j2 = i2;
            lat(1) = LAT(i1,i2);
            lon(1) = LON(i1,i2);
            failed = false;
            for i = 2:N2,
                j2 = 1+rem(j2,N2);
                tmpBm = nan(N1,1); % Bm at I = I0 vs x1
                for j1 = 1:N1,
                    f = isfinite(I(j1,j2,:));
                    if sum(f)>=2,
                        tmpBm(j1) = interp1(squeeze(I(j1,j2,f)),squeeze(Bm(j1,j2,f)),I0,'linear');
                    end
                end
                f = isfinite(tmpBm);
                if sum(f)>=2,
                    lat(i) = interp1(tmpBm(f),LAT(f,j2),Bm0,'linear');
                end
                if ~isfinite(lat(i)),
                    failed = true;
                    break;
                end
                DLON = rem(2*360+180+LON(:,j2)-lon(i-1),360)-180;
                dlon = interp1(tmpBm(f),DLON(f),Bm0,'linear');
                lon(i) = rem(2*360+lon(i-1) + dlon,360);
                if ~isfinite(lon(i)),
                    failed = true;
                    break;
                end
            end
            
            if ~failed,
                traces{i1,i2}.foot_points{i3} = [lat,lon];
                traces{i1,i2}.Phi(i3) = computePhi(kext,options,matlabd,lat,lon,maginput,dlat)*nT;
                Phi(i1,i2,i3) = traces{i1,i2}.Phi(i3);
                if (verbose>=1) && (now-last_t>1/24/60/60),
                    fprintf('Phi(%d,%d,%d) = %g (Lstar = %g)\n',i1,i2,i3,Phi(i1,i2,i3),2*pi*k0/Phi(i1,i2,i3));
                    last_t = now;
                end
            end
        end % for i3 -> N3
    end % for i2 -> N2
end % for i1 -> N1

function [Lstar,traces] = test
[LAT,LON] = ndgrid(35:2:80,0:15:359);
%[LAT,LON] = ndgrid(40:4:80,0:30:359);
kext = 'T89';
maginput = onera_desp_lib_maginputs(2); % Kp=2
R = ones(size(LAT));
options = {};
args = {kext,options,'RLL',datenum(2010,1,1),R,LAT,LON,maginput,'verbose',inf};

a0 = [10:10:90]; % deg
[Lstar,traces] = onera_desp_lib_grid_lstar(args{:},'a0',a0);
for i = length(a0):-2:1,
    figure;
    contourf(LON,LAT,Lstar(:,:,i),2:10);
    axis([0 360 0 90]);
    xlabel('Longitude, ^o East');
    ylabel('Latitude, ^o North');
    title(sprintf('T89, Kp=2, a0=%g',a0(i)));
    cb = colorbar('vert');
    ylabel(cb,'L*');
end

K = [0;0.1;0.3;1.0]; % sqrt(G)*RE
[Lstar,traces] = onera_desp_lib_grid_lstar(args{:},'K',K,'G');
for i = 1:length(K),
    figure;
    contourf(LON,LAT,Lstar(:,:,i),2:10);
    axis([0 360 0 90]);
    xlabel('Longitude, ^o East');
    ylabel('Latitude, ^o North');
    title(sprintf('T89, Kp=2, K=%g',K(i)));
    cb = colorbar('vert');
    ylabel(cb,'L*');
end

Bm = [0.3e3;1e3;3e3;10e3;30e3]; % nT
[Lstar,traces] = onera_desp_lib_grid_lstar(args{:},'Bm',Bm);
for i = 1:length(Bm),
    figure;
    contourf(LON,LAT,Lstar(:,:,i),2:10);
    axis([0 360 0 90]);
    xlabel('Longitude, ^o East');
    ylabel('Latitude, ^o North');
    title(sprintf('T89, Kp=2, Bm=%g',Bm(i)));
    cb = colorbar('vert');
    ylabel(cb,'L*');
end

