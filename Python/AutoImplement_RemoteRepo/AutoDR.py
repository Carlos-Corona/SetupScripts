## AUTO DOWNLOAD REPO 
#  This scritp veryfy the hash of the last commit and comparte it locally if has channge anythinh will automatically download the new version
#
##
import requests
import os
import subprocess
import argparse

repository_url = "https://github.com/your_username/your_repository.git"
token = "your_personal_access_token"

def check_for_changes():
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{repository_url}/commits", headers=headers)
    if response.status_code == 200:
        latest_commit = response.json()[0]["sha"]
        with open(".git/refs/remotes/origin/master", "r") as f:
            current_commit = f.read().strip()
        if latest_commit != current_commit:
            return True
    return False

def download_repository():
    if not os.path.exists(".git"):
        subprocess.run(["git", "clone", repository_url])
    else:
        subprocess.run(["git", "fetch", "origin", "master"], cwd=".git")
        subprocess.run(["git", "checkout", "master"], cwd=".git")


def main(args):
    if check_for_changes():
        download_repository()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("repositoryURL", help="Github Repository")
    parser.add_argument("PersonalToken",)

    main(sys.argv[1:])  # Skip the script name