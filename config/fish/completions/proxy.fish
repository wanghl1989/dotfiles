# 禁用默认的文件补全
complete -c proxy -f

# 开启代理的选项
complete -c proxy -n __fish_use_subcommand -a "on " -d "开启 Git 代理"

# 关闭代理的选项
complete -c proxy -n __fish_use_subcommand -a "off " -d "关闭 Git 全局代理配置"

# 查看状态的选项
complete -c proxy -n __fish_use_subcommand -a "show " -d "显示 Git 代理信息"
