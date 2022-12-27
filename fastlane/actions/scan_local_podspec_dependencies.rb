require 'cocoapods-core'

module Fastlane
  module Actions
    class ScanLocalPodspecDependenciesAction < Action
      def self.run(params)
        all_dependencies = {}
        Dir.glob('*.podspec').each do |path|
          podspec = Pod::Spec.from_file(File.expand_path(path)).to_hash
          dependencies = Set.new
          name = podspec['name']
          scan_dependencies(podspec, name, dependencies)
          all_dependencies[name] = dependencies.to_a
        end
        local_names = all_dependencies.keys
        all_dependencies.each_value do |dependencies|
          dependencies.filter! { |name| local_names.include?(name) }
        end

        loop do
          changes_count = 0
          all_dependencies.each do |name, dependencies|
            dependencies.each do |dependency_name|
              all_dependencies[dependency_name].each do |dependency_name_l2|
                if !dependencies.include?(dependency_name_l2) && name != dependency_name_l2
                  dependencies.append(dependency_name_l2)
                  changes_count += 1
                end
              end
            end
          end
          break if changes_count == 0
        end
        all_dependencies
      end

      def self.scan_dependencies(spec, name, out)
        dependencies = spec['dependencies']
        if dependencies.kind_of?(Hash)
          dependencies.each_key do |dependency_name|
            pod_name = dependency_name.gsub(%r{/.+}, '')
            out.add(pod_name) if pod_name != name
          end
        end
        subspecs = spec['subspecs']
        ['ios', 'watchos', 'macos', 'tvos'].each do |platform|
          platform_spec = spec[platform]
          if platform_spec.kind_of?(Hash)
            scan_dependencies(platform_spec, name, out)
          end
        end
        if subspecs.kind_of?(Array)
          subspecs.each do |subspec|
            scan_dependencies(subspec, name, out)
          end
        end
        testspecs = spec['testspecs']
        testspecs.each { |ts| scan_dependencies(ts, name, out) } if testspecs.kind_of?(Array)

        appspecs = spec['appspecs']
        appspecs.each { |s| scan_dependencies(s, name, out) } if appspecs.kind_of?(Array)
      end
    end
  end
end
