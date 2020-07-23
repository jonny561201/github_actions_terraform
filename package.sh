#!/bin/bash

YELLOW='\033[1;33m'
WHITE='\033[0m'
GREEN='\033[0;32m'

PRESENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ZIP_DIR=lambda_python


function zipFiles {
  echo -e "${GREEN}----------Zipping up directory----------${WHITE}"
  if [[ "$OSTYPE" == "msys" ]]; then
    echo -e "${YELLOW}----------Windows Powershell Zip----------${WHITE}"
    powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('${ZIP_DIR}', '${ZIP_DIR}.zip'); }"
  else
    echo -e "${YELLOW}----------Linux Bash Zip----------${WHITE}"
    cd ${ZIP_DIR}
    zip -r ${ZIP_DIR}.zip .
    mv ${ZIP_DIR}.zip ../
    cd ../
  fi
}

function createDirectories {
  echo -e "${GREEN}----------Creating zip directory and copying python files----------${WHITE}"
  mkdir "${ZIP_DIR}"
  if [[ -f app.py ]]; then cp app.py ${ZIP_DIR}; fi
  cp -r src ${ZIP_DIR}
}

function cleanupDirectory {
  echo -e "${GREEN}----------Deleting original zip directory----------${WHITE}"
  rm -rf ${ZIP_DIR}
}

function installPythonDependencies {
  echo -e "${GREEN}----------Installing Python files to directory----------${WHITE}"
  UPDATED_REQUIREMENTS=$(cat requirements.txt | grep -v boto3)
  UPDATED_REQUIREMENTS=$(echo $UPDATED_REQUIREMENTS | tr '\r\n' ' ')
  if [[ "$OSTYPE" == "msys" ]]; then
    python -m pip install --target="${PRESENT_DIR}/${ZIP_DIR}" -U ${UPDATED_REQUIREMENTS}
  else
    python3 -m pip install --target="${PRESENT_DIR}/${ZIP_DIR}" -U ${UPDATED_REQUIREMENTS}
  fi
}

function validateDependencies {
  if [[ -f requirements.txt ]]; then
    echo "----------requirements found----------"
    installPythonDependencies
  else
    echo "----------requirements not found----------"
  fi
}

function deleteExistingFolders {
  if [[ -d "$ZIP_DIR" ]]; then
    echo -e "${GREEN}----------Deleting existing zip directory: ${ZIP_DIR}----------${WHITE}"
    rm -rf ${ZIP_DIR}
  fi
}

function deleteExistingZipFile {
  if [[ -f "${ZIP_DIR}.zip" ]]; then
    echo -e "${GREEN}----------Deleting existing zip file: ${ZIP_DIR}.zip----------${WHITE}"
    rm -rf "${ZIP_DIR}.zip"
  fi
}


deleteExistingFolders
deleteExistingZipFile
createDirectories
validateDependencies
zipFiles
cleanupDirectory
