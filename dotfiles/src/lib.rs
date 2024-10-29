use cmd::Cmd;
use serde::Deserialize;
use symlink::Symlink;
use tokio::task::JoinSet;

mod cmd;
mod symlink;

#[derive(Debug, Deserialize)]
pub struct App {
    cmds: Vec<String>,
    symlinks: Vec<Symlink>,
}

impl App {
    pub fn setup(cc: &str) -> Self {
        toml::from_str::<Self>(cc).unwrap()
    }

    pub async fn run(self) {
        let mut cmd_set = JoinSet::new();
        for cmd in self.cmds.into_iter().map(Cmd::new) {
            cmd_set.spawn(cmd);
        }
        let res = cmd_set.join_all().await;

        let mut symlink_set = JoinSet::new();
        for symlink in self.symlinks {
            symlink_set.spawn(symlink);
        }
        symlink_set.join_all().await;

        let fail_cmds = res
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
