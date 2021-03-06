load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
level=850
year=ispan(1,29,1)  ; 79/80 - 13/14
it_s=131  ;起始年月
it_e=478  ;结束年月

refmag = 3   ;参考箭头所表示的风速大小
    outfile    = "/home/ys17-19/cjx/figure/HEAT_EMC_figure/ENSO/comp"+level
    ;;;read data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
       f_in  =addfile("/home/ys17-19/cjx/all_output_data/HEAT_EMC_output/HEAT_EMC.cam.h0.250-289.nc","r")
       sst=f_in->TS(it_s:it_e:1,:,:) ; 截取指定时间段
       h=f_in->Z3(it_s:it_e:1,{level},:,:) ; 截取指定时间段
       u=f_in->U(it_s:it_e:1,{level},:,:) ; 截取指定时间段
       v=f_in->V(it_s:it_e:1,{level},:,:) ; 截取指定时间段
       t=f_in->T(it_s:it_e:1,{level},:,:) ; 截取指定时间段
    
      sst_DJF=month_to_season(sst,"JFM")
        ;JFM季节平均，实际是12/1/2月三个月平均，因为从1979年12月开始截取
      copy_VarMeta(sst(0,:,:),sst_DJF(0,:,:))
      sst_DJF!0 = "year"
      sst_DJF&year=year 
      printVarSummary(sst_DJF)
      sst_ano = dim_rmvmean_n_Wrap(sst_DJF,0)
       
      ;;; h
      h_DJF = month_to_season(h, "JFM") 
      copy_VarMeta(h(0,:,:),h_DJF(0,:,:))
      h_DJF!0 = "year"
      h_DJF&year=year 
    
      h_ano = dim_rmvmean_n_Wrap(h_DJF,0)
    
      ;;; u 与h 同维  
      u_DJF = month_to_season(u, "JFM") 
      copy_VarMeta(h_DJF,u_DJF)
    
      u_ano = dim_rmvmean_n_Wrap(u_DJF,0)
      
      ;; v 与h 同维  
      v_DJF = month_to_season(v, "JFM") 
      copy_VarMeta(h_DJF,v_DJF)   
    
      v_ano = dim_rmvmean_n_Wrap(v_DJF,0)
        
      ;; t
      t_DJF = month_to_season(t, "JFM") 
      copy_VarMeta(t(0,:,:),t_DJF(0,:,:))
      t_DJF!0   ="year"
      t_DJF&year=year   
        
      t_ano = dim_rmvmean_n_Wrap(t_DJF,0)
        
    ;;;(3) enso index (5N-5S, 170-120W);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
         ; 0表示仅用非缺省的数值进行计算 
         ;1 表示标准化时除以的是[N] ; 而0表示除以[N-1]
      
      ;; 输出至netcdf文件
       ensoi = wgt_areaave_Wrap(sst_DJF(:,{-5:5},{190:240}),1.,1.,0)
       ensoi = dim_standardize_Wrap(ensoi,1)
    
    ;;;(4) composite ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      irec_positive=ind(ensoi .gt. 0.8)
      nnumb = dimsizes(irec_positive) 
      
        
      sst_comp  = dim_avg_n_Wrap(sst_ano(irec_positive,:,:),0) 
      h_comp  = dim_avg_n_Wrap(h_ano(irec_positive,:,:),0) 
      u_comp  = dim_avg_n_Wrap(u_ano(irec_positive,:,:),0)    
      v_comp  = dim_avg_n_Wrap(v_ano(irec_positive,:,:),0) 
      t_comp = dim_avg_n_Wrap(t_ano(irec_positive,:,:),0)  
    
    ;;;; (5) t-test ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; sst
      sst_std = dim_variance_n_Wrap(sst_ano(irec_positive,:,:),0)
      sst_std = sqrt(sst_std/nnumb)
      sst_std = where(sst_std .eq. 0,sst_std@_FillValue,sst_std)
      t_sst   = sst_comp/sst_std       
      confi_sst = sst_comp
      confi_sst = student_t(t_sst, nnumb-1)   
    
      ;;; h
      h_std = dim_variance_n_Wrap(h_ano(irec_positive,:,:),0)
      h_std = sqrt(h_std/nnumb)
      h_std = where(h_std .eq. 0,h_std@_FillValue,h_std)
      t_h   = h_comp/h_std       
      confi_h = h_comp
      confi_h = student_t(t_h, nnumb-1)   
    
      ;;; t
      t_std = dim_variance_n_Wrap(t_ano(irec_positive,:,:),0)
      t_std = sqrt(t_std/nnumb)
      t_std = where(t_std .eq. 0,t_std@_FillValue,t_std)
      t_t   = t_comp/t_std       
      confi_t = t_comp
      confi_t = student_t(t_t, nnumb-1) 
        
    ;;;; (5) plot
      wks = gsn_open_wks("png",outfile)
      gsn_define_colormap(wks,"rainbow+gray")  ; 调用rainbow+gray色板,，其它色板名称请查阅http://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml
      
      base = new(3,"graphic")
      plot = new(3,"graphic")  
            
      res                   = True   ; 调整地图及显著性等值线, 每个子图均需该res
      res@gsnAddCyclic      = True   ; 添加循环点，否则会在0度经线左侧出现一根白条
      res@gsnDraw           = False        
      res@gsnFrame          = False        
      res@gsnLeftString     = ""
      res@gsnRightString    = ""
      
      resc = res  ;拷贝
      resv = res  ;
      rest = res  ;
      
      res@mpFillOn             = False        ; 不填色地图
      res@mpCenterLonF         = 180          ; 地图的中心经度 
      res@mpGeophysicalLineThicknessF = 0.5   ; 地图边界的粗细
      res@pmTickMarkDisplayMode= "Always"     ; 坐标上标签上添加度符号
      res@mpGridAndLimbOn      = True         ; 绘制经纬度线
      res@mpGridLatSpacingF    = 30           ; 经纬度线间隔
      res@mpGridLonSpacingF    = 60           ; 经纬度线间隔
      res@mpGridLineDashPattern=2             ; 经纬度线线型取为类型为2的虚线。共17种线型供选择。
      res@mpGridLineThicknessF =0.5           ; 其粗细
                  
      res@cnFillOn             = True         ; 填色等值线
      res@cnLinesOn            = True         ; 绘制等值线
      res@cnLineColor          = "white"      ; 颜色
      res@cnLineThicknessF     = 0.3          ; 粗细
      res@cnLineLabelsOn       = False        ; 关闭标签
    
        
      res@cnLevelSelectionMode  = "ExplicitLevels"                ; 指定每根需绘制的等值线
      res@cnLevels              = (/0.01,0.05/)
      res@cnFillPalette         = "GMT_gray"                      ; 用GMT_gray 进行填色。即调用了第2种色板
      res@cnFillColors          = (/5,7,-1/)                      ; -1 为透明
      res@cnInfoLabelOn         = False       ; 关闭图右下方的等值线信息标签
      res@lbLabelBarOn          = False       ; 关闭labelbar
     
      ;resc@cnLevelSelectionMode  = "ExplicitLevels"                ; 指定每根需绘制的等值线
      ;resc@cnLevels              = (/-0.75,-0.25,0,0.25,0.75/)  ;   
      resc@cnFillOn              = False     ; 关闭等值线填色 
      resc@cnLineThicknessF      = 2.        ; 等值线粗细  
      resc@gsnContourZeroLineThicknessF = 0. ; 设置0值线粗细。0则不画
      resc@cnLineLabelsOn        = False     ; 关闭标签
      resc@cnLineDashPattern     = 16        ; 线型为16的虚线
      resc@cnInfoLabelOn         = True      ; 打开图右下方的等值线信息标签
      resc@cnInfoLabelOrthogonalPosF = 0.05  ; 移动等值线信息标签的位置
    
      resv@vcPositionMode            = "ArrowTail"  ;箭头尾部对应着格点的位置
      resv@vcGlyphStyle              = "Fillarrow"  ;其余三种选项为“LineArrow”、“WindBarb” 、“CurlyVector”
      resv@vcFillArrowEdgeThicknessF = 2         ; 箭头边界粗细
      resv@vcFillArrowEdgeColor      = "white"   ; 及颜色
      resv@vcFillArrowFillColor      = "black"  ; 箭头内部填充颜色
      resv@vcFillArrowWidthF         = 0.1       ; 箭头宽度
      resv@vcFillArrowHeadXF         = 0.6       ; 请参考附录中Fillarrow箭头示意图
      resv@vcFillArrowHeadYF         = 0.2       ;
      resv@vcFillArrowHeadInteriorXF = 0.25      ; 
               
      resv@vcMinDistanceF            = 0.03    ; 箭头之间的最小距离（在单位平方中）
      resv@vcMinMagnitudeF           = 1.0     ; 要绘制箭头所表示的最小数值，即小于该数值则不绘制
    
      resv@vcFillArrowMinFracWidthF =0.3 
      resv@vcFillArrowHeadMinFracXF =0.3  
      resv@vcFillArrowHeadMinFracYF =0.3 
      
        ;****设定参考箭头****
        resv@vcRefAnnoOn               = True  
        resv@vcRefMagnitudeF           = refmag  ;标准长度箭头所表示的大小
        resv@vcRefLengthF              = 0.045   ;标准长度箭头在单位平方中的大小
        resv@vcRefAnnoBackgroundColor  = "white" ;背景颜色     
        resv@vcRefAnnoPerimOn          = False   ;关闭边框    
                                            
        resv@vcRefAnnoFontHeightF      = 0.015   ;参考箭头标签字体大小      
        
        resv@vcRefAnnoString1On     = False   ;设定参考箭头上、下的字符        
        resv@vcRefAnnoString2On     = True    ; 这里仅设定其下方的字符
        resv@vcRefAnnoString2       = refmag+" m/s"  
               
        resv@vcRefAnnoSide            = "Top" ; 参考箭头放至图形上方
        resv@vcRefAnnoOrthogonalPosF  = -0.12 ; 调整其位置
        resv@vcRefAnnoParallelPosF    = 0.95 
        
    
      res@gsnCenterString            = "sst" ;子图的主标题 
      res@gsnCenterStringFontHeightF = 0.03  ; 标题字体的大小。由于后面没有修改该值，则每幅图的主标题字体均是此大小
      base(0) = gsn_csm_contour_map(wks,confi_sst,res) ; 只有底图可有地图（map）  
      plot(0) = gsn_csm_contour(wks,sst_comp,resc)      ; 调用的绘图函数不可带“map”
      plot(0) = ColorNegDashZeroPosContour(plot(0),"blue","white","red") ; 负值用蓝色虚线表示，0线用白色实线，正值红色实线
      overlay(base(0),plot(0))     ; 带地图的图必须放在最下图层
    
      ; 绘制多边形及折线以标明nino 3.4区 
      plres                  = True
      plres@gsLineColor      = "black"
      plres@gsLineThicknessF = 1.0
      
      gres                   = True
      gres@gsFillColor       = "yellow"
      gres@gsFillOpacityF    = 0.5
      gres@gsLineColor       = "black"
       
      latx = (/-5,    5,  5, -5, -5/)    ; nino3.4区的坐标位置
      lonx = (/190, 190,240, 240, 190/)  ;
      dum1 = gsn_add_polyline(wks, base(0),lonx,latx,plres)   
      dum2 = gsn_add_polygon(wks,base(0),lonx,latx,gres)
      
      res@gsnCenterString = "h&wind"+level  
      resc@cnLevelSelectionMode  = "ExplicitLevels"                ; 指定每根需绘制的等值线
      resc@cnLevels             := (/-500,-400,-300,-200,-100,0,100,200,300,400,500/)  ;   
      ;resc@cnLevelSpacingF = 1.
      base(1) = gsn_csm_contour_map(wks,confi_h,res)  
      plot(1) = gsn_csm_contour(wks,h_comp,resc) 
      plot(1) = ColorNegDashZeroPosContour(plot(1),"blue","white","red")
      overlay(base(1),plot(1))
      ;draw(base(1))
      ;frame(wks)
      
      plotv   = gsn_csm_vector(wks,u_comp,v_comp,resv) 
      overlay(base(1),plotv)  ; 也可用gsn_csm_vector_map(wks,h_comp,u,v,res_new)
    
      res@gsnCenterString       = "t"+level  
      resc@cnLevelSelectionMode = "ManualLevels" 
      resc@cnMaxLevelValF       = 4
      resc@cnMinLevelValF       = -4 
      resc@cnLevelSpacingF      = 0.5    
      base(2) = gsn_csm_contour_map(wks,confi_t,res)  
      plot(2) = gsn_csm_contour(wks,t_comp,resc) 
      plot(2) = ColorNegDashZeroPosContour(plot(2),"blue","black","red")
      overlay(base(2),plot(2))  
      
      resP = True                        ; 绘制panel图
      resP@txString       = "El nino"    ; 添加主标题
      resP@txFontHeightF  = 0.03         ; 修改其大小  
    
     ; resP@gsnPanelFigureStrings= (/"a)","b)","c)"/)  ;各个子图的标号
      resP@gsnPanelFigureStringsFontHeightF = 0.015   ;字体的大小 
      resP@amJust = "TopLeft"                         ;摆放的位置，默认是“BottomRight”
      
      resP@gsnPanelRowSpec = True       ; 指定每行绘制的子图的个数
      gsn_panel(wks,base(1:),(/2/),resP)        ; 第1行绘制1幅，第2行绘制2幅
end
