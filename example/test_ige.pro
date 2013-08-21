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
    'darwin':ext='dylib'
endcase
lib_name='../onera_desp_lib_'+!version.OS+'_'+$
   !version.ARCH+'.'+ext
lib_name='/v/desp/bourdari/lib/onera_desp_lib_linux_x86.so'

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
print,'Testing fly_in_ige ...'
launch_year=2008l
mission_duration=10l
whichm=1l
whatf=3l
Nene=0l
energy=dblarr(2,50)

;PasE=0.1d0
;Nene=30L
;for i=0,Nene-1 do begin
;   energy(0,i)=(i+1)*PasE
;   print,energy(0,i)
;endfor

PasE=(ALOG(10.)-ALOG(0.01))/(30.-1.)
Nene=30L
for i=0,Nene-1 do begin
   energy(0,i)=0.01*EXP((i)*PasE)
;   print,energy(0,i)
endfor

;nene=11L
;energy(0,0:10)=[0.1000d0, 0.1585d0, 0.2512d0, 0.3981d0, 0.6310d0, 1.0000d0, 1.5849d0,$
;             2.5119d0, 3.9811d0, 6.3096d0, 10.0000d0]


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

print,lib_name

result = call_external(lib_name, 'fly_in_ige_', launch_year,mission_duration,whichm,whatf,Nene,energy,Lower_flux,Mean_flux,Upper_flux,/f_value)
;print,'         Your distribution | Expected value |  Diagnostic'
;for i=0,Nene-1 do begin
;   compare_output,expected_ige_energy(i), Energy(0,i),'Energy = ','(f9.7)'
;endfor
;for i=0,Nene-1 do begin
;   compare_output,expected_ige_flux(i), Mean_flux(i),'Flux = ','(e11.5)'
;endfor
openw,1,'test.dat'
for i=0,50-1 do printf,1,Energy(0,i), Mean_flux(i)
close,1
end
