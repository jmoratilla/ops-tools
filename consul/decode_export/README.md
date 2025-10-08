This tool needs a consul kv export to work.  It will read all the data,
 decode it and match it against the value to find.  It will return the
 key/s where the value contains the string to find.

```json
[
    {
        "key": "example1",
        "value": "dGVzdA=="  //test
    },
    {
        "key": "example2", 
        "value": "NDI="      //42
    }
]
```

### Execute

```shell
cargo run file.json 42
key: example1
```
