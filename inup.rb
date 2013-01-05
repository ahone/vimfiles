#!/usr/bin/env ruby
# ~/vimfiles/inup.rb
#
# by ahone / 2012
#
# download vim plugins from git and vim.org
# create symlinks for .vimrc and .vim
# create a backup from existing .vimrc file and .vim folder

begin
  require 'fileutils'
  require 'open-uri'
  require 'git'
  require 'yaml'

  # default values
  @vim_config = '.vimrc'
  @vim_folder = '.vim'
  @vimfiles_folder = 'vimfiles'
  @home_folder = Dir.home
  @config = 'config.yml'
  
  # load config file
  configFile = "#{File.dirname(__FILE__)}/#{@config}"
  if File.exists?(configFile)
    config = YAML.load_file(configFile)
    @vim_config = config['vim_config'] unless !config['vim_config']
    @vim_folder = config['vim_folder'] unless !config['vim_folder']
    @vimfiles_folder = config['vimfiles_folder'] unless !config['vimfiles_folder']
    git_bundles = config['git_bundles']
    vim_org_bundles = config['vim_org_bundles']
  else
    puts "No config file found. Please create first the config.yml file."
    exit
  end
  
  if File.expand_path(File.dirname(__FILE__)) == "#{@home_folder}/#{@vimfiles_folder}"
    bundles_dir = File.join(File.dirname(__FILE__), "bundle")
  else
    puts "Please move the script to -> #{@home_folder}/#{@vimfiles_folder}"
    exit
  end

  # git.clone
  def clone_git(url,dir)
      FileUtils.rm_rf(dir) if File.directory?(dir)
      puts "unpacking #{url} into #{dir}"
      Git.clone(url,dir)
  end
  
  FileUtils.mkdir(bundles_dir) unless File.directory?(bundles_dir)
  
  FileUtils.cd(bundles_dir) do
    # git
    git_bundles.each_line(' ') do |u|
      url = u.delete(" ")
      dir = url.split('/').last.sub(/\.git$/, '')
      begin
        if Git.open(dir)
          g = Git.open(dir)
          puts "updating #{dir}"
            g.with_working(dir) do
            g.pull
          end
        else
          clone_git(url,dir)
        end
      rescue
        clone_git(url,dir)
      end
    end
    
    # http://www.vim.org/
    vim_org_bundles.each_line do |o|
      obj = o.delete(" ") # delete blanks
      name,download_id,type= obj.strip.split(',')
      puts "downloading #{name}"
      local_file = File.join(name, type, "#{name}.vim")
      FileUtils.mkdir_p(File.dirname(local_file))
      File.open(local_file, "w") do |file|
        file << open("http://www.vim.org/scripts/download_script.php?src_id=#{download_id}").read
      end
    end
  end
  
  
  # create symlink .vim[rc] -> vim[files/vimrc]
  def create_symlink(link)
    puts "create new #{link} symlink"
    FileUtils.ln_s("#{@vimfiles_folder}/vimrc", link, :force => true) if link == @vim_config
    FileUtils.ln_s(@vimfiles_folder, link, :force => true) if link == @vim_folder
  end
  
  # create backup 
  # first time .vim[rc] -> vim[rc]_backup
  # for the second time .vim[rc]_backup -> vim[rc]_backup(DateTime)
  def create_backup(fod)
    puts "backup #{fod} to #{fod}_backup"
    FileUtils.mv("#{fod}_backup","#{fod}_backup_#{Time.now.strftime("%Y%m%d%H%M%S")}") if File.exist?("#{fod}_backup")
    FileUtils.mv(fod,"#{fod}_backup")
    create_symlink(fod)
  end
  
  def validate_symlink?(link)
    File.symlink?(link)
  end
  
  # check correct symlink
  def validate_readlink?(link,target)
    File.readlink(link) == target
  end
  
  def validate_exist?(link)
    File.exist?(link)
  end
  
  
  FileUtils.cd(@home_folder) do
    # create symlink for .vimrc file
    unless validate_exist?(@vim_config)
      create_symlink(@vim_config)                    # create symlink .vimrc -> vimfiles/vimrc
    else
      unless validate_symlink?(@vim_config)          # backup existing .vimrc file and create symlink .vimrc -> vimfiles/vimrc
        create_backup(@vim_config)
      else
        unless validate_readlink?(@vim_config, "#{@vimfiles_folder}/vimrc")
          create_symlink(@vim_config)                # overwrite existing symlink  .vimrc -> vimfiles/vimrc
        end
      end
    end
   
    # create symlink for .vim folder
    unless validate_exist?(@vim_folder)
      create_symlink(@vim_folder)                   # create symlink .vim -> .vimfiles
    else
      unless validate_symlink?(@vim_folder)
        create_backup(@vim_folder)                  # backup existing .vim folder and create symlink .vim -> vimfiles
      else
        unless validate_readlink?(@vim_folder,@vimfiles_folder)
          create_symlink(@vim_folder)               # overwrite existing symlink  .vim -> vimfiles
        end
      end
    end
  end

rescue LoadError => e
  mgem = /\w+$/.match(e.message)
  puts "#{mgem} required."
  puts "Please install with 'gem install #{mgem}'"
  exit

rescue SystemCallError => sce
  puts "#{sce}"
  exit

rescue Exception => e
  puts "#{e}"
  exit
end
