from fabric import Application, Fabricator


# lambda symbols
# f: is the fabricator itself, v: is the new value
counter_fabricator = Fabricator(
    interval=50,  # ms
    default_value=0,
    poll_from=lambda f: f.get_value() + 1,
    on_changed=lambda f, v: (
        (f.stop(), print("Counter Stopped"))
        if v == 43
        else print(f"Counter Value: {v}")
    ),
)

# example output:
# Counter Value: 1
# Counter Value: 2
# Counter Value: 3
# ...
# Counter Value: 42
# Counter Stopped

weather_fabricator = Fabricator(
    interval=1000 * 60,  # 1min
    poll_from="curl https://wttr.in/?format=Weather+in+%l:+%t+(Feels+Like+%f),+%C+%c",
    on_changed=lambda f, v: print(v.strip()),
)

# example output:
# Weather in Homenland:, +15°C (Feels Like +15°C), Clear ☀️
# ...

date_fabricator = Fabricator(
    interval=500,
    poll_from="date",
    on_changed=lambda f, v: print(f"Current Date: {v.strip()}"),
)

# example output:
# current date and time: Fri Nov 29 03:45:32 AM EET 2024
# current date and time: Fri Nov 29 03:45:32 AM EET 2024
# ...

# NOTE: this is just an example, the use of the Playerctl Python module would be a better idea
player_fabricator = Fabricator(
    stream=True,
    poll_from="playerctl --follow metadata --format '[{{status}}] {{title}} - {{artist}}'",
    on_changed=lambda f, v: print(v.strip()),
)

# example output:
# [Playing] Something - HomenArtsHouse
# [Paused] Something - HomenArtsHouse
# [Playing] The Stars - HomenArtsHouse
# ...


# NOTE: this is just an example, the use of something like os would be better
documents_fabricator = Fabricator(
    interval=1000,  # 1 second
    poll_from="du -sh /home/homan/Documents/",  # NOTE: edit this
    on_changed=lambda f, v: print(f"Size of Documents: {v.split()[0]}"),
)

# example output:
# Size of Documents: 1G
# Size of Documents: 1.1G
# ...


app = Application()
app.run()
