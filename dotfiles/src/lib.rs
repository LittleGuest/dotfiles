use cmd::Cmd;
use serde::Deserialize;
use symlink::Symlink;

mod cmd;
mod symlink;

#[derive(Debug, Deserialize)]
pub struct App {
    pre: Option<Vec<String>>,
    cmds: Option<Vec<String>>,
    symlinks: Option<Vec<Symlink>>,
}

impl App {
    pub fn setup(cc: &str) -> Self {
        toml::from_str::<Self>(cc).unwrap()
    }

    pub async fn run(self) {
        if let Some(pre) = self.pre {
            for cmd in pre.into_iter().map(Cmd::new) {
                if let Some((c, err)) = cmd.await {
                    eprintln!("{c}，原因：{err}");
                    return;
                }
            }
        }

        let mut failed_cmds = Vec::new();
        if let Some(cmds) = self.cmds {
            for cmd in cmds.into_iter().map(Cmd::new) {
                failed_cmds.push(cmd.await);
            }
        }

        if let Some(symlinks) = self.symlinks {
            for symlink in symlinks {
                symlink.await;
            }
        }

        if failed_cmds.is_empty() {
            return;
        }

        let fail_cmds = failed_cmds
            .iter()
            .filter(|c| c.is_some())
            .flatten()
            .collect::<Vec<_>>();
        if !fail_cmds.is_empty() {
            eprintln!("\n\n\n以下命令执行失败");
            for (cmd, e) in fail_cmds {
                eprintln!("{cmd}，原因：{e}");
            }
        }
    }
}
