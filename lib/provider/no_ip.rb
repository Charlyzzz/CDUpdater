require 'rest-client'
require 'base64'

module Provider

  class NoIp

    def self.update(domain, ip, username, password, version)
      RestClient.get(urlify(domain, ip),
                     :content_type => :json,
                     'user-agent' => user_agent(version),
                     :authorization => hash_login(username, password))
    end

    def self.urlify(domain, ip)
      "http://dynupdate.no-ip.com/nic/update?hostname=#{domain}&myip=#{ip}"
    end

    def self.hash_login(username, password)
      phrase = "#{username}:#{password}"
      'Basic ' << Base64.encode64(phrase).strip
    end

    def self.user_agent(version)
      "Charlyzzz's Ruby Update Client/#{version} erwincdl@gmail.com"
    end

  end

end