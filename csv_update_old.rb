require 'csv'


#load input csv to memory
#loop through each row
#call following functions on each row:
# => trim_id - check length of legacy contactID and trim if too long
# => find_resume - search for a file that matches ID, and add the
#                  file path to correct column if found (handle
#                  multiples)

$output_csv = File.new("updated_data.csv", "w+")
$xls_ids = []
$no_filetype = []
$found = 0
$not_found = 0
#encoding: "ISO-8859-1",

def main(input_csv, parent_dir)
  candidates = CSV.read(input_csv, headers: true,  return_headers: true)
  #Dir.chdir("#{parent_dir}")


  candidates.each {|candidate|
    #candidate = trim_id(candidate)
    if candidate['Legacy ContactID'].to_i < 100919
      #p candidate['File Path']
      find_resume(candidate, parent_dir)
    end
  }

  puts "xls entered for:"
  puts $xls_ids
  puts "no filetype for:"
  puts $no_filetype
  puts "found: #{$found}"
  puts "not found: #{$not_found}"

end

def find_resume(candidate, parent_dir)
  dir_path = "C:\\Users\\Sheila McNeice\\Desktop\\CVS_Flat\\"
  legacyID = candidate['Legacy ContactID']
  puts "searching for resume with id #{legacyID}"
  subdir = legacyID[0..-5]
  target_dir = "#{parent_dir}/#{subdir}/cand/#{legacyID}"
  puts "target dir: #{target_dir}"
  if Dir.exist?(target_dir)

    target_files = Dir.entries(target_dir)
    target_files.delete(".")
    target_files.delete("..")
    puts "target_files: #{target_files}"

    if target_files.length == 1
      resume = target_files[0]

    elsif target_files.length > 1
      file_paths = target_files.select {|file|
        file =~ /_1\..+/
      }
      if (file_paths[0].to_s =~ /\.xls\z/)
        $xls_ids << legacyID
      elsif !(file_paths[0].to_s =~ /\./)
        $no_filetype << legacyID
      end
      resume = file_paths[0].to_s
    end
  end
  #resumes = Dir.glob("**/#{legacyID}_*")

  if resume
    if candidate['File Path'] == nil
      puts "resume found for #{legacyID}: #{resume}"
      resume = "#{dir_path}#{resume}"
      candidate['File Path'] = resume#.encode("ISO-8859-1")
    end
    $found += 1
  else
    $not_found += 1
  end

  # if resumes.length == 1
  #   puts "1 resume found: #{resumes[0]}"
  #   file_path = resumes[0]
  #   candidate['File Path'] = file_path.encode("ISO-8859-1")
  # elsif resumes.length > 1
  #   file_paths = resumes.select {|resume|
  #     resume =~ /_1\..+/
  #   }
  #   if (file_paths[0].to_s =~ /\.xls\z/)
  #     $xls_ids << legacyID
  #   end
  #   candidate['File Path'] = file_paths[0].to_s.encode("ISO-8859-1")
  # end

  $output_csv << candidate
end

# def trim_id(candidate)
#   legacyID = candidate['Legacy ContactID']
#   if legacyID
#      if legacyID.length > 6
#        candidate['Legacy ContactID'] = legacyID.slice(4..-1)
#      end
#   end
#   return candidate
# end



main("./salesforce_data_2.csv", "./data")
