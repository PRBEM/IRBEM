pro compare_output, expect, calc, prefix,fmt
	e = STRCOMPRESS(STRING(expect,format=fmt),/REMOVE_ALL)
	c = STRCOMPRESS(STRING(calc,format=fmt),/REMOVE_ALL)
	myError=abs(calc/expect-1.)*100.
;	if e eq c then correct='Ok' else correct='*** discrepancy ***'
;	print,prefix,c,'         | ',e,'      | ',correct
	if myError le 0.001 then correct='Ok' else correct='*** discrepancy ***'
	print,prefix,c,'         | ',e,'      | ',myError,'% -> ',correct
return
end

; setup lib path and name
; write default to variables if not provided.
case !version.os of
    'linux':ext='so'
    'sunos':ext='so'
    'Win32':ext='dll'
    'darwin':ext='dylib'
endcase
lib_name='../onera_desp_lib_'+!version.OS+'_'+$
   !version.ARCH+'.'+ext

res=file_search(lib_name,count=count)
if count eq 0 then begin
   print,''
   print,'Library not installed in default directory or not already built !'
   print,''
   lib_path=''
   read,lib_path,prompt='Please provide the full path where the library has been installed : '
   print,lib_path
   lib_name=lib_path+'/onera_desp_lib_'+!version.OS+'_'+$
   !version.ARCH+'.'+ext
endif 

n = 0L
result = call_external(lib_name, 'irbem_fortran_version_', n)
print,''
print,'Repository version: ', n
v = BYTARR(80)
result = call_external(lib_name, 'irbem_fortran_release_', v)
print,''
print,'Release version: ', STRTRIM(STRING(v))
ntime_max = -1L
result = call_external(lib_name, 'get_irbem_ntime_max_', ntime_max)
print,''
print,'NTIME_MAX=', ntime_max

print,''
print,'Testing make_lstar ...'
ntime=1l
kext=5l
options=lonarr(5)
options(0)=1l
options(1)=0l
sysaxes=2l

iyear=lonarr(ntime_max)
iyear(0)=1998l
idoy=lonarr(ntime_max)
idoy(0)=100l
UT=dblarr(ntime_max)
UT(0)=3600.d0

x1=dblarr(ntime_max)
x1(0)=7.d0
x2=dblarr(ntime_max)
x2(0)=0.d0
x3=dblarr(ntime_max)
x3(0)=0.d0

maginput=dblarr(25,ntime_max)
Lm=dblarr(ntime_max)
Lstar=dblarr(ntime_max)
Blocal=dblarr(ntime_max)
Bmin=dblarr(ntime_max)
XJ=dblarr(ntime_max)
MLT=dblarr(ntime_max)


result = call_external(lib_name, 'make_lstar_',$
ntime,kext,options,sysaxes,iyear,idoy,ut, x1,x2,x3,$
maginput,lm,lstar,blocal,bmin,xj,mlt, /f_value)

print,'         Your distribution | Expected value |  Error(%) -> Diagnostic'
compare_output,6.6154250D0,Lm(0),    'Lm =     ','(f9.7)'
compare_output,5.9544700D0,Lstar(0), 'L* =     ','(f9.7)'
compare_output,104.52422D0,Blocal(0),'Blocal = ','(f9.5)'
compare_output,104.17935D0,Bmin(0),  'Bmin =   ','(f9.5)'

print,''
print,'Testing make_lstar_shell_splitting ...'
ntime=1l
npa=6l
kext=5l
options=lonarr(5)
options(0)=1l
options(1)=0l
sysaxes=2l

iyear=lonarr(ntime_max)
iyear(0)=1998l
idoy=lonarr(ntime_max)
idoy(0)=100l
UT=dblarr(ntime_max)
UT(0)=3600.d0

x1=dblarr(ntime_max)
x1(0)=7.d0
x2=dblarr(ntime_max)
x2(0)=0.d0
x3=dblarr(ntime_max)
x3(0)=0.d0

alpha=dblarr(25)
alpha(0)=5.d0
alpha(1)=20.d0
alpha(2)=40.d0
alpha(3)=60.d0
alpha(4)=80.d0
alpha(5)=90.d0

maginput=dblarr(25,ntime_max)

Lm=dblarr(ntime_max,25)
Lstar=dblarr(ntime_max,25)
Blocal=dblarr(ntime_max,25)
Bmin=dblarr(ntime_max)
XJ=dblarr(ntime_max,25)
MLT=dblarr(ntime_max)

result = call_external(lib_name, 'make_lstar_shell_splitting_',$
ntime,Npa,kext,options,sysaxes,iyear,idoy,ut, x1,x2,x3,alpha,$
maginput,lm,lstar,blocal,bmin,xj,mlt, /f_value)

