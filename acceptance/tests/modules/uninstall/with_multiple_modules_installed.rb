begin test_name "puppet module uninstall (with multiple modules installed)"

step "Setup"
apply_manifest_on master, <<-PP
file {
  [
    '/etc/puppet/modules',
    '/etc/puppet/modules/crakorn',
    '/usr/share/puppet',
    '/usr/share/puppet/modules',
    '/usr/share/puppet/modules/crakorn',
  ]: ensure => directory;
  [
    '/etc/puppet/modules/crakorn/metadata.json',
    '/usr/share/puppet/modules/crakorn/metadata.json',
  ]: content => '{
    "name": "jimmy/crakorn",
    "version": "0.4.0",
    "source": "",
    "author": "jimmy",
    "license": "MIT",
    "dependencies": []
  }';
}
PP
on master, '[ -d /etc/puppet/modules/crakorn ]'

step "Uninstall the module jimmy-crakorn"
on master, puppet('module uninstall jimmy-crakorn') do
  assert_equal '', stderr
  assert_equal <<-STDOUT, stdout
Removed /etc/puppet/modules/crakorn (v0.4.0)
Removed /usr/share/puppet/modules/crakorn (v0.4.0)
STDOUT
end
on master, '[ ! -d /etc/puppet/modules/crakorn ]'
on master, '[ ! -d /usr/share/puppet/modules/crakorn ]'

ensure step "Teardown"
apply_manifest_on master, "file { ['/etc/puppet/modules', '/usr/share/puppet/modules']: ensure => directory, recurse => true, purge => true, force => true }"
end