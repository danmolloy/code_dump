root_dir = "./data"

def rename_resume(target_dir)
  unless Dir.exist?(target_dir)
    return nil
  end
  subdirectories = Dir.entries(target_dir)
  subdirectories.delete(".")
  subdirectories.delete("..")
  subdirectories.each {|subdir|
    files = Dir.entries("#{target_dir}/#{subdir}")
    files.delete(".")
    files.delete("..")
    files.each {|file|
      unless File.directory?("#{target_dir}/#{file}")
        file.slice!("Resume_")
        File.rename("#{target_dir}/#{subdir}/Resume_#{file}", "#{target_dir}/#{subdir}/#{file}")
      end
    }
  }

end

#rename_resume(root_dir)

(4..9).each {|index|
  rename_resume("#{root_dir}/#{index}")
}
