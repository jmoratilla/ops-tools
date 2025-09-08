use std::collections::HashMap;
use std::env;
use std::fs;
use std::path::{Path, PathBuf};

fn main() {
    let mut downloads_path: PathBuf = PathBuf::new();
    // If the user pass a directory as argument, use it first
    if env::args().len() > 1 {
        downloads_path = Path::new(&env::args().nth(1).unwrap()).to_path_buf();
        println!("Using directory {}", downloads_path.display());
    } else {
        // 1. Get the user's home directory
        let home_dir = match env::var("HOME") {
            Ok(dir) => dir,
            Err(_) => {
                eprintln!("Error al obtener el directorio de inicio");
                return;
            }
        };
        // 2. Build the path to the "Downloads" directory
        downloads_path = Path::new(&home_dir).join("Downloads");
    }

    // Read the files in the Downloads directory
    let files = match fs::read_dir(&downloads_path) {
        Ok(entries) => entries,
        Err(err) => {
            println!("{}", err);
            return;
        }
    };

    // Create a dictionary to store files by extension
    let mut file_extension_dict: HashMap<String, Vec<String>> = HashMap::new();

    for file in files {
        let file = match file {
            Ok(entry) => entry,
            Err(_) => continue,
        };

        // Skip directories
        if file.file_type().unwrap().is_dir() {
            continue;
        }

        let file_name = file.file_name().to_string_lossy().to_string();

        // Get the file extension
        let extension = match Path::new(&file_name).extension() {
            Some(ext) => ext.to_string_lossy().to_string(),
            None => {
                println!("{} does not have an extension", file_name);
                continue;
            }
        };

        // Exclude .DS_Store filename
        if extension == "DS_Store" {
            println!("Excluding .DS_Store filename");
            continue;
        }

        let ext = extension.to_uppercase();

        // Add the file to the dictionary
        file_extension_dict
            .entry(ext)
            .or_insert_with(Vec::new)
            .push(file_name);
    }

    // Create a directory for each extension in the dictionary
    for (ext, files) in file_extension_dict {
        let ext_path = downloads_path.join(&ext);

        if let Err(err) = fs::create_dir(&ext_path) {
            println!("{}", err);
        }

        // Move all files with the current extension to the new directory
        for file_name in files {
            let src_path = downloads_path.join(&file_name);
            let dst_path = ext_path.join(&file_name);

            if let Err(err) = fs::rename(&src_path, &dst_path) {
                println!("{}", err);
            }
        }

        println!("Moved all {} files to {}", ext, ext_path.display());
    }
}
