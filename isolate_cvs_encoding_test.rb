# encoding: ISO-8859-1
require 'csv'
require 'fileutils'

input_csv = 'encoding_test.csv'
parent_dir = Dir.new('./cvs_encoding_test')
target_dir = Dir.new('./isolated_cvs_encoding_test')
file_names = []

candidates = CSV.read(input_csv, headers: true,  return_headers: true, encoding: 'ISO-8859-1')

candidates.each {|candidate|
  file_names << candidate['File Name']
  p candidate['File Name']
  p candidate['File Name'].encoding
}

p file_names

parent_dir.each {|file_name|
  file_name = file_name.force_encoding('ISO-8859-1')
  p file_name
  p file_name.encoding
  if file_names.include?(file_name)
    p "true"
    FileUtils.mv("./cvs/#{file_name}", target_dir)
  end
}
