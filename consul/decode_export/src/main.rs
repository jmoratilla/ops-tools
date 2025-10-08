use std::env;
use std::fs::File;
use std::io::BufReader;
use base64::{Engine as _, engine::general_purpose};


#[derive(serde::Deserialize)]
#[allow(dead_code)]
struct Entry {
    key: String,
    value: serde_json::Value,
}

/// Decodes a base64 encoded string and returns the decoded string
/// 
/// # Arguments
/// * `encoded_string` - A base64 encoded string
/// 
/// # Returns
#[allow(dead_code)]
fn decode_base64(encoded_string: &str) -> Result<String, Box<dyn std::error::Error>> {
    let decoded_bytes = general_purpose::STANDARD.decode(encoded_string)?;
    let decoded_string = String::from_utf8(decoded_bytes)?;
    Ok(decoded_string)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Use: {} <file.json> <value to find>", args[0]);
        std::process::exit(1);
    }

    let file = File::open(&args[1])?;
    let value_to_find = &args[2];
    let reader = BufReader::new(file);

    let entries: Vec<Entry> = serde_json::from_reader(reader)?;

    for entry in entries {
        match decode_base64(entry.value.as_str().unwrap_or("")) {
            Ok(decoded) => if decoded.contains(value_to_find) {
                println!("key: {}", entry.key)
            },
            Err(e) => println!("Error decoding base64: {}", e),
        }
    }

    Ok(())
}