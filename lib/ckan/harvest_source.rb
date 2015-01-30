require 'json'
require 'net/http'

module CKAN
  class Harvest < CKAN::Model
    self.site = "action/harvest_source"

    PROPERTIES = [:id, :url, :title, :description, :config, :created, :type, :active, :user_id, :publisher_id, :frequency, :next_run,
                  :publisher_title, :status]

    PROPERTIES.each { |f| attr_accessor f }

    def initialize(attributes = {})
      attributes.each { |key, value|
        self.send("#{key}=", value) if PROPERTIES.member? key.to_sym
      }
    end
    
    def to_hash(avoidables = [])
      hash = {}
      self.instance_variables.each do |var|
        key = var.to_s.delete("@").to_sym 
        hash[key] = self.instance_variable_get(var) unless avoidables.member? key
      end 
      hash
    end

    def self.get_local_uri(operation)
      uri = URI(self.site + "_" + operation)
    end

    def self.list_jobs
      uri = get_local_uri("list")
      res = Net::HTTP.get_response(uri)
      JSON::parse(res.body)["result"].map { |r| Harvest.new r}  if res.is_a?(Net::HTTPSuccess)
    end
  end
end
