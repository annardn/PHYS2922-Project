FUNCTION get_obsids
  all_files = mwa_search('20140926_010640', filter={src:'hera_sc3',lvl:1,pol:'I', series:[0,1E6]})
  obsids = all_files[uniq(all_files.obsid, sort(all_files.obsid))].obsid
  return, obsids
end