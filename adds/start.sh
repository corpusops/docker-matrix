#!/usr/bin/env bash
OPTION="${1}"

if [ ! -z "${ROOTPATH}" ]; then
    echo ":: We have changed the semantic and doesn't need the ROOTPATH"
    echo ":: variable anymore"
fi

generate_synapse_file() {
    local filepath="${1}"
   $MATRIX_PYTHON -m synapse.app.homeserver \
           --config-path "${filepath}" \
           --generate-config \
           --report-stats ${REPORT_STATS} \
           --server-name ${SERVER_NAME}
}

configure_homeserver_yaml() {
    local filepath="${1}"
    local ymltemp="$(mktemp)"

    awk -v PIDFILE="pid_file: /data/homeserver.pid" \
        -v DATABASE="database: \"/data/homeserver.db\"" \
        -v LOGFILE="log_file: \"/data/homeserver.log\"" \
        -v MEDIASTORE="media_store_path: \"/data/media_store\"" \
        '{
        sub(/pid_file: \/homeserver.pid/, PIDFILE);
        sub(/database: "\/homeserver.db"/, DATABASE);
        sub(/log_file: "\/homeserver.log"/, LOGFILE);
        sub(/media_store_path: "\/media_store"/, MEDIASTORE);
        print;
        }' "${filepath}" > "${ymltemp}"

    mv ${ymltemp} "${filepath}"
}

# ${SERVER_NAME}.log.config is autogenerated via --generate-config
configure_log_config() {
    sed -i "s|.*filename:\s/homeserver.log|    filename: /data/homeserver.log|g" "/data/${SERVER_NAME}.log.config"
}

case $OPTION in
    "start")
        echo "-=> start matrix"
        groupadd -r -g $MATRIX_GID matrix
        useradd -r -d /data -M -u $MATRIX_UID -g matrix matrix
        chown -R $MATRIX_UID:$MATRIX_GID /data
        chown -R $MATRIX_UID:$MATRIX_GID /uploads
        chmod a+rwx /run
        exec supervisord -c /supervisord.conf
        ;;

    "stop")
        echo "-=> stop matrix"
        echo "-=> via docker stop ..."
        ;;

    "version")
        echo "-=> Matrix Version"
        cat /synapse.version
        ;;

    "diff")
        echo "-=> Diff between local configfile and a fresh generated config file"
        echo "-=>      some values are different in technical point of view, like"
        echo "-=>      autogenerated secret keys etc..."

        DIFFPARAMS="${DIFFPARAMS:-Naur}"
        SERVER_NAME="${SERVER_NAME:-demo_server_name}"
        REPORT_STATS="${REPORT_STATS:-no_or_yes}"
        export SERVER_NAME REPORT_STATS

        generate_synapse_file /tmp/homeserver.synapse.yaml
        diff -${DIFFPARAMS} /tmp/homeserver.synapse.yaml /data/homeserver.yaml
        ;;

    "generate")
        breakup="0"
        [[ -z "${SERVER_NAME}" ]] && echo "STOP! environment variable SERVER_NAME must be set" && breakup="1"
        [[ -z "${REPORT_STATS}" ]] && echo "STOP! environment variable REPORT_STATS must be set to 'no' or 'yes'" && breakup="1"
        [[ "${REPORT_STATS}" != "yes" ]] && [[ "${REPORT_STATS}" != "no" ]] && \
            echo "STOP! REPORT_STATS needs to be 'no' or 'yes'" && breakup="1"

        [[ "${breakup}" == "1" ]] && exit 1

        echo "-=> generate synapse config"
        generate_synapse_file /data/homeserver.tmp
        echo "-=> configure some settings in homeserver.yaml"
        configure_homeserver_yaml /data/homeserver.tmp

        mv /data/homeserver.tmp /data/homeserver.yaml

        echo "-=> configure some settings in ${SERVER_NAME}.log.config"
        configure_log_config

        echo ""
        echo "-=> you have to review the generated configuration file homeserver.yaml"
        ;;

    *)
        echo "-=> unknown \'$OPTION\'"
        ;;
esac

