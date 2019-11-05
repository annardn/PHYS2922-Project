function get_freqs_obsid, iobsid, redo = redo
  obsids = get_obsids()
  if ~file_test('~/code/var/' + trim(obsids[iobsid]) + '_freqs.sav') || keyword_set(redo) then begin
    channels = get_channels()
    freqs = fltarr(n_elements(channels))

    for ifreq = 0, n_elements(channels) - 1 do begin
      chan_files = files_from_obsid_freq(iobsid, ifreq)
      mwa_prep, chan_files.file, index, data
      freqs[ifreq] = round(index[0].restfrq/1E6)
    endfor

    save, freqs, file = '~/code/var/' + trim(obsids[iobsid]) + '_freqs.sav'
  endif else begin
    restore, '~/code/var/' + trim(obsids[iobsid]) + '_freqs.sav'
  endelse
 
  return, freqs
  
end