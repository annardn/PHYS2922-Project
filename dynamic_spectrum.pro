pro dynamic_spectrum, iobsid, spectrum_div_diff, spectrum_div_same, calib_spectrum, raw_spectrum, observation_date
  channels = get_channels()
  chan_files = files_from_obsid_freq(iobsid,0)
  
  freqs = fltarr(n_elements(channels))
  backgrounds = fltarr(n_elements(channels))
  spectrum = fltarr(n_elements(chan_files), n_elements(channels))
  
  spectrum_calib = fltarr(n_elements(chan_files), n_elements(channels))
  raw_spectrum = fltarr(n_elements(chan_files), n_elements(channels))
  
  spectrum_div_diff = fltarr(n_elements(chan_files), n_elements(channels))
  spectrum_div_same = fltarr(n_elements(chan_files), n_elements(channels))
  
  restore, '~/code/var/min_bimg.sav'
  
  for ifreq=0, n_elements(channels)-1 do begin
    chan_files = files_from_obsid_freq(iobsid,ifreq) ;getting the channel files for the obsid at a specific freq
    mwa_prep, chan_files.file, index, data
    freqs[ifreq] = round(index[0].restfrq/1E6)
    intensity = total(total(data,1),1)
    backgrounds[ifreq] = mcbaseline(intensity, /median) ;background for each obsid individually
    spectrum[*,ifreq] = intensity
    raw_spectrum[*, ifreq] = intensity
    spectrum_calib[*, ifreq] = intensity * flux_factor(ifreq)
    spectrum_div_diff[*,ifreq] = intensity / backgrounds[ifreq]
    spectrum_div_same[*, ifreq] = intensity/ min_bimg[ifreq]
  endfor
  
  
; 
;  
;  window, 2
;  mcutplot_image, alog10(spectrum_div_diff >1), index.date_obs, freqs, /nosq, ytitle='Frequency (MHz)', charsize=1.5
;
;
;  ;export  as image using OBSID name
;  obsids = get_obsids()
;  write_png, '~/analysis/diff_background/'+obsids[iobsid]+'.png', tvrd(/true)

;  
;  window, 5
;  mcutplot_image, alog10(spectrum_div_same >1), index.date_obs, freqs, /nosq, ytitle='Frequency (MHz)', charsize=1.5
;  write_png, '~/analysis/same_background/'+obsids[iobsid]+'.png', tvrd(/true)
;  
;  window, 10
;  mcutplot_image, alog10(spectrum >1), index.date_obs, freqs, /nosq, ytitle='Frequency (MHz)', charsize=1.5
;  write_png, '~/analysis/spectrum_calib/'+obsids[iobsid]+'.png', tvrd(/true)
  
  observation_date = index.date_obs
  spectrum = flux_calibrate(iobsid, spectrum)
  
;

  save, spectrum_div_same, file = '~/code/var/' + index[0].obsid + '_spectrum_div_same.sav'
  save, spectrum_div_diff, file = '~/code/var/' + index[0].obsid + '_spectrum_div_diff.sav'
  save, spectrum, file = '~/code/var/' + index[0].obsid + '_spectrum.sav'
  save, observation_date, file = '~/code/var/' + index[0].obsid + '_date_obs.sav'
  save, raw_spectrum, file = '~/code/var/' + index[0].obsid + '_raw_spectrum.sav'
  save, spectrum_calib, file = '~/code/var/' + index[0].obsid + '_spectrum_calib.sav'

  return
  
end