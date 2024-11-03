use cmd::Cmd;
use serde::Deserialize;
use symlink::Symlink;
use tokio::task::JoinSet;

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
            let mut cmd_set = JoinSet::new();
            for cmd in cmds.into_iter().map(Cmd::new) {
                cmd_set.spawn(cmd);
            }
            failed_cmds.append(&mut cmd_set.join_all().await);
        }

        if let Some(symlinks) = self.symlinks {
            let mut symlink_set = JoinSet::new();
            for symlink in symlinks {
                symlink_set.spawn(symlink);
            }
            symlink_set.join_all().await;
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
