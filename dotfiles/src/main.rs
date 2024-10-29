use dotfiles_setup::App;
use std::{env, fs, path::PathBuf};

#[tokio::main]
async fn main() {
    let config_path = env::args().nth(1);
    let config_path = if let Some(path) = config_path {
        PathBuf::from(path)
    } else {
        "config.toml".into()
    };

    if !config_path.exists() {
        eprintln!("config.toml file not exists");
        return;
    }

    let Ok(cc) = fs::read_to_string(config_path) else {
        eprintln!("read config.toml failed");
        return;
    };

    App::setup(&cc).run().await;
}
