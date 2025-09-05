#!/usr/bin/ruby
require 'rubygems'
require 'net/sftp'
require 'logger'

# Connection data
servername = 'xxx'
username = 'xxx'
password = 'xxx'
sourceDir = '/srcdir'
destinationDir = '/destdir'

directories = { 'aaa' => 'AAA', 'bbb' => 'BBB', 'ccc' => 'CCC', 'ddd' => 'DDD', 'eee' => 'EEE' }
filetypes = ['onix', 'jpg', 'pdf', 'epub']

startTime = Time.now
logFile = "/var/log/retrievers/#{startTime.strftime('%Y-%m-%d')}_sftp.log"
log = Logger.new(logFile)
log.level = Logger::INFO
log.info "=================== Begin ========================"
begin
  Net::SFTP.start(servername, username, :password => password) do |sftp|
    # Let's download files
    directories.keys.each do |src|
      ftpSourceDir = "#{sourceDir}/#{src}"
      ftpDestinationDir = "#{destinationDir}/#{directories[src]}"
      Dir.mkdir(ftpDestinationDir, '2755') unless File.exist?(ftpDestinationDir)
      sftp.dir.foreach(ftpSourceDir) do |entry|
        if (filetypes.include?(entry.name.split('.').last))
          log.info "Fetching #{ftpDestinationDir}/#{entry.name}"
          sftp.download!("#{ftpSourceDir}/#{entry.name}","#{ftpDestinationDir}/#{entry.name}")
        end
      end
    end

    # Let's remove files
    directories.keys.each do |src|
      ftpSourceDir = "#{sourceDir}/#{src}"
      sftp.dir.foreach(ftpSourceDir) do |entry|
        if (filetypes.include?(entry.name.split('.').last))
          log.info "Removing #{ftpSourceDir}/#{entry.name}"
          sftp.remove("#{ftpSourceDir}/#{entry.name}")
        end
      end
    end
  end
rescue Exception => e
  puts e.message
end
log.info "Done. Elapsed time #{Time.now - startTime} secs."
log.info "=================== End ======================="
