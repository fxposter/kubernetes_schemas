require "kubernetes_schemas/version"
require "json_schemer"

module KubernetesSchemas
  def self.load(kubernetes_version, strict: false)
    kubernetes_version = "#{kubernetes_version}-strict" if strict
    path = File.expand_path("../../schemas/#{kubernetes_version}", __FILE__)
    Dir.each_child(path).with_object({}) { |filename, hash|
      definition = JSON.parse(File.read(File.join(path, filename)))
      if kinds = definition["x-kubernetes-group-version-kind"]
        definition = JSONSchemer.schema(definition)
        kinds.each do |meta|
          hash["#{meta["group"]}/#{meta["version"]}/#{meta["kind"]}"] = definition
        end
      end
    }
  end

  class Validator
    def initialize(schemas)
      @schemas = schemas
    end

    def validate(resource)
      if schema = @schemas["#{resource["apiVersion"]}/#{resource["kind"]}"]
        schema.validate(resource).map { |e| stringify(e) }
      else
        []
      end
    end

  private
    def stringify(error)
      data_pointer, type, schema = error.values_at('data_pointer', 'type', 'schema')
      location = data_pointer.empty? ? 'root' : "property '#{data_pointer}'"

      case type
      when 'required'
        keys = error.fetch('details').fetch('missing_keys').join(', ')
        "#{location} is missing required keys: #{keys}"
      when 'null', 'string', 'boolean', 'integer', 'number', 'array', 'object'
        "#{location} is not of type: #{type}"
      when 'pattern'
        "#{location} does not match pattern: #{schema.fetch('pattern')}"
      when 'format'
        "#{location} does not match format: #{schema.fetch('format')}"
      when 'const'
        "#{location} is not: #{schema.fetch('const').inspect}"
      when 'enum'
        "#{location} is not one of: #{schema.fetch('enum')}"
      when 'schema'
        "#{location} is present, while it is missing in schema"
      else
        "#{location} is invalid: error_type=#{type}"
      end
    end

  end
end
