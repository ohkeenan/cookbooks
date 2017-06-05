## xml_file - Cookbook

`xml_file` resource-provider to manage XML files.

### Description

`xml_file` resource allows managing XML files where only parts of the file's
content is controlled. Users can specify `XPath` targets and expected content
at those targets.

### Usage
`xml_file` resource allows different attributes to specify
partial content.

- 'partial' attribute to add a XML fragments. Following example will
insert `part.xml` (present in `files/default` directory of the consumer cookbook) at '/parent/child' XPath target's last element.
Content of _whole.xml_
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project name="">
  <repo type="git"></repo>
  <maintainers>
    <maintainer>Hendrix</maintainer>
    <maintainer>Morrison</maintainer>
  </maintainers>
<project>
```

Content of _part.xml_
```xml
<issuetracker>
  <name>Jira</name>
  <url>http://example.com</url>
</issuetracker>
```
*xml_file* resource declaration:
```ruby
xml_file '/opt/whole.xml' do
  partial '//project', 'part.xml'
  owner 'root'
  group 'root'
  mode 0644
end
```
will change _whole.xml_ file to:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project name="">
  <repo type="git"></repo>
  <maintainers>
    <maintainer>Hendrix</maintainer>
    <maintainer>Morrison</maintainer>
  </maintainers>
  <issuetracker>
    <name>Jira</name>
    <url>http://example.com</url>
  </issuetracker>
<project>
```
`before` or `after` keys can be specified alongside the XPath values
to insert the elements at certain position with respective to their siblings.

- The 'attribute' method allows setting the value of an XML element's attribute.
Following is an example:
```ruby
xml_file '/opt/whole.xml' do
  attribute '//project/repo', 'type', 'svn'
  owner 'root'
  group 'root'
  mode 0644
end
```
Will result:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project name="">
  <repo type="svn"></repo>
  <maintainers>
    <maintainer>Hendrix</maintainer>
    <maintainer>Morrison</maintainer>
  </maintainers>
<project>
```
- The 'text' method will set the text content of an XML element. Following example:
```ruby
xml_file '/opt/whole.xml' do
  text '//maintainer[last()]', 'Ray'
  owner 'root'
  group 'root'
  mode 0644
end
```
will result:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project name="">
  <repo type="svn"></repo>
  <maintainers>
    <maintainer>Hendrix</maintainer>
    <maintainer>Ray</maintainer>
  </maintainers>
<project>
```
- The 'remove' method will remove all matching xpath elements: Following example:
```ruby
xml_file '/opt/whole.xml' do
  remove '//maintainer'
end
```
will result:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project name="">
  <repo type="svn"></repo>
  <maintainers>
  </maintainers>
<project>
```

All methods can be combined. When used in combination, partials are
processed before `text` and `attribute`, hence they can refer to XPath introduced by partials.

`xml_file` resource only supports :edit action. Its written in
REXML and should be portable across platforms.

## License
[Apache 2](http://www.apache.org/licenses/LICENSE-2.0)

## Contributing

1. Fork it ( https://github.com/GoatOS/xml_file/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
