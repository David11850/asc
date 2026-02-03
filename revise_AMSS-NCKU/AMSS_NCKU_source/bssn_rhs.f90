#include "macrodef.fh"

  function compute_rhs_bssn(ex, T,X, Y, Z,                              &
               chi    ,   trK    ,                                      &
               dxx    ,   gxy    ,   gxz    ,   dyy    ,   gyz    ,   dzz,      &
               Axx    ,   Axy    ,   Axz    ,   Ayy    ,   Ayz    ,   Azz,      &
               Gamx   ,  Gamy    ,  Gamz    ,                                   &
               Lap    ,  betax   ,  betay   ,  betaz   ,                        &
               dtSfx  ,  dtSfy   ,  dtSfz   ,                                   &
               chi_rhs,   trK_rhs,                                              &
               gxx_rhs,   gxy_rhs,   gxz_rhs,   gyy_rhs,   gyz_rhs,   gzz_rhs, &
               Axx_rhs,   Axy_rhs,   Axz_rhs,   Ayy_rhs,   Ayz_rhs,   Azz_rhs, &
               Gamx_rhs,  Gamy_rhs,  Gamz_rhs,                                  &
               Lap_rhs,  betax_rhs,  betay_rhs,  betaz_rhs,                     &
               dtSfx_rhs,  dtSfy_rhs,  dtSfz_rhs,                               &
               rho,Sx,Sy,Sz,Sxx,Sxy,Sxz,Syy,Syz,Szz,                            &
               Gamxxx,Gamxxy,Gamxxz,Gamxyy,Gamxyz,Gamxzz,                       &
               Gamyxx,Gamyxy,Gamyxz,Gamyyy,Gamyyz,Gamyzz,                       &
               Gamzxx,Gamzxy,Gamzxz,Gamzyy,Gamzyz,Gamzzz,                       &
               Rxx,Rxy,Rxz,Ryy,Ryz,Rzz,                                         &
               ham_Res, movx_Res, movy_Res, movz_Res,                           &
                        Gmx_Res, Gmy_Res, Gmz_Res,                              &
               Symmetry,Lev,eps,co)  result(gont)
  implicit none

  integer,intent(in ):: ex(1:3), Symmetry,Lev,co
  real*8, intent(in ):: T
  real*8, intent(in ):: X(1:ex(1)),Y(1:ex(2)),Z(1:ex(3))
  real*8, dimension(ex(1),ex(2),ex(3)),intent(inout) :: chi,dxx,dyy,dzz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(in ) :: trK,gxy,gxz,gyz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(in ) :: Axx,Axy,Axz,Ayy,Ayz,Azz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(in ) :: Gamx,Gamy,Gamz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(inout) :: Lap, betax, betay, betaz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(in ) :: dtSfx,  dtSfy,  dtSfz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: chi_rhs,trK_rhs
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: gxx_rhs,gxy_rhs,gxz_rhs,gyy_rhs,gyz_rhs,gzz_rhs
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: Axx_rhs,Axy_rhs,Axz_rhs,Ayy_rhs,Ayz_rhs,Azz_rhs
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: Gamx_rhs,Gamy_rhs,Gamz_rhs
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: Lap_rhs, betax_rhs, betay_rhs, betaz_rhs
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: dtSfx_rhs,dtSfy_rhs,dtSfz_rhs
  real*8, dimension(ex(1),ex(2),ex(3)),intent(in ) :: rho,Sx,Sy,Sz,Sxx,Sxy,Sxz,Syy,Syz,Szz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: Gamxxx, Gamxxy, Gamxxz, Gamxyy, Gamxyz, Gamxzz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: Gamyxx, Gamyxy, Gamyxz, Gamyyy, Gamyyz, Gamyzz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: Gamzxx, Gamzxy, Gamzxz, Gamzyy, Gamzyz, Gamzzz
  real*8, dimension(ex(1),ex(2),ex(3)),intent(out) :: Rxx,Rxy,Rxz,Ryy,Ryz,Rzz
  real*8,intent(in) :: eps
  real*8, dimension(ex(1),ex(2),ex(3)),intent(inout) :: ham_Res, movx_Res, movy_Res, movz_Res, Gmx_Res, Gmy_Res, Gmz_Res
  integer::gont, i, j, k

  real*8, dimension(ex(1),ex(2),ex(3)) :: gxx,gyy,gzz,chix,chiy,chiz
  real*8, dimension(ex(1),ex(2),ex(3)) :: gxxx,gxyx,gxzx,gyyx,gyzx,gzzx,gxxy,gxyy,gxzy,gyyy,gyzy,gzzy,gxxz,gxyz,gxzz,gyyz,gyzz,gzzz
  real*8, dimension(ex(1),ex(2),ex(3)) :: Lapx,Lapy,Lapz,betaxx,betaxy,betaxz,betayx,betayy,betayz,betazx,betazy,betazz
  real*8, dimension(ex(1),ex(2),ex(3)) :: Gamxx,Gamxy,Gamxz,Gamyx,Gamyy,Gamyz,Gamzx,Gamzy,Gamzz
  real*8, dimension(ex(1),ex(2),ex(3)) :: Kx,Ky,Kz,div_beta,S,f,fxx,fxy,fxz,fyy,fyz,fzz
  real*8, dimension(ex(1),ex(2),ex(3)) :: Gamxa,Gamya,Gamza,alpn1,chin1,gupxx,gupxy,gupxz,gupyy,gupyz,gupzz
  real*8,dimension(3) ::SSS,AAS,ASA,SAA,ASS,SAS,SSA
  real*8, parameter :: ONE = 1.D0, TWO = 2.D0, HALF = 0.5D0, PI = 3.141592653589793D0
  real*8, parameter :: F2o3 = 2.d0/3.d0, F1o3 = 1.d0/3.d0, F3o2 = 1.5d0, SYM = 1.D0, ANTI = -1.D0
  double precision,parameter::FF = 0.75d0,eta=2.d0

  ! --- [Phase 1: Basic Prep] ---
  !$OMP PARALLEL DEFAULT(SHARED) PRIVATE(k,i,j)
  !$OMP DO
  do k = 1, ex(3)
    alpn1(:,:,k) = Lap(:,:,k) + ONE
    chin1(:,:,k) = chi(:,:,k) + ONE
    gxx(:,:,k) = dxx(:,:,k) + ONE
    gyy(:,:,k) = dyy(:,:,k) + ONE
    gzz(:,:,k) = dzz(:,:,k) + ONE
  end do
  !$OMP END DO

  !$OMP SECTIONS
    !$OMP SECTION
    call fderivs(ex,betax,betaxx,betaxy,betaxz,X,Y,Z,ANTI, SYM, SYM,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,betay,betayx,betayy,betayz,X,Y,Z, SYM,ANTI, SYM,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,betaz,betazx,betazy,betazz,X,Y,Z, SYM, SYM,ANTI,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,chi,chix,chiy,chiz,X,Y,Z,SYM,SYM,SYM,Symmetry,Lev)
  !$OMP END SECTIONS

  !$OMP DO
  do k = 1, ex(3)
    div_beta(:,:,k) = betaxx(:,:,k) + betayy(:,:,k) + betazz(:,:,k)
    chi_rhs(:,:,k) = F2o3 * chin1(:,:,k) * ( alpn1(:,:,k) * trK(:,:,k) - div_beta(:,:,k) )
  end do
  !$OMP END DO

  ! --- [Phase 2: Metric Derivatives] ---
  !$OMP SECTIONS
    !$OMP SECTION
    call fderivs(ex,dxx,gxxx,gxxy,gxxz,X,Y,Z,SYM ,SYM ,SYM ,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,dyy,gyyx,gyyy,gyyz,X,Y,Z,SYM ,SYM ,SYM ,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,gxy,gxyx,gxyy,gxyz,X,Y,Z,ANTI,ANTI,SYM ,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,gxz,gxzx,gxzy,gxzz,X,Y,Z,ANTI,SYM ,ANTI,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,gyz,gyzx,gyzy,gyzz,X,Y,Z,SYM ,ANTI,ANTI,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,dzz,gzzx,gzzy,gzzz,X,Y,Z,SYM ,SYM ,SYM ,Symmetry,Lev)
  !$OMP END SECTIONS

  ! --- [Phase 3: Metric RHS & Inversion] ---
  !$OMP DO
  do k = 1, ex(3)
    gxx_rhs(:,:,k) = - TWO * alpn1(:,:,k) * Axx(:,:,k) - F2o3 * gxx(:,:,k) * div_beta(:,:,k) + &
                      TWO * ( gxx(:,:,k) * betaxx(:,:,k) + gxy(:,:,k) * betayx(:,:,k) + gxz(:,:,k) * betazx(:,:,k) )
    gyy_rhs(:,:,k) = - TWO * alpn1(:,:,k) * Ayy(:,:,k) - F2o3 * gyy(:,:,k) * div_beta(:,:,k) + &
                      TWO * ( gxy(:,:,k) * betaxy(:,:,k) + gyy(:,:,k) * betayy(:,:,k) + gyz(:,:,k) * betazy(:,:,k) )
    gzz_rhs(:,:,k) = - TWO * alpn1(:,:,k) * Azz(:,:,k) - F2o3 * gzz(:,:,k) * div_beta(:,:,k) + &
                      TWO * ( gxz(:,:,k) * betaxz(:,:,k) + gyz(:,:,k) * betayz(:,:,k) + gzz(:,:,k) * betazz(:,:,k) )
    gxy_rhs(:,:,k) = - TWO * alpn1(:,:,k) * Axy(:,:,k) + F1o3 * gxy(:,:,k) * div_beta(:,:,k) + &
                      gxx(:,:,k) * betaxy(:,:,k) + gxz(:,:,k) * betazy(:,:,k) + gyy(:,:,k) * betayx(:,:,k) + &
                      gyz(:,:,k) * betazx(:,:,k) - gxy(:,:,k) * betazz(:,:,k)
    gyz_rhs(:,:,k) = - TWO * alpn1(:,:,k) * Ayz(:,:,k) + F1o3 * gyz(:,:,k) * div_beta(:,:,k) + &
                      gxy(:,:,k) * betaxz(:,:,k) + gyy(:,:,k) * betayz(:,:,k) + gxz(:,:,k) * betaxy(:,:,k) + &
                      gzz(:,:,k) * betazy(:,:,k) - gyz(:,:,k) * betaxx(:,:,k)
    gxz_rhs(:,:,k) = - TWO * alpn1(:,:,k) * Axz(:,:,k) + F1o3 * gxz(:,:,k) * div_beta(:,:,k) + &
                      gxx(:,:,k) * betaxz(:,:,k) + gxy(:,:,k) * betayz(:,:,k) + gyz(:,:,k) * betayx(:,:,k) + &
                      gzz(:,:,k) * betazx(:,:,k) - gxz(:,:,k) * betayy(:,:,k)

    ! Invert metric
    gupzz(:,:,k) = gxx(:,:,k) * gyy(:,:,k) * gzz(:,:,k) + gxy(:,:,k) * gyz(:,:,k) * gxz(:,:,k) + &
                   gxz(:,:,k) * gxy(:,:,k) * gyz(:,:,k) - gxz(:,:,k) * gyy(:,:,k) * gxz(:,:,k) - &
                   gxy(:,:,k) * gxy(:,:,k) * gzz(:,:,k) - gxx(:,:,k) * gyz(:,:,k) * gyz(:,:,k)
    gupxx(:,:,k) = ( gyy(:,:,k) * gzz(:,:,k) - gyz(:,:,k) * gyz(:,:,k) ) / gupzz(:,:,k)
    gupxy(:,:,k) = - ( gxy(:,:,k) * gzz(:,:,k) - gyz(:,:,k) * gxz(:,:,k) ) / gupzz(:,:,k)
    gupxz(:,:,k) = ( gxy(:,:,k) * gyz(:,:,k) - gyy(:,:,k) * gxz(:,:,k) ) / gupzz(:,:,k)
    gupyy(:,:,k) = ( gxx(:,:,k) * gzz(:,:,k) - gxz(:,:,k) * gxz(:,:,k) ) / gupzz(:,:,k)
    gupyz(:,:,k) = - ( gxx(:,:,k) * gyz(:,:,k) - gxy(:,:,k) * gxz(:,:,k) ) / gupzz(:,:,k)
    gupzz(:,:,k) = ( gxx(:,:,k) * gyy(:,:,k) - gxy(:,:,k) * gxy(:,:,k) ) / gupzz(:,:,k)
  end do
  !$OMP END DO
  ! --- [Phase 4: Connections] ---
  !$OMP DO
  do k = 1, ex(3)
    Gamxxx(:,:,k) = HALF * (gupxx(:,:,k)*gxxx(:,:,k) + gupxy(:,:,k)*(TWO*gxyx(:,:,k) - gxxy(:,:,k)) + gupxz(:,:,k)*(TWO*gxzx(:,:,k) - gxxz(:,:,k)))
    Gamyxx(:,:,k) = HALF * (gupxy(:,:,k)*gxxx(:,:,k) + gupyy(:,:,k)*(TWO*gxyx(:,:,k) - gxxy(:,:,k)) + gupyz(:,:,k)*(TWO*gxzx(:,:,k) - gxxz(:,:,k)))
    Gamzxx(:,:,k) = HALF * (gupxz(:,:,k)*gxxx(:,:,k) + gupyz(:,:,k)*(TWO*gxyx(:,:,k) - gxxy(:,:,k)) + gupzz(:,:,k)*(TWO*gxzx(:,:,k) - gxxz(:,:,k)))
    Gamxyy(:,:,k) = HALF * (gupxx(:,:,k)*(TWO*gxyy(:,:,k) - gyyx(:,:,k)) + gupxy(:,:,k)*gyyy(:,:,k) + gupxz(:,:,k)*(TWO*gyzy(:,:,k) - gyyz(:,:,k)))
    Gamyyy(:,:,k) = HALF * (gupxy(:,:,k)*(TWO*gxyy(:,:,k) - gyyx(:,:,k)) + gupyy(:,:,k)*gyyy(:,:,k) + gupyz(:,:,k)*(TWO*gyzy(:,:,k) - gyyz(:,:,k)))
    Gamzyy(:,:,k) = HALF * (gupxz(:,:,k)*(TWO*gxyy(:,:,k) - gyyx(:,:,k)) + gupyz(:,:,k)*gyyy(:,:,k) + gupzz(:,:,k)*(TWO*gyzy(:,:,k) - gyyz(:,:,k)))
    Gamxzz(:,:,k) = HALF * (gupxx(:,:,k)*(TWO*gxzz(:,:,k) - gzzx(:,:,k)) + gupxy(:,:,k)*(TWO*gyzz(:,:,k) - gzzy(:,:,k)) + gupxz(:,:,k)*gzzz(:,:,k))
    Gamyzz(:,:,k) = HALF * (gupxy(:,:,k)*(TWO*gxzz(:,:,k) - gzzx(:,:,k)) + gupyy(:,:,k)*(TWO*gyzz(:,:,k) - gzzy(:,:,k)) + gupyz(:,:,k)*gzzz(:,:,k))
    Gamzzz(:,:,k) = HALF * (gupxz(:,:,k)*(TWO*gxzz(:,:,k) - gzzx(:,:,k)) + gupyz(:,:,k)*(TWO*gyzz(:,:,k) - gzzy(:,:,k)) + gupzz(:,:,k)*gzzz(:,:,k))

    Gamxxy(:,:,k) = HALF * (gupxx(:,:,k)*gxxy(:,:,k) + gupxy(:,:,k)*gyyx(:,:,k) + gupxz(:,:,k)*(gxzy(:,:,k) + gyzx(:,:,k) - gxyz(:,:,k)))
    Gamyxy(:,:,k) = HALF * (gupxy(:,:,k)*gxxy(:,:,k) + gupyy(:,:,k)*gyyx(:,:,k) + gupyz(:,:,k)*(gxzy(:,:,k) + gyzx(:,:,k) - gxyz(:,:,k)))
    Gamzxy(:,:,k) = HALF * (gupxz(:,:,k)*gxxy(:,:,k) + gupyz(:,:,k)*gyyx(:,:,k) + gupzz(:,:,k)*(gxzy(:,:,k) + gyzx(:,:,k) - gxyz(:,:,k)))
    Gamxxz(:,:,k) = HALF * (gupxx(:,:,k)*gxxz(:,:,k) + gupxy(:,:,k)*(gxyz(:,:,k) + gyzx(:,:,k) - gxzy(:,:,k)) + gupxz(:,:,k)*gzzx(:,:,k))
    Gamyxz(:,:,k) = HALF * (gupxy(:,:,k)*gxxz(:,:,k) + gupyy(:,:,k)*(gxyz(:,:,k) + gyzx(:,:,k) - gxzy(:,:,k)) + gupyz(:,:,k)*gzzx(:,:,k))
    Gamzxz(:,:,k) = HALF * (gupxz(:,:,k)*gxxz(:,:,k) + gupyz(:,:,k)*(gxyz(:,:,k) + gyzx(:,:,k) - gxzy(:,:,k)) + gupzz(:,:,k)*gzzx(:,:,k))
    Gamxyz(:,:,k) = HALF * (gupxx(:,:,k)*(gxyz(:,:,k) + gxzy(:,:,k) - gyzx(:,:,k)) + gupxy(:,:,k)*gyyz(:,:,k) + gupxz(:,:,k)*gzzy(:,:,k))
    Gamyyz(:,:,k) = HALF * (gupxy(:,:,k)*(gxyz(:,:,k) + gxzy(:,:,k) - gyzx(:,:,k)) + gupyy(:,:,k)*gyyz(:,:,k) + gupyz(:,:,k)*gzzy(:,:,k))
    Gamzyz(:,:,k) = HALF * (gupxz(:,:,k)*(gxyz(:,:,k) + gxzy(:,:,k) - gyzx(:,:,k)) + gupyz(:,:,k)*gyyz(:,:,k) + gupzz(:,:,k)*gzzy(:,:,k))
  end do
  !$OMP END DO

  ! --- [Phase 5: Ricci Tensor Raising Indices] ---
  !$OMP DO
  do k = 1, ex(3)
    Rxx(:,:,k) = gupxx(:,:,k) * gupxx(:,:,k) * Axx(:,:,k) + gupxy(:,:,k) * gupxy(:,:,k) * Ayy(:,:,k) + gupxz(:,:,k) * gupxz(:,:,k) * Azz(:,:,k) + &
                 TWO*(gupxx(:,:,k) * gupxy(:,:,k) * Axy(:,:,k) + gupxx(:,:,k) * gupxz(:,:,k) * Axz(:,:,k) + gupxy(:,:,k) * gupxz(:,:,k) * Ayz(:,:,k))
    Ryy(:,:,k) = gupxy(:,:,k) * gupxy(:,:,k) * Axx(:,:,k) + gupyy(:,:,k) * gupyy(:,:,k) * Ayy(:,:,k) + gupyz(:,:,k) * gupyz(:,:,k) * Azz(:,:,k) + &
                 TWO*(gupxy(:,:,k) * gupyy(:,:,k) * Axy(:,:,k) + gupxy(:,:,k) * gupyz(:,:,k) * Axz(:,:,k) + gupyy(:,:,k) * gupyz(:,:,k) * Ayz(:,:,k))
    Rzz(:,:,k) = gupxz(:,:,k) * gupxz(:,:,k) * Axx(:,:,k) + gupyz(:,:,k) * gupyz(:,:,k) * Ayy(:,:,k) + gupzz(:,:,k) * gupzz(:,:,k) * Azz(:,:,k) + &
                 TWO*(gupxz(:,:,k) * gupyz(:,:,k) * Axy(:,:,k) + gupxz(:,:,k) * gupzz(:,:,k) * Axz(:,:,k) + gupyz(:,:,k) * gupzz(:,:,k) * Ayz(:,:,k))
    Rxy(:,:,k) = gupxx(:,:,k) * gupxy(:,:,k) * Axx(:,:,k) + gupxy(:,:,k) * gupyy(:,:,k) * Ayy(:,:,k) + gupxz(:,:,k) * gupyz(:,:,k) * Azz(:,:,k) + &
                 (gupxx(:,:,k) * gupyy(:,:,k) + gupxy(:,:,k) * gupxy(:,:,k)) * Axy(:,:,k) + &
                 (gupxx(:,:,k) * gupyz(:,:,k) + gupxz(:,:,k) * gupxy(:,:,k)) * Axz(:,:,k) + &
                 (gupxy(:,:,k) * gupyz(:,:,k) + gupxz(:,:,k) * gupyy(:,:,k)) * Ayz(:,:,k)
    Rxz(:,:,k) = gupxx(:,:,k) * gupxz(:,:,k) * Axx(:,:,k) + gupxy(:,:,k) * gupyz(:,:,k) * Ayy(:,:,k) + gupxz(:,:,k) * gupzz(:,:,k) * Azz(:,:,k) + &
                 (gupxx(:,:,k) * gupyz(:,:,k) + gupxy(:,:,k) * gupxz(:,:,k)) * Axy(:,:,k) + &
                 (gupxx(:,:,k) * gupzz(:,:,k) + gupxz(:,:,k) * gupxz(:,:,k)) * Axz(:,:,k) + &
                 (gupxy(:,:,k) * gupzz(:,:,k) + gupxz(:,:,k) * gupyz(:,:,k)) * Ayz(:,:,k)
    Ryz(:,:,k) = gupxy(:,:,k) * gupxz(:,:,k) * Axx(:,:,k) + gupyy(:,:,k) * gupyz(:,:,k) * Ayy(:,:,k) + gupyz(:,:,k) * gupzz(:,:,k) * Azz(:,:,k) + &
                 (gupxy(:,:,k) * gupyz(:,:,k) + gupyy(:,:,k) * gupxz(:,:,k)) * Axy(:,:,k) + &
                 (gupxy(:,:,k) * gupzz(:,:,k) + gupyz(:,:,k) * gupxz(:,:,k)) * Axz(:,:,k) + &
                 (gupyy(:,:,k) * gupzz(:,:,k) + gupyz(:,:,k) * gupyz(:,:,k)) * Ayz(:,:,k)
  end do
  !$OMP END DO

  !$OMP SECTIONS
    !$OMP SECTION
    call fderivs(ex,Lap,Lapx,Lapy,Lapz,X,Y,Z,SYM,SYM,SYM,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,trK,Kx,Ky,Kz,X,Y,Z,SYM,SYM,SYM,symmetry,Lev)
  !$OMP END SECTIONS

  !$OMP DO
  do k = 1, ex(3)
    Gamx_rhs(:,:,k) = - TWO * (Lapx(:,:,k) * Rxx(:,:,k) + Lapy(:,:,k) * Rxy(:,:,k) + Lapz(:,:,k) * Rxz(:,:,k)) + &
         TWO * alpn1(:,:,k) * ( -F3o2/chin1(:,:,k) * (chix(:,:,k)*Rxx(:,:,k) + chiy(:,:,k)*Rxy(:,:,k) + chiz(:,:,k)*Rxz(:,:,k)) - &
         gupxx(:,:,k) * (F2o3*Kx(:,:,k) + EIGHT*PI*Sx(:,:,k)) - gupxy(:,:,k) * (F2o3*Ky(:,:,k) + EIGHT*PI*Sy(:,:,k)) - &
         gupxz(:,:,k) * (F2o3*Kz(:,:,k) + EIGHT*PI*Sz(:,:,k)) + Gamxxx(:,:,k)*Rxx(:,:,k) + Gamxyy(:,:,k)*Ryy(:,:,k) + &
         Gamxzz(:,:,k)*Rzz(:,:,k) + TWO * (Gamxxy(:,:,k)*Rxy(:,:,k) + Gamxxz(:,:,k)*Rxz(:,:,k) + Gamxyz(:,:,k)*Ryz(:,:,k)) )
    ! ... 此处复现 Gamy_rhs, Gamz_rhs 的完整公式 ...
  end do
  !$OMP END DO

  !$OMP SECTIONS
    !$OMP SECTION
    call fdderivs(ex,betax,gxxx,gxyx,gxzx,gyyx,gyzx,gzzx,X,Y,Z,ANTI,SYM, SYM ,Symmetry,Lev)
    !$OMP SECTION
    call fdderivs(ex,betay,gxxy,gxyy,gxzy,gyyy,gyzy,gzzy,X,Y,Z,SYM ,ANTI,SYM ,Symmetry,Lev)
    !$OMP SECTION
    call fdderivs(ex,betaz,gxxz,gxyz,gxzz,gyyz,gyzz,gzzz,X,Y,Z,SYM ,SYM, ANTI,Symmetry,Lev)
  !$OMP END SECTIONS

  !$OMP DO
  do k = 1, ex(3)
    fxx(:,:,k) = gxxx(:,:,k) + gxyy(:,:,k) + gxzz(:,:,k)
    fxy(:,:,k) = gxyx(:,:,k) + gyyy(:,:,k) + gyzz(:,:,k)
    fxz(:,:,k) = gxzx(:,:,k) + gyzy(:,:,k) + gzzz(:,:,k)
    Gamxa(:,:,k) = gupxx(:,:,k)*Gamxxx(:,:,k) + gupyy(:,:,k)*Gamxyy(:,:,k) + gupzz(:,:,k)*Gamxzz(:,:,k) + &
                   TWO*(gupxy(:,:,k)*Gamxxy(:,:,k) + gupxz(:,:,k)*Gamxxz(:,:,k) + gupyz(:,:,k)*Gamxyz(:,:,k))
    Gamya(:,:,k) = gupxx(:,:,k)*Gamyxx(:,:,k) + gupyy(:,:,k)*Gamyyy(:,:,k) + gupzz(:,:,k)*Gamyzz(:,:,k) + &
                   TWO*(gupxy(:,:,k)*Gamyxy(:,:,k) + gupxz(:,:,k)*Gamyxz(:,:,k) + gupyz(:,:,k)*Gamyyz(:,:,k))
    Gamza(:,:,k) = gupxx(:,:,k)*Gamzxx(:,:,k) + gupyy(:,:,k)*Gamzyy(:,:,k) + gupzz(:,:,k)*Gamzzz(:,:,k) + &
                   TWO*(gupxy(:,:,k)*Gamzxy(:,:,k) + gupxz(:,:,k)*Gamzxz(:,:,k) + gupyz(:,:,k)*Gamzyz(:,:,k))
  end do
  !$OMP END DO
  !$OMP SECTIONS
    !$OMP SECTION
    call fderivs(ex,Gamx,Gamxx,Gamxy,Gamxz,X,Y,Z,ANTI,SYM ,SYM ,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,Gamy,Gamyx,Gamyy,Gamyz,X,Y,Z,SYM ,ANTI,SYM ,Symmetry,Lev)
    !$OMP SECTION
    call fderivs(ex,Gamz,Gamzx,Gamzy,Gamzz,X,Y,Z,SYM ,SYM ,ANTI,Symmetry,Lev)
  !$OMP END SECTIONS

  ! --- [Gauge Logic] ---
  !$OMP DO
  do k = 1, ex(3)
    Lap_rhs(:,:,k) = -TWO*alpn1(:,:,k)*trK(:,:,k)
    #if (GAUGE == 0)
      betax_rhs(:,:,k) = FF*dtSfx(:,:,k)
      betay_rhs(:,:,k) = FF*dtSfy(:,:,k)
      betaz_rhs(:,:,k) = FF*dtSfz(:,:,k)
      dtSfx_rhs(:,:,k) = Gamx_rhs(:,:,k) - eta*dtSfx(:,:,k)
      dtSfy_rhs(:,:,k) = Gamy_rhs(:,:,k) - eta*dtSfy(:,:,k)
      dtSfz_rhs(:,:,k) = Gamz_rhs(:,:,k) - eta*dtSfz(:,:,k)
    #endif
  end do
  !$OMP END DO

  !$OMP END PARALLEL

  SSS = (/SYM, SYM, SYM/); AAS = (/ANTI, ANTI, SYM/); ASA = (/ANTI, SYM, ANTI/)
  SAA = (/SYM, ANTI, ANTI/); ASS = (/ANTI, SYM, SYM/); SAS = (/SYM, ANTI, SYM/); SSA = (/SYM, SYM, ANTI/)

  ! --- [Phase 9: Advection & Dissipation] ---
  call lopsided(ex,X,Y,Z,gxx,gxx_rhs,betax,betay,betaz,Symmetry,SSS)
  call lopsided(ex,X,Y,Z,gxy,gxy_rhs,betax,betay,betaz,Symmetry,AAS)
  call lopsided(ex,X,Y,Z,gxz,gxz_rhs,betax,betay,betaz,Symmetry,ASA)
  call lopsided(ex,X,Y,Z,gyy,gyy_rhs,betax,betay,betaz,Symmetry,SSS)
  call lopsided(ex,X,Y,Z,gyz,gyz_rhs,betax,betay,betaz,Symmetry,SAA)
  call lopsided(ex,X,Y,Z,gzz,gzz_rhs,betax,betay,betaz,Symmetry,SSS)

  if(eps>0)then 
    call kodis(ex,X,Y,Z,chi,chi_rhs,SSS,Symmetry,eps)
    call kodis(ex,X,Y,Z,trK,trK_rhs,SSS,Symmetry,eps)
    call kodis(ex,X,Y,Z,dxx,gxx_rhs,SSS,Symmetry,eps)
    call kodis(ex,X,Y,Z,gxy,gxy_rhs,AAS,Symmetry,eps)
    call kodis(ex,X,Y,Z,gxz,gxz_rhs,ASA,Symmetry,eps)
    call kodis(ex,X,Y,Z,dyy,gyy_rhs,SSS,Symmetry,eps)
    call kodis(ex,X,Y,Z,gyz,gyz_rhs,SAA,Symmetry,eps)
    call kodis(ex,X,Y,Z,dzz,gzz_rhs,SSS,Symmetry,eps)
  endif

  gont = 0
  return
  end function compute_rhs_bssn

  ! --- compute_rhs_bssn_ss 的逻辑结构同上，仅在 shellpatch 下运行 ---
  function compute_rhs_bssn_ss(ex, T,crho,sigma,R,x,y,z, ...)
    ! (此处省略声明...)
    !$OMP PARALLEL DO DEFAULT(SHARED) PRIVATE(k)
    do k = 1, ex(3)
       ! ... 执行 shellpatch 下的数组转循环逻辑 ...
    end do
  end function compute_rhs_bssn_ss