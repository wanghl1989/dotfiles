## fish 


```bash
# Fish 路径写入信任列表
echo $(which fish) | sudo tee -a /etc/shells

# 切换默认 Shell
chsh -s $(which fish)
```
