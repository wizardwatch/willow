from typing import List  # noqa: F401

from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Screen, Match
from libqtile.lazy import lazy
mod = "mod4"
terminal = "kitty"
primary = [mod]
secondary = [mod, "shift"]
tertiary = [mod, "control", "shift"]
keys = [
    Key(primary,	"n",		lazy.spawncmd(),),
    Key(primary,	"Tab",		lazy.layout.next(),),
    Key(primary,	"Return",	lazy.spawn(terminal),),
    # moves the focus
    Key(primary,	"s",		lazy.layout.down(),),
    Key(primary,	"w", 		lazy.layout.up(),),
    Key(primary,	"a", 		lazy.layout.left(),),
    Key(primary,    "d", 		lazy.layout.right(),),
    # moves the window
    Key(secondary,  "s",		lazy.layout.shuffle_down(),),
    Key(secondary,  "w",		lazy.layout.shuffle_up(),),
    Key(secondary,  "a",		lazy.layout.shuffle_left(),),
    Key(secondary,  "d",		lazy.layout.shuffle_right(),),
    Key(secondary,  "Tab", 		lazy.next_layout(),),
    Key(secondary,  "x", 		lazy.window.kill(),),
    Key(secondary,  "space",	lazy.window.toggle_floating(),),
    Key(tertiary,	"q", 		lazy.shutdown(),),
]
brootcmd = terminal + " -e fish -c 'br'"
confDir1 = "/home/wyatt/.config/"
confDir2 = "/etc/nixos/"
firefox = "firefox -p default"
discord = "firefox -p discord"
editor = terminal + " -e nvim "
confFiles = []
confFileNames = ["qtile/config.py", "broot/conf.hjson"]
for fileName in confFileNames:
    confFiles.append(editor + confDir1 + fileName)
nixProf = "machines/wizardwatch/"
confFileNames = ["flake.nix", nixProf + "main.nix", nixProf + "vim/neovim.nix"]
for fileName in confFileNames:
    confFiles.append(editor + confDir2 + fileName)
groups = [
    Group("Latex"),
    Group("ConfEdit", spawn=confFiles, layout="bsp"),
    Group("Web", spawn=[firefox], matches=Match(wm_class='firefox')),
    Group("Broot", matches=Match(title='broot'), spawn=[brootcmd])
]
layouts = [
    layout.Max(),
    # layout.Stack(num_stacks=2),
    # Try more layouts by unleashing below layouts.
    layout.Bsp(),

    # layout.Columns(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font='sans',
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()
topbar0 = bar.Bar(
    [
        widget.CurrentLayout(),
        widget.GroupBox(visible_groups=["ConfEdit", "Latex"]),
        widget.Prompt(),
        widget.WindowName(),
        # widget.Chord(
        #     chords_colors={
        #         'launch': ("#ff0000", "#ffffff"),
        #     },
        #     name_transform=lambda name: name.upper(),
        # ),
        # widget.TextBox("default config", name="default"),
        # widget.TextBox("Press &lt;M-r&gt; to spawn", foreground="#d75f5f"),
        widget.Systray(),
        widget.Clock(format='%Y-%m-%d %a %I:%M %p'),
        widget.QuickExit(),
    ],
    24,
)
topbar1 = bar.Bar(
    [
        widget.CurrentLayout(),
        widget.GroupBox(visible_groups=["Web"]),
        widget.Prompt(),
        widget.WindowName(),
        # widget.Chord(
        #     chords_colors={
        #         'launch': ("#ff0000", "#ffffff"),
        #     },
        #     name_transform=lambda name: name.upper(),
        # ),
        # widget.TextBox("default config", name="default"),
        # widget.TextBox("Press &lt;M-r&gt; to spawn", foreground="#d75f5f"),
        widget.Systray(),
        widget.Clock(format='%Y-%m-%d %a %I:%M %p'),
        widget.QuickExit(),
    ],
    24,
)

topbar2 = bar.Bar(
    [
        widget.CurrentLayout(),
        widget.GroupBox(visible_groups=["Broot", "Discord"]),
        widget.Prompt(),
        widget.WindowName(),
        # widget.Chord(
        #     chords_colors={
        #         'launch': ("#ff0000", "#ffffff"),
        #     },
        #     name_transform=lambda name: name.upper(),
        # ),
        # widget.TextBox("default config", name="default"),
        # widget.TextBox("Press &lt;M-r&gt; to spawn", foreground="#d75f5f"),
        widget.Systray(),
        widget.Clock(format='%Y-%m-%d %a %I:%M %p'),
        widget.QuickExit(),
    ],
    24,
)

screens = [
    # main display
    Screen(top=topbar0),
    Screen(top=topbar1),
    Screen(top=topbar2)
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    # Drag([mod], "Button3", lazy.window.set_size_floating(),
    #     start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]
# mouse = []
dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    {'wmclass': 'confirm'},
    {'wmclass': 'dialog'},
    {'wmclass': 'download'},
    {'wmclass': 'error'},
    {'wmclass': 'file_progress'},
    {'wmclass': 'notification'},
    {'wmclass': 'splash'},
    {'wmclass': 'toolbar'},
    {'wmclass': 'confirmreset'},  # gitk
    {'wmclass': 'makebranch'},  # gitk
    {'wmclass': 'maketag'},  # gitk
    {'wname': 'branchdialog'},  # gitk
    {'wname': 'pinentry'},  # GPG key password entry
    {'wmclass': 'ssh-askpass'},  # ssh-askpass
])
auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
