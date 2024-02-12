sudo mkdir -p /usr/src/depin/thingsix/forwarder
sudo sh -c "echo '' > /usr/src/depin/thingsix/gateways.yaml"

#ThingsIX forwarder
#client of multiplexer. listen on 1685.
#https://github.com/ThingsIXFoundation/packet-handling/blob/main/cmd/forwarder/example-config.yaml
sudo sh -c "echo '
forwarder:
    backend:
        semtech_udp:
            udp_bind: 127.0.0.1:1685
    gateways:
        api:
            address: 127.0.0.1:8880

metrics:
    prometheus:
        address: 127.0.0.1:8885

' > /usr/src/depin/thingsix/forwarder_config.yaml"

sudo docker run -d --restart unless-stopped  \
        --name thingsix \
        --network host \
        -v /usr/src/depin/thingsix/forwarder:/etc/thingsix-forwarder \
        -v /usr/src/depin/thingsix/forwarder_config.yaml:/etc/thingsix-forwarder/forwarder_config.yaml \
        -v /usr/src/depin/thingsix/gateways.yaml:/etc/thingsix-forwarder/gateways.yaml \
        --label=com.centurylinklabs.watchtower.enable=true \
        ghcr.io/thingsixfoundation/packet-handling/forwarder:latest \
        --config /etc/thingsix-forwarder/forwarder_config.yaml

echo "On the crankk local dashboard, open Info > Setup Gateway."
echo "In the 'Forwards to' field, append: ,127.0.0.1:1685"
echo "This field should look like this:"
echo "127.0.0.1:1700,127.0.0.1:1680,127.0.0.1:1685"
