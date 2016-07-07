
REM start CouchDB service
net.exe start "Apache CouchDB"

set TARGET=http://adminuser:password@localhost:5984

REM Add admin user
REM curl -k -X PUT http://localhost:5984/_config/admins/adminuser -d "\"password\""

REM curl -k -H "Content-Type:application/json" -vX PUT %TARGET%/_users/org.couchdb.user:adminuser -d "{\"_id\": \"org.couchdb.user:adminuser\",\"name\": \"adminuser\",\"roles\": [\"reader\",\"writer\",\"admin\"],\"type\": \"user\",\"password\": \"password\"}" 

REM Configure JSONP
curl -k -H "Content-Type: application/json" -vX PUT %TARGET%/_config/httpd/allow_jsonp -d \"true\"

REM Set require valid user
curl -k -H "Content-Type: application/json" -vX PUT %TARGET%/_config/httpd/require_valid_user -d \"true\"

REM Add databases
curl -k -vX PUT %TARGET%/events
curl -k -vX PUT %TARGET%/mil_cqb
curl -k -vX PUT %TARGET%/mil_logistics
curl -k -vX PUT %TARGET%/mil_opcom
curl -k -vX PUT %TARGET%/sys_data
curl -k -vX PUT %TARGET%/sys_logistics
curl -k -vX PUT %TARGET%/sys_aar
curl -k -vX PUT %TARGET%/sys_marker
curl -k -vX PUT %TARGET%/sys_patrolrep
curl -k -vX PUT %TARGET%/sys_perf
curl -k -vX PUT %TARGET%/sys_player
curl -k -vX PUT %TARGET%/sys_profile
curl -k -vX PUT %TARGET%/sys_sitrep
curl -k -vX PUT %TARGET%/sys_spotrep
curl -k -vX PUT %TARGET%/sys_tasks