require 'csv'

#load input csv to memory
#loop through each row
#call following functions on each row:
# => trim_id - check length of legacy contactID and trim if too long
# => find_resume - search for a file that matches ID, and add the
#                  file path to correct column if found (handle
#                  multiples)

$output_csv = File.new("updated_data_2.csv", "w+")
$xls_ids = []


def main(input_csv, target_dir)
  candidates = CSV.read(input_csv, headers: true, return_headers: true)
  Dir.chdir("#{target_dir}")


  candidates.each {|candidate|
    #candidate = trim_id(candidate)
    if candidate['Legacy ContactID'].to_i.between?(99999, 110000)
      candidate = find_resume(candidate, target_dir)
    end
    $output_csv << candidate
  }

  puts "xls entered for:"
  puts $xls_ids

end

def find_resume(candidate, target_dir)
  dir_path = "C:\\Users\\Sheila McNeice\\Desktop\\CVS_Flat\\"
  legacyID = candidate['Legacy ContactID']
  puts "searching for resume with id #{legacyID}"
  resumes = Dir.glob("#{legacyID}_*")
  unless resumes.empty?
    resumes.each_with_index {|resume, index|
       resumes[index] = "#{dir_path}Resume_#{resume}"
       #resumes[index].gsub!(/\d\d\/Resume_/, "Resume_")
     }
     puts "resume found for #{legacyID}"
  end

  if resumes.length == 1
    puts "1 resume found: #{resumes[0]}"
    file_path = resumes[0]
    candidate['File Path'] = file_path#.encode("ISO-8859-1")
  elsif resumes.length > 1
    file_paths = resumes.select {|resume|
      resume =~ /_1\..+/
    }
    if (file_paths[0].to_s =~ /\.xls\z/)
      $xls_ids << legacyID
    end
    candidate['File Path'] = file_paths[0].to_s#.encode("ISO-8859-1")
  end
  return candidate

  #$output_csv << candidate
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



main("./updated_data.csv", "./data/10")
