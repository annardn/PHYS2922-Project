function flux_factor, ifreq
  
  if file_test('~/code/var/' + trim(ifreq) + '_flux_factor.sav') then begin
    restore, '~/code/var/' + trim(ifreq) + '_flux_factor.sav'
    return, flux_factor
  endif


  file_paths = ['/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_80_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_89_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_98_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_108_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_120_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_132_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_145_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_161_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_179_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_196_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_217_gyro_I.sav', $
    '/import/silo3/pmcc8541/data/forward/20140926/2014-09-26_240_gyro_I.sav']


  channels = get_channels()
  obsids = get_obsids()
  freqs = get_freqs_obsid(0)

  ;search for the model image for the correct date and frequency channel
  for_sav = file_paths[ifreq]

  ;restore the file
  restore, for_sav, /v

  ;move the Stokes I values into a map structure
  qmap = quantmap
  qmap.data = stokesstruct.i

  ;obtain the flux implied by the model image in Solar Flux Units (SFU)
  for_flux = forward_tb2flux(qmap, freqs[ifreq]*1.E6)

  ;since the background plot showed an almost constant total intensity
  ;i will use the first OBSID to calculate the flux factor
  chan_files = files_from_obsid_freq(0,ifreq)
  mwa_prep, chan_files.file, index, data

  if file_test('~/code/var/' + obsids[0] + '_' + trim(ifreq) + '_total_bimg.sav') then begin
    print, 'restoring background...'
    restore, '~/code/var/' + obsids[0] + '_' + trim(ifreq) + '_total_bimg.sav'
  endif else begin
    total_bimg =  total(baseline_image(data, /median))  
  endelse
  
  ;determine a flux calibration factor by dividing the model flux by the total intensity
  ;of the baseline background image. We are assuming here that the flux in our background
  ;image is equal to the model.
  flux_factor = for_flux / total_bimg

  save, flux_factor, file = '~/code/var/' + trim(ifreq) + '_flux_factor.sav'

  return, flux_factor
end