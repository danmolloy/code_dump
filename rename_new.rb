$accepted_filetypes = [".doc", ".docx", ".pdf", ".txt", ".rtf",
                       ".html", ".odt", ".htm", ".html_files",
                       ".pdf_=", ".doc_=", ".xls", ".tif", ".docm",
                       ".docx_=", ".odf_="]

def main
  Dir.chdir("./CVS_Backup")
  (0..10).each {|dir|
    path = "#{Dir.pwd}/#{dir}/cand"
    if Dir.exist?(path)
      flatten_subdirectories(path)
      flatten_subdirectories(path)
      flatten_subdirectories(path)
      merge_duplicate_directories(path)
      check_for_duplicates(path)
      delete_bad_filetypes(path)
      rename_files(path)
    end
  }

end

def delete_bad_filetypes(parent_dir)
  subdirectories = Dir.entries(parent_dir)
  subdirectories.delete(".")
  subdirectories.delete("..")

  subdirectories.each {|subdir|
    files = get_files_new_first("#{parent_dir}/#{subdir}")
    files.each {|file|
      type = /\.[^\.]+\z/.match(file).to_s.downcase
      if /_=\z/.match(type)
        puts "sanitizing #{type} in #{subdir}"
        new_file = file[0..-3]
        File.rename("#{parent_dir}/#{subdir}/#{file}",
        "#{parent_dir}/#{subdir}/#{new_file}")
        type.slice!(/_=/)
        file = new_file
        puts "converted to #{type}"
      end

      unless (type == "") || ($accepted_filetypes.include?(type))
        File.delete("#{parent_dir}/#{subdir}/#{file}")
        puts "#{type} deleted from #{subdir}"
      end
    }

  }
end

def flatten_subdirectories(parent_dir)
  subdirectories = Dir.entries(parent_dir)
  subdirectories.delete(".")
  subdirectories.delete("..")

  subdirectories.each {|subdir|
    files = get_files_new_first("#{parent_dir}/#{subdir}")
    files.each {|file|
      if File.directory?("#{parent_dir}/#{subdir}/#{file}")
        puts "subfolder found in #{subdir}"
        subfiles = get_files_new_first("#{parent_dir}/#{subdir}/#{file}")
        subfiles.each {|subfile|
          File.rename("#{parent_dir}/#{subdir}/#{file}/#{subfile}",
          "#{parent_dir}/#{subdir}/#{subfile}")
        }
        Dir.delete("#{parent_dir}/#{subdir}/#{file}")
      end
    }
  }
end

def rename_files(parent_dir)
  subdirectories = Dir.entries(parent_dir)
  subdirectories.delete(".")
  subdirectories.delete("..")

  subdirectories.each {|subdir|
    files = get_files_new_first("#{parent_dir}/#{subdir}")

    if files.length == 1
      File.rename("#{parent_dir}/#{subdir}/#{files[0]}", "#{parent_dir}/#{subdir}/Resume_#{subdir}_#{files[0]}")
    elsif files.length > 1
      files.each_with_index {|file, index|
        old_name = file
        base = file
        puts "base before slice: #{base}"
        type = base.slice!(/\..+/)
        new_name = "#{subdir}_#{base}_#{index+1}#{type}"
        puts "base after slice: #{base}"
        puts "type: #{type}"
        puts "new name: #{new_name}"
        File.rename("#{parent_dir}/#{subdir}/#{old_name}#{type}", "#{parent_dir}/#{subdir}/Resume_#{new_name}")
      }
    end
  }
end

def check_for_duplicates(parent_dir)
   subdirectories = Dir.entries(parent_dir)
   subdirectories.delete(".")
   subdirectories.delete("..")

   subdirectories.each {|subdir|
     puts "looking in subdir #{subdir}"
     files = get_files_new_first("#{parent_dir}/#{subdir}")

     files.each_with_index {|anchor, anchor_index|
       if anchor
         anchor_size = File.stat("#{parent_dir}/#{subdir}/#{anchor}").size
         files[(anchor_index + 1)..-1].each_with_index { |candidate, candidate_index|

           if candidate
             candidate_size =
                  File.stat("#{parent_dir}/#{subdir}/#{candidate}").size
             if anchor_size == candidate_size
               File.delete("#{parent_dir}/#{subdir}/#{candidate}")
               files[(candidate_index + anchor_index + 1)] = nil
             end
           end
         }

       end

     }

     files_new = get_files_new_first("#{parent_dir}/#{subdir}")

     sizes = []
     files_new.each { |file|
       sizes << File.stat("#{parent_dir}/#{subdir}/#{file}").size
     }
     if sizes != sizes.uniq
      # puts "DUPLICATES SILL PRESENT IN #{subdir}:\n "
      #puts files_new
     end

   }

end

def parse_subdirectories(parent_dir)
  subdirectories = Dir.entries(parent_dir)


end

def merge_duplicate_directories(parent_dir)
  subdirectories = Dir.entries(parent_dir)

  subdirectories.each { |subdir|
    if (subdir.length > 6) && (subdir[0..4] == subdir[5..9]) &&
                    Dir.exist?("#{parent_dir}/#{subdir[0..4]}")
        # move files from duplicate to main & delete duplicate

        move_files("#{parent_dir}/#{subdir}",
                  "#{parent_dir}/#{subdir[0..4]}")
    elsif (subdir.length > 6) && (subdir[0..4] == subdir[5..9]) &&
                    !Dir.exist?("#{parent_dir}/#{subdir[0..4]}")
        # truncate filename
        truncate_dirname(parent_dir, subdir, 4)

    end
  }

end

def truncate_dirname(path, dir, index)
  new_name = dir[0..index]
  File.rename("#{path}/#{dir}", "#{path}/#{new_name}")
end

def move_files(source_dir, target_dir)
  files = Dir.entries(source_dir)
  files.delete(".")
  files.delete("..")

  files.each { |file|
    if File.exist?("#{target_dir}/#{file}")
      File.rename("#{source_dir}/#{file}", "#{target_dir}/moved_#{file}")
    else
      File.rename("#{source_dir}/#{file}", "#{target_dir}/#{file}")
    end
  }

  files_remaining = Dir.entries(source_dir)
  files_remaining.delete(".")
  files_remaining.delete("..")
  if files_remaining.empty?
    Dir.delete(source_dir)
  else
#    puts "files left in #{source_dir}"
#    puts files_remaining
  end

end

def get_files_new_first(target_dir)
  files = Dir.entries(target_dir)
  files.delete(".")
  files.delete("..")
  files.sort! {|a, b|
    File.stat("#{target_dir}/#{b}").mtime <=> File.stat("#{target_dir}/#{a}").mtime
  }
  return files
end

main()
