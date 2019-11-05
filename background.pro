function background, iobsid, ifreq
  obsids = get_obsids()
  ;check if it has already been calculated
  if file_test('~/code/var/' + obsids[iobsid] + '_' + trim(ifreq) + '_total_bimg.sav') then begin
    print, 'restoring background...'
    restore, '~/code/var/' + obsids[iobsid] + '_' + trim(ifreq) + '_total_bimg.sav'
    return, total_bimg
  endif
    

  chan_files = files_from_obsid_freq(iobsid, ifreq)
  mwa_prep, chan_files.file, index, data
  
  ;get baseline image and plot
  bimg = baseline_image(data, /median)
  total_bimg = total(bimg)
  save, total_bimg, file = '~/code/var/' + index[0].obsid + '_' + trim(ifreq) + '_total_bimg.sav'
  print, total_bimg
  return, total_bimg
  
end