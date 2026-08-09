#!/bin/bash
WEBDAV_URL="http://127.0.0.1:5244/dav/123%20OpenList/"
WEBDAV_USER="admin"
WEBDAV_PASS="admin123"

# 创建目录（如果不存在）
curl -u "$WEBDAV_USER:$WEBDAV_PASS" -X MKCOL "$WEBDAV_URL" 2>/dev/null

# 上传函数
upload_file() {
    local file=$1
    local name=$(basename "$file")
    curl -u "$WEBDAV_USER:$WEBDAV_PASS" -T "$file" "$WEBDAV_URL$name"
    if [ $? -eq 0 ]; then
        echo "$(date): Uploaded $file" >> /var/log/aria2-upload.log
    else
        echo "$(date): Failed to upload $file" >> /var/log/aria2-upload.log
    fi
}

# 判断是文件还是目录
if [ -f "$3" ]; then
    upload_file "$3"
elif [ -d "$3" ]; then
    for file in "$3"/*; do
        if [ -f "$file" ]; then
            upload_file "$file"
        fi
    done
else
    echo "$(date): Invalid path $3" >> /var/log/aria2-upload.log
fi
