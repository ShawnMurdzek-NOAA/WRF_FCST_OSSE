#!/bin/ksh --login

np=`cat $PBS_NODEFILE | wc -l`

# Load modules
source ${MODULE_FILE}

# Make sure we are using GMT time zone for time computations
export TZ="GMT"

# Set up paths to shell commands
LS=/bin/ls
LN=/bin/ln
RM=/bin/rm
MKDIR=/bin/mkdir
CP=/bin/cp
MV=/bin/mv
ECHO=/bin/echo
CAT=/bin/cat
GREP=/bin/grep
CUT=/bin/cut
AWK="/bin/gawk --posix"
SED=/bin/sed
DATE=/bin/date
BC=/usr/bin/bc
CNVGRIB=${EXE_ROOT}/cnvgrib.exe
CNVOPTS='-g12 -p32'

# Print run parameters
${ECHO}
${ECHO} "prep_chem_sources.ksh started at `${DATE}`"
${ECHO}
${ECHO} "DATAHOME = ${DATAHOME}"
${ECHO} "HRRR_DIR = ${HRRR_DIR}"
${ECHO} "START_TIME = ${START_TIME}"

# Check to make sure that the DATAHOME exists
if [ ! ${DATAHOME} ]; then
  ${ECHO} "ERROR: DATAHOME, \$DATAHOME, is not defined"
  exit 1
fi

# Check to make sure that the RETRO_DATA directory exists
if [ ! ${RETRO_DATA} ]; then
  ${ECHO} "ERROR: RETRO_DATA, \$RETRO_DATA, is not defined"
  exit 1
fi

# Check to make sure that the EDGARv4 directory exists
if [ ! ${EDGAR_DATA} ]; then
  ${ECHO} "ERROR: EDGAR_DATA, \$EDGAR_DATA, is not defined"
  exit 1
fi

# Check to make sure that the GOCART directory exists
if [ ! ${GOCART_DATA} ]; then
  ${ECHO} "ERROR: GOCART_DATA, \$GOCART_DATA, is not defined"
  exit 1
fi

# Check to make sure that the STREETS directory exists
if [ ! ${STREETS_DATA} ]; then
  ${ECHO} "ERROR: STREETS_DATA, \$STREETS_DATA, is not defined"
  exit 1
fi

# Check to make sure that the SEAC4RS directory exists
if [ ! ${SEAC4RS_DATA} ]; then
  ${ECHO} "ERROR: SEAC4RS_DATA, \$SEAC4RS_DATA, is not defined"
  exit 1
fi

# Check to make sure that the FWBAWB directory exists
if [ ! ${FWBAWB_DATA} ]; then
  ${ECHO} "ERROR: FWBAWB_DATA, \$FWBAWB_DATA, is not defined"
  exit 1
fi

# Check to make sure that the WFABBA directory exists
if [ ! ${WFABBA_DATA} ]; then
  ${ECHO} "ERROR: WFABBA_DATA, \$WFABBA_DATA, is not defined"
  exit 1
fi

# Check to make sure that the MODIS directory exists
if [ ! ${MODIS_DATA} ]; then
  ${ECHO} "ERROR: MODIS_DATA, \$MODIS_DATA, is not defined"
  exit 1
fi

# Check to make sure that the INPE directory exists
if [ ! ${INPE_DATA} ]; then
  ${ECHO} "ERROR: INPE_DATA, \$INPE_DATA, is not defined"
  exit 1
fi

# Check to make sure that the EXTRA directory exists
if [ ! ${EXTRA_DATA} ]; then
  ${ECHO} "ERROR: EXTRA_DATA, \$EXTRA_DATA, is not defined"
  exit 1
fi

# Check to make sure that the VEG_TYPE directory exists
if [ ! ${VEG_TYPE_DATA} ]; then
  ${ECHO} "ERROR: VEG_TYPE_DATA, \$VEG_TYPE_DATA, is not defined"
  exit 1
fi

# Check to make sure that the OLSON directory exists
if [ ! ${OLSON_DATA} ]; then
  ${ECHO} "ERROR: OLSON_DATA, \$OLSON_DATA, is not defined"
  exit 1
fi

# Check to make sure that the CARBON_DENSITY directory exists
if [ ! ${CARBON_DENSITY_DATA} ]; then
  ${ECHO} "ERROR: CARBON_DENSITY_DATA, \$CARBON_DENSITY_DATA, is not defined"
  exit 1
fi

# Check to make sure that the GOCART_BACKGROUND directory exists
if [ ! ${GOCART_BG_DATA} ]; then
  ${ECHO} "ERROR: GOCART_BG_DATA, \$GOCART_BG_DATA, is not defined"
  exit 1
fi

# Check to make sure that the START_TIME is defined and in the correct format
if [ ! "${START_TIME}" ]; then
  ${ECHO} "ERROR: START_TIME, \$START_TIME, is not defined"
  exit 1
fi

# Set up the work directory and cd into it
workdir=${DATAHOME}/${START_TIME}
cd ${workdir}
${MKDIR} -p preprd
${MKDIR} -p emisprd
cd preprd/

