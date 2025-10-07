#!/usr/bin/env python3
## TODO
"""
switching workspace with a window causes it to lose focus
- on workspace switch, if one of the workspace's window ID is in a different workspace, then it has been moved and focus should be applied

after refocussing, the <super>+<tab> window switcher doesn't seem to know the window got refocussed

upload to github
"""


import gi
gi.require_version('Wnck', '3.0')
from gi.repository import Wnck, GLib

# Store most recently focused window per workspace by XID
mru_window_xids = {}

def describe_window(window):
    wtype = window.get_window_type()
    return {
        'name': window.get_name(),
        'class_group': window.get_class_group().get_name() if window.get_class_group() else "None",
        'type': str(wtype),
        'minimized': window.is_minimized(),
        'skip_tasklist': window.is_skip_tasklist(),
        'skip_pager': window.is_skip_pager(),
        'workspace': window.get_workspace().get_number() if window.get_workspace() else -1,
    }

def is_focusable(window, workspace):
    if not window.is_on_workspace(workspace):
        return False
    if window.is_skip_tasklist() or window.is_skip_pager() or window.is_minimized():
        return False
    wtype = window.get_window_type()
    return wtype not in (Wnck.WindowType.DESKTOP, Wnck.WindowType.DOCK)

def on_active_window_changed(screen, _):
    active = screen.get_active_window()
    if not active or not active.get_workspace():
        return

    ws_num = active.get_workspace().get_number()
    xid = active.get_xid()
    mru_window_xids[ws_num] = xid
    print(f"[Focus] Workspace {ws_num}: {active.get_name()} (XID: 0x{xid:x})")

def find_window_by_xid(screen, xid):
    for win in screen.get_windows():
        if win.get_xid() == xid:
            return win
    return None

def on_active_workspace_changed(screen, _):
    screen.force_update()
    active_workspace = screen.get_active_workspace()
    ws_num = active_workspace.get_number()
    print(f"\n[Workspace Switch] Now on workspace {ws_num}")

    xid = mru_window_xids.get(ws_num)
    win = find_window_by_xid(screen, xid) if xid else None

    if win and is_focusable(win, active_workspace):
        print(f"→ Focusing MRU window: {win.get_name()} (XID: 0x{xid:x})")
        win.activate(int(GLib.get_monotonic_time() / 1000))
    else:
        print("→ No valid/focusable MRU window. Skipping focus.")

def main():
    screen = Wnck.Screen.get_default()
    screen.force_update()

    screen.connect('active-window-changed', on_active_window_changed)
    screen.connect('active-workspace-changed', on_active_workspace_changed)

    print("Tracking MRU window per workspace (by XID)...")
    loop = GLib.MainLoop()
    loop.run()

if __name__ == "__main__":
    main()

