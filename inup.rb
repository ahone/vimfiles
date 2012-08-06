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
  require "git"


  git_bundles = [
    "git://github.com/astashov/vim-ruby-debugger.git",
    "git://github.com/ervandew/supertab.git",
    "git://github.com/godlygeek/tabular.git",
    "git://github.com/msanders/snipmate.vim.git",
    "git://github.com/pangloss/vim-javascript.git",
    "git://github.com/scrooloose/nerdtree.git",
    "git://github.com/timcharper/textile.vim.git",
    "git://github.com/tomtom/tcomment_vim.git",
    "git://github.com/Townk/vim-autoclose.git",
    "git://github.com/tpope/vim-abolish.git",
    "git://github.com/tpope/vim-bundler.git",
    "git://github.com/tpope/vim-commentary.git",
    "git://github.com/tpope/vim-cucumber.git",
    "git://github.com/tpope/vim-fugitive.git",
    "git://github.com/tpope/vim-git.git",
    "git://github.com/tpope/vim-haml.git",
    "git://github.com/tpope/vim-markdown.git",
    "git://github.com/tpope/vim-pathogen.git",
    "git://github.com/tpope/vim-rails.git",
    "git://github.com/tpope/vim-repeat.git",
    "git://github.com/tpope/vim-rvm.git",
    "git://github.com/tpope/vim-surround.git",
    "git://github.com/tsaleh/vim-matchit.git",
    "git://github.com/tsaleh/vim-shoulda.git",
    "git://github.com/tsaleh/vim-tmux.git",
    "git://github.com/vim-ruby/vim-ruby.git",
    "git://github.com/vim-scripts/FuzzyFinder.git",
    "git://github.com/vim-scripts/L9.git",
    "git://github.com/vim-scripts/mru.vim.git",
  ]

  # www.vim.org
  # name, ID (src_id), script type
  vim_org_scripts = [
    ["IndexedSearch", "7062",  "plugin"],
    ["jquery",        "15752", "syntax"],
  ]

  # personal vim folder
  @vfd = 'vimfiles'


  ####################################################################
  
  # vimrc file
  @vf = '.vimrc'

  # default vim folder 
  @vd = '.vim'
  
  # home
  @home_dir = Dir.home

  if File.expand_path(File.dirname(__FILE__)) == @home_dir + "/" + @vfd
    bundles_dir = File.join(File.dirname(__FILE__), "bundle")
  else
    puts "Please move the script to -> " + @home_dir + "/" + @vfd
    exit
  end

  # git.clone
  def clone_git(url,dir)
      FileUtils.rm_rf(dir) if File.directory?(dir)
      puts "unpacking #{url} into #{dir}"
      Git.clone(url,dir)
  end
  
  # create bundle folder
  FileUtils.mkdir (bundles_dir) unless File.directory?(bundles_dir)
  
  # download files
  FileUtils.cd(bundles_dir) do
    # git - http://github.com
    git_bundles.each do |url|
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
    vim_org_scripts.each do |name, script_id, script_type|
      puts "downloading #{name}"
      local_file = File.join(name, script_type, "#{name}.vim")
      FileUtils.mkdir_p(File.dirname(local_file))
      File.open(local_file, "w") do |file|
        file << open("http://www.vim.org/scripts/download_script.php?src_id=#{script_id}").read
      end
    end
  end
  
  
  # create symlink .vim[rc] -> vim[files/vimrc]
  def create_symlink(link)
    puts "create new " + link + " symlink"
    FileUtils.ln_s(@vfd + '/vimrc', link, :force => true) if link == @vf
    FileUtils.ln_s(@vfd, link, :force => true) if link == @vd
  end
  
  # create backup 
  # first time .vim[rc] -> vim[rc]_backup
  # for the second time .vim[rc]_backup -> vim[rc]_backup(DateTime)
  def create_backup(fod)
    puts "backup " + fod + " to " + fod + "_backup"
    FileUtils.mv(fod + '_backup',fod + '_backup_' + Time.now.strftime("%Y%m%d%H%M%S")) if File.exist?(fod + '_backup')
    FileUtils.mv(fod,fod + '_backup')
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
  
  
  FileUtils.cd(@home_dir) do
    # .vimrc file
    unless validate_exist?(@vf)
      create_symlink(@vf)                    # create symlink .vimrc -> vimfiles/vimrc
    else
      unless validate_symlink?(@vf)          # backup existing .vimrc file and create symlink .vimrc -> vimfiles/vimrc
        create_backup(@vf)
      else
        unless validate_readlink?(@vf, @vfd + '/vimrc')
          create_symlink(@vf)                # overwrite existing symlink  .vimrc -> vimfiles/vimrc
        end
      end
    end
   
    # .vim folder
    unless validate_exist?(@vd)
      create_symlink(@vd)                   # create symlink .vim -> .vimfiles
    else
      unless validate_symlink?(@vd)
        create_backup(@vd)                  # backup existing .vim folder and create symlink .vim -> vimfiles
      else
        unless validate_readlink?(@vd,@vfd)
          create_symlink(@vd)               # overwrite existing symlink  .vim -> vimfiles
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

