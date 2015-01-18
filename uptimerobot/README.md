# BQ UptimeRobot

bq-uptimerobot is a cli tool that helps with the management of the uptimerobot monitors, contacts, and logs.

It allows:
  - Create, Edit, Delete monitors
  - Create, Delete contacts
  - Get logs
  - Get a dump of the configuration in uptimerobot


### Install it
```
$ gem install bundler --no-ri --no-rdoc
$ bundle install
```

### Configure it

bq-uptimerobot.rb needs to read three config files:
- accounts.json: with info about the account to use
- [account].json: with the configuration to upload
- mappings.json: mappings needed to create the proper URL's to upload monitors


### Use it

```sh
$ UPTIMEROBOT_ENV=guardias ./bq-uptimerobot.rb show_config
$ UPTIMEROBOT_ENV=guardias ./bq-uptimerobot.rb dump
$ UPTIMEROBOT_ENV=guardias ./bq-uptimerobot.rb upload_monitors

```
