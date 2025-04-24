/system script add name=/config.rsc source=":\
    do {\r\
    \n    :do {/system script remove \"/infostat\"} on-error={}\r\
    \n    :do {/system script add name=/infostat source=\":\\\r\
    \n    log info \\\"/infostat start\\\"\\r\\\r\
    \n    \\n:local routername [system identity get name]\\r\\\r\
    \n    \\n:local routerversion [system resource get version]\\r\\\r\
    \n    \\n:local routermodel [system resource get board-name]\\r\\\r\
    \n    \\n:local address [/ip address get [find interface=\\\"bridge\\\"] a\
    ddress ];\\r\\\r\
    \n    \\n# set uptime\\r\\\r\
    \n    \\n:local uptime [system resource get uptime]\\r\\\r\
    \n    \\n# version settings\\r\\\r\
    \n    \\n:local version \\\"v.0042\\\"\\r\\\r\
    \n    \\n# set url to telegramm bot\\r\\\r\
    \n    \\n:local sendtotele \\\"https://api.telegram.org/bot5471169056:AAFK\
    YaMBuSIWE\\\r\
    \n    7o_CW5kqEb49inGEUfGz6k/sendmessage\\\\\\\?chat_id=-1001672697090&tex\
    t=\\\"\\r\\\r\
    \n    \\n# message to telegramm bot\\r\\\r\
    \n    \\n/tool fetch url=\\\"\\\$sendtotele \\\$routername %0A \\\$routerm\
    odel %0A versio\\\r\
    \n    n: \\\$routerversion %0A skript: \\\$version %0A ip: \\\$address %0A\
    \_uptime: \\\$u\\\r\
    \n    ptime\\\" keep-result=no\"} on-error={}\r\
    \n    :do {\r\
    \n        :local identity [system identity get name]\r\
    \n        :local namedef [:pick \$identity ([:find \$identity \"-\"] - 0) \
    11]\r\
    \n        :if (\$namedef = \"-gate\") do={\r\
    \n            :do {\r\
    \n                :local address [/ip address get [find interface=\"bridge\
    \"] address]\r\
    \n                :local ip [:pick \$address ([:find \$address \"168\"] + \
    4) 11]\r\
    \n                :log info \"IP address: \$ip\"\r\
    \n                /queue simple add name=\"wi-fi\" target=\"192.168.\$ip.1\
    28/25\" dst=ether2 max-limit=7M/7M queue=pcq-upload-default/pcq-download-d\
    efault\r\
    \n            } on-error={:log error \"Failed to set IP pool range\"}\r\
    \n        } else={\r\
    \n            :log info \"Condition not met: namedef is not -gate\"\r\
    \n        }\r\
    \n    } on-error={:log error \"Script execution failed\"}\r\
    \n}"
