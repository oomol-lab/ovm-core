#!/usr/bin/env python3

# Implementation reference:
# https://github.com/electron/electron/blob/f5c177698ed8ad80c068d0f5788c8606e81d31c2/script/lib/git.py

import argparse
import os
import re
import sys
import subprocess
from datetime import datetime

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
PATCHES_DIR = os.path.join(PROJECT_DIR, "patches")

def check_output(cmd, shell=False, cwd=PROJECT_DIR, timeout=5):
    return subprocess.check_output(
        cmd,
        shell=shell,
        cwd=cwd,
        timeout=timeout,
        stderr=subprocess.STDOUT
    ).decode("utf-8").strip()

def shell(cmd, cwd=PROJECT_DIR):
    return check_output(cmd, cwd=cwd, shell=True)

def git_sub(submodule, git_args):
    cmd = [
        "git",
        "-C",
        submodule
    ] + git_args

    return check_output(cmd)

def git_submodule_list():
    stdout = shell("git submodule | awk '{ print $2 }'")

    submodules = []
    for line in stdout.splitlines():
        submodules.append(line.strip())

    return submodules

def git_ref(submodule):
    """get branch name or tag name of submodule
    Returns:
        Branch name or tag name, not support commit hash
    """

    branch = git_sub(
        submodule,
        [
            "branch",
            "--show-current"
        ]
    )
    if branch:
        return branch
    
    return git_sub(
        submodule,
        [
            "describe",
            "--tags"
        ]
    )

def git_unpushed_commits(submodule):
    stdout = git_sub(
        submodule,
        [
            "log",
            git_ref(submodule),
            "--not",
            "--remotes",
            "--pretty=format:%h:%s"
        ]
    )

    commits = []
    for line in stdout.splitlines():
        commits.append(line)

    return commits

def git_format_patch(submodule):
    commits = git_unpushed_commits(submodule)
    if len(commits) == 0:
        print("Not found need export commits at {}".format(submodule))
        exit(0)
    
    stdout = git_sub(
        submodule,
        [
            "format-patch",
            "-{}".format(len(commits)),
            "--zero-commit",
            "--no-signature",
            "--full-index",
            "--keep-subject",
            "--no-stat",
            "--stdout"
        ]
    )

    patches = []
    # Output an all-zero hash in each patch’s From header instead of the hash of the commit
    patch_start_flag = re.compile("^From 0{40} ")

    for line in stdout.splitlines(True):
        if patch_start_flag.match(line):
            patches.append([])
        patches[-1].append(line)
    return patches

def patch_generate_filename(patch):
    kSubject = "Subject: "
    for line in patch:
        if line.startswith(kSubject):
            return re.sub(r"[^A-Za-z0-9-]+", "_", line[len(kSubject):]).strip("_\n").lower()

def patch_sub_dir(submodule):
    p = os.path.join(PATCHES_DIR, submodule)
    if not os.path.exists(p):
        os.makedirs(p)
    
    return p

def backup(submodule):
    backup_branch = "patch-backup/{}".format(datetime.now().strftime("%Y%m%d%H%M%S"))
    git_sub(
        submodule,
        [
            "checkout",
            "--quiet",
            "-b",
            backup_branch
        ]
    )

    print("Backup branch: {} in {}".format(backup_branch, submodule))

    ref = git_ref(submodule)
    git_sub(
        submodule,
        [
            "checkout",
            "--quiet",
            ref
        ]
    )

def export(submodule):
    workdir = patch_sub_dir(submodule)
    patches = git_format_patch(submodule)
    with open(os.path.join(workdir, ".patches"), "w+") as pl:
        for patch in patches:
            patch_filename = patch_generate_filename(patch)
            with open(os.path.join(workdir, patch_filename + ".patch"), "wb") as p:
                formatted_patch = "".join(patch).rstrip("\n") + "\n"
                p.write(formatted_patch.encode("utf-8"))

            pl.write(patch_filename + ".patch\n")

def reset(submodule):
    commits = git_unpushed_commits(submodule)
    if len(commits) == 0:
        print("Not found need reset commits at {}".format(submodule))
        exit(0)
    
    backup(submodule)

    for commit in commits:
        h, subject = commit.split(":", 1)
        print("Resting commit hash: {}, subject: {} in {}".format(h, subject, submodule))

        git_sub(
            submodule,
            [
                "reset",
                "--hard",
                h + "~1"
            ]
        )

def apply(submodule):
    workdir = patch_sub_dir(submodule)
    patch_list = os.path.join(workdir, ".patches")

    if not os.path.exists(patch_list):
        print("Not found {}, please export patches first".format(patch_list))
        exit(0)

    for line in open(patch_list, "r").readlines():
        line = line.strip()
        if line == "" or line.startswith("#"):
            continue

        patch_path = os.path.join(workdir, line)
        if not os.path.exists(patch_path):
            print("Not found {}".format(patch_path))
            continue

        git_sub(
            submodule,
            [
                "apply",
                "--whitespace",
                "fix",
                "--3way",
                "--check",
                patch_path
            ]
        )

        git_sub(
            submodule,
            [
                "am",
                "--keep-cr",
                "--whitespace",
                "fix",
                "--quiet",
                "--3way",
                patch_path
            ]
        )

        print("Applying {} patches success".format(patch_path))

def main(argv):
    submodules = git_submodule_list()
    append_help = " (Allow values {})".format(", ".join(submodules))

    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--export",  help="Export patches" + append_help, metavar="", choices=submodules)
    group.add_argument("--apply", help="Apply patches" + append_help, metavar="", choices=submodules)
    group.add_argument("--reset", help="Reset patches" + append_help, metavar="", choices=submodules)
    args = parser.parse_args(argv)

    if args.export:
        return export(args.export)
    elif args.apply:
        return apply(args.apply)
    elif args.reset:
        return reset(args.reset)
    else:
        return parser.print_help()

if __name__ == "__main__":
    main(sys.argv[1:])
