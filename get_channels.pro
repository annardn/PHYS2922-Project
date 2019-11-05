FUNCTION get_channels, ifreq
  all_files = mwa_search('20140926_010640', filter={src:'hera_sc3',lvl:1,pol:'I', series:[0,1E6]})
  obsids = all_files[uniq(all_files.obsid, sort(all_files.obsid))].obsid
  obs_files = mwa_search(obsids[0], filter={src:'hera_sc3',lvl:1,pol:'I', series:[0,1E6]})
  channels = obs_files[uniq(obs_files.chan, sort(obs_files.chan))].chan
  return, channels
end