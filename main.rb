require 'rubygems'
require "highline/import"
require 'pathname'
require 'active_support'
require 'one_password'

# modules included
require 'log4r'

def setup_logger()
  # create a logger
  @logger = Log4r::Logger.new 'main'
  @logger.outputters << Log4r::Outputter.stdout
  @logger.outputters << Log4r::FileOutputter.new('full', filename:  'log/ full.log')
  @logger.debug "logger setup OK"
end

setup_logger
@logger.info("=======================  [START] 1PASSWORD.RB ================================")

# load custom config
require 'yaml'
config = YAML.load_file('config.yml')
directory = config['directory']
@logger.debug("config.directory = #{directory} ")

# main
keychain = OnePassword::Keychain.new(directory)
keychain.password = ask('Master Password :'){ |x| x.echo = false }

begin

  profile = keychain.current_profile

  # get all
  profile.all.each_with_index do |kv, i|
    item = kv[1].decrypt_data
    puts "#{i}. #{item.map { |k,v| "#{k}: #{v}"}.join('   ')}"
  end

  @logger.info("decrypt success")
rescue Exception => e
  @logger.error("wrong password")
end

@logger.info("=======================  [END] 1PASSWORD.RB ================================")
