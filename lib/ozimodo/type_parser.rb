require 'yaml'

module Ozimodo
  class TypeParser
    class <<self

      def parse_file(file)
        if File.read(file) =~ /<%#(.+?)(-?)%>/m
          self.parse($1)
        else
          false
        end
      end

      def parse(yaml)
        yaml_fields = YAML.load(yaml.dup)
        parsed_fields = {}

        yaml_fields.each do |field, hash_array_or_type|
          parsed_fields[field] = {}

          hash_array_or_type.each { |field| parsed_fields[field] = { 'type' => 'text' } } if field == 'fields'
          
          parsed_fields[field]['type'] = hash_array_or_type if hash_array_or_type.is_a?(String)

          parsed_fields[field] = hash_array_or_type if hash_array_or_type.is_a?(Hash)

          parsed_fields.delete('fields') if parsed_fields['fields']

          parsed_fields[field]['type'] ||= 'text'
        end

        parsed_fields
      end

    end
  end
end
