require 'uri'
require 'byebug'

module Phase5
  class Params
    attr_accessor :params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}
      parse_www_encoded_form(req.query_string) if req.query_string
      parse_www_encoded_form(req.body) if req.body
      @params.merge!(route_params)
    end

    def [](key)
      self.params[key] unless self.params.empty?
    end

    def to_s
      self.params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      URI::decode_www_form(www_encoded_form).each do |nest_keys, value|
        # @params[array[0]] = array[1]
        current_node = self.params
        key_array = parse_key(nest_keys)
        key_array.each_with_index do |key, i|
          if i == (key_array.length - 1)
            current_node[key] = value
          else
            current_node[key] = {} unless current_node[key].is_a?(Hash)
            current_node = current_node[key]
          end
        end
      end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
