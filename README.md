# anynines Dumper
*anynines Dumper* is an utility for creating and downloading database dumps from your databases with the following features:
- Start the dump process and download the saved database dumps from a web interface
- Dumps are created asynchronously using a background worker ([sidekiq](http://sidekiq.org)) and stored in OpenStack Swift
- Support for PostgreSQL databases

## Requirements
### Supported database services
- [PostgreSQL](http://www.postgresql.org/)

### Required services
- [Redis](http://redis.io/)
- [Swift](http://docs.openstack.org/developer/swift/)

### Local requirements
- [Ruby](https://www.ruby-lang.org/en/) 2.2.2
- [Bundler](https://rubygems.org/gems/bundler) (`gem install bundler`)
- [Libpq-dev](http://stackoverflow.com/questions/6040583/cant-find-the-libpq-fe-h-header-when-trying-to-install-pg-gem)
- [pg](https://rubygems.org/gems/pg/versions/0.18.2) (`gem install pg`)

## Getting Started
### Create services in Cloud Foundry
After you've logged in to your anynines account with the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads), start by creating the services required by *anynines Dumper*: **Swift** and **Redis**.

Create a new Swift service. To see the available service plans, type `cf m[arketplace]`. You can choose any name you want as service name. Please make sure to use quotation marks if you use whitespace characters in the name.
```SHELL
cf create-service swift <SERVICE PLAN> <SERVICE NAME>
```

Create a new Redis service as you did with Swift:
```SHELL
cf create-service redis <SERVICE PLAN> <SERVICE NAME>
```

### Checkout repository and bundle gems
Checkout this repository:
```SHELL
git clone https://github.com/anynines/dumper.git
cd dumper
```
Install the gems:
```SHELL
bundle install
```

### Adapt manifest files
Adapt the manifest files for the web interface (`web-manifest.yml`) and the background worker (`worker-manifest.yml`) to suit your installation:

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
Deploy the app and its background worker to the cloud:
```SHELL
 cf push -f web-manifest.yml
```
```SHELL
 cf push -f worker-manifest.yml
```

Note: Make sure to use in both files the same service names (for the database, Swift and Redis services).

### Access web interface
Run `cf apps` to see all apps. You can find the URL of the web interface of *anynines Dumper* in the `urls` column of your app.

Open the displayed URL in a browser and login using the credentials you specified for `HTTP_AUTH_USER` and `HTTP_AUTH_PWD`.
