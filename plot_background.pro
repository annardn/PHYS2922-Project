 pro plot_background
  channels = get_channels()
  obsids = get_obsids()
  
  if file_test('~/code/var/backgrounds.sav') then begin
    restore, '~/code/var/backgrounds.sav'
  endif else begin
    ;stores the background intensity for the first frequency channels for the CME event (obsids 5 to 10)
    backgrounds = fltarr(n_elements(obsids), n_elements(channels))
    help, backgrounds

    iobsid = 0
    i = 0

    for ifreq = 0, n_elements(channels)-1 do begin
      for iobsid = 0, n_elements(obsids)-1 do begin
        backgrounds[iobsid, ifreq] = background(iobsid, ifreq)
      endfor
    endfor

    save, backgrounds, file = '~/code/var/backgrounds.sav'
  endelse
  
  stop
  
;  avg_bimg = fltarr(n_elements(backgrounds[0,*]))
;  for ifreq = 0, n_elements(backgrounds[0,*])-1 do begin
;    avg_bimg[ifreq] = average(backgrounds[*, ifreq])
;  endfor
 
  min_bimg = fltarr(n_elements(backgrounds[0,*]))
  for ifreq = 0, n_elements(backgrounds[0,*])-1 do begin
    min_bimg[ifreq] = min(backgrounds[*, ifreq])
  endfor
  
  save, min_bimg, file = '~/code/var/min_bimg.sav'
  
  min_bimg_plot = replicate(min_bimg[0], n_elements(obsids))
;  avg_bimg_plot = replicate(avg_bimg[0], n_elements(obsids))
  
  window, 5
  plot, backgrounds[*,0], xtitle = 'OBSID' ;plots the background for first frequency
  oplot, min_bimg_plot, linestyle = 1 ;dotted
;  oplot, avg_bimg_plot, linestyle = 2 ;dashed
  
  write_png, '~/analysis/background.png', tvrd(/true)
  
  stop
  
end