require "bundler/gem_tasks"
task :default => :spec

KUBERNETES_VERSIONS = {
  "1.22" => "v1.22.17",
  "1.23" => "v1.23.17",
  "1.24" => "v1.24.17",
  "1.25" => "v1.25.16",
  "1.26" => "v1.26.14",
  "1.27" => "v1.27.11",
  "1.28" => "v1.28.7",
  "1.29" => "v1.29.2",
}

task :schemas do
  require "tmpdir"
  require "json"
  require "fileutils"

  KUBERNETES_VERSIONS.each do |kubernetes_version, full_kubernetes_version|
    base_image = "kindest/node"
    base_image = "#{base_image}-arm64" if RUBY_PLATFORM.start_with?('arm64-')
    kind_docker_image = "#{base_image}:#{full_kubernetes_version}"
    openapi_path = "#{Dir.tmpdir}/kubernetes-openapi-#{kubernetes_version}"
    jsonschema_dir = "./schemas/#{kubernetes_version}"
    strict_jsonschema_dir = "./schemas/#{kubernetes_version}-strict"

    system("kind", "delete", "cluster", "--name", "schemas-#{kubernetes_version}")
    system("kind", "create", "cluster", "--name", "schemas-#{kubernetes_version}", "--image", kind_docker_image) or raise "could not create kind cluster for version #{kubernetes_version}"
    system("kubectl", "--context", "kind-schemas-#{kubernetes_version}", "get", "--raw", "/openapi/v2", :out => "#{Dir.tmpdir}/kubernetes-openapi-#{kubernetes_version}") or raise "could not get OpenAPI schemas from kubernetes apiserver"
    FileUtils.rm_rf(jsonschema_dir)
    FileUtils.rm_rf(strict_jsonschema_dir)
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
