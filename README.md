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
```SHELL
cf create-service swift <service_plan> <service_name>
```

Create a new redis service:
```SHELL
cf create-service redis <service_plan> <service_name>
```

### Checkout repository and bundle gems
Checkout this repository:
```SHELL
git clone https://github.com/anynines/dumper.git
cd dumper
```
Bundle the gems:
```SHELL
bundle install
```

### Adapt manifest files
Adapt the manifest files to suit your installation:

*web-manifest.yml*
```YAML
applications:
- name: <application name>
  memory: 512M
  instances: 1
  buildpack: https://github.com/cloudfoundry/ruby-buildpack.git
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
  buildpack: https://github.com/cloudfoundry/ruby-buildpack.git
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
```SHELL
 cf push -f web-manifest.yml
 cf push -f worker-manifest.yml
```

Both web application (`web-manifest.yml`) and background worker (`worker-manifest.yml`) need their own manifest file.
Note: You may want do change the username and password for the HTTP authentification.
Note: Make sure that you use the same database, redis and swift service names in both files.
