require "kubernetes_schemas/version"
require "json-schema"

module KubernetesSchemas
  def self.load(kubernetes_version, strict: false)
    kubernetes_version = "#{kubernetes_version}-strict" if strict
    path = File.expand_path("../../schemas/#{kubernetes_version}", __FILE__)
    Dir.each_child(path).with_object({}) { |filename, hash|
      definition = JSON.parse(File.read(File.join(path, filename)))
      if definition["x-kubernetes-group-version-kind"]
        definition["$schema"] = "http://json-schema.org/draft-04/schema#"
        definition["x-kubernetes-group-version-kind"].each do |meta|
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
        validator = JSON::Validator.new(schema, resource, :record_errors => true)
        validator.validate
        validator.validation_errors.map(&:message)
      else
        []
      end
    end
  end
end
