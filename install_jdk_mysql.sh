#!/usr/bin/env bash

#颜色定义
re="\033[0m"
red="\033[1;91m"
green="\e[1;32m"
yellow="\e[1;33m"
purple="\e[1;35m"


#颜色打印函数
red() { echo -e "\e[1;91m$1\033[0m"; }
green() { echo -e "\e[1;32m$1\033[0m"; }
yellow() { echo -e "\e[1;33m$1\033[0m"; }
purple() { echo -e "\e[1;35m$1\033[0m"; }
reading() { read -p "$(red "$1")" "$2"; }


menu(){
 #先清空上面的指令
  clear

   echo ""
   purple "=== RDM JDK&&MySQL Environmental Installation ===\n"

   green "1. 安装JDK与MySQL"
   echo  "==============="
   green "2. 安装JDK"
   echo  "==============="
   green "3. 安装MySQL"
   echo  "==============="
   green "4. 卸载JDK"
   echo  "==============="
   green "5. 卸载MySQL"
   echo  "==============="
   red   "6. 退出脚本"
   echo  "==============="


   reading "请输入选择(1-6): " choice
   echo ""
      case "${choice}" in
        1) install_jdk_mysql ;;
        2) install_jdk ;;
        3) install_mysql ;;
        4) uninstall_jdk ;;
        
        6) exit 0 ;;
        *) red "无效的选项，请输入 1 到 6" ;;
    esac



}

#卸载jdk
uninstall_jdk(){
   #先检查是否安装，命令：dpkg --list | grep -i jdk 
   #根据该指令显示的结果数量判断有没有安装jdk dpkg --list | grep -i jdk | wc -l 

   #执行该指令


   # 获取已安装的 JDK 包的数量
   jdk_count=$(dpkg --list | grep -i jdk | wc -l)

   # 判断 JDK 包的数量
if [ "$jdk_count" -gt 0 ]; then
     apt-get  -y  purge openjdk* 
     apt-get purge icedtea-* openjdk-*
     echo "###############################已完成jdk卸载###############################"
    
else
    echo "###############################系统中没有安装 JDK 包###############################"
fi

   
}



#安装jdk和MySQL
install_jdk_mysql(){
   install_jdk
   intstall_mysql
}



#安装jdk1.8
install_jdk(){

    jvmpath=/usr/lib/jvm/

    if [ ! -d "$jvmpath" ]; then

    echo "###############################JDK未安装###############################"
    echo "  "
        echo "*******************************开始更新apt**************************************"
        apt update
    echo "*******************************开始安装JDK**************************************"
    sudo apt-get  install openjdk-8-jdk -y
    echo "*******************************JDK 已经成功安装**************************************"

  else
    echo "*******************************JDK 已经安装**************************************"

    fi

}

#安装mysql
install_mysql(){

    # 根据MySQL 的依赖的数量判断有没有安装MySQL
     mysql_count=$(dpkg --list | grep mysql | wc -l)
     if [ "$mysql_count" -eq 0 ]; then
  
     echo "###############################MySQL未安装###############################"
     echo "  "
     echo "###############################开始安装MySQL###############################"
     tar -xvf  /usr/ppz/mysql-server_5.7.36-1ubuntu18.04_amd64.deb-bundle.tar
     sleep 2
     cd /usr/ppz
     sudo apt-get install /usr/ppz/libmysql* -y
     sudo apt-get install libtinfo5

     sudo apt-get install ./mysql-community-client_5.7.36-1ubuntu18.04_amd64.deb
     sudo apt-get install ./mysql-client_5.7.36-1ubuntu18.04_amd64.deb
     sudo apt-get install -y ./mysql-community-server_5.7.36-1ubuntu18.04_amd64.deb
     sudo apt-get install -y ./mysql-server_5.7.36-1ubuntu18.04_amd64.deb
      echo "###############################MySQL已经成功安装###############################"

      
       #开始对MySQL进行初始化配置修改

     #注释掉bind-address= 127.0.0.1
     echo "开始修改配置文件"

      #删除bind-address这行
     sed -i '/bind-address/d' /etc/mysql/mysql.conf.d/mysqld.cnf
      #追加不区分大小写lower_case_table_names=1
      sed -i -e '$a\lower_case_table_names=1' /etc/mysql/mysql.conf.d/mysqld.cnf
      #设置不用密码登录
      #sed -i '/\[mysqld\]/a skip-grant-tables' /etc/mysql/mysql.conf.d/mysqld.cnf

      # 重启MySQL服务
      systemctl restart mysql

      echo "修改配置文件成功"

       echo "开始修改密码和设置远程登录"

       sudo mysql -uroot -proot  << EOF
       update mysql.user set authentication_string=PASSWORD('rdm123'), plugin='mysql_native_password' where user='root';
       grant all ON *.* to root@'%' identified by 'rdm123' with grant option;
      flush privileges;
      exit
EOF

      echo "修改密码成功"

      # 恢复配置文件，移除skip-grant-tables
      #sed -i '/skip-grant-tables/d' /etc/mysql/mysql.conf.d/mysqld.cnf

      echo "重启MySQL服务"
     sudo /etc/init.d/mysql restart
     echo "重启完成"

    
      
      echo "开始插入表数据"
      #插入表数据
       mysql -uroot -prdm123 -e "source /usr/ppz/cams.sql"
      echo "插入完成"

      else
        echo "###############################MySQL已经安装###############################"

     fi

}

menu

