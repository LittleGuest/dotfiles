use std::{
    fmt::Display,
    future::Future,
    io::Write,
    process::{Command, Stdio},
    task::Poll,
};

use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct Cmd {
    cmd: String,
    /// 计数器
    counter: u8,
    /// 重试次数
    retry: u8,
}

impl Cmd {
    pub fn new(cmd: String) -> Self {
        Self {
            cmd,
            counter: 0,
            retry: 5,
        }
    }
}

impl Display for Cmd {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(&self.cmd)
    }
}

impl Future for Cmd {
    type Output = Option<(String, String)>;

    fn poll(
        self: std::pin::Pin<&mut Self>,
        cx: &mut std::task::Context<'_>,
    ) -> std::task::Poll<Self::Output> {
        if self.counter >= self.retry {
            return Poll::Ready(Some((self.cmd.clone(), "retry more than 5".into())));
        }

        if self.cmd.is_empty() {
            return Poll::Ready(Some((self.cmd.clone(), "cmd is empty".into())));
        }

        println!("开始执行 {}", self.cmd);

        let mut child = match Command::new("bash")
            .arg("-c")
            .arg(self.cmd.clone())
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .spawn()
        {
            Ok(c) => c,
            Err(e) => {
                return Poll::Ready(Some((self.cmd.clone(), format!("cmd execute failed: {e}"))));
            }
        };

        let mut child_stdin = child.stdin.take().unwrap();

        std::thread::spawn(move || {
            child_stdin.write_all(b"y").ok();
        });

        let child_output = child.wait_with_output().unwrap();

        let cmd = self.get_mut();

        if child_output.status.success() {
            println!("执行 {} 成功", cmd.cmd);
            return Poll::Ready(None);
        }

        cmd.counter += 1;

        eprintln!(
            "执行 {} 失败，原因：{}",
            cmd.cmd,
            String::from_utf8_lossy(&child_output.stderr)
        );

        cx.waker().wake_by_ref();

        Poll::Pending
    }
}
