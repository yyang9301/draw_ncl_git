l_thick= 2
begin
outfile="/home/ys17-19/cjx/figure/correlation-observation/correlation_uwnd850"
in_file="/home/yangsong3/data-observation/NCEP_DOE/monthly/197901-201801/uwnd.mon.mean.nc"
fin_var = addfile(in_file,"r")
var = fin_var->uwnd(0:467:1,{850},:,:)
printVarSummary(var)
var_ssn = month_to_season(short2flt(var),"MAM")
printVarSummary(var_ssn)
var_reference=var_ssn({lat | 0.0},{lon | 115.0},time|:)
;printVarSummary(var_reference)
;print(var_reference)
r=var_ssn(0,:,:)
r=escorc(var_ssn(lat|:,lon|:,time|:),var_reference)
print(r({lat | 0.0},{lon | 115.0}))


r_sig_level=0.316;  siglvl = 0.05
;  xtmp = pre_T_ssn(lat |:,lon |:,time |:)
;  ytmp = var_reference
;  aveX = dim_avg(xtmp)
;  aveY = dim_avg(ytmp)
;  varX = dim_variance(xtmp)
;  varY = dim_variance(ytmp)
;  eqvX = equiv_sample_size(xtmp,siglvl,0)
;  eqvY = equiv_sample_size(ytmp,siglvl,0)
;  nX   = wgt_areaave(eqvX, 1, 1, 0)
;  nY   = wgt_areaave(eqvY, 1, 1, 0)
;  prob = pre_T_ssn(0,:,:)
;  prob = ttest(aveX, varX, nX, aveY, varY, nY, False, False)
;  pre_diff_sig=var
;  pre_diff_sig=mask(var, prob .lt. siglvl, True)
  ;printVarSummary(var)
  ;printVarSummary(prob)
  ;printVarSummary(pre_diff_sig)
sig=var_ssn(0,:,:)
sig=mask(r, abs(r) .gt. r_sig_level,True)

wks = gsn_open_wks("png",outfile)
gsn_define_colormap(wks,"BlueWhiteOrangeRed")
res=True
res@gsnDraw         = False
res@gsnFrame        = False
res@gsnLeftString   = "uwnd_850hPa & (0.0N,115.0E) correlation coefficient "                   
res@gsnRightString  = "NCEP_DOE"                 
res@gsnCenterString = " "
res@cnLineThicknessF =3.
res@cnLinesOn            = False
res@cnFillOn             = True
res@cnLevelSelectionMode = "ManualLevels"
res@cnFillColors =(/2,17,33,49,81,161,193,209,225,241/)
res@cnMinLevelValF        = -0.8         ; set min contour level
res@cnMaxLevelValF        = 0.8         ; set max contour level
res@cnLevelSpacingF       = 0.2          ; set contour interval
res@mpFillOn=False
;res@tmXMajorGrid=True
;res@tmXMinorGridLineDashPattern =3
;res@tmXMinorGridThicknessF=0.3
;res@tmXBMode="Manual"
;res@tmXBTickStartF=1979
;res@tmXBTickEndF=2015
;res@tmXBLabelFontHeightF =0.021
res@mpGeophysicalLineThicknessF =l_thick
;res@txString ="significant level = 0.05"
;res@txPosXF=0.5
;res@txPosYF =0.5
    plot1 = new(1,"graphic")
    plot2 = new(1,"graphic")
  res4                  = True       ; use plot options
  res4@cnFillOn         = True       ; Fill contours
  res4@cnLinesOn        = False;True      ; turn off contour lines
  res4@gsnFrame         = False
  res4@gsnDraw  = False
  res4@gsnLeftString   = " "                   
  res4@gsnRightString  = " "                 
  res4@gsnCenterString = " "
  res4@cnLineLabelsOn   = False      ; turn off contour line labels
  res4@cnLineThicknessF = 2
  res4@cnLineColor      = "black"
  res4@cnInfoLabelOn = False
  res4@cnMonoFillPattern    = True;False
  res4@cnFillPattern = 17
  res4@cnMonoFillScale = True
  res4@cnFillScaleF = 1.
  res4@cnMonoFillColor = True
  res4@cnFillColor  =  "black"
  res4@cnFillDotSizeF = 0.004
  res4@lbLabelBarOn =False
  plot1 = gsn_csm_contour_map(wks,r,res)
  plot2 = gsn_csm_contour(wks,sig,res4)
  overlay(plot1,plot2)
  draw(plot1)
  frame(wks)
end
