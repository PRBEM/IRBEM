Public Declare Function juldaydll _
                Lib "C:\Documents and Settings\Hugh Evans\Desktop\Repository\IRBEM-LIB\irbem\Excel\irbem-lib.dll" _
                Alias "julday_" _
                (ByRef iy As Long, ByRef im As Long, ByRef id As Long) As Long

Public Declare Function caldatdll _
                Lib "C:\Documents and Settings\Hugh Evans\Desktop\Repository\IRBEM-LIB\irbem\Excel\irbem-lib.dll" _
                Alias "caldat_" _
                (ByRef jd As Long, ByRef iyear As Long, ByRef imonth As Long, ByRef iday As Long)

Public Declare Function get_gstdll _
                Lib "C:\Documents and Settings\Hugh Evans\Desktop\Repository\IRBEM-LIB\irbem\Excelirbem-lib.dll" _
                Alias "get_gst_" _
                (ByRef iyear As Long, ByRef iday As Long, ByRef UT As Double) As Double

Public Declare Function get_lstarxls _
                Lib "C:\Documents and Settings\Hugh Evans\Desktop\Repository\IRBEM-LIB\irbem\Excel\irbem-lib.dll" _
                Alias "get_lstar_" _
                (ByRef year As Long, ByRef doy As Long, ByRef UT As Double, _
                 ByRef x1 As Double, ByRef X2 As Double, ByRef X3 As Double, _
                 ByRef csys As Long, ByRef kint As Long, ByRef kext As Long, _
                 ByRef what As Long) As Double
                 
Public Declare Function get_nasa_a8xls _
                Lib "C:\Documents and Settings\Hugh Evans\Desktop\Repository\IRBEM-LIB\irbem\Excel\irbem-lib.dll" _
                Alias "get_nasa_a8_" _
                (ByRef sysaxes As Long, ByRef whichm As Long, ByRef whatf As Long, _
                 ByRef energy As Double, _
                 ByRef iyear As Long, ByRef idoy As Long, ByRef UT As Double, _
                 ByRef x1 As Double, ByRef X2 As Double, ByRef X3 As Double _
                ) As Double
Public Declare Function get_nasa_a8_BB0_Lxls _
                Lib "C:\Documents and Settings\Hugh Evans\Desktop\Repository\IRBEM-LIB\irbem\Excel\irbem-lib.dll" _
                Alias "get_nasa_a8_bb0_l_" _
                (ByRef whichm As Long, ByRef whatf As Long, _
                 ByRef energy As Double, _
                 ByRef BB0 As Double, ByRef L As Double _
                ) As Double
                
Public Declare Function get_onera_meo_gnssxls _
                Lib "C:\Documents and Settings\Hugh Evans\Desktop\Repository\IRBEM-LIB\irbem\Excel\irbem-lib.dll" _
                Alias "get_onera_meo_gnss_" _
                (ByRef iyear As Long, ByRef iduration As Long, _
                 ByRef whichm As Long, ByRef whatf As Long, _
                 ByRef energy As Double, _
                 ByRef iwhatc As Long) As Double
Public Declare Function get_onera_igexls _
                Lib "C:\Documents and Settings\Hugh Evans\Desktop\Repository\IRBEM-LIB\irbem\Excel\irbem-lib.dll" _
                Alias "get_onera_ige_" _
                (ByRef iyear As Long, ByRef iduration As Long, _
                 ByRef whichm As Long, ByRef whatf As Long, _
                 ByRef energy As Double, _
                 ByRef iwhatc As Long) As Double

Function get_gst(ByRef year As Variant, ByRef doy As Variant, ByRef UT As Variant) As Long

    Dim gst As Double
    'MsgBox ("get_gst: " & gst)
    gst = get_gstdll(CLng(year), CLng(doy), CDbl(UT))
    
    get_gst = gst
End Function

Function get_lstar(ByRef year As Variant, ByRef doy As Variant, ByRef UT As Variant, _
                 ByRef x1 As Variant, ByRef X2 As Variant, ByRef X3 As Variant, _
                 ByRef csys As Variant, ByRef kint As Variant, ByRef kext As Variant, _
                 ByRef what As Variant) As Double

   Dim lstar As Double
   lstar = get_lstarxls(CLng(year), CLng(doy), CDbl(UT), _
                        CDbl(x1), CDbl(X2), CDbl(X3), CLng(csys), _
                        CLng(kint), CLng(kext), CLng(what))
   'jd = juldaydll(CLng(iy), CLng(im), CLng(id))
   'MsgBox ("Test" & jd & " a=" & a)
   get_lstar = lstar
End Function

Function get_nasa_a8(ByRef sysaxes As Variant, ByRef whichm As Variant, ByRef whatf As Variant, _
                    ByRef energy As Variant, ByRef iyear As Variant, ByRef idoy As Variant, _
                    ByRef UT As Variant, ByRef x1 As Variant, ByRef X2 As Variant, ByRef X3 As Variant)

                    
    Dim flux As Double
    'If Not (sysaxes >= 1 And sysaxes <= 8) Then sysaxes = 1
    ' If (whichm < 1 Or whichm > 4) Then whichm = 1
    'If Not (whatf = 1 Or whatf = 3) Then whatf = 1
    
    flux = get_nasa_a8xls(CLng(sysaxes), CLng(whichm), CLng(whatf), CDbl(energy), _
                            CLng(iyear), CLng(idoy), CDbl(UT), _
                            CDbl(x1), CDbl(X2), CDbl(X3))
'    If flux < 0 Then flux = 0.01
    get_nasa_a8 = flux
'    MsgBox ("flux: " & flux)
End Function
Function get_nasa_a8_BB0_L(ByRef whichm As Variant, ByRef whatf As Variant, _
                    ByRef energy As Variant, ByRef BB0 As Variant, ByRef L As Variant)

    Dim flux As Double
    
    flux = get_nasa_a8_BB0_Lxls(CLng(whichm), CLng(whatf), CDbl(energy), _
                            CDbl(BB0), CDbl(L))
'    If flux < 0 Then flux = 0.01
    get_nasa_a8_BB0_L = flux
    'MsgBox ("flux: " & flux)
End Function

Function get_onera_meo_gnss( _
                    ByRef year As Variant, ByRef duration As Variant, _
                    ByRef whichm As Variant, ByRef whatf As Variant, _
                    ByRef energy As Variant, _
                    ByRef whatc As Variant)
                 
    Dim flux As Double
    
    flux = get_onera_meo_gnssxls(CLng(year), CLng(duration), _
                                 CLng(whichm), CLng(whatf), _
                                 CDbl(energy), _
                                 CLng(whatc))
    get_onera_meo_gnss = flux

End Function

Function get_onera_ige( _
                    ByRef year As Variant, ByRef duration As Variant, _
                    ByRef whichm As Variant, ByRef whatf As Variant, _
                    ByRef energy As Variant, _
                    ByRef whatc As Variant)
                 
    Dim flux As Double
     
    flux = get_onera_igexls(CLng(year), CLng(duration), _
                                 CLng(whichm), CLng(whatf), _
                                 CDbl(energy), _
                                 CLng(whatc))
    get_onera_ige = flux

End Function



