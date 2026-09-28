#!/usr/bin/env python3
"""Exercise the TI60 CVBS menu and status OSD through X2000 /dev/ttyS1."""
import argparse
import pathlib
import subprocess
import tempfile

HEADER, FOOTER, CATEGORY = 0xBB, 0xAA, 0x04
TYPE_WRITE, TYPE_ACK = 0x00, 0x02
KEYS = {"up": 0, "down": 1, "enter": 2, "back": 3}
PAGES = {
    "root": 0x0000,
    "image": 0x0100, "image-pip": 0x0101, "image-correction": 0x0102,
    "palette": 0x0200, "zoom": 0x0300,
    "functions": 0x0400, "functions-wifi": 0x0401, "functions-moment": 0x0402,
    "settings": 0x0500, "settings-language": 0x0501,
    "settings-time": 0x0502, "settings-buttons": 0x0503,
    "settings-auto-off": 0x0504, "settings-pixels": 0x0505,
    "measurement": 0x0600, "measurement-color": 0x0601,
    "zeroing": 0x0700, "zeroing-adjust": 0x0701, "zeroing-group": 0x0702,
    "zeroing-style": 0x0703, "zeroing-color": 0x0704,
    "ballistics": 0x0800, "ballistics-color": 0x0801,
    "display": 0x0900, "display-move": 0x0901,
}

def crc16(data):
    crc=0
    for value in data:
        crc ^= value << 8
        for _ in range(8):
            crc=((crc<<1)^0x1021)&0xffff if crc&0x8000 else (crc<<1)&0xffff
    return crc

def packet(sub,payload=b""):
    body=bytes((CATEGORY,sub,TYPE_WRITE))+payload
    return bytes((HEADER,))+len(body).to_bytes(2,"big")+body+crc16(body).to_bytes(2,"big")+bytes((FOOTER,))

def signed16(value):
    if not -32768 <= value <= 32767: raise ValueError("俯仰角/横滚角必须在-32768..32767")
    return (value & 0xffff).to_bytes(2,"big")

def exchange(args,data,response_bytes=10):
    with tempfile.TemporaryDirectory() as directory:
        tx=pathlib.Path(directory)/"ui_command.bin"; rx=pathlib.Path(directory)/"ui_ack.bin"
        tx.write_bytes(data)
        subprocess.run([args.adb,"push",str(tx),"/tmp/fpga_ui_command.bin"],check=True)
        shell=("stty -F {0} 115200 cs8 -cstopb -parenb -crtscts raw -echo; "
               "rm -f /tmp/fpga_ui_ack.bin; (timeout {1} dd if={0} bs=1 count={2} "
               "of=/tmp/fpga_ui_ack.bin 2>/dev/null) & reader=$!; sleep 0.1; "
               "cat /tmp/fpga_ui_command.bin > {0}; wait $reader").format(
                   args.device,max(1,int(args.timeout)),response_bytes)
        subprocess.run([args.adb,"shell",shell],check=True)
        subprocess.run([args.adb,"pull","/tmp/fpga_ui_ack.bin",str(rx)],check=True)
        return rx.read_bytes()

def main():
    p=argparse.ArgumentParser(description="测试TI60 CVBS菜单和状态UI")
    g=p.add_mutually_exclusive_group(required=True)
    g.add_argument("--show",action="store_true"); g.add_argument("--hide",action="store_true")
    g.add_argument("--key",choices=KEYS); g.add_argument("--status",action="store_true")
    g.add_argument("--marker",nargs=2,type=int,metavar=("X","Y"),
                   help="移动测距标记")
    g.add_argument("--clear",action="store_true")
    g.add_argument("--view",choices=sorted(PAGES),help="直接切换到指定菜单页")
    g.add_argument("--image-values",nargs=4,type=int,
                   metavar=("ENHANCE","CONTRAST","IMAGE_BRIGHTNESS","SCREEN_BRIGHTNESS"))
    g.add_argument("--query-view",action="store_true",help="查询当前菜单状态")
    p.add_argument("--selected",type=int,default=0,help="SET_VIEW的绝对子项序号")
    p.add_argument("--edit",action="store_true",help="SET_VIEW后直接进入数值编辑")
    p.add_argument("--hidden",action="store_true",help="SET_VIEW时保持UI隐藏")
    p.add_argument("--azimuth",type=int,default=0); p.add_argument("--lrf",type=int,default=0)
    p.add_argument("--pitch",type=int,default=0); p.add_argument("--roll",type=int,default=0)
    p.add_argument("--valid-flags",type=lambda x:int(x,0),default=0x0f,
                   help="bit0方位角 bit1 LRF bit2俯仰 bit3横滚")
    p.add_argument("--adb",default="adb"); p.add_argument("--device",default="/dev/ttyS1")
    p.add_argument("--timeout",type=float,default=5.0); a=p.parse_args()
    if a.show: sub,payload=1,b"\x01"
    elif a.hide: sub,payload=1,b"\x00"
    elif a.key is not None: sub,payload=2,bytes((KEYS[a.key],))
    elif a.marker is not None:
        x,y=a.marker
        if not 11<=x<=708 or not 11<=y<=564: p.error("marker坐标超出范围")
        sub,payload=5,x.to_bytes(2,"big")+y.to_bytes(2,"big")
    elif a.clear: sub,payload=4,b""
    elif a.view is not None:
        if not 0<=a.selected<=255: p.error("selected必须在0..255")
        flags=(0 if a.hidden else 1)|(2 if a.edit else 0)
        sub=6; payload=PAGES[a.view].to_bytes(2,"big")+bytes((a.selected,flags))
    elif a.image_values is not None:
        if not (0<=a.image_values[0]<=5 and all(0<=x<=10 for x in a.image_values[1:])):
            p.error("图像增强范围0..5，其余三项范围0..10")
        sub=7; payload=bytes(a.image_values)
    elif a.query_view:
        sub,payload=8,b""
    else:
        if not 0<=a.azimuth<=65535 or not 0<=a.lrf<=65535: p.error("方位角/LRF必须在0..65535")
        if not 0<=a.valid_flags<=15: p.error("valid-flags必须在0..15")
        sub=3; payload=bytes((a.valid_flags,))+a.azimuth.to_bytes(2,"big")+a.lrf.to_bytes(2,"big")+signed16(a.pitch)+signed16(a.roll)
    tx=packet(sub,payload); rx=exchange(a,tx,18 if sub==8 else 10)
    body_length=int.from_bytes(rx[1:3],"big") if len(rx)>=3 else 0
    body=rx[3:3+body_length]
    received_crc=int.from_bytes(rx[3+body_length:5+body_length],"big") if len(rx)>=body_length+5 else -1
    expected_body_length=12 if sub==8 else 4
    if (len(rx)!=body_length+6 or body_length!=expected_body_length or rx[0]!=HEADER or
        rx[-1]!=FOOTER or crc16(body)!=received_crc or
        body[:3]!=bytes((CATEGORY,sub,TYPE_ACK)) or body[3]!=0xff):
        raise RuntimeError("UI命令失败："+rx.hex( ))
    print("UI命令成功")
    if sub==8:
        page_id=int.from_bytes(body[4:6],"big")
        print("页面=0x{0:04X} 选中项={1} 显示={2} 编辑={3} 数值={4}".format(
            page_id,body[6],bool(body[7]&1),bool(body[7]&2),list(body[8:12])))
    print("发送：",tx.hex( )); print("返回：",rx.hex( ))

if __name__=="__main__": raise SystemExit(main())
