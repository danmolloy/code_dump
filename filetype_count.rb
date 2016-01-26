# scan through database
# discover filetypes and count number of each

$filetypes = {}

def main
  Dir.chdir("./data")
  (0..10).each {|dir|
    path = "#{Dir.pwd}/#{dir}/cand"
    if Dir.exist?(path)
      puts "scanning directory #{dir}"
      scan_subdirectories(path)
    end
  }

  puts "scan complete, sorting data"
  $filetypes = Hash[$filetypes.sort_by{|k, v| v}.reverse]

  puts "filetype count:\n"
  $filetypes.each_pair {|type, count|
    puts "\"#{type}\",\"#{count}\""
  }

  total = 0
  $filetypes.each_pair { |type, count|
    total += count
  }
  puts "total: #{total}"

  save_to_csv($filetypes)

end

def scan_subdirectories(parent_dir)
  subdirectories = Dir.entries(parent_dir)
  subdirectories.delete(".")
  subdirectories.delete("..")

  subdirectories.each { |subdir|
    puts "#{subdir}"
    files = Dir.entries("#{parent_dir}/#{subdir}")
    files.delete(".")
    files.delete("..")
    filetypes = files.map { |file|
      /\.[^\.]+\z/.match(file)
    }
    filetypes.each_with_index {|type, index|
      if !type
        filetypes[index] = "none"
      else
        filetypes[index] = type.to_s
      end
    }
    filetypes.each {|type|
      if $filetypes.has_key?(type)
        $filetypes[type] += 1
      else
        $filetypes[type] = 1
      end
    }
  }


end

def save_to_csv(data)
  file = File.new("filetypes.csv", "w+")
  $filetypes.each_pair {|type, count|
    file.puts "\"#{type}\",\"#{count}\""
  }
end

main()
