require 'logger'
require_relative 'updater'

logger = Logger.new('info.log', 3)
filename = 'hosts.yaml'

updater = Updater.new(filename, logger)

puts updater.run
