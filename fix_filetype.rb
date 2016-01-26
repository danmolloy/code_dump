require 'csv'

$accepted_filetypes = ["doc", "docx", "pdf", "txt", "rtf",
                       "html", "odt", "htm", "html_files",
                       "pdf_=", "doc_=", "docm",
                       "docx_=", "odf_="]

$output_csv = File.new("updated_data_3.csv", "w+")

$renamed_ids = []
$invalids = []

def main(input_csv)
  candidates = CSV.read(input_csv, headers: true, encoding: "ISO-8859-1", return_headers: true)


  candidates.each {|candidate|
    puts "checking filetype of: #{candidate['File Path']}"
    check_filetype(candidate)
  }

  puts "renamed files:"
  puts "#{$renamed_ids}"
  puts "invalids: #{$invalids}"


end

def check_filetype(candidate)
  filepath = candidate['File Path']
  if filepath && !(filepath =~ /\./)
    puts "no period"
    position = filepath =~ /(#{$accepted_filetypes.join("|")})\z/
    if position
      puts "valid doctype found, fixing"
      filepath.insert(position, ".")
      if filepath =~ /_=\z/
        filepath.slice!(-2..-1)
      end
      puts "new filepath: #{filepath}"
      candidate['File Path'] = filepath
      $renamed_ids << candidate['Legacy ContactID']
    else
      puts "no valid doctype found"
      $invalids << candidate['Legacy ContactID']

    end
  end
  $output_csv << candidate
end



main("./updated_data_2.csv")
