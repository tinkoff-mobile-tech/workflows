module Fastlane
  module Actions
    class BumpPodspecDependencyAction < Action
      def self.run(params)
        podspecs = params[:podspecs]
        name = params[:name]
        version = params[:version]
        regexp = %r{(\.dependency\s+['"]#{Regexp.escape(name)}(?:/[^/'"]+)*['"]\s*,\s*['"])(?:[^'"]+)(['"])}m
        affected_podspecs = []
        podspecs.each do |podspec|
          UI.message("replacing #{regexp}")
          content = File.read(podspec)
          new_content = content.gsub(regexp, "\\1#{version}\\2")
          if new_content != content
            File.write(podspec, new_content)
            affected_podspecs.append(podspec)
          end
        end
        if affected_podspecs.empty?
          UI.important("No affected podspecs for dependency '#{name}'")
        else
          UI.success("Update dependency '#{name}' to version #{version} in #{affected_podspecs.join(', ')}")
        end
        affected_podspecs
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :podspecs,
            description: 'Podspec path list',
            type: Array,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :name,
            description: 'Dependency name (example: Alamofire)',
            type: String,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :version,
            description: 'Dependency version (example: \'~> 1.2.3\')',
            type: String,
            optional: false
          )
        ]
      end
    end
  end
end
