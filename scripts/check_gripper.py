#!/usr/bin/env python3
"""Ping a Dynamixel gripper servo to confirm it is powered on and responding."""
import sys

from dynamixel_sdk import PacketHandler, PortHandler

PROTOCOL_VERSION = 2.0
BAUD_RATE = 2000000
DXL_ID = 1


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <port>", file=sys.stderr)
        return 1

    port_name = sys.argv[1]
    port_handler = PortHandler(port_name)
    packet_handler = PacketHandler(PROTOCOL_VERSION)

    if not port_handler.openPort():
        print(f"Could not open port {port_name}", file=sys.stderr)
        return 1

    if not port_handler.setBaudRate(BAUD_RATE):
        print(f"Could not set baud rate {BAUD_RATE} on {port_name}", file=sys.stderr)
        port_handler.closePort()
        return 1

    _, comm_result, _ = packet_handler.ping(port_handler, DXL_ID)
    port_handler.closePort()

    if comm_result != 0:
        print(f"No response from Dynamixel ID {DXL_ID} on {port_name}: "
              f"{packet_handler.getTxRxResult(comm_result)}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
