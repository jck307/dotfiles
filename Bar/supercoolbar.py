from time import sleep
from datetime import datetime
from subprocess import check_output, CalledProcessError
from traceback import format_exception
import json
import re
import os

LOG_FILE = os.path.expanduser("~/Bar/log")
DEBUG = False
TIMEOUT = 1

def handle_exc(exc):
    if DEBUG:
        try:
            with open(LOG_FILE, "a") as file:
                file.write("".join(format_exception(exc)) + "\n")
        except:
            pass

weeks = ("Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag", "Söndag")
months = ("Januari", "Februari", "Mars", "April", "Maj", "Juni", "Juli", "Augusti", "September", "Oktober", "November", "December")

sep = "   "

os.system("source ~/colors.env")
white  = os.environ["WHITE"]
red    = os.environ["RED"]
# orange = os.environ["ORANGE"]
orange = "#fe8019"
yellow = os.environ["YELLOW"]
green  = os.environ["GREEN"]

# print('{"version": 1}\n[', end="")

with open(LOG_FILE, "w") as file:
    file.truncate()

if 1:
    widgets = []

    # TIME
    now = datetime.now()
    weekday = weeks[now.weekday()]
    day = now.day
    time = f"{now.hour:02d}:{now.minute:02d}"
    month = months[now.month-1]
    widgets.append(f"{weekday} {day} {month} {time}")

    # NETWORK
    network_name = None
    try:
        output = check_output(("iwgetid", "-r"), timeout=TIMEOUT).replace("\n".encode(), "".encode()).decode("utf-8")
        if not output.isspace():
            network_name = output
    except Exception as e:
        handle_exc(e)
    if not network_name:
        try:
            output = check_output(("nmcli", "-c", "yes", "connection", "show"), timeout=TIMEOUT)
            if b"\033[32m" in output:
                network_name = "Ansluten"
            else:
                network_name = "Oansluten"
        except Exception as e:
            handle_exc(e)
    if not network_name:
        network_name = "?"
    widgets.append(f"Nät: {network_name}")

    # BATTERY
    try:
        battery = check_output(("cat", "/sys/class/power_supply/BAT0/capacity"), timeout=TIMEOUT).decode().strip()
        charging = "+" if check_output(("cat", "/sys/class/power_supply/BAT0/status"), timeout=TIMEOUT).decode().strip() != \
            "Discharging" else "-"
        widgets.append((
            f"Bat: {battery}% ",
            red if int(battery) < 30 and charging == "-" else white,
            None
        ))
        widgets.append((charging, green if charging == "+" else red))
    except Exception as e:
        handle_exc(e)

    # TEMP
    try:
        sensors = check_output("sensors", timeout=TIMEOUT).decode("ascii", errors="ignore")
        try:
            temp = re.search(r"temp1:(.*)", sensors).group(1).strip()[1:-1]
            temp = int(float(temp))
        except:
            temp = re.search(r"Tctl:(.*)", sensors).group(1).strip()[1:-1]
            temp = int(float(temp))
        widgets.append((f"Temp: {temp}°C",
            red    if temp >= 85 else \
            orange if temp >= 70 else \
            yellow if temp >= 55 else green
        ))
    except Exception as e:
        handle_exc(e)

    # BRIGHTNESS
    try:
        brightness = check_output("light", timeout=TIMEOUT).decode().strip()
        brightness = brightness[:brightness.index(".")]
        widgets.append(f"Ljus: {brightness}%")
    except Exception as e:
        handle_exc(e)

    # VOLUME
    try:
        volume = check_output(("pactl", "get-sink-volume", "@DEFAULT_SINK@"), timeout=TIMEOUT).decode()
        volume = re.search(r"\d*%", volume).group(0)
        # volume = volume[volume.index("%")-2:volume.index("%")].lstrip()
        widgets.append((f"Vol: {volume}", white))
    except Exception as e:
        handle_exc(e)

    # BLUETOOTH
    try:
        bluetooth = check_output(("bluetoothctl", "info"), timeout=TIMEOUT).decode()
        bluetooth = re.search(r"Name: (.*)", bluetooth).group(1)
    except Exception as e:
        handle_exc(e)
        bluetooth = "Oansluten"
    widgets.append(f"Bt: {bluetooth}")

    out = []

    for w in widgets:
        if type(w) is not tuple:
            w = (w, white)

        out.append({
            "full_text": w[0] + (sep if w[-1] is not None else ""),
            "color": w[1],
            "separator": False,
            "separator_block_width": 0,
        })

    out = json.dumps(out) + ","

    print(out, flush=True,  end="")

    # sleep(3)

