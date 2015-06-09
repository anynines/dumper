# anynines Dumper
*anynines Dumper* is a small web interface for creating and downloading database dumps from Cloud Foundry services.
- Creates asynchronously a database dump using [sidekiq](http://sidekiq.org/)
- Stores dumps in OpenStack Swift

## Supported Database Services
- PostgreSQL

## Additional Required Services
- Redis
- Swift

## Requirements
- Ruby 2.2.2
- Bundler (`gem install bundler`)
- [Libpq-dev](http://stackoverflow.com/questions/6040583/cant-find-the-libpq-fe-h-header-when-trying-to-install-pg-gem)
- [pg](https://rubygems.org/gems/pg/versions/0.18.2) (`gem install pg`)

## Getting Started
### Create services in Cloud Foundry
Start by creating the services required by *anynines Dumper*:

Create a new swift service (you can see the available service plans by typing `cf m[arketplace]`):
```SHELL
cf create-service swift <SERVICE PLAN> <SERVICE NAME>
```

Create a new redis service:
```SHELL
cf create-service redis <SERVICE PLAN> <SERVICE NAME>
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
---
applications:
- name: <APPLICATION NAME>
  memory: 512M
  instances: 1
  buildpack: https://github.com/cloudfoundry/ruby-buildpack.git
  host: <HOST NAME>
  domain: de.a9sapp.eu
  path: .
  services:
  - <REDIS SERVICE NAME>
  - <SWIFT SERVICE NAME>
  - <DATABASE SERVICE NAME> # You can use more than one database service
  #- <DATABASE SERVICE NAME 2>
  #- <DATABASE SERVICE NAME 3>
  env:
    LD_LIBRARY_PATH: /home/vcap/app/vendor/postgresql/lib
    HTTP_AUTH_USER: <USER NAME> # HTTP Authentication is used to access the web interface
    HTTP_AUTH_PWD: <PASSWORD>
```

*worker-manifest.yml*
```YAML
---
applications:
- name: <WORKER NAME>
  memory: 128M
  instances: 1
  buildpack: https://github.com/ddollar/heroku-buildpack-multi.git
  path: .
  command: bundle exec sidekiq -e production
  no-route: true
  services:
  - <REDIS SERVICE NAME>
  - <SWIFT SERVICE NAME>
  - <DATABASE SERVICE NAME> # You can use more than one database service
  #- <DATABASE SERVICE NAME 2>
  #- <DATABASE SERVICE NAME 3>
  env:
    LD_LIBRARY_PATH: /home/vcap/app/vendor/postgresql/lib
```

### Push anynines dumper to Cloud Foundry
Push the app and its background worker:
```SHELL
 cf push -f web-manifest.yml
 cf push -f worker-manifest.yml
```

Note: Make sure that you use the same database, Redis and Swift service names in both files.

### Access web interface
Run `cf apps` to see all apps. You can find the URL of the web interface for *anynines Dumper* in the `urls` column of your app.

Open the displayed URL in a browser and login using the credentials you specified for `HTTP_AUTH_USER` and `HTTP_AUTH_PWD`.
