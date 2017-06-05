cookbook_file '/opt/template.xml' do
  action :create_if_missing
  source 'cruise.xml'
end

puts Chef::Config

template_file = Chef::Config[:file_cache_path] + '/partial.xml'
template template_file do
  action :create
  source 'partial.xml.erb'
  variables(
    name: 'xml_file',
    level: 'debug'
  )
end

xml_file '/opt/template.xml' do
  partial '//pipelines', template_file, before: '//pipeline'
  partial '//pipelines', 'second_partial.xml', before: '//pipeline'
  remove '//stage'
end