header='$RP_INPUT'
ending='$END'

cat > prep_chem_sources.inp << __EOFF
  ${header}
!#################################################################
!  CCATT-BRAMS/MCGA-CPTEC/WRF-Chem/FIM-Chem emission models CPTEC/INPE
!  version 1.6: April 2016
!  contact: gmai@cptec.inpe.br   - http://meioambiente.cptec.inpe.br
!  Modified by Ravan Ahmadov using Saulo's version
!#################################################################


!---------------- grid_type of the grid output
   grid_type= 'lambert',
   rams_anal_prefix = '/Users/saulofreitas/work/test2/dataout/ANL/test',
!---------------- date of emission
    ihour=${HOUR},
    iday=${DAY},
    imon=${MONTH},
    iyear=${YEAR},

 !---------------- select the sources datasets to be used
!   use_retro=1,  ! 1 = yes, 0 = not
!   retro_data_dir='./datain/EMISSION_DATA/RETRO/anthro',

!   use_edgar =0,  ! 0 - not,
                  ! 1 - Version 3,
                  ! 2 - Version 4 for some species
                  ! 3 - Version HTAP

!   edgar_data_dir='./datain/EMISSION_DATA/EDGAR/anthro/hdf',

!   use_gocart=0,
!   gocart_data_dir='./datain/EMISSION_DATA/GOCART/emissions',

!   use_streets =0,
!   streets_data_dir='./datain/EMISSION_DATA/STREETS',

!   use_seac4rs =0,
!   seac4rs_data_dir='./datain/EMISSION_DATA/SEAC4RS',


!   use_fwbawb =0,
!   fwbawb_data_dir ='./datain/EMISSION_DATA/Emissions_Yevich_Logan',

    use_retro =0,  ! 1 = yes, 0 = not
    retro_data_dir='${RETRO_DATA}',

    use_edgar =0,  ! 0 - not, 1 - Version 3, 2 - Version 4 for some species
    edgar_data_dir='${EDGAR_DATA}',

    use_gocart =0,
    gocart_data_dir='${GOCART_DATA}',

    use_streets =0,
    streets_data_dir='${STREETS_DATA}',

    use_seac4rs =0,
    seac4rs_data_dir='${SEAC4RS_DATA}',

    use_fwbawb =0,
    fwbawb_data_dir ='${FWBAWB_DATA}',

   use_bioge =0, ! 1 - geia, 2 - megan
   ! ######
   ! # BIOGENIC = 1
   !bioge_data_dir ='./datain/EMISSION_DATA/biogenic_emissions',
   ! # MEGAN = 2
   ! ######
   bioge_data_dir='./datain/EMISSION_DATA/MEGAN/2000',
   ! ######

   use_gfedv2=0,
   gfedv2_data_dir='./datain/EMISSION_DATA/GFEDv2-8days',

   use_bbem=2,  ! 1=traditional methodology ; 2 = FRE methodology
   use_bbem_plumerise=1,

!--------------------------------------------------------------------------------------------------

!---------------- if  the merging of gfedv2 with bbem is desired (=1, yes, 0 = no)
   merge_GFEDv2_bbem =0,

!---------------- Fire product for BBBEM/BBBEM-plumerise emission models
!   bbem_wfabba_data_dir   ='./GOES/f',
!   bbem_modis_data_dir    ='./datain/EMISSION_DATA/FIRES/MODIS/Fires',
!   bbem_inpe_data_dir     ='./datain/EMISSION_DATA/FIRES/DSA/Focos',
!   bbem_fre_data_dir      ='./PIX/f',
!   bbem_extra_data_dir    ='NONE',

   bbem_fre_data_dir      ='${DATAHOME}/${START_TIME}/frp_proc/f'
   bbem_wfabba_data_dir   ='${WFABBA_DATA}/f',
   bbem_modis_data_dir    ='${MODIS_DATA}/Global_MCD14DL_',
   bbem_inpe_data_dir     ='${INPE_DATA}/Focos',
   bbem_extra_data_dir    ='${EXTRA_DATA}/current.dat',

!---------------- veg type data set (dir + prefix)
!   veg_type_data_dir      ='./datain/SURFACE_DATA/GL_IGBP_INPE_39classes/IGBP',
  veg_type_data_dir      ='${VEG_TYPE_DATA}/IGBP',
!  veg_type_data_dir = /scratch3/BMC/ap-fc/Ravan/HRRR_smoke/Input/LU_data/

!---------------- vcf type data set (dir + prefix)
  use_vcf = 0,
  vcf_type_data_dir      ='./datain/SURFACE_DATA/VCF/data_out/2005/VCF',
!---------------- olson data set (dir + prefix)
!  olson_data_dir      ='./datain/EMISSION_DATA/OLSON2/OLSON',
  olson_data_dir= '${OLSON_DATA}/OLSON',

!---------------- carbon density data set (dir + prefix)

