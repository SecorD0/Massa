#!/bin/bash
# Default variables
insert_variables="false"
action=""
language="EN"
raw_output="false"
private_keys="false"
max_buy="false"

# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo $1 | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script provides advanced CLI client features"
		echo
		echo -e "Usage: script ${C_LGn}[OPTIONS]${RES} ${C_LGn}[ARGUMENTS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help               show help page"
		echo -e "  -a, --action ACTION      execute the ACTION"
		echo -e "  -l, --language LANGUAGE  use the LANGUAGE for texts"
		echo -e "                           LANGUAGE is '${C_LGn}EN${RES}' (default), '${C_LGn}RU${RES}'"
		echo -e "  -pk, --private-keys      show private keys of wallets in '${C_LGn}node_info${RES}' and '${C_LGn}wallet_info${RES}' commands (${C_R}unsafe${RES})"
		echo -e "  -mb, --max-buy           buy ROLLs for the whole balance when using '${C_LGn}buy_rolls${RES}' command"
		echo -e "  -ro, --raw-output        the raw output in '${C_LGn}node_info${RES}', '${C_LGn}wallet_info${RES}' and ${C_LGn}other${RES} actions"
		echo
		echo -e "You can use ${C_LGn}either${RES} \"=\" or \" \" as an option and value delimiter"
		echo
		echo -e "${C_LGn}Arguments${RES} - any arguments separated by spaces for actions not specified in the script"
		echo
		echo -e "${C_LGn}Modified actions${RES}:"
		echo -e "  ${C_C}client${RES}                         launches the official GUI client"
		echo -e "  ${C_C}node_info${RES}                      shows processed node and wallet info or raw node info"
		echo -e "  ${C_C}wallet_info${RES}                    shows processed/raw wallet info"
		echo -e "  ${C_C}buy_rolls${RES}                      buys a specified number of ROLLs or for the whole balance"
		echo -e "  ${C_C}node_add_staking_private_keys${RES}  registers the private key created first"
		echo -e "  ${C_C}node_testnet_rewards_program_ownership_proof${RES}  after entering the Discord ID it gives you"
		echo -e "                                                 a hash for registering in the Discord bot"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Massa/blob/main/cli_client.sh - script URL"
		echo -e "         (you can send Pull request with new texts to add a language)"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-a*|--action*)
		if ! grep -q "=" <<< $1; then shift; fi
		action=`option_value $1`
		shift
		;;
	-l*|--language*)
		if ! grep -q "=" <<< $1; then shift; fi
		language=`option_value $1`
		shift
		;;
	-pk|--private-keys)
		private_keys="true"
		shift
		;;
	-mb|--max-buy)
		max_buy="true"
		shift
		;;
	-ro|--raw-output)
		raw_output="true"
		shift
		;;
	*|--)
		break
		;;
	esac
done

# Texts
if [ "$language" = "RU" ]; then
	t_ni1="\nID ноды:                ${C_LGn}%s${RES}"
	t_ni2="Версия ноды:            ${C_LGn}%s${RES}\n"
	
	t_ni3="Текущий цикл:           ${C_LGn}%d${RES}"
	#t_ni4="Запланировано слотов:   ${C_LGn}%d${RES}"
	#t_ni5="Запланировано слотов:   ${C_R}0${RES} (попробуйте позже ${C_LGn}ещё раз${RES})"
	
	t_ni6="Порты открыты:          ${C_LGn}да${RES}"
	t_ni7="Порты открыты:          ${C_R}нет${RES}"
	t_ni8="Входящих подключений:   ${C_LGn}%d${RES}"
	t_ni9="Исходящих подключений:  ${C_LGn}%d${RES}\n\n"
	t_ni10="   Кошельки"
	
	
	t_wi1="Адрес кошелька:  ${C_LGn}%s${RES}"
	t_wi2=" (${C_LGn}основной${RES})"
	t_wi3="Приватный ключ:  ${C_LGn}%s${RES} (${C_R}никому не показывать${RES})"
	t_wi4="Публичный ключ:  ${C_LGn}%s${RES}"
	t_wi5="Зарегистрирован\nдля стейкинга:   ${C_LGn}да${RES}"
	t_wi6="Зарегистрирован\nдля стейкинга:   ${C_R}нет${RES}"
	t_wi7="Баланс:          ${C_LGn}%.2f${RES}"
	t_wi8="ROLL'ов всего:   ${C_LGn}%d${RES}"
	t_wi9="Активные ROLL'ы: ${C_LGn}%d${RES}"
	
	
	t_br1="${C_R}Баланс менее 100 токенов${RES}"
	t_br2="Куплено ${C_LGn}%d${RES} ROLL'ов"
	t_br3="Введите количество ROLL'ов (максимально ${C_LGn}%d${RES}): "
	t_br4="${C_R}Недостаточно токенов для покупки${RES}"
	
	
	t_rpk="${C_R}Не удалось зарегистрировать ключ для стейкинга${RES}"
	
	
	t_ctrp1="${C_LGn}Введите Discord ID:${RES} "
	t_ctrp2="\nОтправьте Discord боту следующее:\n${C_LGn}%s${RES}\n"
	
	
	t_done="${C_LGn}Готово!${RES}"
	t_err="${C_R}Нет такого действия!${RES}"
	t_err_nwn="\n${C_R}Нода не работает!${RES}\nПосмотреть лог: ${C_LGn}massa_log${RES}\n"
