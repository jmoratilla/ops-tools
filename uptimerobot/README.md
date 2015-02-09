# BQ UptimeRobot

bq-uptimerobot is a cli tool that helps with the management of the uptimerobot monitors, contacts, and logs.

It allows:
  - Create, Edit, Delete monitors
  - Create, Delete contacts
  - Get a dump of the configuration in uptimerobot
  - Start or pause monitors using a substring or regexp

### Install it
```
$ gem install bundler --no-ri --no-rdoc
$ bundle install
```

### Configure it

bq-uptimerobot.rb needs to read three config files:
- settings.json: with info about the account and the mappings to use
- [account].json: with the configuration to upload

#### settings.json

```
{
  "accounts": {
    "example":            "xxx-yyyyy",
    "dev-example":        "xxx-yyyyy",
    "qa-example":         "xxx-yyyyy",
    "staging-example":    "xxx-yyyyy",
    "next-example":       "xxx-yyyyy",
    "current-example":    "xxx-yyyyy",
    "production-example": "xxx-yyyyy"
  },
  "format": "json",
  "mappings": {
    "newMonitor": {
      "friendlyname": "monitorFriendlyName",
      "url": "monitorURL",
      "type": "monitorType",
      "subtype": "monitorSubType",
      "keywordtype": "monitorKeywordType",
      "keywordvalue": "monitorKeywordValue",
      "httpusername": "monitorHTTPUsername",
      "httppassword": "monitorHTTPPassword",
      "port": "monitorPort",
      "interval": "monitorInterval",
      "status": "monitorStatus",
      "alertcontacts": "monitorAlertContacts"
    },
    "editMonitor": {
      "id": "monitorID",
      "friendlyname": "monitorFriendlyName",
      "url": "monitorURL",
      "type": "monitorType",
      "subtype": "monitorSubType",
      "keywordtype": "monitorKeywordType",
      "keywordvalue": "monitorKeywordValue",
      "httpusername": "monitorHTTPUsername",
      "httppassword": "monitorHTTPPassword",
      "port": "monitorPort",
      "interval": "monitorInterval",
      "status": "monitorStatus",
      "alertcontacts": "monitorAlertContacts"
    }
  }
}
```

#### [account].json

These file have all of the contacts and monitors defined in your uptimerobot account.

```
{
  "example": {
    "contacts": [
      {
        "id": "0000001",
        "value": "oncall@example.com",
        "friendlyname": "oncall@example.com",
        "type": "2",
        "status": "2"
      }
    ],
    "monitors": [
      {
        "id": "00000001",
        "friendlyname": "web-example",
        "url": "http://www.example.com",
        "type": "2",
        "subtype": "0",
        "keywordtype": "2",
        "keywordvalue": "example",
        "httpusername": "",
        "httppassword": "",
        "port": "0",
        "interval": "5",
        "status": "1",
        "alertcontacts": ""
      }
    ]
  }
}

```



### Use it

```sh
$ ./bq-uptimerobot.rb [-d] -a example show_config
$ ./bq-uptimerobot.rb [-d] -a example dump
$ ./bq-uptimerobot.rb [-d] -a example update
$ ./bq-uptimerobot.rb [-d] -a example pause substring
$ ./bq-uptimerobot.rb [-d] -a example start substring
```

#### Creating records

If you want to create a new contact or monitor, just fill the entry in the config/[account].json file.  Do not add an id field. 

```
{
  "example": {
    "contacts": [
      {
        ## "id": "0198901", ## DO NOT INCLUDE THE ID FIELD
        "value": "oncall@example.com",
        "friendlyname": "oncall@example.com",
        "type": "2",
        "status": "2"
      }
    ],
    "monitors": [
      {
        ## "id": "776628754",  ## DO NOT INCLUDE THE ID FIELD
        "friendlyname": "web-example",
        "url": "http://www.example.com",
        "type": "2",
        "subtype": "0",
        "keywordtype": "2",
        "keywordvalue": "bq",
        "httpusername": "",
        "httppassword": "",
        "port": "0",
        "interval": "5",
        "status": "1",
        "alertcontacts": ""
      }
    ]
  }
}

```

About status:

* 0 stop
* 1 start
* 2 is running and ok
* 8 is running failing


#### Editing an existing record

If you want to edit (update) an existing monitor, just edit the entry, but ensure it has an id field.  Contacts cannot be edited.


#### Deleting records

If you want to delete a contact or monitor, just add "delete": "true" to the entry.

```
{
  "example": {
    "contacts": [
      {
        "deleted": "true", ## Add "deleted": "true" to delete a record
        "id": "0198901",
        "value": "oncall@example.com",
        "friendlyname": "oncall@example.com",
        "type": "2",
        "status": "2"
      }
    ],
    "monitors": [
      {
        ## "id": "776628754",  ## DO NOT INCLUDE THE ID FIELD
        "friendlyname": "web-example",
        "url": "http://www.example.com",
        "type": "2",
        "subtype": "0",
        "keywordtype": "2",
        "keywordvalue": "bq",
        "httpusername": "",
        "httppassword": "",
        "port": "0",
        "interval": "5",
        "status": "1",
        "alertcontacts": ""
      }
    ]
  }
}

```

#### Pausing/Starting Monitors

You can pause a monitor or set of monitors if they share a prefix or suffix. 

```
$ ./bq-uptimerobot.rb [-d] -a example pause substring
I, [2015-02-09T12:09:44.824307 #12592]  INFO -- : start: {"id"=>"xxxx", "friendlyname"=>"web-example", "status"=>"0"}
```

To start a monitor or set of monitors, just execute the same command with start instead pause.


## NOTES:


### KNOWN ISSUES

Removing alertcontacts doesn't work, so if you want to remove contacts, you must do it manually.
