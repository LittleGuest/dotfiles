use std::{env, fs, future::Future, path::PathBuf, task::Poll};

use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct Symlink {
    source: String,
    target: String,
}

impl Future for Symlink {
    type Output = ();

    fn poll(
        self: std::pin::Pin<&mut Self>,
        _cx: &mut std::task::Context<'_>,
    ) -> std::task::Poll<Self::Output> {
        let Ok(dotfiles_path) = env::var("DOTFILES_PATH") else {
            eprintln!("DOTFILES_PATH is not set");
            return Poll::Ready(());
        };

        let Ok(home) = env::var("HOME") else {
            eprintln!("HOME is not set");
            return Poll::Ready(());
        };

        let source = PathBuf::from(&dotfiles_path).join(&self.source);
        let target = PathBuf::from(&home).join(&self.target);

        if !source.exists() {
            eprintln!(
                "链接 {} -> {} 失败，原因：source is not exists",
                source.to_string_lossy(),
                target.to_string_lossy()
            );
            return Poll::Ready(());
        }

        fs::remove_file(&target).ok();
        match std::os::unix::fs::symlink(&source, &target) {
            Ok(_) => {
                println!(
                    "链接 {} -> {} 成功",
                    source.to_string_lossy(),
                    target.to_string_lossy()
                );
            }
            Err(e) => {
                println!(
                    "链接 {} -> {} 失败，原因：{e}",
                    source.to_string_lossy(),
                    target.to_string_lossy()
                );
            }
        }

        Poll::Ready(())
    }
}
