-- Hyprland Lua configuration.
-- The legacy hyprland.conf remains available as a rollback copy.

local terminal = "wezterm"
local fileManager = "thunar"
local browser = "librewolf"
local mainMod = "SUPER"
local mirrored = false
local work_hosts = {
    pennypacker = true,
}

local hostname_file = io.open("/etc/hostname", "r")
local hostname = hostname_file and hostname_file:read("*l") or ""
if hostname_file then
    hostname_file:close()
end

local monitor_mode = "1920x1200"
if hostname == "chunnel" then
    local monitors_path = (os.getenv("HOME") or "") .. "/.config/hypr/monitors.conf"
    local monitors_file = io.open(monitors_path, "r")
    if monitors_file then
        for line in monitors_file:lines() do
            local resolution = line:match("^%s*monitor%s*=%s*eDP%-1%s*,%s*([^,%s]+)")
            if resolution then
                monitor_mode = resolution
                break
            end
        end
        monitors_file:close()
    end
end

-- Catppuccin Mocha colors used by Hyprland. mocha.conf remains for hyprlock.
local pink = "rgb(f5c2e7)"
local blue = "rgb(89b4fa)"
local surface2border = "rgba(585b70aa)"

local function has_gpu_vendor(vendor_id)
    local pipe = io.popen(
        "for device in /sys/bus/pci/devices/*; do " ..
        "[ -r \"$device/vendor\" ] && [ -r \"$device/class\" ] || continue; " ..
        "read class < \"$device/class\"; case \"$class\" in 0x03*) ;; *) continue ;; esac; " ..
        "read id < \"$device/vendor\"; " ..
        "[ \"$id\" = \"" .. vendor_id .. "\" ] && printf yes && break; " ..
        "done",
        "r"
    )

    if not pipe then
        return false
    end

    local found = pipe:read("*a") == "yes"
    pipe:close()
    return found
end

local hybrid_graphics =
    has_gpu_vendor("0x8086") and has_gpu_vendor("0x10de")

hl.monitor({
    output = "eDP-1",
    mode = monitor_mode,
    position = "-1920x0",
    scale = 1.0,
})

local dp_monitor = {
    output = "DP-1",
    mode = "3840x2160",
    position = "0x0",
    scale = mirrored and 1.0 or 1.5,
}

if mirrored then
    dp_monitor.mirror = "eDP-1"
end

hl.monitor(dp_monitor)

hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

if hybrid_graphics then
    hl.env("LIBVA_DRIVER_NAME", "iHD")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("NVD_BACKEND", "direct")
    hl.env("GBM_BACKEND", "nvidia-drm")
    hl.env("__GL_MaxFramesAllowed", "1")
    hl.env("__GL_VRR_ALLOWED", "0")
    hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")
    hl.env("PROTON_ENABLE_NGX_UPDATER", "1")
    hl.env("VDPAU_DRIVER", "nvidia")
