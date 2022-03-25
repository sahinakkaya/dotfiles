from libqtile.command.client import CommandClient
c = CommandClient()


groups = {}

for name, group in c.call('groups').items():
    if name == "scratchpad":
        continue
    occupied = len(group["windows"]) > 0
    focused = group['screen'] is not None
    groups[name] = {"occupied": occupied, "focused": focused}

output = '(box	:class "works"	:orientation "h" :spacing 5 :space-evenly "false" '
for name, prop in groups.items():
    command = f"scripts/qtile switch {name}"
    class_ = "0"
    focused, occupied = prop['focused'], prop['occupied']
    if focused:
        class_ += name * 2
    elif occupied:
        class_ += name

    if occupied:
        if name == "3":
            class_ += " thunderbird"
        elif name == "6":
            class_ += " twitter"
        elif name == "7":
            class_ += " firefox"
        elif name == "8":
            class_ += " twitch"
        elif name == "9":
            class_ += " discord"
        elif name == "0":
            class_ += " telegram"
    icons = {
        "1": "1",
        "2": "",
        "3": "",
        "4": "",
        "5": "",
        "6": "",
        "7": "",
        "8": "既",
        "9": "ﭮ",
        "0": "",
    }
    icon = icons[name]
    output += f'(button :onclick "{command}"	:class	"{class_}"	"{icon}") '

output += ')'
print(output)
