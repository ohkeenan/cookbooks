require 'chef/mixin/securable'
require 'chef/mixin/enforce_ownership_and_permissions'
require 'chef/scan_access_control'
require_relative 'helper'
require 'chef/run_context'
require 'chef/event_dispatch/dispatcher'

if defined?(ChefSpec)
  def edit_xml_file(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('xml_file', :edit, resource_name)
  end
end

class Chef
  class Resource
    # Chef resource for editing XML file
    class XmlFile < Chef::Resource
      include Chef::Mixin::Securable

      attr_reader :partials
      attr_reader :attributes
      attr_reader :texts
      attr_reader :removes
      attr_reader :decorator_block
      identity_attr :path
      state_attrs :owner, :group, :mode

      def initialize(name, run_context = nil)
        super
        @resource_name = :xml_file
        @action = 'edit'
        @provider = Chef::Provider::XmlFile
        @partials = []
        @attributes = Hash.new { |h, k| h[k] = [] }
        @texts = {}
        @removes = {}
        @path = name
        @decorator_block = ->(doc) {}
        allowed_actions.push(:edit)
      end

      def partial(xpath, file, position = nil)
        @partials.push([xpath, file, position])
      end

      def text(xpath, content)
        @texts[xpath] = content
      end

      def attribute(xpath, name, value)
        @attributes[xpath] << { name: name, value: value }
      end

      def decorate(&block)
        @decorator_block = block if block
      end

      def remove(xpath)
        @removes[xpath] = xpath
      end

      def path(arg = nil)
        set_or_return(:path, arg, kind_of: String)
      end
    end
  end

  class Provider
    # Chef provider for XmlFile resource
    class XmlFile < Chef::Provider
      include Chef::Mixin::EnforceOwnershipAndPermissions

      provides :xml_file

      def define_resource_requirements
        access_controls.define_resource_requirements
      end

      def load_current_resource
        @current_resource ||= Chef::Resource::XmlFile.new(new_resource.name)
        current_resource.path(new_resource.path)
        if ::File.exist?(new_resource.path)
          load_resource_attributes_from_file(current_resource)
        end
        current_resource
      end

      def load_resource_attributes_from_file(resource)
        return if Chef::Platform.windows?
        acl_scanner = ScanAccessControl.new(@new_resource, resource)
        acl_scanner.set_all!
      end

      def whyrun_supported?
        true
      end

      def manage_symlink_access?
        false
      end

      def action_edit
        file = XMLFile.new(new_resource.path)
        if new_resource.decorator_block
          new_resource.decorator_block.call(file.doc)
        end
        updated_partials = do_partials(file)
        updated_texts = do_texts(file)
        updated_attributes = do_attributes(file)
        updated_removes = do_removes(file)
        if updated_partials || updated_texts || updated_attributes || updated_removes
          converge_by "updated xml_file '#{@new_resource.name}" do
            file.write(new_resource.path)
          end
        end
        do_acl_changes
        load_resource_attributes_from_file(new_resource)
      end

      def do_partials(file)
        modified = false
        new_resource.partials.each do |xpath, spec, position|
          partial_path = file_cache_path(spec)
          unless file.partial_exist?(xpath, partial_path)
            file.add_partial(xpath, partial_path, position)
            modified = true
          end
        end
        modified
      end

      def do_attributes(file)
        modified = false
        new_resource.attributes.each do |xpath, specs|
          specs.each do |spec|
            unless file.same_attribute?(xpath, spec[:name], spec[:value])
              file.set_attribute(xpath, spec[:name], spec[:value])
              modified = true
            end
          end
        end
        modified
      end

      def do_texts(file)
        modified = false
        new_resource.texts.each do |xpath, content|
          unless file.same_text?(xpath, content)
            file.add_text(xpath, content)
            modified = true
          end
        end
        modified
      end

      def do_removes(file)
        modified = false
        new_resource.removes.each do |xpath, _|
          if file.remove?(xpath)
            file.remove(xpath)
            modified = true
          end
        end
        modified
      end

      def do_acl_changes
        if access_controls.requires_changes?
          converge_by(access_controls.describe_changes) do
            access_controls.set_all
          end
        end
      end

      def file_cache_path(name)
        if name[0] == '/'
          name
        else
          cookbook.preferred_filename_on_disk_location(run_context.node, :files, name)
        end
      end

      def cookbook
        @cookbook ||= run_context.cookbook_collection[new_resource.cookbook_name]
      end
    end
  end
end
