# encoding: ISO-8859-1
require 'csv'
require 'fileutils'

input_csv = 'updated_data_existing.csv'
parent_dir = Dir.new('./cvs')
target_dir = Dir.new('./isolated_cvs')
file_names = []

candidates = CSV.read(input_csv, headers: true,  return_headers: true, encoding: 'ISO-8859-1')

candidates.each {|candidate|
  file_names << candidate['File Name']
}

parent_dir.each {|file_name|
  file_name = file_name.force_encoding('ISO-8859-1')
  if file_names.include?(file_name)
    FileUtils.mv("./cvs/#{file_name}", target_dir)
  end
}
