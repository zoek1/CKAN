require 'json'
require 'net/http'

module CKAN
  class Organization < Model
    self.site = "action/organization"

    PROPERTIES = [ :display_name, :description, :title, :image_display_url, :approval_status, :is_organization,
   	          :state, :image_url, :revision_id, :packages, :type, :id, :name ]

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

    def self.list(opts={})
      params = {}
      keys = [:all_fields, :order_by, :sort, :organizations]
      
      keys.each { |k| params[k] = opts[k] unless opts[k].nil? }
      
      uri = get_local_uri("list")
      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)

      resjson = JSON::parse(res.body)["result"] if res.is_a?(Net::HTTPSuccess)
      unless opts[:all_fields].nil? or resjson.nil? 
        resjson.map { |j| Organization.new j }
      else
        resjson
      end
    end

    def self.show(id, include_datasets=true)
      uri = get_local_uri("show")
      params = {}
      params[:id] = id # Name or ID
      params[:include_datasets] = include_datasets

      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)
      JSON::parse(res.body)["result"] if res.is_a?(Net::HTTPSuccess)
    end

    def self.create(name, api_key, opts = {})
      params = { :name => name }
      PROPERTIES.each { |p| params[p] = opts[p] unless opts[p].nil? }
     
      uri = get_local_uri("create")
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      req['X-CKAN-API-Key'] = api_key

      req.body = params.to_json
      res = http.request(req)
      Organization.new(JSON::parse(res.body)["result"]) if res.is_a?(Net::HTTPSuccess)
    end

    def self.delete(id, api_key)
      params = { :id => id }
     
      uri = get_local_uri("delete")
      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      req['X-CKAN-API-Key'] = api_key

      req.body = params.to_json
      res = http.request(req)
      JSON::parse(res.body)["success"] if res.is_a?(Net::HTTPSuccess)
    end
  end
end
# puts Organization.list(all_fields: true, order_by: "packages", organizations: ["escuela-de-datos", "buendia-laredo"])
# puts Organization.show(ARGV[0])
