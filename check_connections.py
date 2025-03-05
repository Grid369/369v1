import subprocess
import os

def check_aws_cli():
    try:
        subprocess.run(["aws", "--version"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        print("AWS CLI is installed.")
    except subprocess.CalledProcessError:
        print("AWS CLI is not installed. Please install it from https://aws.amazon.com/cli/")

def check_aws_configuration():
    if os.path.isfile(os.path.expanduser("~/.aws/credentials")):
        print("AWS CLI is configured.")
    else:
        print("AWS CLI is not configured. Please run 'aws configure' to set it up.")

def check_github_ssh():
    try:
        result = subprocess.run(["ssh", "-T", "git@github.com"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if "successfully authenticated" in result.stderr.decode():
            print("GitHub is connected via SSH.")
        else:
            print("GitHub is not connected via SSH. Please set up SSH authentication with GitHub.")
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr.decode()}")
        print("GitHub is not connected via SSH. Please set up SSH authentication with GitHub.")

if __name__ == "__main__":
    check_aws_cli()
    check_aws_configuration()
    check_github_ssh()
