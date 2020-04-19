Gem::Specification.new do |s|
  s.name        = 'encrypted-databag'
  s.version     = '0.0.1'
  s.date        = '2014-11-27'
  s.summary     = 'Tool for encrypted databags'
  s.description = 'This is a set of tools I wrote to help me with encrpted databag'
  s.authors     = ['Jorge Moratilla']
  s.email       = 'jorge@moratilla.com'
  s.files       = [
    "bin/create-encrypted-databag",
    "bin/show-encrypted-databag"
  ]
  s.executables << 'create-encrypted-databag'
  s.executables << 'show-encrypted-databag'
  s.homepage    =
    "https://bitbucket.org/jmoratilla/encrypted-databag"
  s.license       = 'MIT'

  s.add_dependency 'json', '~>1.8'
  s.add_dependency 'chef'
end
