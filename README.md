Anynines Dumper
====

Dumper is small web interface for creating and downloading database dumps from cloud foundry services.

  - Creates asynchronously a database dump using sidekiq
  - Stores dumps in Openstack swift

Supported Database Services
----
  - PostgreSQL

Addtional Required Services
----
  - Redis
  - Swift

Getting Started
====

First you need to create the by dumper required services.

Create a new swift service:
```sh
cf create-service swift [SERVICEPLAN] [SERVICENAME]
```

Create a new redis service:
```sh
cf create-service redis [SERVICEPLAN] [SERVICENAME]
```

Note: You can see the available service plans with ```cf marketplace```

Checkout the repository:
```sh
git clone https://github.com/anynines/dumper.git
cd dumper
```
Bundle the gems:
```sh
bundle install
```

Edit the [manifest.yml](#manifest-files) files and then push the app with it's background worker:
```sh
 cf push -f web-manifest.yml
 cf push -f worker-manifest.yml
```
You can login at the server with the in *web-manifest.yml* defined credentials.

Manifest Files
====
Both web application (web-manifest.yml) and background worker (worker-manifest.yml) have their own manifest files:

*web-manifest.yml*
```
---
applications:
- name: [APPNAME]
  memory: 512M
  instances: 1
  buildpack: https://github.com/ddollar/heroku-buildpack-multi.git
  host: [HOST]
  domain: de.a9sapp.eu
  path: .
  services:
  - [REDIS_SERVICENAME]
  - [SWIFT_SERVICENAME]
  - [DATABASE_SERVICENAME]
  env:
    LD_LIBRARY_PATH: /home/vcap/app/vendor/postgresql/lib
    HTTP_AUTH_USER: dumper
    HTTP_AUTH_PWD: dumper
```

Note: You may want do change the username and password for the http authentification.

*workerweb-manifest.yml*
```
---
applications:
- name: [WORKERNAME]
  memory: 128M
  instances: 1
  buildpack: https://github.com/ddollar/heroku-buildpack-multi.git
  path: .
  command: bundle exec sidekiq -e production
  no-route: true
  services:
  - [REDIS_SERVICENAME]
  - [SWIFT_SERVICENAME]
  - [DATABASE_SERVICENAME]
  env:
    LD_LIBRARY_PATH: /home/vcap/app/vendor/postgresql/lib
```

* [APPNAME] a unique name for the application
* [HOST] a unique hostname for the application
* [REDIS_SERVICENAME] the name of the redis service you created before
* [SWIFT_SERVICENAME] the name of the swift service you created before
* [WORKERNAME] a unique name for the background worker
* [DATABASE_SERVICENAME] the name of the database service you would like to dump

Note: Make sure that you always use the same database, redis and swift services in both files.
