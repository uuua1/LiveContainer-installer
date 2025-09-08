import json
import re
import requests
from datetime import datetime

def prepare_description(text):
    text = re.sub('<[^<]+?>', '', text)  # Remove HTML tags
    text = re.sub(r'#{1,6}\s?', '', text)  # Remove markdown headers
    text = re.sub(r'\*{2}', '', text)  # Remove bold markdown
    text = re.sub(r'`', '"', text)  # Replace backticks with quotes
    return text

def fetch_latest_release(repo_url):
    api_url = f"https://api.github.com/repos/{repo_url}/releases"
    headers = {"Accept": "application/vnd.github+json"}
    response = requests.get(api_url, headers=headers)
    response.raise_for_status()
    releases = response.json()
    if releases:
        return releases[0]  # latest release
    return None

def update_json_file(json_file, latest_release):
    if not latest_release:
        print("No release found.")
        return

    # Read existing JSON or create new
    try:
        with open(json_file, "r") as f:
            data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        data = {
            "name": "LcInstaller Repo",
            "identifier": "site.ashutoshportfolio.lcinstaller",
            "subtitle": "LiveContainer Installer Repo to install or update LcInstaller",
            "iconURL": "https://raw.githubusercontent.com/asrma7/LiveContainer-installer/main/screenshots/100.png",
            "website": "https://github.com/asrma7/LiveContainer-Installer",
            "sourceURL": "https://raw.githubusercontent.com/asrma7/LiveContainer-Installer/main/source.json",
            "apps": []
        }

    app_entry = {
        "name": "LcInstaller",
        "bundleIdentifier": "site.ashutoshportfolio.lcinstaller",
        "developerName": "Ashutosh Sharma",
        "version": re.search(r"(\d+\.\d+\.\d+)", latest_release["tag_name"] or "1.0.0").group(1),
        "versionDate": datetime.strptime(latest_release["published_at"], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d"),
        "downloadURL": next((asset["browser_download_url"] for asset in latest_release.get("assets", []) if asset["name"].endswith(".ipa")), ""),
        "localizedDescription": f"Update of LiveContainer just got released!",
        "iconURL": "https://raw.githubusercontent.com/asrma7/LiveContainer-installer/main/screenshots/100.png",
        "size": next((asset["size"] for asset in latest_release.get("assets", []) if asset["name"].endswith(".ipa")), 0)
    }

    # Replace or append
    existing = next((a for a in data["apps"] if a["version"] == app_entry["version"]), None)
    if existing:
        data["apps"].remove(existing)
    data["apps"].append(app_entry)

    # Save
    with open(json_file, "w") as f:
        json.dump(data, f, indent=2)

    print(f"Updated {json_file} successfully.")

def update_sidestore_file(json_file, latest_release):
    if not latest_release:
        print("No release found.")
        return

    # Read existing JSON or create new
    try:
        with open(json_file, "r") as f:
            data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        data = {
            "name": "LcInstaller Repo",
            "identifier": "site.ashutoshportfolio.lcinstaller",
            "subtitle": "LiveContainer Installer Repo to install or update LcInstaller",
            "iconURL": "https://raw.githubusercontent.com/asrma7/LiveContainer-installer/main/screenshots/100.png",
            "website": "https://github.com/asrma7/LiveContainer-Installer",
            "sourceURL": "https://raw.githubusercontent.com/asrma7/LiveContainer-Installer/main/sidestore.json",
            "apps": []
        }

    app_entry = {
        "name": "LcInstaller",
        "bundleIdentifier": "site.ashutoshportfolio.lcinstaller",
        "developerName": "Ashutosh Sharma",
        "subtitle": "App installer for LiveContainer",
        "version": re.search(r"(\d+\.\d+\.\d+)", latest_release["tag_name"] or "1.0.0").group(1),
        "versionDate": datetime.strptime(latest_release["published_at"], "%Y-%m-%dT%H:%M:%SZ").strftime("%Y-%m-%d"),
        "versionDescription": prepare_description(latest_release.get("body", "No description provided.")),
        "downloadURL": next((asset["browser_download_url"] for asset in latest_release.get("assets", []) if asset["name"].endswith(".ipa")), ""),
        "localizedDescription": f"Install apps on LiveContainer from different sources with ease!",
        "iconURL": "https://raw.githubusercontent.com/asrma7/LiveContainer-installer/main/screenshots/100.png",
        "tintColor": "#307CFF",
        "size": next((asset["size"] for asset in latest_release.get("assets", []) if asset["name"].endswith(".ipa")), 0)
    }

    data["apps"] = [app_entry]  # Sidestore only keeps the latest version


    # Save
    with open(json_file, "w") as f:
        json.dump(data, f, indent=2)

    print(f"Updated {json_file} successfully.")

def main():
    repo_url = "asrma7/LiveContainer-Installer"
    latest = fetch_latest_release(repo_url)
    update_json_file("source.json", latest)
    update_sidestore_file("sidestore.json", latest)

if __name__ == "__main__":
    main()