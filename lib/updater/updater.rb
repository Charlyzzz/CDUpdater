require 'yaml'
require_relative '../provider/no_ip'

class Updater

  def self.run_with(hosts_filename, logger)
    @hosts_filename = hosts_filename
    @logger = logger
    run
  end

  def self.run
    loop do
      log 'Starting update'
      hosts.each do |host|
        begin
          Provider::NoIp.update(host['domain'], public_ip, host['user'], host['password'], version)
          log 'Update successful!'
        rescue => unsuccessful_response
          log :error, "Error updating host: #{unsuccessful_response.message}"
        end
      end
      try_again_later
    end

  end

  def self.hosts
    parse_yaml['hosts']
  end

  def self.settings
    parse_yaml['settings']
  end

  def self.version
    settings.first['version']
  end

  def self.parse_yaml
    begin
      content = YAML.load(File.read(@hosts_filename))
    rescue => exception
      log :error, "Ops! Something went wrong trying to
        open/parse the hosts file (#{@hosts_filename})"
      close(exception.message)
    end
    content
  end

  def self.public_ip
    log 'Refreshing public IP'
    begin
      response = RestClient.get 'http://ipecho.net/plain'
    rescue => connection_related_exception
      log :error, "Error updating IP:
        #{connection_related_exception.message}"
      try_again_later
    end
    ip = response.body
    log "The new address is #{ip}"
    ip
  end

  def self.log(level=:info, *messages)
    messages.each do |message|
      @logger.send(level, message)
    end
  end

  def self.try_again_later
    log 'Sleeping for 5 minutes. Zzz'
    sleep 300
  end

  def self.close(error_message)
    log :error, error_message
    log 'Exiting.'
    exit(false)
  end

end
