pro arc_only
  channels = get_channels()
  
  ;get the observation for the first 5 minutes (seems like a quiet sun) in first frequency channel
  first_chan_files = files_from_obsid_freq(0,0)
  mwa_prep, first_chan_files.file, first_index, first_data

  first_bimg = fltarr(n_elements(channels))
  ;baseline image of the first 5 minutes in first frequency channels
  for i = 0, n_elements(channels)-1 do begin
    first_bimg[i] = background(0, i)
  endfor
  
  

  ;signal to noise ratio for the entire image for first 5 minutes
  bg = baseline_image(first_data, /median)
  snr = snr_img(bg, sig)

  want = where(snr lt 20)

  ;create a blank image and set all pixels in the mask to 1
  mask_img = intarr(first_index[0].naxis1, first_index[1].naxis2)
  mask_img[want] = 1
  
  avg_spectrum = fltarr(n_elements(channels))
  
  for ifreq = 0, n_elements(channels)-1 do begin

    ;get files for CME event for each frequency channel
    arc_chan_files = files_from_obsid_freq(5,ifreq)
    mwa_prep, arc_chan_files.file, arc_index, arc_data
    
    masked_data = arc_data
    
    
    for i=0, n_elements(arc_index)-1 do begin
      masked_data[*,*,i] = masked_data[*,*,i]*flux_factor(ifreq)
    endfor
    
    
    ;loop through the data of that specific OBSID at that frequency
    ;and if it's not equal to 1 in the mask (not wanted), it will
    ;become zero
    for i = 0, n_elements(arc_data[*,0,0])-1 do begin
      for j =0, n_elements(arc_data[0,*,0])-1 do begin
        for k = 0, n_elements(arc_data[0,0,*])-1 do begin
          if mask_img[i,j] ne 1 then begin
            masked_data[i,j,k] = 0
          endif
        endfor
      endfor
    endfor
    
    intensity = total(total(masked_data, 1), 1)
    avg_spectrum[ifreq] = intensity[0]
    
  endfor
  


;  chan_files = files_from_obsid_freq(5,6)
;  mwa_prep, chan_files.file, index, data
;  
;  ;signal to noise ratio for the entire image for first 5 minutes
;  bg = baseline_image(data, /median)
;  snr = snr_img(bg, sig)
;
;  want = where(snr gt 90)
;
;  ;create a blank image and set all pixels in the mask to 1
;  mask_img = intarr(index[0].naxis1, index[1].naxis2)
;  mask_img[want] = 1
;  
;  masked_data = data
;  
;  for i = 0, n_elements(data[*,0,0])-1 do begin
;    for j =0, n_elements(data[0,*,0])-1 do begin
;      for k = 0, n_elements(data[0,0,*])-1 do begin
;        if mask_img[i,j] ne 1 then begin
;          masked_data[i,j,k] = 0
;        endif
;      endfor
;    endfor
;  endfor
;  
;  freqs = get_freqs_obsid(5)
;  
;  
;  spectrum = fltarr(n_elements(freqs))
;  for i = 0, n_elements(freqs)-1 do begin
;    chan_files = files_from_obsid_freq(5,i)
;    mwa_prep, chan_files.file, index, data
;    intensity = total(total(data,1),1)
;    spectrum[i] = intensity[0]*flux_factor(i)
;  endfor

   freqs = get_freqs_obsid(5)
  
  stop  
end