require 'cocoapods'
require 'tsort'

module Fastlane
  module Actions
    class SortedPodspecsAction < Action
      def self.run(params)
        @podspecs = params[:podspecs].map { |filename| Fastlane::Helper::Podspec.new(filename) }

        tsort.map(&:path)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Returns a list of podspecs sorted by dependency'
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        'Parses podspec from a given list and topologically sorts them by dependency'
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(
            key: :podspecs,
            description: 'Podspec path list',
            type: Array,
            optional: false
          )
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ['adarovsky']
      end

      #####################################################
      # @!group Sorting
      #####################################################

      def self.tsort_each_node(&block)
        @podspecs.each(&block)
      end

      def self.tsort_each_child(node, &block)
        node
          .dependencies
          .filter_map { |d| @podspecs.find { |e| e.name == d.name } }
          .each(&block)
      end

      extend TSort
    end
  end

  module Helper
    class Podspec

      attr_reader :path

      # @param [String] path
      def initialize(path)
        @path = path
        @spec = Pod::Spec.from_file(path)
      end

      def dependencies
        @spec.dependencies
      end

      def name
        @spec.name
      end

      def to_s
        "#{@spec}: #{path}/#{@spec.name}.podspec"
      end
    end
  end
end
