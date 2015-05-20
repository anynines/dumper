# anynines Dumper
anynines Dumper is a small web interface for creating and downloading database dumps from Cloud Foundry services.
  - Creates asynchronously a database dump using sidekiq
  - Stores dumps in OpenStack Swift

## Supported Database Services
  - PostgreSQL

## Addtional Required Services
  - Redis
  - Swift

## Getting Started
### Create services in Cloud Foundry
Start by creating the services required by dumper:
Create a new swift service (you can see the available service plans by typing `cf m[arketplace]`):
```sh
cf create-service swift <service_plan> <service_name>
```

Create a new redis service:
```sh
cf create-service redis <service_plan> <service_name>
```

### Checkout repository and bundle gems
Checkout this repository:
```sh
git clone https://github.com/anynines/dumper.git
cd dumper
```
Bundle the gems:
```sh
bundle install
```

### Adapt manifest files
Adapt the to suit your installation:
*web-manifest.yml*
```YAML
applications:
- name: <application name>
  memory: 512M
  instances: 1
  buildpack: https://github.com/ddollar/heroku-buildpack-multi.git
  host: <host name>
  domain: de.a9sapp.eu
  path: .
  services:
  - <Redis service name>
  - <Swift service name>
  - <Database (PostgreSQL) service name>
  env:
    LD_LIBRARY_PATH: /home/vcap/app/vendor/postgresql/lib
    HTTP_AUTH_USER: dumper
    HTTP_AUTH_PWD: dumper
```

*workerweb-manifest.yml*
```YAML
applications:
- name: <worker name>
  memory: 128M
  instances: 1
  buildpack: https://github.com/ddollar/heroku-buildpack-multi.git
  path: .
  command: bundle exec sidekiq -e production
  no-route: true
  services:
  - <Redis service name>
  - <Swift service name>
  - <Database (PostgreSQL) service name>
  env:
    LD_LIBRARY_PATH: /home/vcap/app/vendor/postgresql/lib
```

### Push anynines dumper to Cloud Foundry
Push the app and its background worker:
```sh
 cf push -f web-manifest.yml
 cf push -f worker-manifest.yml
```

Manifest Files
====
Both web application (web-manifest.yml) and background worker (worker-manifest.yml) need their own manifest files.

Note: You may want do change the username and password for the http authentification.

Note: Make sure that you always use the same database, redis and swift services in both files.
