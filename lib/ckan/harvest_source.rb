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

    def self.create_job(url, name, source_type, api_key, opts={})
      keys = [:title, :notes, :frequency, :config]
      params = {}

      keys.each { |k| params[k] = opts[k] unless opts[k].nil? }
      params[:url] = url
      params[:name] = name
      params[:source_type] = source_type

      uri = get_local_uri("create")

      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, initheader =  {"Content-Type" => "aplication/json"})

      req["X-CKAN-API-Key"] = api_key
      req.body = params.to_json
      res = http.request(req)
      JSON::parse(res.body)["success"] if res.is_a?(Net::HTTPSuccess)
    end

    def self.find_by(api_key, fields={})
      jobs = list_jobs.map do |job|
        res = fields.map do |key, val|
          if not job.send(key).nil? and job.send(key) == val
            true
          else
            false
          end
        end
        job unless res.member? false
      end
      jobs.delete nil
      jobs
    end
  end
end
