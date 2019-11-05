pro plot_spectrum
  ;plot the spectrum for every observation (should be 19)
  obsids = get_obsids()
  freqs = get_freqs_obsid(0)
  
  ;to plot all the specta together, I must create a single variable which has a length of all readings
  ; to do this I must loop over all OBSIDS and get the length
  spectrum_len = 0
  obs_len = 0
  i = 0
  while i le n_elements(obsids)-1 do begin
    ;check if the files for the OBSID are present
    if file_test('~/code/var/'+obsids[i]+'_raw_spectrum.sav') then begin
      print, 'restoring OBSID files'
      restore, '~/code/var/'+obsids[i]+'_spectrum_div_diff.sav'
      restore, '~/code/var/'+obsids[i]+'_spectrum_div_same.sav'
      restore, '~/code/var/'+obsids[i]+'_spectrum_calib.sav'
      restore, '~/code/var/'+obsids[i]+'_date_obs.sav'
      restore, '~/code/var/'+obsids[i]+'_raw_spectrum.sav'
    endif else begin
      dynamic_spectrum, i, spectrum_div_diff, spectrum_div_same, calib_spectrum, raw_spectrum, observation_date
    endelse

    spectrum_len += n_elements(spectrum_div_diff[*,0])
    obs_len += n_elements(observation_date)
    
    i += 1
  endwhile
  
  all_div_diff = fltarr(spectrum_len, n_elements(freqs))
  all_div_same = fltarr(spectrum_len, n_elements(freqs))
  all_spectra_calib = fltarr(spectrum_len, n_elements(freqs))
  all_spectra_raw = fltarr(spectrum_len, n_elements(freqs))
  all_time = strarr(obs_len)

  x = 0
  i = 0
  while i le n_elements(obsids)-1 do begin
    ;indices for all_spectra
    
    restore, '~/code/var/'+obsids[i]+'_spectrum_div_diff.sav'
    restore, '~/code/var/'+obsids[i]+'_spectrum_div_same.sav'
    restore, '~/code/var/'+obsids[i]+'_spectrum_calib.sav'
    restore, '~/code/var/'+obsids[i]+'_date_obs.sav'
    restore, '~/code/var/'+obsids[i]+'_raw_spectrum.sav'

    
    if i eq 0 then begin
      all_div_diff = spectrum_div_diff
      all_div_same = spectrum_div_same
      all_spectra_calib = spectrum_calib
      all_spectra_raw = raw_spectrum
      all_time = observation_date
    endif else begin
      all_div_diff = [all_div_diff,spectrum_div_diff]
      all_div_same = [all_div_same, spectrum_div_same]
      all_spectra_calib = [all_spectra_calib, spectrum_calib]
      all_spectra_raw = [all_spectra_raw, raw_spectrum]
      all_time = [all_time, observation_date]
    endelse

;    ;add to the group spectra, each element at a time
;    ;loop through frequencies  then through each element in frequencies
;    for j=0, n_elements(spectrum_div_diff[0,*])-1  do begin
;      for k = 0, n_elements(spectrum_div_diff[*,0])-1 do begin
;        all_div_diff[k+x,j] = spectrum_div_diff[k,j]
;        all_div_same[k+x,j] = spectrum_div_same[k,j]
;        all_spectra[k+x,j] = spectrum[k,j]
;        if j eq 0 then all_time[k+x] = observation_date[k]
;      endfor
;    endfor  
;    x += n_elements(spectrum_div_diff[*,0])

    i += 1
  endwhile
  
  
  help, all_spectra_raw
  help, all_div_diff
  help, all_div_same
  help, all_time
  
  
    
  loadct, 39
  
  
  tstep = (anytim(all_time[-1]) - anytim(all_time[0]))/(n_elements(all_time)-1)
  new_time = anytim(dindgen(n_elements(all_time))*tstep + anytim(all_time[0]), /ccsds)
  print, new_time[-1], all_time[-1]

  window, 0
  mcutplot_image, alog10(all_div_diff >1), new_time, freqs, /nosq, ytitle='Frequency (MHz)', charsize=1.5
  save, all_div_diff, file = '~/code/var/all_div_diff.sav'
  
  window, 2
  mcutplot_image, alog10(all_div_same >1), new_time, freqs, /nosq, ytitle='Frequency (MHz)', charsize=1.5
  save, all_div_same, file = '~/code/var/all_div_same.sav'
  
  window, 3
  mcutplot_image, alog10(all_spectra_raw >1), new_time, freqs, /nosq, ytitle='Frequency (MHz)', charsize=1.5
  save, all_spectra_raw, file = '~/code/var/all_spectra_raw.sav'
  
  window, 4
  mcutplot_image, alog10(all_spectra_calib >1), new_time, freqs, /nosq, ytitle='Frequency (MHz)', charsize=1.5
  save, all_spectra_calib, file = '~/code/var/all_spectra_calib.sav'

  
  save, all_time, file = '~/code/var/all_time.sav'
  save, freqs, file = '~/code/var/freqs.sav'

  
  stop
end