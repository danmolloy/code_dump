require 'csv'

lin_csv = './dec09_lin_dedupe.csv'
sf_csv = './dec09_salesforce.csv'
lin_emails = []

sf_data = CSV.read(sf_csv, headers: true, return_headers: true, encoding: 'ISO-8859-1')
sf_headers = sf_data.headers
output_csv = CSV.open("dec09_salesforce_lin_update4.csv", "w+",
                      write_headers: true, headers: sf_headers)

CSV.foreach(lin_csv, headers: true, return_headers: true, encoding: 'ISO-8859-1') {|lin_row|
  email = lin_row['E-mail Address']
  lin_emails << email #if (email && email != 'E-mail Address')
}

lin_data = CSV.read(lin_csv, headers: true, return_headers: true, encoding: 'ISO-8859-1')
# lin_data.each {|lin_row|
#   email = lin_row['E-mail Address']
#   lin_emails << email
# }
lin_data.delete(0)
sf_index = 0

CSV.foreach(sf_csv, headers: true, return_headers: true, encoding: 'ISO-8859-1') {|sf_row|
  sf_index += 1
  puts "sf: #{sf_index}/113508"
  sf_emails = []
  sf_emails << sf_row['Email'] if sf_row['Email']
  sf_emails << sf_row['Email 2'] if sf_row['Email 2']
  sf_emails << sf_row['Email 3'] if sf_row['Email 3']

  target_lin_row_num = lin_emails.find_index {|lin_email|
    sf_emails.include?(lin_email)
  }
  if target_lin_row_num
    puts "found match: #{lin_data[target_lin_row_num-1]}, #{sf_emails}"
    sf_row['LIN ID'] = lin_data[target_lin_row_num-1]['LIN ID']
    sf_row['Candidate Source'] = lin_data[target_lin_row_num-1]['Recruiter']
    sf_row['Bulk-Email-Tags'] = lin_data[target_lin_row_num-1]['Bulk-Email-Tags']
    if sf_row['Employer Organization Name 1'].nil?
      sf_row['Employer Organization Name 1'] = lin_data[target_lin_row_num-1]['Employer Organization Name 1']
    end
    if sf_row['Employer 1 Title'].nil?
      sf_row['Employer 1 Title'] = lin_data[target_lin_row_num-1]['Employer 1 Title']
    end
    lin_data.delete(target_lin_row_num-1)
    lin_emails.delete_at(target_lin_row_num)
  end
  output_csv << sf_row


}

lin_index = 0
lin_data.each {|lin_row|
  lin_index += 1
  puts "lin: #{lin_index}"
  new_sf_row = CSV::Row.new(sf_headers, [])
  new_sf_row['LIN ID'] = lin_row['LIN ID']
  new_sf_row['Candidate Source'] = lin_row['Recruiter']
  new_sf_row['First Name'] = lin_row['First Name']
  new_sf_row['Last Name'] = lin_row['Last Name']
  new_sf_row['Email'] = lin_row['E-mail Address']
  new_sf_row['Employer Organization Name 1'] = lin_row['Employer Organization Name 1']
  new_sf_row['Employer 1 Title'] = lin_row['Employer 1 Title']
  new_sf_row['Bulk-Email-Tags'] = lin_row['Bulk-Email-Tags']
  new_sf_row['Account Name'] = 'Candidates'
  output_csv << new_sf_row

}

output_csv.close
