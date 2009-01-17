!==========================================================================================!
! BRAMS. Module micro_coms                                                                 !
!                                                                                          !
!     This module is an attempt to bring all microphysics related constants and lookup     !
! tables to a module. Not all constants have been moved to here yet, but that's the goal.  !
!==========================================================================================!
!==========================================================================================!
module micro_coms

   use rconstants, only : boltzmann,pi1,t00,cliq,alli,cice,t3ple
   use micphys   , only : ncat,nhcat

   implicit none

   !----- Precipitation table structure ---------------------------------------------------!
   type pcp_tab_type
      real, pointer, dimension(:,:,:,:) :: pcpfillc,pcpfillr
      real, pointer, dimension(:,:,:)   :: sfcpcp
   end type pcp_tab_type
   type (pcp_tab_type), dimension(:), allocatable :: pcp_tab


   !---------------------------------------------------------------------------------------!
   !   Nucleation-related variables.                                                       !
   !---------------------------------------------------------------------------------------!
   real, parameter :: mfp      = 6.6e-8  ! Mean free path at ref temp and press.  [    1/m]
   real, parameter :: retempk  = 298.15  ! Reference temperature                  [      K]
   real, parameter :: dtempmax = 25.0    ! Maximum reduction for ref. temperature [      K]
   real, parameter :: repres   = 101325. ! Reference pressure                     [     Pa]
   real, parameter :: raros    = 3.e-7   ! Aerosol radius, (Cotton et al. 1986)   [      m]
   real, parameter :: aka      = 5.39e-3 ! Aerosol thermal conductivity 
   !----- Combination of factors for Walko et. al (1995) equation 58 ----------------------!
   real, parameter :: w95_58 = mfp*repres/ retempk
   !----- Boltzmann over 6 pi -------------------------------------------------------------!
   real, parameter :: boltzo6pi = boltzmann/(6.*pi1) 
   !----- Minimum temperature for ice nucleation and ice growth [ K] ----------------------!
   real, parameter :: ticenucmin = t00 - 2.0
   real, parameter :: ticegrowth = t00 - 14.0
   !---------------------------------------------------------------------------------------!
   !    Maximum supersaturation with respect to ice for determining total number of IFN    !
   ! that can nucleate in Meyers' formula
   !---------------------------------------------------------------------------------------!
   real, parameter ::  ssi0 = 0.40
   !---------------------------------------------------------------------------------------!

   !----- Minimum and maximum energy for rain ---------------------------------------------!
   real, parameter :: qrainmin = cliq * (t00 - 80.) + alli ! Minimum -80�C
   real, parameter :: qrainmax = cliq * (t00 + 48.) + alli ! Maximum  48�C
   !----- Minimum and maximum energy for mixed phases -------------------------------------!
   real, parameter :: qmixedmin = cice * (t00 - 4.)        ! Minimum, full ice at -4�C
   real, parameter :: qmixedmax = cliq * (t00 + 4.) + alli ! Minimum, full liquid at 4�C
   !----- Maximum energy for pristine ice before it completely disappears -----------------!
   real, parameter :: qprismax  = 0.99*(cliq*t3ple+alli)+0.01*cice*t3ple ! 99% is gone
   !---------------------------------------------------------------------------------------!

   !----- Coefficients to compute the thermal conductivity --------------------------------!
   real, dimension(3), parameter :: ckcoeff = (/ -4.818544e-3, 1.407892e-4, -1.249986e-7 /)
   !----- Coefficients to compute the dynamic viscousity ----------------------------------!
   real, dimension(2), parameter :: dvcoeff = (/    .1718e-4 ,  .49e-7   /)
   !----- Coefficients to compute the vapour diffusivity ----------------------------------!
   real, dimension(2), parameter :: vdcoeff = (/         2.14,    1.94   /)
   !---------------------------------------------------------------------------------------!



   !----- Variables for collection --------------------------------------------------------!
   real, dimension(nhcat), parameter ::  alpha_coll2 = (/                                  &
          00.,00.,00., 1., 1., 1., 1.,00.,00.,00.,00., 1., 1., 1., 1. /)
   real, dimension(nhcat), parameter ::  beta_coll2  = (/                                  &
          00.,00.,00.,1.5,1.1,0.0,0.0,00.,00.,00.,00.,1.2,1.1,1.1,1.3 /)
   !----- Variables for collection --------------------------------------------------------!
   real, dimension(nhcat), parameter :: alpha_coll3 =(/                                    &
          00.,00., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1. /)
   real, dimension(nhcat), parameter :: beta_coll3  =(/                                    &
          00.,00., 2., 2., 2., 1., 0., 2., 2., 2., 2., 2., 2., 2., 2. /)
   !---------------------------------------------------------------------------------------!


   !----- Variables for sedimentation -----------------------------------------------------!
   real   , dimension(ncat), parameter :: alphasfc = (/                                    &
            .001, .001, .010, .010, .010, .003, .001 /)

   !----- Variables for melting -----------------------------------------------------------!
   real   , dimension(ncat), parameter :: dmean    = (/                                    &
            20.e-6,500.e-6,30.e-6,500.e-6,500.e-6,500.e-6,8000.e-6 /)
   real                    , parameter :: vk = 0.2123e-04
   !---------------------------------------------------------------------------------------!


   !---------------------------------------------------------------------------------------!
   !    Below are some huge look-up tables that should be kept untouched unless you are    !
   ! absolutely sure of what you are doing...                                              !
   !---------------------------------------------------------------------------------------!
   !----- Hydrometeor basic parameters ----------------------------------------------------!
  real, dimension(9,15), parameter:: dstprms=reshape( (/   &
  !----------------------------------------------------------------------------------------!
  !  shape     cfmas  pwmas     cfvt   pwvt     dmb0     dmb1   parm   rxmin               !
  !----------------------------------------------------------------------------------------!
     .5000,     524.,    3.,   3173.,    2.,   2.e-6,  40.e-6,  .3e9, 1.e-12 &  !cloud
   , .5000,     524.,    3.,    149.,    .5,   .1e-3,   5.e-3, .1e-2, 1.e-09 &  !rain
   , .1790,    110.8,  2.91, 5.769e5,  1.88,  15.e-6, 125.e-6,  .1e4, 1.e-12 &  !pris col
   , .1790, 2.739e-3,  1.74, 188.146,  .933,   .1e-3,  10.e-3, .1e-2, 1.e-09 &  !snow col
   , .5000,     .496,   2.4,   3.084,    .2,   .1e-3,  10.e-3, .1e-2, 1.e-09 &  !aggreg
   , .5000,     157.,    3.,    93.3,    .5,   .1e-3,   5.e-3, .1e-2, 1.e-09 &  !graup
   , .5000,     471.,    3.,    161.,    .5,   .8e-3,  10.e-3, .3e-2, 1.e-09 &  !hail 
   , .0429,    .8854,   2.5,    316.,  1.01,      00,      00,    00,     00 &  !pris hex
   , .3183,  .377e-2,    2.,    316.,  1.01,      00,      00,    00,     00 &  !pris den
   , .1803,  1.23e-3,   1.8, 5.769e5,  1.88,      00,      00,    00,     00 &  !pris ndl
   , .5000,    .1001, 2.256,  3.19e4,  1.66,      00,      00,    00,     00 &  !pris ros
   , .0429,    .8854,   2.5,   4.836,   .25,      00,      00,    00,     00 &  !snow hex
   , .3183,  .377e-2,    2.,   4.836,   .25,      00,      00,    00,     00 &  !snow den
   , .1803,  1.23e-3,   1.8, 188.146,  .933,      00,      00,    00,     00 &  !snow ndl
   , .5000,    .1001, 2.256, 1348.38, 1.241,      00,      00,    00,     00 /) & !snow ros
   , (/9,15/))

  real, dimension(15,15), parameter :: jpairr = reshape((/                         &
         0,   0,   0,   1,   2,   3,   4,   0,   0,   0,   0,   5,   6,   7,   8   &
     ,   0,   0,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21   &
     ,   0,  22,  23,  24,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0   &
     ,  25,  26,  27,  28,   0,   0,   0,  29,  30,  31,  32,   0,   0,   0,   0   &
     ,  33,  34,  35,  36,   0,   0,   0,  37,  38,  39,  40,  41,  42,  43,  44   &
     ,  45,  46,  47,  48,  49,   0,   0,  50,  51,  52,  53,  54,  55,  56,  57   &
     ,  58,  59,  60,  61,  62,  63,   0,  64,  65,  66,  67,  68,  69,  70,  71   &
     ,   0,  72,   0,  73,   0,   0,   0,  74,   0,   0,   0,  75,  76,  77,  78   &
     ,   0,  79,   0,  80,   0,   0,   0,   0,  81,   0,   0,  82,  83,  84,  85   &
     ,   0,  86,   0,  87,   0,   0,   0,   0,   0,  88,   0,  89,  90,  91,  92   &
     ,   0,  93,   0,  94,   0,   0,   0,   0,   0,   0,  95,  96,  97,  98,  99   &
     , 100, 101, 102,   0,   0,   0,   0, 103, 104, 105, 106, 107,   0,   0,   0   &
     , 108, 109, 110,   0,   0,   0,   0, 111, 112, 113, 114,   0, 115,   0,   0   &
     , 116, 117, 118,   0,   0,   0,   0, 119, 120, 121, 122,   0,   0, 123,   0   &
     , 124, 125, 126,   0,   0,   0,   0, 127, 128, 129, 130,   0,   0,   0, 131   /) &
     , (/15,15/) )


  real, dimension(15,15), parameter  :: jpairc = reshape( (/                       &
         0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0   &
      ,  0,   1,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0   &
      ,  0,   2,   3,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0   &
      ,  4,   5,   6,   7,   0,   0,   0,   8,   9,  10,  11,   0,   0,   0,   0   &
      , 12,  13,  14,  15,  16,   0,   0,  17,  18,  19,  20,  21,  22,  23,  24   &
      , 25,  26,  27,  28,  29,  30,   0,  31,  32,  33,  34,  35,  36,  37,  38   &
      , 39,  40,  41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  52,  53   &
      ,  0,  54,   0,   0,   0,   0,   0,  55,   0,   0,   0,   0,   0,   0,   0   &
      ,  0,  56,   0,   0,   0,   0,   0,   0,  57,   0,   0,   0,   0,   0,   0   &
      ,  0,  58,   0,   0,   0,   0,   0,   0,   0,  59,   0,   0,   0,   0,   0   &
      ,  0,  60,   0,   0,   0,   0,   0,   0,   0,   0,  61,   0,   0,   0,   0   &
      , 62,  63,  64,   0,   0,   0,   0,  65,  66,  67,  68,  69,   0,   0,   0   &
      , 70,  71,  72,   0,   0,   0,   0,  73,  74,  75,  76,   0,  77,   0,   0   &
      , 78,  79,  80,   0,   0,   0,   0,  81,  82,  83,  84,   0,   0,  85,   0   &
      , 86,  87,  88,   0,   0,   0,   0,  89,  90,  91,  92,   0,   0,   0,  93   /) &
      , (/15,15/) )


   !----- Nucleation table ----------------------------------------------------------------!
   real, parameter, dimension(9,7,7) :: cldnuctab = reshape(   (/              &
                                                                    !     -- itemp = 1 --
      .307,  .520,  .753,  .919,  .990,  .990,  .990,  .990,  .990  & ! iconc = 1  iw = 1:9
   ,  .230,  .426,  .643,  .860,  .969,  .990,  .990,  .990,  .990  & ! iconc = 2  iw = 1:9
   ,  .164,  .336,  .552,  .777,  .940,  .990,  .990,  .990,  .990  & ! iconc = 3  iw = 1:9
   ,  .098,  .254,  .457,  .701,  .892,  .979,  .990,  .990,  .990  & ! iconc = 4  iw = 1:9
   ,  .045,  .145,  .336,  .614,  .822,  .957,  .990,  .990,  .990  & ! iconc = 5  iw = 1:9
   ,  .018,  .073,  .206,  .426,  .672,  .877,  .969,  .990,  .990  & ! iconc = 6  iw = 1:9
   ,  .008,  .027,  .085,  .206,  .280,  .336,  .336,  .336,  .906  & ! iconc = 7  iw = 1:9
                                                                    !     -- itemp = 2 --
   ,  .230,  .426,  .643,  .860,  .969,  .990,  .990,  .990,  .990  & ! iconc = 1  iw = 1:9
   ,  .164,  .336,  .552,  .777,  .930,  .990,  .990,  .990,  .990  & ! iconc = 2  iw = 1:9
   ,  .112,  .254,  .457,  .701,  .877,  .974,  .990,  .990,  .990  & ! iconc = 3  iw = 1:9
   ,  .073,  .184,  .365,  .583,  .822,  .949,  .990,  .990,  .990  & ! iconc = 4  iw = 1:9
   ,  .038,  .112,  .254,  .489,  .727,  .906,  .982,  .990,  .990  & ! iconc = 5  iw = 1:9
   ,  .015,  .054,  .145,  .365,  .614,  .841,  .957,  .990,  .990  & ! iconc = 6  iw = 1:9
   ,  .005,  .018,  .073,  .184,  .395,  .614,  .800,  .940,  .990  & ! iconc = 7  iw = 1:9
                                                                    !     -- itemp = 3 --
   ,  .164,  .336,  .552,  .800,  .949,  .990,  .990,  .990,  .990  & ! iconc = 1  iw = 1:9
   ,  .128,  .254,  .457,  .701,  .892,  .979,  .990,  .990,  .990  & ! iconc = 2  iw = 1:9
   ,  .085,  .184,  .365,  .583,  .822,  .949,  .990,  .990,  .990  & ! iconc = 3  iw = 1:9
   ,  .054,  .128,  .280,  .489,  .727,  .906,  .982,  .990,  .990  & ! iconc = 4  iw = 1:9
   ,  .027,  .085,  .206,  .395,  .643,  .841,  .963,  .990,  .990  & ! iconc = 5  iw = 1:9
   ,  .012,  .038,  .112,  .280,  .520,  .777,  .930,  .990,  .990  & ! iconc = 6  iw = 1:9
   ,  .004,  .015,  .054,  .145,  .365,  .614,  .822,  .949,  .990  & ! iconc = 7  iw = 1:9
                                                                    !     -- itemp = 4 --
   ,  .145,  .280,  .489,  .727,  .919,  .990,  .990,  .990,  .990  & ! iconc = 1  iw = 1:9
   ,  .098,  .206,  .395,  .614,  .841,  .963,  .990,  .990,  .990  & ! iconc = 2  iw = 1:9
   ,  .063,  .145,  .307,  .520,  .753,  .919,  .990,  .990,  .990  & ! iconc = 3  iw = 1:9
   ,  .038,  .098,  .230,  .426,  .643,  .860,  .963,  .990,  .990  & ! iconc = 4  iw = 1:9
   ,  .022,  .063,  .164,  .336,  .552,  .777,  .930,  .990,  .990  & ! iconc = 5  iw = 1:9
   ,  .010,  .027,  .085,  .230,  .426,  .701,  .877,  .974,  .990  & ! iconc = 6  iw = 1:9
   ,  .003,  .012,  .038,  .112,  .280,  .552,  .777,  .940,  .990  & ! iconc = 7  iw = 1:9
                                                                    !     -- itemp = 5 --
   ,  .112,  .230,  .457,  .701,  .892,  .982,  .990,  .990,  .990  & ! iconc = 1  iw = 1:9
   ,  .073,  .164,  .336,  .552,  .800,  .940,  .990,  .990,  .990  & ! iconc = 2  iw = 1:9
   ,  .054,  .112,  .254,  .457,  .672,  .877,  .979,  .990,  .990  & ! iconc = 3  iw = 1:9
   ,  .032,  .085,  .184,  .365,  .583,  .800,  .940,  .990,  .990  & ! iconc = 4  iw = 1:9
   ,  .018,  .045,  .128,  .254,  .457,  .701,  .892,  .979,  .990  & ! iconc = 5  iw = 1:9
   ,  .008,  .022,  .073,  .184,  .365,  .614,  .822,  .949,  .990  & ! iconc = 6  iw = 1:9
   ,  .003,  .010,  .032,  .098,  .230,  .489,  .727,  .906,  .979  & ! iconc = 7  iw = 1:9
                                                                    !     -- itemp = 6 --
   ,  .098,  .206,  .395,  .643,  .860,  .974,  .990,  .990,  .990  & ! iconc = 1  iw = 1:9
   ,  .063,  .145,  .307,  .520,  .753,  .930,  .990,  .990,  .990  & ! iconc = 2  iw = 1:9
   ,  .045,  .098,  .206,  .395,  .643,  .841,  .963,  .990,  .990  & ! iconc = 3  iw = 1:9
   ,  .027,  .063,  .145,  .307,  .520,  .753,  .919,  .990,  .990  & ! iconc = 4  iw = 1:9
   ,  .015,  .038,  .098,  .230,  .426,  .643,  .841,  .963,  .990  & ! iconc = 5  iw = 1:9
   ,  .007,  .018,  .054,  .145,  .307,  .552,  .777,  .919,  .990  & ! iconc = 6  iw = 1:9
   ,  .003,  .008,  .027,  .073,  .206,  .395,  .672,  .860,  .969  & ! iconc = 7  iw = 1:9
                                                                    !     -- itemp = 7 --
   ,  .098,  .206,  .365,  .614,  .841,  .969,  .990,  .990,  .990  & ! iconc = 1  iw = 1:9
   ,  .054,  .128,  .280,  .489,  .727,  .906,  .990,  .990,  .990  & ! iconc = 2  iw = 1:9
   ,  .038,  .085,  .184,  .365,  .583,  .822,  .957,  .990,  .990  & ! iconc = 3  iw = 1:9
   ,  .022,  .063,  .128,  .280,  .457,  .701,  .892,  .982,  .990  & ! iconc = 4  iw = 1:9
   ,  .012,  .038,  .085,  .184,  .365,  .583,  .822,  .949,  .990  & ! iconc = 5  iw = 1:9
   ,  .005,  .018,  .045,  .128,  .280,  .489,  .727,  .892,  .979  & ! iconc = 6  iw = 1:9
   ,  .002,  .007,  .022,  .063,  .164,  .365,  .614,  .822,  .949  & ! iconc = 7  iw = 1:9
   /) &
   ,(/9,7,7/))



  !----- Parameters, establishing order of routine calls and "from-to" relationships. -----!
  integer, dimension(7)   :: mcats    = (/    0,    3,    0,    0,    6,    7,   10 /)
  integer, dimension(7)   :: mivap    = (/    1,    3,    4,    5,    2,    6,    7 /)
  integer, dimension(7)   :: mix02    = (/    3,    1,    4,    5,    6,    7,    2 /)

  integer, dimension(7,2) :: mcat2    = reshape((/    0,    0,    0,    6,    6,    7,    7  &
       ,    0,    0,    0,    2,    2,    9,    9    /) &
       ,(/7,2/))
  
  integer, dimension(9,4) :: mcat1    = reshape((/   3,   3,   3,   4,   4,   4,   5,   5,   6  &
       ,   5,   6,   7,   5,   6,   7,   6,   7,   7  &
       ,   5,   6,   7,   5,   6,   7,   6,   7,   7  &
       ,   4,   7,   8,   5,   7,   8,   7,   8,   8 /) &
       ,(/9,4/))

  integer, dimension(4)   :: mcat33   = (/   0,    0,    4,    5 /)

  !----- Converting lhcat to lcat ---------------------------------------------------------!
  integer, dimension(15) :: lcat_lhcat = (/1,2,3,4,5,6,7,3,3,3,3,4,4,4,4/)


  contains
  !========================================================================================!
  !========================================================================================!






  !========================================================================================!
  !========================================================================================!
  subroutine alloc_sedimtab(sedtab,mzp,maxkfall,nembfall,nhcat)

     implicit none
     type (pcp_tab_type), intent(inout) :: sedtab
     integer            , intent(in)    :: mzp,maxkfall,nembfall,nhcat

     allocate (sedtab%pcpfillc(mzp,maxkfall,nembfall,nhcat))
     allocate (sedtab%pcpfillr(mzp,maxkfall,nembfall,nhcat))
     allocate (sedtab%sfcpcp  (    maxkfall,nembfall,nhcat))

     return
  end subroutine alloc_sedimtab
  !========================================================================================!
  !========================================================================================!






  !========================================================================================!
  !========================================================================================!
  subroutine nullify_sedimtab(sedtab)

     implicit none
     type (pcp_tab_type), intent(inout) :: sedtab

     if (associated(sedtab%pcpfillc)) nullify (sedtab%pcpfillc)
     if (associated(sedtab%pcpfillr)) nullify (sedtab%pcpfillr)
     if (associated(sedtab%sfcpcp  )) nullify (sedtab%sfcpcp  )

     return
  end subroutine nullify_sedimtab
  !========================================================================================!
  !========================================================================================!
end module micro_coms
!==========================================================================================!
!==========================================================================================!
