# stackdriver-annotation

This script allows us to send annotations, and marks, to stackdriver in order to have
some references.

## Installation

Enter the directory and check you have the bundler gem installed, then

```
$ gem bundler install --no-ri --no-rdoc
$ bundle install 
```

## Environment variable

This script uses an environment variable called STACKDRIVER_API_KEY.  Check in stackdriver
the api-key value or ask to your colleagues.

## Execution

```
stackdriver$ ./stackdriver-annotation.rb 
./stackdriver-annotation.rb -p project -m message [-t YYYY-MM-DD-HH-mm]
```

where
  - project: (i.e: silkroad) is an arbitrarian text related with a project. It's for our understanding
  - message: "silkroad-1.10 deployed to production"
  - t The time when the mark will be set.  Default is Time.now

Happy tagging!
