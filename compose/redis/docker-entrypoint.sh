#!/bin/sh
set -e

## from redis-5.0
# Redis서버에 접근가능한 Host를 설정합니다.
sed -i "s/bind 127.0.0.1/bind $CLIENTHOST 127.0.0.1/g" /usr/local/bin/redis.conf

### redis port inside redis.conf
#redis.conf 파일의 port 6379 문자열을 port $CLINETPORT로 변경합니다.
#($CLIENTPORT는 docker-compose.yml파일의 Environment에서 지정하였습니다.)
sed -i "s/port 6379/port $CLIENTPORT/g" /usr/local/bin/redis.conf

# requirepass foobared 문자열을 requirepass $REQUIREPASS로 변경하였습니다.
#(Redis 접속 시 비밀번호를 설정하였습니다.)
sed -i "s/# requirepass foobared/requirepass $REQUIREPASS/g" /usr/local/bin/redis.conf
sed -i "s/# masterauth <master-password>/masterauth $REQUIREPASS/g" /usr/local/bin/redis.conf

### slaveof <masterip> <masterport> => slaveof $MASTERHOST $MASTERPORT
# $MASTERPORT가 공백이 아닌 Container에 대해 slaveof 설정을 통해 Master-Slave 설정을 합니다.
if [ "$MASTERPORT" != "" ];then
    sed -i "s/# slaveof <masterip> <masterport>/slaveof $MASTERHOST $MASTERPORT/g" /usr/local/bin/redis.conf
fi

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
    set -- redis-server "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'redis-server' -a "$(id -u)" = '0' ]; then
    chown -R redis .
    exec su-exec redis "$@"
fi

exec "$@"