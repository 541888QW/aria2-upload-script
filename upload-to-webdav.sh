cat > /usr/local/bin/upload-to-webdav.sh << 'EOF'
#!/bin/bash
WEBDAV_URL="http://127.0.0.1:5244/dav/123%20OpenList/"
WEBDAV_USER="admin"
WEBDAV_PASS="admin123"

# 创建目录（如果不存在）
curl -u "$WEBDAV_USER:$WEBDAV_PASS" -X MKCOL "$WEBDAV_URL" 2>/dev/null

# 上传函数
upload_file() {
    local file="$1"
    local name=$(basename "$file")
    curl -u "$WEBDAV_USER:$WEBDAV_PASS" -T "$file" "$WEBDAV_URL$name"
    if [ $? -eq 0 ]; then
        echo "$(date): Uploaded $file" >> /var/log/aria2-upload.log
    else
        echo "$(date): Failed to upload $file" >> /var/log/aria2-upload.log
    fi
}

# 获取文件路径（支持带空格的路径）
FILE_PATH="$3"

if [ -f "$FILE_PATH" ]; then
    # 单个文件
    upload_file "$FILE_PATH"
elif [ -d "$FILE_PATH" ]; then
    # 文件夹：遍历所有文件
    find "$FILE_PATH" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
        upload_file "$file"
    done
else
    echo "$(date): Invalid path: $FILE_PATH" >> /var/log/aria2-upload.log
fi
EOF

chmod +x /usr/local/bin/upload-to-webdav.sh
systemctl restart aria2
