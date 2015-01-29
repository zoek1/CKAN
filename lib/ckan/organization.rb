require 'json'
require 'net/http'
require 'ckan'

CKAN::API.api_url = "http://172.17.0.2/api/"

module CKAN
class Organization
  def initialize()

  organization = [:display_name, :description, :title, :image_display_url, :approval_status, :is_organization,
   	          :state, :image_url, :revision_id, :packages, :type, :id, :name ]

  # Build getter y setters
  end

  def self.get_local_uri(operation)
    uri = URI("http://datamx.io/api/action/organization_" + operation)
  end

  def self.list(opts={})
    uri = get_local_uri("list")
    puts opts
    params = {}
    params[:all_fields] = opts[:all_fields] unless opts[:all_fields].nil?
    params[:order_by] = opts[:order_by] unless opts[:order_by].nil?
    params[:sort] = opts[:sort] unless opts[:sort].nil?
    params[:organizations] = opts[:organizations] unless opts[:organizations].nil?
    
    uri.query = URI.encode_www_form(params)
    puts uri
    res = Net::HTTP.get_response(uri)

    JSON::parse(res.body)["result"] if res.is_a?(Net::HTTPSuccess)
  end

  def self.show(id, include_datasets=true)
    uri = get_local_uri("show")
    params = {}
    params[:id] = id # Name or id
    params[:include_datasets] = include_datasets

    uri.query = URI.encode_www_form(params)
    puts uri
    res = Net::HTTP.get_response(uri)
    JSON::parse(res.body)["result"] if res.is_a?(Net::HTTPSuccess)
  end

end
end
# puts Organization.list(all_fields: true, order_by: "packages", organizations: ["escuela-de-datos", "buendia-laredo"])
puts Organization.show(ARGV[0])
