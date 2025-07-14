#!/bin/bash

######################################################################
#           Auto Install & Optimize LEMP Stack on CentOS 7, 8        #
#                                                                    #
#                Author: Sanvv - HOSTVN Technical                    #
#                  Website: https://hostvn.vn                        #
#                                                                    #
#              Please do not remove copyright. Thank!                #
#  Please do not copy under any circumstance for commercial reason!  #
######################################################################

# shellcheck disable=SC2154
# shellcheck disable=SC1091
source /var/hostvn/hostvn.conf
source /var/hostvn/menu/helpers/variable_common

# Get telegram config
if [ ! -f "/var/hostvn/telegram/.telegram_backup_config" ]; then
    exit 1
fi

TELEGRAM_BOT_TOKEN=$(grep -w "telegram_bot_token" "/var/hostvn/telegram/.telegram_backup_config" | cut -f2 -d'=')
TELEGRAM_CHAT_ID=$(grep -w "telegram_chat_id" "/var/hostvn/telegram/.telegram_backup_config" | cut -f2 -d'=')

if [[ -z "${TELEGRAM_BOT_TOKEN}" || -z "${TELEGRAM_CHAT_ID}" ]]; then
    exit 1
fi

# Telegram API URL
TELEGRAM_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"
TIMEOUT="10"

for domains in ${BASH_DIR}/telegram/*; do
    domain=$(echo $domains | cut -f5 -d'/')
    if [[ -f "${USER_DIR}/.${domain}.conf" ]]; then
        user=$(grep -w "username" "${USER_DIR}/.${domain}.conf" | cut -f2 -d'=')
        db_name=$(grep -w "db_name" "${USER_DIR}/.${domain}.conf" | cut -f2 -d'=')
        
        if [[ ! -d "/home/backup/${CURRENT_DATE}/${domain}" ]]; then
            mkdir -p /home/backup/"${CURRENT_DATE}"/"${domain}"
        fi
        rm -rf /home/backup/"${CURRENT_DATE}"/"${domain}"/*
        cd /home/backup/"${CURRENT_DATE}"/"${domain}" || exit
        mysqldump -uadmin -p"${mysql_pwd}" "${db_name}" | gzip > "${db_name}".sql.gz

        cd /home/"${user}"/"${domain}" || exit
        if [[ ! -f "/home/${user}/${domain}/public_html/wp-config.php" && -f "/home/${user}/${domain}/wp-config.php" ]]; then
            cp /home/"${user}"/"${domain}"/wp-config.php /home/"${user}"/"${domain}"/public_html/wp-config.php
        fi
        if [ -d "/home/${user}/${domain}/public_html/storage" ]; then
            tar -cpzvf /home/backup/"${CURRENT_DATE}"/"${domain}"/"${domain}".tar.gz "public_html" \
                --exclude "public_html/wp-content/cache" --exclude "public_html/storage/framework/cache" \
                --exclude "public_html/storage/framework/view" --exclude "public_html/storage/logs"
        else
            tar -cpzvf /home/backup/"${CURRENT_DATE}"/"${domain}"/"${domain}".tar.gz "public_html" \
                --exclude "public_html/wp-content/cache" --exclude "public_html/storage/framework/cache" \
                --exclude "public_html/storage/framework/view"
        fi

        # Send telegram notification
        BACKUP_SIZE=$(du -sh /home/backup/"${CURRENT_DATE}"/"${domain}" | awk '{print $1}')
        MESSAGE="📦 BACKUP COMPLETED
🖥 Server: $(hostname -I | awk '{print $1}')
🌐 Domain: ${domain}
📅 Date: ${CURRENT_DATE}
💾 Size: ${BACKUP_SIZE}
⏰ Time: $(date '+%H:%M:%S')"

        curl -s --max-time "${TIMEOUT}" -d "chat_id=${TELEGRAM_CHAT_ID}&disable_web_page_preview=1&text=${MESSAGE}" "${TELEGRAM_URL}" > /dev/null

    fi
done

# Cleanup old backups
backup_num=$(grep -w "backup_num" "${FILE_INFO}" | cut -f2 -d'=')
if [[ -n "${backup_num}" && "${backup_num}" -gt 0 ]]; then
    find /home/backup -type d -name "*-*-*" -mtime +${backup_num} -exec rm -rf {} \; 2>/dev/null
fi
