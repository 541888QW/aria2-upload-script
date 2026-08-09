cat > /usr/local/bin/upload-to-webdav.sh << 'EOF'
#!/bin/bash
WEBDAV_URL="http://127.0.0.1:5244/dav/"
WEBDAV_USER="admin"
WEBDAV_PASS="admin123"

# 上传函数
upload_file() {
    local file="$1"
    local name=$(basename "$file")
    local dir_path="$2"
    local target_url="${WEBDAV_URL}${dir_path}"

    # 创建子目录（如果不存在）
    curl -u "$WEBDAV_USER:$WEBDAV_PASS" -X MKCOL "$target_url" 2>/dev/null

    # 上传文件
    curl -u "$WEBDAV_USER:$WEBDAV_PASS" -T "$file" "${target_url}${name}" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "$(date): Uploaded $file to ${target_url}${name}" >> /var/log/aria2-upload.log
    else
        echo "$(date): Failed to upload $file" >> /var/log/aria2-upload.log
    fi
}

FILE_PATH="$3"

if [ -z "$FILE_PATH" ]; then
    echo "$(date): No file path provided" >> /var/log/aria2-upload.log
    exit 1
fi

# 如果是文件，直接上传到根目录
if [ -f "$FILE_PATH" ]; then
    upload_file "$FILE_PATH" ""
    exit 0
fi

# 如果是目录，获取目录名
if [ -d "$FILE_PATH" ]; then
    DIR_NAME=$(basename "$FILE_PATH")
    find "$FILE_PATH" -type f -print0 | while IFS= read -r -d '' file; do
        upload_file "$file" "$DIR_NAME"
    done
    exit 0
fi

echo "$(date): Invalid path: $FILE_PATH" >> /var/log/aria2-upload.log
EOF

chmod +x /usr/local/bin/upload-to-webdav.sh
systemctl restart aria2
