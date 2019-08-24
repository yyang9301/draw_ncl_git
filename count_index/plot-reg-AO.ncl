begin

  ;;;;read SLP data   

  f     = addfile("/home/ys17-19/data-observation/ERA-interim/monthly/slp.mon.mean.nc", "r")  
  ;time = f->time
  ;yyyymm  = cd_calendar(time, -1)
  ;istrt   = ind(yyyymm .eq. g_strt_mon)
  ;ilast   = ind(yyyymm .eq. g_lst_mon)
  slp = short2flt(f->msl(::12,{0:90},:))  ;��ȡÿ���1�£�����������
  
  dims = dimsizes(slp)                    ; ���ظ�ά�Ĵ�С

  year = ispan(1979,1979+dims(0)-1,1)     ; �����ĸ����
  
  ;; ����Ȩ��  
  w  = sqrt(cos(0.01745329*slp&latitude) )     ; Ȩ��ϵ��                 
  wp = slp*conform(slp, w, 1)             ; wp
  copy_VarCoords(slp, wp)
  
  ;; EOF�ֽ�
  x    = wp({latitude|20:90},longitude|:,time|:)  ; ʱ��ά�����ұ�
  neof = 2                             ; ����ǰ2ģ̬�����ڼ����1ģ̬�Ƿ�����������ģ̬�����
  eof  = eofunc_Wrap(x, neof, False)   ; EOF�ֽ�

  ;; north ����
  ntim = dims(0)               
  sig_pcv = eofunc_north(eof@pcvar, ntim, False)
    
  ;; ����PC������׼��
  eof_ts = eofunc_ts_Wrap (x, eof, False)
  eof_ts = dim_standardize_n(eof_ts,1,1)
  eof_ts!1 = "year"
  eof_ts&year = ispan(1979, 2017, 1)
  print(eof_ts(0,:))
  
  ;path_out = "/home/ys17-19/cjx/all_output_data/AOI/AOI.nc"
  ;system("rm -f " + path_out)
  ;f_out = addfile(path_out,"c")
  ;f_out->AOI = eof_ts(0,:)
end