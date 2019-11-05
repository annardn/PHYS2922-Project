pro spectrum_arc
  ;get channel files for the 5 minutes when the arc first appears
  ;isolate the arc (mask away the main part of the sun from the first 5 minutes)
  ;get the dynamic spectrum of the remaining parts
  obsids = get_obsids()
  channels = get_channels()
  chan_files = files_from_obsid_freq(5,0)
  

  freqs = fltarr(n_elements(channels))
  backgrounds = fltarr(n_elements(channels))
  spectrum_div = fltarr(n_elements(chan_files), n_elements(channels))
  spectrum = fltarr(n_elements(chan_files), n_elements(channels))
  intensities = fltarr(n_elements(channels))
  wavelengths = fltarr(n_elements(channels))
  
  restore, '~/code/var/min_bimg.sav'
  
  ;isolate the arc from the rest of the sun
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
  ;;use one column of the dynamic spectrum with emission at allfrequency channels (intensity vs frequency)
  ;;or use the mean/median for each row
  CME_spectrum_div = []
  CME_spectrum = []
  for iobsid = 5, 7 do begin
    for ifreq = 0, n_elements(channels)-1 do begin
      
      ;get files for CME event for each frequency channel
      arc_chan_files = files_from_obsid_freq(iobsid,ifreq)
      mwa_prep, arc_chan_files.file, arc_index, arc_data
      
      for i=0, n_elements(arc_index)-1 do begin
        arc_data[*,*,i] = arc_data[*,*,i]*flux_factor(ifreq)
      endfor

      ;loop through the data of that specific OBSID at that frequency
      ;and if it's not equal to 1 in the mask (not wanted), it will
      ;become zero
      for i = 0, n_elements(arc_data[*,0,0])-1 do begin
        for j =0, n_elements(arc_data[0,*,0])-1 do begin
          for k = 0, n_elements(arc_data[0,0,*])-1 do begin
            if mask_img[i,j] ne 1 then begin
              arc_data[i,j,k] = 0
            endif
          endfor
        endfor
      endfor


      ;get the spectrum_div (divided by background of first OBSID since its quiet
      freqs[ifreq] = round(arc_index[0].restfrq/1E6)
      intensity = total(total(arc_data,1),1)
      backgrounds[ifreq] = min_bimg[ifreq]
      spectrum_div[*,ifreq] = intensity / min_bimg[ifreq]
      spectrum[*,ifreq] = intensity
      wavelengths[ifreq] = arc_index[0].wavelnth
      
      CME_spectrum_div = [CME_spectrum_div,spectrum_div]
      CME_spectrum = [CME_spectrum, spectrum]

    endfor
   
  
  
  
  ;;trying to plot spectrum only
  spectrum_alone = fltarr(n_elements(freqs))
  for i = 0, n_elements(spectrum[0,*])-1 do begin
    spectrum_alone[i] = spectrum[0, i]*flux_factor(i)
  endfor
  
  
  ;;using average
  spectrum_avg = fltarr(n_elements(freqs))
  for i = 0, n_elements(spectrum[0,*])-1 do begin
    spectrum_avg[i] = mean(CME_spectrum[*, i])
  endfor
  
  ;;using median
  spectrum_mid = fltarr(n_elements(freqs))
  for i = 0, n_elements(spectrum[0,*])-1 do begin
    spectrum_mid[i] = median(spectrum[*, i])
  endfor
  
  stop
  endfor
    
  window, 0
  loadct, 39
  mcutplot_image, alog10(spectrum_div >1), arc_index.date_obs, freqs, /nosq, ytitle='Frequency (MHz)', charsize=1.5
  
;  window, 2
;  plot, alog10(wavelengths), alog10(intensities), xtitle = 'Wavelength (m)', ytitle = 'Intensity'
;  
;  window, 5
;  plot, alog10(freqs), alog10(spectrum), xtitle = 'LOG Frequency (MHz)', ytitle = 'LOG Intensity'
end
