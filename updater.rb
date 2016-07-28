require 'base64'
require 'rest-client'
require 'yaml'

class Updater
  attr_reader :hosts_filename, :logger

  def initialize(hosts_filename, logger)
    @hosts_filename = hosts_filename
    @logger = logger
  end

  def run
    loop do
      @logger.info 'Starting update'
      ip = public_ip
      hosts.each { |host| update(host, ip) }
      try_again_later
    end

  end

  def update(host, ip)
    @logger.info "Updating #{host['domain']}"
    begin
      RestClient.get(urlify(host, ip),
                     :content_type => :json,
                     'user-agent' => user_agent,
                     :authorization => hash_login(host))
    rescue => exception
      @logger.error "Error updating host: #{exception.response}"
    end
    @logger.info 'Update successful!'
  end

  def urlify(host, ip)
    "http://dynupdate.no-ip.com/nic/update?hostname=#{host['domain']}&myip=#{ip}"
  end

  def hash_login(host)
    phrase = "#{host['user']}:#{host['password']}"
    Base64.encode64(phrase).strip
  end

  def user_agent
    "Charlyzzz's Ruby Update Client/#{version} erwincdl@gmail.com"
  end

  def hosts
    parse_yaml['hosts']
  end

  def version
    parse_yaml['version']
  end

  def parse_yaml
    begin
      content = YAML.load File.read(@hosts_filename)
    rescue => exception
      @logger.error "Ops! Something went wrong trying to
        open/parse the hosts file (#{hosts_filename})"
      close(exception.message)
    end
    content
  end

  def public_ip
    @logger.info 'Refreshing public IP'
    begin
      response = RestClient.get 'http://ipecho.net/plain'
    rescue => connection_related_exception
      @logger.error "Error updating IP:
        #{connection_related_exception.message}"
      try_again_later
    end
    ip = response.body
    @logger.info "The new address is #{ip}"
    ip
  end

  def try_again_later
    @logger.info 'Sleeping for 5 minutes. Zzz'
    sleep 300
  end

  def close(error_message)
    @logger.error error_message
    @logger.info 'Exiting.'
    exit(false)
  end

end