!   carbon_density_data_dir='./datain/SURFACE_DATA/GL_OGE_INPE/OGE',
   carbon_density_data_dir='${CARBON_DENSITY_DATA}/OGE',

!   fuel_data_dir      ='./datain/EMISSION_DATA/Carbon_density_Saatchi/amazon_biomass_final.gra',


!---------------- gocart background
   use_gocart_bg=0,
   gocart_bg_data_dir='${GOCART_BG_DATA}',

!---------------- volcanoes emissions
   use_volcanoes =0,
   volcano_index =1143, !REDOUBT

   use_these_values='NONE',
! define a text file for using external values for INJ_HEIGHT, DURATION,
! MASS ASH (units are meters - seconds - kilograms) and the format for
!   begin_eruption='201303280000',  !begin time UTC of eruption YYYYMMDDhhmm
!  begin_eruption='201512081700',  !begin time UTC of eruption YYYYMMDDhhmm

!---------------- degassing volcanoes emissions
   use_degass_volcanoes =0,
   degass_volc_data_dir ='./datain/EMISSION_DATA/VOLC_SO2',

!---------------- user specific  emissions directory
!---------------- Update for South America megacities
   user_data_dir='NONE',


!--------------------------------------------------------------------------------------------------
   pond=1,   ! mad/mfa  0 -> molar mass weighted
             !          1 -> Reactivity weighted

!---------------- for grid type 'll' or 'gg' only
   grid_resolucao_lon=0.2,
   grid_resolucao_lat=0.2,

   nlat=320,          ! if gg (only global grid)
   lon_beg   = -180., ! (-180.:+180.) long-begin of the output file
   lat_beg   =  -90., ! ( -90.:+90. ) lat -begin of the output file
   delta_lon =  360, ! total long extension of the domain (360 for global)
   delta_lat =  180, ! total lat  extension of the domain (180 for global)

!---------------- For regional grids (polar or lambert)

   NGRIDS   = 1,            ! Number of grids to run

   NNXP     = 1799,50,86,46,        ! Number of x gridpoints
   NNYP     = 1059,50,74,46,        ! Number of y gridpoints
   NXTNEST  = 0,1,1,1,          ! Grid number which is the next coarser grid
   DELTAX   = 3000.0,
   DELTAY   = 3000.0,         ! X and Y grid spacing

   ! Nest ratios between this grid and the next coarser grid.
   NSTRATX  = 1,2,3,4,           ! x-direction
   NSTRATY  = 1,2,3,4,           ! y-direction

   NINEST = 1,10,0,0,        ! Grid point on the next coarser
   NJNEST = 1,10,0,0,        !  nest where the lower southwest
                             !  corner of this nest will start.
                             !  If NINEST or NJNEST = 0, use CENTLAT/LON
   POLELAT  =  38.5, !-89.99,        ! If polar, latitude/longitude of pole point
   POLELON  = -97.5,         ! If lambert, lat/lon of grid origin (x=y=0.)

   STDLON   = -97.5,          ! Standard longitude, used if lambert or polar
   STDLAT1  = 38.5,           ! If polar for BRAMS, use 90.0 in STDLAT2
   STDLAT2  = 38.5,         ! If lambert, standard latitudes of projection
                            !(truelat2/truelat1 from namelist.wps, STDLAT1 < STDLAT2)
                            ! If mercator STDLAT1 = 1st true latitude

   CENTLAT  =  38.5, -89.99,  -23., 27.5,  27.5,
   CENTLON  = -97.5,  -46.,-80.5, -80.5,


!---------------- model output domain for each grid (only set up for rams)
   lati =  -90.,  -90.,   -90.,
   latf =  +90.,  +90.,   +90.,
   loni = -180., -180.,  -180.,
   lonf =  180.,  180.,   180.,

!---------------- project rams grid (polar sterogr) to lat/lon: 'YES' or 'NOT'
   proj_to_ll='NO',

!---------------- output file prefix (may include directory other than the current)
   chem_out_prefix = 'FIRE-HRRR_new',
   chem_out_format = 'vfm',
!---------------- convert to WRF/CHEM (yes,not)
  special_output_to_wrf = 'yes',
   
  ${ending}

__EOFF

cp ${EXEC} .
${EXEC}

cd ../emisprd

#ln -sf ../preprd/FIRE-HRRR_new-T-${YEAR}-${MONTH}-${DAY}-${HOUR}0000-g1-gocartBG.bin wrf_gocart_backg
ln -sf ../preprd/FIRE-HRRR_new-T-${YEAR}-${MONTH}-${DAY}-${HOUR}0000-g1-bb.bin emissfire_d01
#ln -sf ../preprd/FIRE-HRRR_new-T-${YEAR}-${MONTH}-${DAY}-${HOUR}0000-g1-ab.bin emissopt3_d01
#ln -sf ../preprd/FIRE-HRRR_new-T-${YEAR}-${MONTH}-${DAY}-${HOUR}0000-g1-volc.bin volc_d01

${ECHO} "prep_chem_sources.ksh completed at `${DATE}`"

exit 0
