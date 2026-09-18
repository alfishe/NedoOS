#!/usr/bin/env python3
"""
Sync new revisions from upstream SVN (svn://nedoos.ru/nedoos/nedoos) to Git main branch.
Can be run locally or inside GitHub Actions.
"""

import os
import sys
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

SVN_URL = "svn://nedoos.ru/nedoos/nedoos"
CACHE_DIR = os.environ.get("SVN_CACHE_DIR", "/tmp/nedoos-svn-wc")

AUTHOR_MAP = {
    "alone": ("Alone", "alone@users.noreply.github.com"),
    "Alone": ("Alone", "alone@users.noreply.github.com"),
    "kulich": ("Kulich", "kulich@users.noreply.github.com"),
    "Kulich": ("Kulich", "kulich@users.noreply.github.com"),
    "dimkam": ("DimkaM", "dimkam@users.noreply.github.com"),
    "DimkaM": ("DimkaM", "dimkam@users.noreply.github.com"),
    "DImkaM": ("DimkaM", "dimkam@users.noreply.github.com"),
    "lvd": ("lvd", "lvd@users.noreply.github.com"),
    "demige": ("demige", "demige@users.noreply.github.com"),
    "galstaff": ("galstaff", "galstaff@users.noreply.github.com"),
    "salex": ("salex", "salex@users.noreply.github.com"),
    "baho": ("baho", "baho@users.noreply.github.com"),
    "gr8b": ("gr8b", "gr8b@users.noreply.github.com"),
    "Urfin": ("Urfin", "urfin@users.noreply.github.com"),
    "bruxy": ("bruxy", "bruxy@users.noreply.github.com"),
    "savelij": ("savelij", "savelij@users.noreply.github.com"),
    "(no author)": ("NedoOS Team", "nedoos@users.noreply.github.com"),
}

def get_author_info(svn_author):
    if not svn_author:
        return ("NedoOS Team", "nedoos@users.noreply.github.com")
    if svn_author in AUTHOR_MAP:
        return AUTHOR_MAP[svn_author]
    return (svn_author, f"{svn_author.lower()}@users.noreply.github.com")

def run(cmd, cwd=None, capture=False, env=None):
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)
    res = subprocess.run(
        cmd,
        cwd=cwd,
        check=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
        text=True,
        env=merged_env
    )
    return res.stdout if capture else None

def get_remote_head():
    output = run(["svn", "info", SVN_URL, "--xml"], capture=True)
    root = ET.fromstring(output)
    entry = root.find("entry")
    return int(entry.attrib["revision"])

def main():
    repo_root = Path(__file__).resolve().parent.parent
    os.chdir(repo_root)

    rev_file = repo_root / ".svn-revision"
    if rev_file.exists():
        current_rev = int(rev_file.read_text().strip())
    else:
        current_rev = 2685
        rev_file.write_text(f"{current_rev}\n")

    print(f"Current local synced revision: {current_rev}")
    remote_head = get_remote_head()
    print(f"Remote SVN HEAD revision: {remote_head}")

    if remote_head <= current_rev:
        print("Everything is up to date. No new SVN commits.")
        return 0

    print(f"Found {remote_head - current_rev} new revision(s) to synchronize.")

    # Prepare SVN working copy
    wc_path = Path(CACHE_DIR)
    if not (wc_path / ".svn").exists():
        print(f"Checking out SVN working copy at r{current_rev} into {wc_path}...")
        wc_path.parent.mkdir(parents=True, exist_ok=True)
        run(["svn", "checkout", "-r", str(current_rev), SVN_URL, str(wc_path)])
    else:
        print(f"Ensuring existing SVN working copy is at r{current_rev}...")
        run(["svn", "update", "-r", str(current_rev), str(wc_path)])

    synced_count = 0
    for rev in range(current_rev + 1, remote_head + 1):
        print(f"\n--- Syncing revision {rev}/{remote_head} ---")
        run(["svn", "update", "-r", str(rev), str(wc_path)])

        # Sync files to git repo (excluding git/svn/github files)
        rsync_cmd = [
            "rsync", "-av", "--delete",
            "--exclude=.svn",
            "--exclude=.git",
            "--exclude=.github",
            "--exclude=scripts",
            "--exclude=.svn-revision",
            f"{wc_path}/", "./"
        ]
        run(rsync_cmd)

        # Update .svn-revision file
        rev_file.write_text(f"{rev}\n")

        # Fetch log details for this revision
        log_xml = run(["svn", "log", "-c", str(rev), SVN_URL, "--xml"], capture=True)
        log_root = ET.fromstring(log_xml)
        log_entry = log_root.find("logentry")

        author_elem = log_entry.find("author")
        svn_author = author_elem.text if author_elem is not None else "(no author)"
        name, email = get_author_info(svn_author)

        date_elem = log_entry.find("date")
        commit_date = date_elem.text if date_elem is not None else ""

        msg_elem = log_entry.find("msg")
        commit_msg = msg_elem.text.strip() if (msg_elem is not None and msg_elem.text) else f"r{rev}: (no commit message)"

        # Check git status
        status = run(["git", "status", "--porcelain"], capture=True)
        if status.strip():
            run(["git", "add", "-A"])
            commit_env = {
                "GIT_AUTHOR_NAME": name,
                "GIT_AUTHOR_EMAIL": email,
                "GIT_AUTHOR_DATE": commit_date,
                "GIT_COMMITTER_NAME": name,
                "GIT_COMMITTER_EMAIL": email,
                "GIT_COMMITTER_DATE": commit_date,
            }
            run(["git", "commit", "-m", commit_msg], env=commit_env)
            print(f"Created Git commit for r{rev} by {name} <{email}>")
            synced_count += 1
        else:
            print(f"Revision {rev} had no file changes affecting git root.")

    print(f"\nSync complete! Synced {synced_count} commit(s). Local revision is now {remote_head}.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
