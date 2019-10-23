led=0
tcp_ms = 1000
check_ms = 2000
srv = nil
gpio.mode(led,gpio.OUTPUT)
gpio.write(led,gpio.LOW)

wifi.setmode(wifi.STATIONAP) 
station_cfg = {}
station_cfg.ssid="esp8266"
station_cfg.pwd="12345678"
wifi.sta.config(station_cfg)
--wifi.sta.connect()

tcp_timer = tmr.create()
connect_timer = tmr.create()

function receiver(sck, data)
	print("data:"..data)
    if(data == "open")
    then
        gpio.write(led,gpio.LOW)
    else
        gpio.write(led,gpio.HIGH)
    end
end

function connector(sck,data)
    connect_timer:stop()
    srv:send("devno0")
    print("connector")
end

function disconnector(sck,data)
    connect_timer:start()
    print("disconnector")
end

function create_tcp_client()
	srv = net.createConnection(net.TCP, 0)
    --srv:connect(8080, "192.168.43.240")
    srv:connect(8080, "10.20.155.94")
	srv:on("receive", receiver)
    srv:on("connection", connector) 
    srv:on("disconnection", disconnector)
end


function connect()
    ipaddr,netmask,gateway = wifi.sta.getip()
    if(ipaddr == nil) then
        print("connecting...")
    else
        tcp_timer:stop()
        print("ipaddr :"..ipaddr)
        print("netmask:"..netmask)
        print("gateway:"..gateway)
		create_tcp_client()
    end
end

tcp_timer:alarm(tcp_ms,tmr.ALARM_AUTO,connect) 
connect_timer:alarm(tcp_ms,tmr.ALARM_SEMI,create_tcp_client) 


 


