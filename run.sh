#!/bin/bash
## =================================================================== ##
#  Mysqlのデータベースをクローン
#
#  [使い方]
#     mysql-db-clone.sh [database name from] [database name to]
## =================================================================== ##

function main() {(
    [ ${#} -ne 2 ] && _help && exit 1

    _DB_FROM="${1}"
    _DB_TO="${2}"

    if ! _check_database ${_DB_FROM};then
        echo "Error: ${_DB_FROM} does not exist." && return 1
    fi

    _drop_database ${_DB_TO}

    _create_database ${_DB_TO}


    _TABLES=($(_show_tables ${_DB_FROM}))

    for _TABLE in ${_TABLES[*]};do
        _create_table ${_DB_FROM} ${_DB_TO} ${_TABLE}
        _select_insert ${_DB_FROM} ${_DB_TO} ${_TABLE}
    done

    return 0
)}

function _help() {(
    echo "Usage: ./mysql-db-clone.sh [database name from] [database name to]"
)}

function _check_database() {(
    _SQL="SHOW DATABASES LIKE '${1}'"

    [ $(_mysql "${_SQL}" | wc -l) -eq 1 ] && return 0 || return 1
)}

function _create_database() {(
    _SQL="CREATE DATABASE IF NOT EXISTS ${1}"

    _mysql "${_SQL}"
)}

function _create_table() {(
    _SQL="CREATE TABLE ${2}.${3} LIKE ${1}.${3};"

    _mysql "${_SQL}"
)}

function _drop_database() {(
     _SQL="DROP DATABASE IF EXISTS ${1}"

     _mysql "${_SQL}"
)}

function _show_tables() {(
    _SQL="SHOW TABLES"
    _mysql "${_SQL}" ${1}
)}

function _select_insert() {(
    _SQL="INSERT INTO ${2}.${3} SELECT * FROM ${1}.${3}"

    _mysql "${_SQL}"
)}

function _mysql() {(
    # MAMPのmysqlになっているので適宜変更してください。
    /Applications/MAMP/Library/bin/mysql -uroot -proot ${2} -N -e "${1}" || exit 1
)}

main ${*}

exit $?
