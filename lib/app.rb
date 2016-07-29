require 'logger'
require_relative 'updater/updater'

logger = Logger.new('info.log', 3)

Updater.run_with 'hosts.yaml', logger

