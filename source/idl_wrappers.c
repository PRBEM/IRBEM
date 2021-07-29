/**************************************************************************
 *
 * IRBEM IDL wrappers
 *
 *************************************************************************/
#define WRAPPER_DECL(FNAME,ARGS) void FNAME##_(ARGL##ARGS);
#define IDL_WRAPPER(INAME, FNAME, ARGS) WRAPPER_DECL(FNAME,ARGS) float INAME##_(int argc, void * argv[]) { FNAME##_(ARG##ARGS); return 9.9; }
#define IDL_SIMPLE(INAME, ARGS) IDL_WRAPPER(INAME,INAME##1,ARGS)

#define ARG1 argv[0]
#define ARG2 ARG1,argv[1]
#define ARG3 ARG2,argv[2]
#define ARG4 ARG3,argv[3]
#define ARG5 ARG4,argv[4]
#define ARG6 ARG5,argv[5]
#define ARG7 ARG6,argv[6]
#define ARG8 ARG7,argv[7]
#define ARG9 ARG8,argv[8]
#define ARG10 ARG9,argv[9]
#define ARG11 ARG10,argv[10]
#define ARG12 ARG11,argv[11]
#define ARG13 ARG12,argv[12]
#define ARG14 ARG13,argv[13]
#define ARG15 ARG14,argv[14]
#define ARG16 ARG15,argv[15]
#define ARG17 ARG16,argv[16]
#define ARG18 ARG17,argv[17]
#define ARG19 ARG18,argv[18]
#define ARG20 ARG19,argv[19]
#define ARG21 ARG20,argv[20]
#define ARG22 ARG21,argv[21]
#define ARG23 ARG22,argv[22]
#define ARG24 ARG23,argv[23]
#define ARG25 ARG24,argv[24]
#define ARG26 ARG25,argv[25]
#define ARG27 ARG26,argv[26]
#define ARG28 ARG27,argv[27]
#define ARG29 ARG28,argv[28]

#define ARGL1 void*
#define ARGL2 ARGL1,void*
#define ARGL3 ARGL2,void*
#define ARGL4 ARGL3,void*
#define ARGL5 ARGL4,void*
#define ARGL6 ARGL5,void*
#define ARGL7 ARGL6,void*
#define ARGL8 ARGL7,void*
#define ARGL9 ARGL8,void*
#define ARGL10 ARGL9,void*
#define ARGL11 ARGL10,void*
#define ARGL12 ARGL11,void*
#define ARGL13 ARGL12,void*
#define ARGL14 ARGL13,void*
#define ARGL15 ARGL14,void*
#define ARGL16 ARGL15,void*
#define ARGL17 ARGL16,void*
#define ARGL18 ARGL17,void*
#define ARGL19 ARGL18,void*
#define ARGL20 ARGL19,void*
#define ARGL21 ARGL20,void*
#define ARGL22 ARGL21,void*
#define ARGL23 ARGL22,void*
#define ARGL24 ARGL23,void*
#define ARGL25 ARGL24,void*
#define ARGL26 ARGL25,void*
#define ARGL27 ARGL26,void*
#define ARGL28 ARGL27,void*
#define ARGL29 ARGL28,void*


IDL_SIMPLE(irbem_fortran_version,1)
IDL_SIMPLE(irbem_fortran_release,1)
IDL_SIMPLE(get_irbem_ntime_max,1)

IDL_SIMPLE(make_lstar_shell_splitting,19)
IDL_SIMPLE(lstar_phi,7)
IDL_SIMPLE(drift_shell,17)
IDL_SIMPLE(trace_field_line,16)
IDL_WRAPPER(trace_field_line2, trace_field_line2_1,17)
IDL_SIMPLE(trace_field_line_towards_earth,13)
IDL_SIMPLE(find_mirror_point,14)
IDL_SIMPLE(find_magequator,12)
IDL_SIMPLE(get_field,12)
IDL_WRAPPER(get_field_multi_idl, get_field_multi,13)
IDL_SIMPLE(get_mlt,5)

IDL_SIMPLE(get_hemi,11)
IDL_WRAPPER(get_hemi_multi_idl,get_hemi_multi,12)

IDL_SIMPLE(coord_trans,7)
IDL_SIMPLE(coord_trans_vec,8)
IDL_SIMPLE(geo2gsm,6)
IDL_SIMPLE(gsm2geo,6)
IDL_SIMPLE(geo2gse,5)
IDL_SIMPLE(gse2geo,5)
IDL_WRAPPER(gdz2geo,gdz_geo,6)
IDL_WRAPPER(geo2gdz,geo_gdz,6)
IDL_SIMPLE(geo2gei,5)
IDL_SIMPLE(gei2geo,5)
IDL_SIMPLE(geo2sm,5)
IDL_SIMPLE(sm2geo,5)
IDL_SIMPLE(gsm2sm,5)
IDL_SIMPLE(sm2gsm,5)
IDL_SIMPLE(geo2mag,3)
IDL_SIMPLE(mag2geo,3)
IDL_WRAPPER(sph2car,sph_car,4)
IDL_WRAPPER(car2sph,car_sph,4)
IDL_WRAPPER(rll2gdz,rll_gdz,4)
IDL_SIMPLE(gse2hee,5)
IDL_SIMPLE(hee2gse,5)
IDL_SIMPLE(hae2hee,5)
IDL_SIMPLE(hee2hae,5)
IDL_SIMPLE(hae2heeq,5)
IDL_SIMPLE(heeq2hae,5)

IDL_SIMPLE(fly_in_nasa_aeap,13)
IDL_WRAPPER(get_ae8_ap8_flux_idl,get_ae8_ap8_flux,8)
IDL_SIMPLE(fly_in_afrl_crres,16)
IDL_WRAPPER(get_crres_flux_idl,get_crres_flux,11)
IDL_SIMPLE(fly_in_ige,9)
IDL_SIMPLE(fly_in_meo_gnss,9)
IDL_SIMPLE(sgp4_tle,8)
IDL_SIMPLE(sgp4_ele,23)
IDL_WRAPPER(rv2coe_idl,rv2coe,13)
IDL_WRAPPER(date_and_time2decy_idl,date_and_time2decy,7)

IDL_WRAPPER(msis86_idl,msis86,12)
IDL_WRAPPER(msise90_idl,msise90,12)
IDL_WRAPPER(nrlmsise00_idl,nrlmsise00,12)

IDL_SIMPLE(make_lstar,17)
IDL_WRAPPER(make_lstar_shell_splitting2_idl,make_lstar_shell_splitting2,19)

IDL_SIMPLE(find_foot_point,15)
IDL_SIMPLE(drift_bounce_orbit,19)
IDL_WRAPPER(drift_bounce_orbit2,drift_bounce_orbit2_1,22)
IDL_WRAPPER(compute_grad_curv_curl_idl,compute_grad_curv_curl,13)
IDL_WRAPPER(get_bderivs_idl,get_bderivs,15)

IDL_SIMPLE(landi2lstar,17)
IDL_SIMPLE(landi2lstar_shell_splitting,19)
IDL_SIMPLE(empiricallstar,9)

IDL_WRAPPER(shieldose2idl,shieldose2,28)