end

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in = 2,
        gaps_out = 2,
        border_size = 1,
        col = {
            active_border = { colors = { blue, pink }, angle = 45 },
            inactive_border = surface2border,
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 0,
        rounding_power = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo = false,
        disable_splash_rendering = true,
        enable_anr_dialog = false,
        anr_missed_pings = 30,
        middle_click_paste = false,
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        repeat_rate = 25,
        repeat_delay = 600,
        touchpad = {
            natural_scroll = false,
            middle_button_emulation = false,
            disable_while_typing = true,
        },
    },

    cursor = {
        inactive_timeout = 30,
        no_hardware_cursors = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

local function exec(command)
    return hl.dsp.exec_cmd(command)
end

hl.on("hyprland.start", function()
    hl.exec_cmd('hyprctl setcursor "Catppuccin Mocha Pink" 24')
    hl.exec_cmd("hypridle")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("vicinae server")
    hl.exec_cmd(terminal, { workspace = "1 silent" })
    hl.exec_cmd(browser, { workspace = "2 silent" })
    hl.exec_cmd("brave-origin", { workspace = "3 silent" })

    local communication_app = work_hosts[hostname]
        and "slack --ozone-platform=x11"
        or "discord"
    hl.exec_cmd(communication_app, { workspace = "9 silent" })

    local communication_class = work_hosts[hostname] and "slack" or "discord"
    hl.timer(function()
        for _, window in ipairs(hl.get_windows()) do
            if string.lower(window.initial_class or "") == communication_class then
                hl.dispatch(hl.dsp.window.move({ workspace = 9, window = window }))
                break
            end
        end
    end, { timeout = 5000, type = "oneshot" })
end)

hl.on("window.open", function(window)
    if window.initial_class == "brave-origin" then
        hl.dispatch(hl.dsp.window.move({ workspace = 3, window = window }))
    end
end)

hl.bind(mainMod .. " + Return", exec(terminal), { description = "Terminal" })
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Quit" })
hl.bind(mainMod .. " + E", exec(fileManager), { description = "File Manager" })
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle window floating" })
hl.bind(mainMod .. " + D", exec("discord"), { description = "Discord" })
hl.bind(mainMod .. " + R", exec("pkill waybar; waybar"), { description = "Reload Waybar" })
hl.bind(mainMod .. " + S", exec("slack --ozone-platform=x11"), { description = "Slack" })
hl.bind(mainMod .. " + ESCAPE", exec("wleave"), { description = "Power Menu" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Fullscreen" })
hl.bind(mainMod .. " + B", exec(browser), { description = "Browser" })
hl.bind(mainMod .. " + SHIFT + B", exec(browser .. " --private-window"), { description = "Private Browser" })
hl.bind(mainMod .. " + SPACE", exec("vicinae toggle"), { description = "Launcher" })
hl.bind("PRINT", exec("hyprshot -m window"), { description = "Screenshot (window)" })
hl.bind("SHIFT + PRINT", exec("hyprshot -m region"), { description = "Screenshot (region)" })
hl.bind(mainMod .. " + M", hl.dsp.window.move({ monitor = "+1" }), { description = "Move window to other monitor" })

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), { description = "Move focus left" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), { description = "Move focus right" })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { description = "Move focus up" })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { description = "Move focus down" })
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }), { description = "Swap window to the left" })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }), { description = "Swap window to the right" })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }), { description = "Swap window up" })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }), { description = "Swap window down" })
hl.bind("ALT + TAB", hl.dsp.window.cycle_next(), { description = "Cycle to next window" })
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ prev = true }), { description = "Cycle to prev window" })
hl.bind("ALT + TAB", hl.dsp.window.alter_zorder({ mode = "top" }))
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.alter_zorder({ mode = "top" }))
hl.bind(mainMod .. " + code:20", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { description = "Expand window left" })
hl.bind(mainMod .. " + code:21", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { description = "Shrink window left" })
hl.bind(mainMod .. " + SHIFT + code:20", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { description = "Shrink window up" })
hl.bind(mainMod .. " + SHIFT + code:21", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { description = "Expand window down" })

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Switch to workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Move window to workspace " .. i })
end

hl.bind("XF86AudioRaiseVolume", exec("pamixer -i 5"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", exec("pamixer -d 5"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", exec("pamixer --default-source -m"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", exec("pamixer -t"), { repeating = true, locked = true })
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", exec("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })
hl.bind("XF86MonBrightnessUp", exec("brightnessctl s 10%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", exec("brightnessctl s 10%-"), { repeating = true, locked = true })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
for i = 2, 6 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end
for i = 7, 9 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
end
hl.workspace_rule({ workspace = "10", monitor = "DP-1" })

hl.window_rule({
    name = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.layer_rule({
    name = "vicinae-blur",
    match = { namespace = "vicinae" },
    blur = true,
    ignore_alpha = 0,
})
hl.layer_rule({
    name = "vicinae-no-animation",
    match = { namespace = "vicinae" },
    no_anim = true,
})