# Send Pull request with new texts to add a language - https://github.com/SecorD0/Massa/blob/main/cli_client.sh
#elif [ "$language" = ".." ]; then
else
	t_ni1="\nNode ID:                ${C_LGn}%s${RES}"
	t_ni2="Node version:           ${C_LGn}%s${RES}\n"
	
	t_ni3="Currnet cycle:          ${C_LGn}%d${RES}"
	#t_ni4="Draws scheduled:        ${C_LGn}%d${RES}"
	#t_ni5="Draws scheduled:        ${C_R}0${RES} (try ${C_LGn}again later${RES})"
	
	t_ni6="Ports opened:           ${C_LGn}yes${RES}"
	t_ni7="Ports opened:           ${C_R}no${RES}"
	t_ni8="Incoming connections:   ${C_LGn}%d${RES}"
	t_ni9="Outcoming connections:  ${C_LGn}%d${RES}\n\n"
	t_ni10="   Wallets"
	
	
	t_wi1="Wallet address:  ${C_LGn}%s${RES}"
	t_wi2=" (${C_LGn}the main${RES})"
	t_wi3="Private key:     ${C_LGn}%s${RES} (${C_R}don't show it to anyone${RES})"
	t_wi4="Public key:      ${C_LGn}%s${RES}"
	t_wi5="Registered\nfor staking:     ${C_LGn}yes${RES}"
	t_wi6="Registered\nfor staking:     ${C_R}no${RES}"
	t_wi7="Balance:         ${C_LGn}%.2f${RES}"
	t_wi8="Total ROLLs:     ${C_LGn}%d${RES}"
	t_wi9="Active ROLLs:    ${C_LGn}%d${RES}"
	
	
	t_br1="${C_R}Balance is less than 100 tokens${RES}"
	t_br2="${C_LGn}%d${RES} ROLLs were bought"
	t_br3="Enter a ROLL count (max ${C_LGn}%d${RES}): "
	t_br4="${C_R}Not enough tokens for buying${RES}"
	
	
	t_rpk="${C_R}Failed to register a key for staking!${RES}"
	
	
	t_ctrp1="${C_LGn}Enter a Discord ID:${RES} "
	t_ctrp2="\nSend the following to Discord bot:\n${C_LGn}%s${RES}\n"
	
	
	t_done="${C_LGn}Done!${RES}"
	t_err="${C_R}There is no such action!${RES}"
	t_err_nwn="\n${C_R}Node isn't working!${RES}\nView the log: ${C_LGn}massa_log${RES}\n"
fi

# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
client() { ./massa-client; }
node_info() {
	local wallet_info=`./massa-client -j wallet_info`
	local main_address=`jq -r "[.[]] | .[0].address_info.address" <<< "$wallet_info"`
	local node_info=`./massa-client -j get_status | jq`
	if [ "$raw_output" = "true" ]; then
		printf_n "$node_info"
	else
		local node_id=`jq -r ".node_id" <<< "$node_info"`
		printf_n "$t_ni1" "$node_id"
		local node_version=`jq -r ".version" <<< "$node_info"`
		printf_n "$t_ni2" "$node_version"
		
		local current_cycle=`jq -r ".current_cycle" <<< "$node_info"`
		printf_n "$t_ni3" "$current_cycle"
		#local draws_count=`./massa-client -j get_addresses "$main_address" | jq -r ".[0].block_draws | length" 2>/dev/null`
		#if [ -n "$draws_count" ] && [ "$draws_count" -gt 0 ]; then
		#	printf_n "$t_ni4" "$draws_count"
		#else
		#	printf_n "$t_ni5"
		#fi
		printf_n
		local opened_ports=`ss -tulpn | grep :3303`
		if [ -n "$opened_ports" ]; then
			printf_n "$t_ni6"
		else
			printf_n "$t_ni7"
		fi
		local incoming_connections=`jq -r ".network_stats.in_connection_count" <<< "$node_info"`
		printf_n "$t_ni8" "$incoming_connections"
		local outcoming_connections=`jq -r ".network_stats.out_connection_count" <<< "$node_info"`
		printf_n "$t_ni9" "$outcoming_connections"
		printf_n "$t_ni10"
		wallet_info
	fi
}
wallet_info() {
	local wallet_info=`./massa-client -j wallet_info`
	local main_address=`jq -r "[.[]] | .[0].address_info.address" <<< "$wallet_info"`
	if [ "$raw_output" = "true" ]; then
		printf_n "`jq -r "[.[]]" <<< "$wallet_info"`"
	else
		local staking_addresses=`./massa-client -j node_get_staking_addresses`
		local wallets=`jq -r "to_entries[]" <<< "$wallet_info" | tr -d '[:space:]' | sed 's%}{%} {%g'`
		printf_n
		for wallet in $wallets; do
			local address=`jq -r ".key" <<< "$wallet"`
			printf "$t_wi1" "$address"
			if [ "$address" = "$main_address" ]; then
				printf_n "$t_wi2"
			else
				printf_n
			fi
			if [ "$private_keys" = "true" ]; then
				local private_key=`jq -r ".value.private_key" <<< "$wallet"`
				printf_n "$t_wi3" "$private_key"
			fi
			local public_key=`jq -r ".value.public_key" <<< "$wallet"`
			printf_n "$t_wi4" "$public_key"
			if grep -q "$address" <<< "$staking_addresses"; then
				printf_n "$t_wi5"
			else
				printf_n "$t_wi6"
			fi
			local balance=`jq -r ".value.address_info.balance.candidate_ledger_info.balance" <<< "$wallet"`
			printf_n "$t_wi7" "$balance"
			local total_rolls=`jq -r ".value.address_info.rolls.candidate_rolls" <<< "$wallet"`
			printf_n "$t_wi8" "$total_rolls"
			local active_rolls=`jq -r ".value.address_info.rolls.active_rolls" <<< "$wallet"`
			printf_n "$t_wi9" "$active_rolls"
			printf_n
		done
	fi
}
buy_rolls() {
	local wallet_info=`./massa-client -j wallet_info`
	local main_address=`jq -r "[.[]] | .[0].address_info.address" <<< "$wallet_info"`
	local balance=`jq -r "[.[]] | .[-1].address_info.balance.candidate_ledger_info.balance" <<< "$wallet_info"`
	local roll_count=`printf "%d" $(bc -l <<< "$balance/100") 2>/dev/null`
	if [ "$roll_count" -eq "0" ]; then
		printf_n "$t_br1"
	elif [ "$max_buy" = "true" ]; then
		local resp=`./massa-client buy_rolls "$main_address" "$roll_count" 0`
		if grep -q 'insuffisant balance' <<< "$resp"; then
			printf_n "$t_br4"
			return 1 2>/dev/null; exit 1
		else
			printf_n "$t_br2" "$roll_count"
		fi
	else
		printf "$t_br3" "$roll_count"
		local rolls_for_buy
		read -r rolls_for_buy
		if [ "$rolls_for_buy" -gt "$roll_count" ]; then
			local resp=`./massa-client buy_rolls "$main_address" "$roll_count" 0`
		else
			local resp=`./massa-client buy_rolls "$main_address" "$rolls_for_buy" 0`
		fi
		if grep -q 'insuffisant balance' <<< "$resp"; then
			printf_n "$t_br4"
			return 1 2>/dev/null; exit 1
		else
			printf_n "$t_done"
		fi
	fi
}
node_add_staking_private_keys() {
	local wallet_info=`./massa-client -j wallet_info`
	local private_key=`jq -r "[.[]] | .[0].private_key" <<< "$wallet_info"`
	local resp=`./massa-client node_add_staking_private_keys "$private_key"`
	if grep -q "error" <<< "$resp"; then
		printf_n "$t_rpk"
	else
		printf_n "$t_done"
	fi
}
node_testnet_rewards_program_ownership_proof() {
	local wallet_info=`./massa-client -j wallet_info`
	local main_address=`jq -r "[.[]] | .[0].address_info.address" <<< "$wallet_info"`
	local discord_id
	printf "$t_ctrp1"
	read -r discord_id
	local resp=`./massa-client -j node_testnet_rewards_program_ownership_proof "$main_address" "$discord_id" | jq -r`
	printf_n "$t_ctrp2" "$resp"
}
other() {
	if [ "$raw_output" = "true" ]; then
		local resp=`./massa-client -j "$action" "$@" 2>&1`
	else
		local resp=`./massa-client "$action" "$@" 2>&1`
	fi
	if grep -q 'error: Found argument' <<< "$resp"; then
		printf_n "$t_err"
		return 1 2>/dev/null; exit 1
	else
		printf_n "$resp"
	fi
}

# Actions
sudo apt install jq bc -y &>/dev/null
cd $HOME/massa/massa-client/
if grep -q "check if your node is running" <<< `./massa-client get_status`; then
	printf_n "$t_err_nwn"
else
	if grep -q "$action" <<< "client node_info wallet_info buy_rolls node_add_staking_private_keys node_testnet_rewards_program_ownership_proof"; then $action; else other "$@"; fi
fi
cd
