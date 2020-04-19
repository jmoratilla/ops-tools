# README

This is a little tool I wrote to ease the creation of encrypted databags in Chef-solo

## commands
  - create_encrypted_databag.rb
  - show_encrypted_databag.rb

## requirements

  - ruby
  - gem bundler

## installation

```
$ bundle install
```

## use

### create_encrypted_databag
```
$ create_encrypted_databag.rb -s origin_file -d dest_file -k encryption_key
```

### show_encrypted_databag

```
$ show_encrypted_databag.rb -s encrypted_file -k encryption_key
```