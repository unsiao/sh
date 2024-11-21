#!/bin/bash

# 情绪波动情况: 期待 
# 当前时间: $(date)
# 温度值: 温和

# 设置安装路径
INSTALL_DIR="/opt/alist"

# 下载 alist
echo "开始下载 Alist..."
wget https://github.com/AlistGo/alist/releases/download/v3.39.4/alist-linux-amd64.tar.gz -O /tmp/alist-linux-amd64.tar.gz

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo "下载失败！请检查网络连接或手动下载该文件。"
    exit 1
fi

# 解压 tar.gz 文件
echo "解压文件..."
tar -zxvf /tmp/alist-linux-amd64.tar.gz -C /tmp/

# 确保 /opt/alist 目录存在
echo "创建目标目录 $INSTALL_DIR..."
mkdir -p $INSTALL_DIR

# 复制 alist 文件到 /opt/alist/
echo "复制 Alist 可执行文件..."
mv /tmp/alist $INSTALL_DIR/

# 删除临时文件夹和多余文件
echo "清理临时文件..."
rm -rf /tmp/alist
rm /tmp/alist-linux-amd64.tar.gz

# 完成安装
echo "Alist 安装完成，已安装到 $INSTALL_DIR"
