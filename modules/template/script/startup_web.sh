#!/bin/bash
sudo dnf install -y httpd
sudo dnf install -y httpd python3

# 创建动态HTML页面
cat <<'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>MetroC Cloud Application Program</title>
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; }
        th { background-color: #f2f2f2; }
        .error { color: red; }
    </style>
</head>
<body>
    <h2>Cloud Computing and Application - Advanced Diploma</h2>
    <button onclick="loadData()">Refresh</button>
    <table>
        <thead><tr><th>COURSE NAME</th><th>COURSE GRADE</th></tr></thead>
        <tbody id="table-body"></tbody>
    </table>

<script>
async function loadData() {
    const tbody = document.getElementById('table-body');
    tbody.innerHTML = '<tr><td colspan="2">Loading...</td></tr>';

    try {
        const response = await fetch('/data');
        if (!response.ok) throw new Error(`HTTP $${response.status}`);

        // 更安全的JSON解析
        const result = await response.json();

        // 兼容两种数据格式：
        // 1. { data: [...] }
        // 2. 直接返回数组
        const data = result.data || result;

        if (!Array.isArray(data)) throw new Error("No Validate Data");

        tbody.innerHTML = data.map(item => `
            <tr>
                <td>$${item[0]}</td>
                <td>$${item[1]}</td>
            </tr>
        `).join('');
    } catch(e) {
        tbody.innerHTML = `
            <tr><td colspan="2" class="error">
                Error: $${e.message}<br>
                <small>Check F12 Console</small>
            </td></tr>
        `;
        console.error("Load Error", e);
    }
}
</script>

</body>
</html>
EOF



#Python 后端脚本 (/var/www/cgi-bin/data.py)
cat <<EOF > /var/www/cgi-bin/data.py
#!/usr/bin/python3
import json
import urllib.request

print("Content-Type: application/json\n")

try:
    # 从Flask获取数据
    with urllib.request.urlopen("http://${lb_app_ip}") as response:
        raw_data = response.read().decode('utf-8').strip()
    
    # 解析Python元组数据
    courses = [
        [x.strip(" '") for x in item.split(',')] 
        for item in raw_data.strip('()').split('), (')
    ]
    
    print(json.dumps({
        "status": "success",
        "data": courses
    }))
    
except Exception as e:
    print(json.dumps({
        "status": "error",
        "message": str(e)
    }))
EOF



# 配置CGI支持
cat <<EOF > /etc/httpd/conf.d/cgi.conf
ScriptAlias /data /var/www/cgi-bin/data.py
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options +ExecCGI
    AddHandler cgi-script .py
    Require all granted
</Directory>
EOF

#
sudo chmod +x /var/www/cgi-bin/data.py

# 设置SELinux允许网络连接
sudo setsebool -P httpd_can_network_connect on

# 配置防火墙
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# 启动服务
sudo systemctl restart httpd

