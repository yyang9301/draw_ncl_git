load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
level=500
year=ispan(1,29,1)  ; 79/80 - 13/14
it_s=131  ;��ʼ����
it_e=478  ;��������

refmag = 5   ;�ο���ͷ����ʾ�ķ��ٴ�С
    outfile    = "/home/ys17-19/cjx/figure/HEAT_EMC_figure/ENSO/comp"+level
    ;;;read data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
       f_in  =addfile("/home/ys17-19/cjx/all_output_data/HEAT_EMC_output/HEAT_EMC.cam.h0.250-289.nc","r")
       sst=f_in->TS(it_s:it_e:1,:,:) ; ��ȡָ��ʱ���
       h=f_in->Z3(it_s:it_e:1,{level},:,:) ; ��ȡָ��ʱ���
       u=f_in->U(it_s:it_e:1,{level},:,:) ; ��ȡָ��ʱ���
       v=f_in->V(it_s:it_e:1,{level},:,:) ; ��ȡָ��ʱ���
       t=f_in->T(it_s:it_e:1,{level},:,:) ; ��ȡָ��ʱ���
    
      sst_DJF=month_to_season(sst,"JFM")
        ;JFM����ƽ����ʵ����12/1/2��������ƽ������Ϊ��1979��12�¿�ʼ��ȡ
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
    
      ;;; u ��h ͬά  
      u_DJF = month_to_season(u, "JFM") 
      copy_VarMeta(h_DJF,u_DJF)
    
      u_ano = dim_rmvmean_n_Wrap(u_DJF,0)
      
      ;; v ��h ͬά  
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
         ; 0��ʾ���÷�ȱʡ����ֵ���м��� 
         ;1 ��ʾ��׼��ʱ���Ե���[N] ; ��0��ʾ����[N-1]
      
      ;; �����netcdf�ļ�
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
      t_h   = h_comp/h_std       
      confi_h = h_comp
      confi_h = student_t(t_h, nnumb-1)   
    
      ;;; t
      t_std = dim_variance_n_Wrap(t_ano(irec_positive,:,:),0)
      t_std = sqrt(t_std/nnumb)
      t_t   = t_comp/t_std       
      confi_t = t_comp
      confi_t = student_t(t_t, nnumb-1) 
        
    ;;;; (5) plot
      wks = gsn_open_wks("png",outfile)
      gsn_define_colormap(wks,"rainbow+gray")  ; ����rainbow+grayɫ��,������ɫ�����������http://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml
      
      base = new(3,"graphic")
      plot = new(3,"graphic")  
            
      res                   = True   ; ������ͼ�������Ե�ֵ��, ÿ����ͼ�����res
      res@gsnAddCyclic      = True   ; ����ѭ���㣬�������0�Ⱦ���������һ������
      res@gsnDraw           = False        
      res@gsnFrame          = False        
      res@gsnLeftString     = ""
      res@gsnRightString    = ""
      
      resc = res  ;����
      resv = res  ;
      rest = res  ;
      
      res@mpFillOn             = False        ; ����ɫ��ͼ
      res@mpCenterLonF         = 180          ; ��ͼ�����ľ��� 
      res@mpGeophysicalLineThicknessF = 0.5   ; ��ͼ�߽�Ĵ�ϸ
      res@pmTickMarkDisplayMode= "Always"     ; �����ϱ�ǩ�����Ӷȷ���
      res@mpGridAndLimbOn      = True         ; ���ƾ�γ����
      res@mpGridLatSpacingF    = 30           ; ��γ���߼��
      res@mpGridLonSpacingF    = 60           ; ��γ���߼��
      res@mpGridLineDashPattern=2             ; ��γ��������ȡΪ����Ϊ2�����ߡ���17�����͹�ѡ��
      res@mpGridLineThicknessF =0.5           ; ���ϸ
                  
      res@cnFillOn             = True         ; ��ɫ��ֵ��
      res@cnLinesOn            = True         ; ���Ƶ�ֵ��
      res@cnLineColor          = "white"      ; ��ɫ
      res@cnLineThicknessF     = 0.3          ; ��ϸ
      res@cnLineLabelsOn       = False        ; �رձ�ǩ
    
        
      res@cnLevelSelectionMode  = "ExplicitLevels"                ; ָ��ÿ������Ƶĵ�ֵ��
      res@cnLevels              = (/0.01,0.05/)
      res@cnFillPalette         = "GMT_gray"                      ; ��GMT_gray ������ɫ���������˵�2��ɫ��
      res@cnFillColors          = (/5,7,-1/)                      ; -1 Ϊ͸��
      res@cnInfoLabelOn         = False       ; �ر�ͼ���·��ĵ�ֵ����Ϣ��ǩ
      res@lbLabelBarOn          = False       ; �ر�labelbar
     
      ;resc@cnLevelSelectionMode  = "ExplicitLevels"                ; ָ��ÿ������Ƶĵ�ֵ��
      ;resc@cnLevels              = (/-0.75,-0.25,0,0.25,0.75/)  ;   
      resc@cnFillOn              = False     ; �رյ�ֵ����ɫ 
      resc@cnLineThicknessF      = 2.        ; ��ֵ�ߴ�ϸ  
      resc@gsnContourZeroLineThicknessF = 0. ; ����0ֵ�ߴ�ϸ��0�򲻻�
      resc@cnLineLabelsOn        = False     ; �رձ�ǩ
      resc@cnLineDashPattern     = 16        ; ����Ϊ16������
      resc@cnInfoLabelOn         = True      ; ��ͼ���·��ĵ�ֵ����Ϣ��ǩ
      resc@cnInfoLabelOrthogonalPosF = 0.05  ; �ƶ���ֵ����Ϣ��ǩ��λ��
    
      resv@vcPositionMode            = "ArrowTail"  ;��ͷβ����Ӧ�Ÿ���λ��
      resv@vcGlyphStyle              = "Fillarrow"  ;��������ѡ��Ϊ��LineArrow������WindBarb�� ����CurlyVector��
      resv@vcFillArrowEdgeThicknessF = 2         ; ��ͷ�߽��ϸ
      resv@vcFillArrowEdgeColor      = "white"   ; ����ɫ
      resv@vcFillArrowFillColor      = "black"  ; ��ͷ�ڲ������ɫ
      resv@vcFillArrowWidthF         = 0.1       ; ��ͷ����
      resv@vcFillArrowHeadXF         = 0.6       ; ��ο���¼��Fillarrow��ͷʾ��ͼ
      resv@vcFillArrowHeadYF         = 0.2       ;
      resv@vcFillArrowHeadInteriorXF = 0.25      ; 
               
      resv@vcMinDistanceF            = 0.03    ; ��ͷ֮�����С���루�ڵ�λƽ���У�
      resv@vcMinMagnitudeF           = 1.0     ; Ҫ���Ƽ�ͷ����ʾ����С��ֵ����С�ڸ���ֵ�򲻻���
    
      resv@vcFillArrowMinFracWidthF =0.3 
      resv@vcFillArrowHeadMinFracXF =0.3  
      resv@vcFillArrowHeadMinFracYF =0.3 
      
        ;****�趨�ο���ͷ****
        resv@vcRefAnnoOn               = True  
        resv@vcRefMagnitudeF           = refmag  ;��׼���ȼ�ͷ����ʾ�Ĵ�С
        resv@vcRefLengthF              = 0.045   ;��׼���ȼ�ͷ�ڵ�λƽ���еĴ�С
        resv@vcRefAnnoBackgroundColor  = "white" ;������ɫ     
        resv@vcRefAnnoPerimOn          = False   ;�رձ߿�    
                                            
        resv@vcRefAnnoFontHeightF      = 0.015   ;�ο���ͷ��ǩ�����С      
        
        resv@vcRefAnnoString1On     = False   ;�趨�ο���ͷ�ϡ��µ��ַ�        
        resv@vcRefAnnoString2On     = True    ; ������趨���·����ַ�
        resv@vcRefAnnoString2       = refmag+" m/s"  
               
        resv@vcRefAnnoSide            = "Top" ; �ο���ͷ����ͼ���Ϸ�
        resv@vcRefAnnoOrthogonalPosF  = -0.12 ; ������λ��
        resv@vcRefAnnoParallelPosF    = 0.95 
        
    
      res@gsnCenterString            = "sst" ;��ͼ�������� 
      res@gsnCenterStringFontHeightF = 0.03  ; ��������Ĵ�С�����ں���û���޸ĸ�ֵ����ÿ��ͼ��������������Ǵ˴�С
      base(0) = gsn_csm_contour_map(wks,confi_sst,res) ; ֻ�е�ͼ���е�ͼ��map��  
      plot(0) = gsn_csm_contour(wks,sst_comp,resc)      ; ���õĻ�ͼ�������ɴ���map��
      plot(0) = ColorNegDashZeroPosContour(plot(0),"blue","white","red") ; ��ֵ����ɫ���߱�ʾ��0���ð�ɫʵ�ߣ���ֵ��ɫʵ��
      overlay(base(0),plot(0))     ; ����ͼ��ͼ�����������ͼ��
    
      ; ���ƶ���μ������Ա���nino 3.4�� 
      plres                  = True
      plres@gsLineColor      = "black"
      plres@gsLineThicknessF = 1.0
      
      gres                   = True
      gres@gsFillColor       = "yellow"
      gres@gsFillOpacityF    = 0.5
      gres@gsLineColor       = "black"
       
      latx = (/-5,    5,  5, -5, -5/)    ; nino3.4��������λ��
      lonx = (/190, 190,240, 240, 190/)  ;
      dum1 = gsn_add_polyline(wks, base(0),lonx,latx,plres)   
      dum2 = gsn_add_polygon(wks,base(0),lonx,latx,gres)
      
      res@gsnCenterString = "h&wind"+level  
      resc@cnLevelSelectionMode  = "ExplicitLevels"                ; ָ��ÿ������Ƶĵ�ֵ��
      resc@cnLevels             := (/-500,-400,-300,-200,-100,0,100,200,300,400,500/)  ;   
      ;resc@cnLevelSpacingF = 1.
      base(1) = gsn_csm_contour_map(wks,confi_h,res)  
      plot(1) = gsn_csm_contour(wks,h_comp,resc) 
      plot(1) = ColorNegDashZeroPosContour(plot(1),"blue","white","red")
      overlay(base(1),plot(1))
      ;draw(base(1))
      ;frame(wks)
      
      plotv   = gsn_csm_vector(wks,u_comp,v_comp,resv) 
      overlay(base(1),plotv)  ; Ҳ����gsn_csm_vector_map(wks,h_comp,u,v,res_new)
    
      res@gsnCenterString       = "t"+level  
      resc@cnLevelSelectionMode = "ManualLevels" 
      resc@cnMaxLevelValF       = 4
      resc@cnMinLevelValF       = -4 
      resc@cnLevelSpacingF      = 0.5    
      base(2) = gsn_csm_contour_map(wks,confi_t,res)  
      plot(2) = gsn_csm_contour(wks,t_comp,resc) 
      plot(2) = ColorNegDashZeroPosContour(plot(2),"blue","black","red")
      overlay(base(2),plot(2))  
      
      resP = True                        ; ����panelͼ
      resP@txString       = "El nino"    ; ����������
      resP@txFontHeightF  = 0.03         ; �޸����С  
    
     ; resP@gsnPanelFigureStrings= (/"a)","b)","c)"/)  ;������ͼ�ı��
      resP@gsnPanelFigureStringsFontHeightF = 0.015   ;����Ĵ�С 
      resP@amJust = "TopLeft"                         ;�ڷŵ�λ�ã�Ĭ���ǡ�BottomRight��
      
      resP@gsnPanelRowSpec = True       ; ָ��ÿ�л��Ƶ���ͼ�ĸ���
      gsn_panel(wks,base(1:),(/2/),resP)        ; ��1�л���1������2�л���2��
end