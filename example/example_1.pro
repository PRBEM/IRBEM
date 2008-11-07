pro compare_output, expect, calc, prefix,fmt
	e = STRCOMPRESS(STRING(expect,format=fmt),/REMOVE_ALL)
	c = STRCOMPRESS(STRING(calc,format=fmt),/REMOVE_ALL)
	if e eq c then correct='Ok' else correct='*** discrepancy ***'
	print,prefix,c,'         | ',e,'      | ',correct
return
end

; setup lib path and name
; write default to variables if not provided.
case !version.os of
    'linux':ext='so'
    'sunos':ext='so'
    'Win32':ext='dll'
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

print,''
print,'Testing make_lstar ...'
ntime=1l
kext=5l
options=lonarr(5)
options(0)=1l
options(1)=0l
sysaxes=2l

iyear=lonarr(100000)
iyear(0)=1998l
idoy=lonarr(100000)
idoy(0)=100l
UT=dblarr(100000)
UT(0)=3600.d0

x1=dblarr(100000)
x1(0)=7.d0
x2=dblarr(100000)
x2(0)=0.d0
x3=dblarr(100000)
x3(0)=0.d0

maginput=dblarr(25,100000)

Lm=dblarr(100000)
Lstar=dblarr(100000)
Blocal=dblarr(100000)
Bmin=dblarr(100000)
XJ=dblarr(100000)
MLT=dblarr(100000)


result = call_external(lib_name, 'make_lstar_',$
ntime,kext,options,sysaxes,iyear,idoy,ut, x1,x2,x3,$
maginput,lm,lstar,blocal,bmin,xj,mlt, /f_value)

print,'         Your distribution | Expected value |  Diagnostic'
compare_output,6.6159597D0,Lm(0),    'Lm =     ','(f9.7)'
compare_output,5.9074070D0,Lstar(0), 'L* =     ','(f9.7)'
compare_output,104.54581D0,Blocal(0),'Blocal = ','(f9.5)'
compare_output,104.15972D0,Bmin(0),  'Bmin =   ','(f9.5)'

print,''
print,'Testing make_lstar_shell_splitting ...'
ntime=1l
npa=6l
kext=5l
options=lonarr(5)
options(0)=1l
options(1)=0l
sysaxes=2l

iyear=lonarr(100000)
iyear(0)=1998l
idoy=lonarr(100000)
idoy(0)=100l
UT=dblarr(100000)
UT(0)=3600.d0

x1=dblarr(100000)
x1(0)=7.d0
x2=dblarr(100000)
x2(0)=0.d0
x3=dblarr(100000)
x3(0)=0.d0

alpha=dblarr(25)
alpha(0)=5.d0
alpha(1)=20.d0
alpha(2)=40.d0
alpha(3)=60.d0
alpha(4)=80.d0
alpha(5)=90.d0

maginput=dblarr(25,100000)

Lm=dblarr(100000,25)
Lstar=dblarr(100000,25)
Blocal=dblarr(100000,25)
Bmin=dblarr(100000)
XJ=dblarr(100000,25)
MLT=dblarr(100000)

result = call_external(lib_name, 'make_lstar_shell_splitting_',$
ntime,Npa,kext,options,sysaxes,iyear,idoy,ut, x1,x2,x3,alpha,$
maginput,lm,lstar,blocal,bmin,xj,mlt, /f_value)

expectLstar=[6.3440260d0,6.3377330d0,6.2429260d0,6.0852281d0,5.9219087d0,5.9074070d0]
expectBloc=[13739.408d0,892.84257d0,252.97473d0,139.37175d0,107.78491d0,104.54581d0]
print,'         Your distribution | Expected value |  Diagnostic'
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
print,'         Your distribution | Expected value |  Diagnostic'
compare_output,104.54581D0, bl,'blocal = ','(f9.5)'

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
1.031546d10,$ 
8.842727d09,$
7.666364d09,$
6.476364d09,$
5.522727d09,$
4.744546d09,$
3.860909d09,$
3.004546d09,$
2.200909d09,$
1.501818d09,$
9.549091d08,$
5.691818d08,$
1.990000d08,$
7.036364d07,$
2.817273d07,$
1.012818d07,$
3.932727d06,$
1.446364d06,$
4.761818d05,$
1.031091d05,$
2.870909d04,$
8.793636d03,$
1.396545d03,$
5.281818d02,$
1.630454d02,$
3.252273d01,$
5.341818d00]

result = call_external(lib_name, 'fly_in_ige_', launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux,/f_value)
print,'         Your distribution | Expected value |  Diagnostic'

for i=0,Nene-1 do begin
   compare_output,expected_ige_energy(i), Energy(0,i),'Energy = ','(f9.7)'
endfor
for i=0,Nene-1 do begin
   compare_output,expected_ige_flux(i), Mean_flux(i),'Flux = ','(e11.5)'
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
8.300000d05,$ 
5.240000d05,$
2.502730d05,$
1.040270d05,$
4.021820d04,$
1.166450d04,$
3.032730d03]

result = call_external(lib_name, 'fly_in_meo_gnss_', launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux,/f_value)
print,'         Your distribution | Expected value |  Diagnostic'

for i=0,Nene-1 do begin
   compare_output,expected_meo_gnss_energy(i), Energy(0,i),'Energy = ','(f9.7)'
endfor
for i=0,Nene-1 do begin
   compare_output,expected_meo_gnss_flux(i), Mean_flux(i),'Flux = ','(e11.5)'
endfor

end
