## 2017-03-16 Release 0.1.2

Added option to optionally install Apache.

## 2017-03-16 Release 0.1.1

- changed ownership of docroot and env file to avoid conflit with vcsrepo resource
- mod_php71w is used and not the apache::mod::php since it's difficult to use the latter when apache config files come from a different package
- let's stick to the default mpm prefork (RHEL/CentOS)
- do not purge apache configs but expose a parameter to do that

### Bugfixes

- added HOME also when installing composer

## 2017-03-15 Release 0.1.0

First release

- worked for my initial tests :)
