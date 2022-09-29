import fcntl
import struct
from socket import socket, AF_PACKET, SOCK_RAW, AF_INET, SOCK_DGRAM
import binascii
import argparse





def getHwAddr(ifname):
  s = socket(AF_INET, SOCK_DGRAM)
  info = fcntl.ioctl(s.fileno(), 0x8927, struct.pack('256s', bytes(ifname, 'utf-8')[:15]))
  return ':'.join('%02x' % b for b in info[18:24])

def pack(byte_sequence):
  """Convert list of bytes to byte string."""
  return b"".join(map(chr, byte_sequence))

def send_ether(src, dst, type, payload, interface="eth0"):
  # 48-bit Ethernet addresses
  assert(len(src) == len(dst) == 6)

  # 16-bit Ethernet type
  assert(len(type) == 2) # 16-bit Ethernet type

  s = socket(AF_PACKET, SOCK_RAW)
  s.bind((interface, 0))
  return s.send(dst + src + type + payload)




parser = argparse.ArgumentParser()
parser.add_argument("--iface", type=str, required=True,
                    help="Network Interface (e.g. eth9 for SFP Wan")
parser.add_argument("--session_id", type=int, required=True,
                    help="PPP Session ID")
parser.add_argument("--remote_mac", type=str, required=True,
                    help="PPP Remote MAC addr")
parser.add_argument("-v", "--verbose", action="store_true",
                    help="increase output verbosity")

args = parser.parse_args()
source_mac = getHwAddr(args.iface)



ethernet_packet = []
ethernet_payload = []

src_macbytes = binascii.unhexlify(source_mac.replace(':', ''))
dst_macbytes = binascii.unhexlify(args.remote_mac.replace(':', ''))
frame_type = [0x88, 0x63]
pppoe_type = 0x11
pppoe_padt = 0xa7
session_id = args.session_id.to_bytes(2, byteorder='big')
length = [0x00, 0x01]
payload = 0x00

ethernet_packet.extend(src_macbytes)
ethernet_packet.extend(dst_macbytes)
ethernet_packet.extend(frame_type)
ethernet_payload.append(pppoe_type)
ethernet_payload.append(pppoe_padt)
ethernet_payload.extend(session_id)
ethernet_payload.extend(length)
ethernet_payload.append(payload)


r = send_ether(bytes(src_macbytes), bytes(dst_macbytes), bytes(frame_type), bytes(ethernet_payload), interface=args.iface)
print("Sent Ethernet bytes " + str(r))