expectLstar=[6.4019230d0,6.3878798d0,6.2932170d0,6.1326451d0,5.9692525d0,5.9544700d0]
expectBloc=[13757.979d0,893.43930d0,252.96913d0,139.36545d0,107.77378d0,104.52422d0]
print,'         Your distribution | Expected value |  Error(%) -> Diagnostic'
for i=0,5 do compare_output,expectLstar(i), lstar(0,i),'L* =     ','(f9.7)'
for i=0,5 do begin
   if expectBloc(i) LT 1000.D0 then compare_output,expectBloc(i), blocal(0,i),'blocal = ','(f9.5)'
   if expectBloc(i) LT 10000.D0 and expectBloc(i) GE 1000.D0 then compare_output,expectBloc(i), blocal(0,i),'blocal = ','(f9.4)'
   if expectBloc(i) LT 100000.D0 and expectBloc(i) GE 10000.D0 then compare_output,expectBloc(i), blocal(0,i),'blocal = ','(f9.3)'
endfor

print,''
print,'Testing get_field ...'
iyear=1998l
idoy=100l
UT=3600.d0

x1=7.d0
x2=0.d0
x3=0.d0
maginput=dblarr(25)
Bgeo=dblarr(3)
Bl=0.d0
result = call_external(lib_name, 'get_field_', kext,options,sysaxes,iyear,idoy,ut, $
x1,x2,x3, maginput,Bgeo, Bl,  /f_value)
print,'         Your distribution | Expected value |  Error(%) -> Diagnostic'
compare_output,104.52422D0, bl,'blocal = ','(f9.5)'

print,''
print,'Testing fly_in_ige ...'
launch_year=1998l
mission_duration=11l
whichm=3l
whatf=1l
Nene=0l
energy=dblarr(2,50)

Lower_flux=dblarr(50)
Mean_flux=dblarr(50)
Upper_flux=dblarr(50)
expected_ige_energy=[$
0.0009171d+0,$ 
0.0012040d+0,$
0.0015720d+0,$
0.0020510d+0,$
0.0026680d+0,$
0.0034680d+0,$
0.0045300d+0,$
0.0058990d+0,$
0.0077310d+0,$
0.0101500d+0,$
0.0132800d+0,$
0.0173500d+0,$
0.0300000d+0,$
0.0612400d+0,$
0.0887400d+0,$
0.1255000d+0,$
0.1837100d+0,$
0.2662200d+0,$
0.3968600d+0,$
0.6123700d+0,$
0.9083000d+0,$
1.2845200d+0,$
1.9899700d+0,$
2.4372100d+0,$
3.0740800d+0,$
3.9686200d+0,$
5.1961500d+0]

expected_ige_flux=[$
1.08273d+10,$ 
9.26455d+09,$ 
8.01455d+09,$ 
6.81091d+09,$ 
5.80000d+09,$ 
4.92636d+09,$ 
3.99364d+09,$ 
3.10000d+09,$ 
2.26727d+09,$ 
1.54636d+09,$ 
9.82909d+08,$ 
5.86364d+08,$ 
2.01818d+08,$ 
7.10818d+07,$ 
2.83636d+07,$ 
1.01427d+07,$ 
3.91364d+06,$ 
1.43455d+06,$ 
4.69818d+05,$ 
1.00955d+05,$ 
2.78727d+04,$ 
8.48091d+03,$ 
1.33827d+03,$ 
5.05273d+02,$ 
1.55673d+02,$ 
3.10218d+01,$ 
5.09273d+00]


result = call_external(lib_name, 'fly_in_ige_', launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux,/f_value)
print,'         Your distribution | Expected value |  Error(%) -> Diagnostic'

for i=0,Nene-1 do begin
   compare_output,expected_ige_energy(i), Energy(0,i),'Energy = ','(f9.7)'
endfor
for i=0,Nene-1 do begin
   compare_output,expected_ige_flux(i), Mean_flux(i),'Flux = ','(e12.5)'
endfor


print,''
print,'Testing fly_in_meo_gnss ...'
launch_year=1998l
mission_duration=11l
whichm=2l
whatf=3l
Nene=0l
energy=dblarr(2,50)

Lower_flux=dblarr(50)
Mean_flux=dblarr(50)
Upper_flux=dblarr(50)
expected_meo_gnss_energy=[$
0.2800000d+0,$
0.4000000d+0,$
0.5600000d+0,$
0.8000000d+0,$
1.1200000d+0,$
1.6000000d+0,$
2.2400000d+0]

expected_meo_gnss_flux=[$
8.17273d+05,$ 
5.13000d+05,$
2.43545d+05,$
1.00664d+05,$
3.87364d+04,$
1.11864d+04,$
2.90091d+03]

result = call_external(lib_name, 'fly_in_meo_gnss_', launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux,/f_value)
print,'         Your distribution | Expected value |  Error(%) -> Diagnostic'

for i=0,Nene-1 do begin
   compare_output,expected_meo_gnss_energy(i), Energy(0,i),'Energy = ','(f9.7)'
endfor
for i=0,Nene-1 do begin
   compare_output,expected_meo_gnss_flux(i), Mean_flux(i),'Flux = ','(e12.5)'
endfor

end
