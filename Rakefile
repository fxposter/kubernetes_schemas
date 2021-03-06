require "bundler/gem_tasks"
task :default => :spec

task :schemas do
  require "kubernetes_schemas/kubernetes_versions"
  require "tmpdir"
  require "json"
  require "fileutils"

  KubernetesSchemas::KUBERNETES_VERSIONS.each do |kubernetes_version, kind_docker_image|
    openapi_path = "#{Dir.tmpdir}/kubernetes-openapi-#{kubernetes_version}"
    jsonschema_dir = "./schemas/#{kubernetes_version}"
    strict_jsonschema_dir = "./schemas/#{kubernetes_version}-strict"

    system("kind", "delete", "cluster", "--name", "schemas-#{kubernetes_version}")
    FileUtils.rm_rf(jsonschema_dir)
    FileUtils.rm_rf(strict_jsonschema_dir)

    system("kind", "create", "cluster", "--name", "schemas-#{kubernetes_version}", "--image", kind_docker_image) or raise "could not create kind cluster for version #{kubernetes_version}"
    system("kubectl", "--context", "kind-schemas-#{kubernetes_version}", "get", "--raw", "/openapi/v2", :out => "#{Dir.tmpdir}/kubernetes-openapi-#{kubernetes_version}") or raise "could not get OpenAPI schemas from kubernetes apiserver"
    system("openapi2jsonschema", "--kubernetes", "--stand-alone", "--output", jsonschema_dir, openapi_path) or raise "failed to run openapi2jsonschema"
    system("openapi2jsonschema", "--kubernetes", "--stand-alone", "--strict", "--output", strict_jsonschema_dir, openapi_path) or raise "failed to run openapi2jsonschema"

    [jsonschema_dir, strict_jsonschema_dir].each do |dir|
      Dir.each_child(dir) do|filename|
        path = File.join(dir, filename)
        File.unlink(path) unless JSON.parse(File.read(path))['x-kubernetes-group-version-kind']
      end
    end
  ensure
    system("kind", "delete", "cluster", "--name", "schemas-#{kubernetes_version}")
  end
end
