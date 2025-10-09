use reqwest::Client;
use serde_json::Value;
use serde_json::json;
use std::env;

#[tokio::main]
async fn main() {
    let client = Client::new();
    let args = env::args().collect::<Vec<String>>();
    if args.len() != 2 {
        eprintln!("Use: {} <heartbeat name>", args[0]);
        std::process::exit(1);
    }
    let heartbeat_name = &args[1];

    let url = env::var("API_URL").unwrap_or("https://api.rootly.com/v1/heartbeats".to_string());
    let token = env::var("API_TOKEN").unwrap_or("example".to_string());
    let params = [("filter[name]", heartbeat_name)];

    let response = client
        .get(url)
        .bearer_auth(token)
        .query(&params)
        .send()
        .await;

    match response {
        Ok(resp) => {   
            if resp.status().is_success() {
                match resp.json::<Value>().await {
                    Ok(json) => println!("Respuesta JSON: {}", serde_json::to_string_pretty(&json.get("data")).unwrap()),
                    Err(e) => eprintln!("Error al interpretar el JSON: {}", e),
                }
            } else {
                eprintln!("Error HTTP: {}", resp.status());
            }
        }
        Err(e) => eprintln!("Error en la petición: {}", e),
    }
}
