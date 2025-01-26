#/bin/bash
archive_name=$(zenity --forms="Archive Details" --add-entry=Name)
if [[ "$?" == "1"]]; then
    exit 1
fi

zip 